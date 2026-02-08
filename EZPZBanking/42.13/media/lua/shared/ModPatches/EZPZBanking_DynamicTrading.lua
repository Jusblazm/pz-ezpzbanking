-- EZPZBanking_DynamicTrading

--[[
    this patch allows Dynamic Trading to use EZPZ Banking's 
    bank system, but disables the use of physical money.

    This is a very hostile patch. It will very likely
    break in the future and need to be fixed.
]]

local function patchDynamicTradingWithEZPZBankingAccounts()
    if not getActivatedMods():contains("\\DynamicTrading") then
        print("[EZPZBanking] General: Dynamic Trading is not installed")
        return
    end

    require "DT_ServerCommands"
    local EZPZBanking_BankServer = require("EZPZBanking_BankServer")

    local Commands = DynamicTrading.ServerCommands

    local function ShouldSendNetworkPackets()
        -- Only send container update packets if we are the Authority (MP Server/Host).
        return isServer()
    end

    -- [CRITICAL FIX]
    -- Helper to handle the difference between SP and MP communication.
    -- In SP, sendServerCommand doesn't fire 'OnServerCommand' on the client side automatically.
    -- We must manually trigger the event to bridge the gap.
    local function SendResponse(player, command, args)
        if isServer() then
            -- MULTIPLAYER: Send packet over network
            sendServerCommand(player, "DynamicTrading", command, args)
        else
            -- SINGLEPLAYER: Simulate packet arrival immediately
            -- This triggers 'OnServerCommand' in DT_ClientCommands.lua
            triggerEvent("OnServerCommand", "DynamicTrading", command, args)
        end
    end

    -- Helper to remove a specific item instance and sync it
    local function ServerRemoveItem(item)
        if not item then return end
        local container = item:getContainer()
        if not container then return end
        
        -- Perform Action
        container:DoRemoveItem(item)
        
        -- Sync
        if ShouldSendNetworkPackets() then
            sendRemoveItemFromContainer(container, item)
        end
    end

    -- Helper to add items by type and sync them
    local function ServerAddItem(container, fullType, count)
        if not container or not fullType then return end
        local qty = count or 1
        
        -- AddItems returns an ArrayList of the created items
        local items = container:AddItems(fullType, qty)
        
        -- Sync
        if ShouldSendNetworkPackets() and items then
            for i=0, items:size()-1 do
                local item = items:get(i)
                sendAddItemToContainer(container, item)
            end
        end
    end

    function Commands.TradeTransaction(player, args)
        local type = args.type
        local traderID = args.traderID
        local key = args.key
        local category = args.category or "Misc"
        local clientQty = tonumber(args.qty) or 1 

        local data = DynamicTrading.Manager.GetData()
        local trader = data.Traders[traderID]
        local itemData = DynamicTrading.Config.MasterList[key]

        if not trader or not itemData then return end
        local inv = player:getInventory()

        -- Cache Display Name from Script for logging
        local scriptItem = getScriptManager():getItem(itemData.item)
        local safeDisplayName = scriptItem and scriptItem:getDisplayName() or "Unknown Item"

        if type == "buy" then
            -- 1. Calculate Price
            local unitPrice = DynamicTrading.Economy.GetBuyPrice(key, data.globalHeat)
            local totalCost = unitPrice * clientQty
            
            -- 2. Check Stock
            local currentStock = trader.stocks[key] or 0
            if currentStock < clientQty then
                SendResponse(player, "TransactionResult", { success=false, msg="Sold Out!" })
                return
            end

            -- 3. Check Wealth
            local accountID = EZPZBanking_BankServer.getAccountID(player)
            if EZPZBanking_BankServer.getBalanceByID(accountID) < totalCost then
                SendResponse(player, "TransactionResult", { success=false, msg="Not enough cash!" })
                return
            end

            -- 4. Execute Trade
            if EZPZBanking_BankServer.withdraw(accountID, totalCost) then
                DynamicTrading.Manager.OnBuyItem(traderID, key, category, clientQty)
                ServerAddItem(inv, itemData.item, clientQty)
                
                -- [NEW] Log transaction for global history
                local logText = string.format("Trade: %s purchased %s for $%d", player:getUsername(), safeDisplayName, totalCost)
                DynamicTrading.NetworkLogs.AddLog(logText, "info")

                SendResponse(player, "TransactionResult", { 
                    success = true, 
                    itemName = safeDisplayName,
                    price = totalCost
                })
            else
                SendResponse(player, "TransactionResult", { success=false, msg="Transaction Error" })
            end

        elseif type == "sell" then
            -- 1. Locate specific physical item by ID
            -- [ROBUST FIX] We now find the item by the unique ID passed from the client
            local itemObj = inv:getItemById(args.itemID)
            
            -- [B42 ROBUST] If direct main-inv lookup fails, do a recursive search across ALL carried containers
            if not itemObj then
                local function findItemRecursive(container)
                    local items = container:getItems()
                    for i = 0, items:size() - 1 do
                        local it = items:get(i)
                        if it:getID() == args.itemID then
                            return it
                        end
                        if instanceof(it, "InventoryContainer") then
                            local sub = it:getItemContainer()
                            if sub then
                                local found = findItemRecursive(sub)
                                if found then return found end
                            end
                        end
                    end
                    return nil
                end
                itemObj = findItemRecursive(inv)
            end
            
            if not itemObj then
                -- Fallback: If ID search fails, try traditional search by type (rare but safe)
                local allItemsList = inv:getItemsFromType(itemData.item, true)
                if allItemsList and allItemsList:size() > 0 then
                    itemObj = allItemsList:get(0)
                end
            end
            
            if not itemObj then
                SendResponse(player, "TransactionResult", { success=false, msg="Item missing!" })
                return
            end

            -- [NEW SAFETY LOCK] Double check it's not the active radio
            -- If the physical radio is turned on, the server blocks the sale as a safeguard.
            if itemObj.getDeviceData then
                local dev = itemObj:getDeviceData()
                if dev and dev:getIsTurnedOn() then
                    SendResponse(player, "TransactionResult", { success=false, msg="Cannot sell an active radio!" })
                    return
                end
            end

            -- [NEW] Check Trader Budget
            local localCount = (trader.localDeflation and trader.localDeflation[key]) or 0
            local unitPrice = DynamicTrading.Economy.GetSellPrice(itemObj, key, trader.archetype, data.globalHeat, localCount)
            local totalGain = unitPrice * clientQty

            if (trader.budget or 0) < totalGain then
                SendResponse(player, "TransactionResult", { success=false, msg="Trader cannot afford this!" })
                return
            end

            local itemNameForLog = itemObj:getDisplayName()

            -- [FIX] Ensure item is unequipped before removal to prevent duplication (Ghost Item Glitch)
            if player:getPrimaryHandItem() == itemObj then
                player:setPrimaryHandItem(nil)
            end
            if player:getSecondaryHandItem() == itemObj then
                player:setSecondaryHandItem(nil)
            end

            -- 2. Execute Trade
            ServerRemoveItem(itemObj)
            local accountID = EZPZBanking_BankServer.getAccountID(player)
            EZPZBanking_BankServer.deposit(accountID, totalGain)
            
            DynamicTrading.Manager.OnSellItem(traderID, key, category, clientQty)
            
            -- [NEW] Log transaction for global history
            local logText = string.format("Trade: %s sold %s for $%d", player:getUsername(), itemNameForLog, totalGain)
            DynamicTrading.NetworkLogs.AddLog(logText, "info")

            -- Send exact keys client expects for Audit Log
            SendResponse(player, "TransactionResult", { 
                success = true, 
                itemName = itemNameForLog,
                price = totalGain
            })
        end
    end

    function Commands.RequestTrader(player, args)
        local archetype = args.archetype
        local price = args.price or 0
        local targetUser = player:getUsername()

        -- 1. Validate Money
        local accountID = EZPZBanking_BankServer.getAccountID(player)
        if EZPZBanking_BankServer.getBalanceByID(accountID) < price then
            SendResponse(player, "RequestResult", { success=false, msg="Insufficient Funds" })
            return
        end

        -- 2. Validate Cap (Double Check Server Side)
        local found, limit = DynamicTrading.Manager.GetDailyStatus()
        if found >= limit then
            SendResponse(player, "RequestResult", { success=false, msg="Network Busy (Cap Reached)" })
            return
        end

        -- 3. Deduct Money
        if not EZPZBanking_BankServer.withdraw(accountID, price) then
            SendResponse(player, "RequestResult", { success=false, msg="Transaction Error" })
            return
        end

        -- 4. Generate Trader
        local trader = DynamicTrading.Manager.GenerateRandomContact(player, archetype)
        
        if trader then
            -- [NEW] Auto-discover for requesting player
            DynamicTrading.Manager.DiscoverTrader(trader.id, player)
            
            DynamicTrading.NetworkLogs.AddLog("Favor: " .. targetUser .. " requested a " .. archetype, "info")
            SendResponse(player, "RequestResult", { success=true, name=trader.name })
        else
            EZPZBanking_BankServer.deposit(accountID, price)
            -- ServerAddItem(player:getInventory(), "Base.Money", price) -- Refund
            SendResponse(player, "RequestResult", { success=false, msg="Contact unavailable" })
        end
    end

    function Commands.BurnMoney(player, args)
        local amount = args.amount
        local accountID = EZPZBanking_BankServer.getAccountID(player)
        if amount and amount > 0 then
            EZPZBanking_BankServer.withdraw(accountID, amount)
            DynamicTrading.NetworkLogs.AddLog("Scam: " .. player:getUsername() .. " lost $" .. amount, "bad")
        end

    end

    function DynamicTradingUI:getPlayerWealth(player)
        if not player then return 0 end

        local accountID = EZPZBanking_BankServer.getAccountID(player)
        local balance = EZPZBanking_BankServer.getBalanceByID(accountID)
        return balance
    end

    print("[EZPZBanking] General: Dynamic Trading detected, allowing Dynamic Trading to use EZPZ Banking's bank accounts")
end

Events.OnGameStart.Add(patchDynamicTradingWithEZPZBankingAccounts)