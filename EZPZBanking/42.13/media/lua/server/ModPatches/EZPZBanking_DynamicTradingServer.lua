-- EZPZBanking_DynamicTradingServer

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

    require "DT/V1/DT_ServerCommands"
    require "DT/Common/ServerHelpers"
    local EZPZBanking_BankServer = require("EZPZBanking_BankServer")

    local Commands = DynamicTrading.ServerCommands
    local Helpers = DynamicTrading.ServerHelpers
    local ServerRemoveItem = Helpers.RemoveItem
    local ServerAddItem = Helpers.AddItem

    -- Local wrapper for SendResponse to maintain existing call signature
    local function SendResponse(player, command, args)
        Helpers.SendResponse(player, "DynamicTrading", command, args)
    end

    function Commands.TradeTransaction(player, args)
        local transactionType = args.type
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

        if transactionType == "buy" then
            -- 1. Check Stock & Data
            local stockEntry = trader.stocks[key]
            local currentStock = 0
            local customData = nil
            
            if type(stockEntry) == "table" then
                currentStock = tonumber(stockEntry.qty) or 0
                customData = stockEntry.customData
            else
                currentStock = tonumber(stockEntry) or 0
            end

            -- 2. Calculate Price
            -- local unitPrice = DynamicTrading.Economy.GetBuyPrice(key, data.globalHeat)
            local unitPrice = DynamicTrading.Economy.V1.GetBuyPrice(key, data.globalHeat, customData)
            local totalCost = unitPrice * clientQty
            
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
            local accountID = EZPZBanking_BankServer.getAccountID(player)
            if EZPZBanking_BankServer.withdraw(accountID, totalCost) then
            -- if EZPZBanking_BankServer.getBalanceByID(accountID) > totalCost then
                -- sendClientCommand("EZPZBanking", "DoWithdrawWithoutMoney", { 
                --     accountID = accountID,
                --     amount = totalCost
                -- })
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

        elseif transactionType == "sell" then
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
            -- local unitPrice = DynamicTrading.Economy.GetSellPrice(itemObj, key, trader.archetype, data.globalHeat, localCount)
            local unitPrice = DynamicTrading.Economy.V1.GetSellPrice(itemObj, key, trader.archetype, data.globalHeat, localCount)
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
            -- sendClientCommand("EZPZBanking", "DoDepositWithoutMoney", { 
            --     accountID = accountID,
            --     amount = totalGain
            -- })
            
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
        -- if EZPZBanking_BankServer.getBalanceByID(accountID) < price then
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
            -- sendClientCommand("EZPZBanking", "DoDepositWithoutMoney", { 
            --     accountID = accountID,
            --     amount = price
            -- })
            SendResponse(player, "RequestResult", { success=false, msg="Contact unavailable" })
        end
    end

    function Commands.BurnMoney(player, args)
        local amount = args.amount
        local accountID = EZPZBanking_BankServer.getAccountID(player)
        if amount and amount > 0 then
            EZPZBanking_BankServer.withdraw(accountID, amount)
            -- sendClientCommand("EZPZBanking", "DoWithdrawWithoutMoney", { 
            --     accountID = accountID,
            --     amount = amount
            -- })
            DynamicTrading.NetworkLogs.AddLog("Scam: " .. player:getUsername() .. " lost $" .. amount, "bad")
        end
    end

    print("[EZPZBanking] General: Dynamic Trading detected, allowing Dynamic Trading to use EZPZ Banking's bank accounts")
end

Events.OnGameStart.Add(patchDynamicTradingWithEZPZBankingAccounts)
Events.OnServerStarted.Add(patchDynamicTradingWithEZPZBankingAccounts)