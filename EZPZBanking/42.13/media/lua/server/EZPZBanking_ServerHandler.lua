-- EZPZBanking_ServerHandler
local EZPZBanking_BankServer = require("EZPZBanking_BankServer")
local EZPZBanking_Utils = require("EZPZBanking_Utils")

Events.OnClientCommand.Add(function(module, command, player, args)
    if module == "EZPZBanking" and command == "GiveCreditCardOnStart" then
        if not player or player:isDead() then return end

        local playerData = player:getModData()
        if playerData.hasCreditCard then return end

        local inv = player:getInventory()

        for i=0, inv:getItems():size()-1 do
            local item = inv:getItems():get(i)
            if item:getType() == "CreditCard" then
                playerData.hasCreditCard = true
                return
            end
        end

        EZPZBanking_Utils.CreateCreditCard(player)
        playerData.hasCreditCard = true
    end
end)

Events.OnClientCommand.Add(function(module, command, player, args)
    if module == "EZPZBanking" and command == "OrderCreditCard" then
        if not player or player:isDead() then return end
        EZPZBanking_Utils.CreateCreditCard(player)
    end
end)

Events.OnClientCommand.Add(function(module, command, player, args)
    if module == "EZPZBanking" and command == "GetOrCreateAccount" then
        if not player or not args.itemID then return end

        local inv = player:getInventory()
        local card = nil

        for i=0, inv:getItems():size()-1 do
            local item = inv:getItems():get(i)
            if item:getID() == args.itemID then
                card = item
                print("found card on server side")
                break
            end
        end

        EZPZBanking_Utils.ensureCardHasData(card)
        
        local modData = card:getModData()
        local account = EZPZBanking_BankServer.getOrCreateAccountByID(modData)
        print("I ran getOrCreateAccountByID")
        syncItemModData(player, card)
    end
end)

Events.OnClientCommand.Add(function(module, command, player, args)
    if module == "EZPZBanking" and command == "SetPIN" then
        if not args or not args.itemID or not args.pin then return end

        local inv = player:getInventory()
        local card = nil

        for i=0, inv:getItems():size()-1 do
            local item = inv:getItems():get(i)
            if item:getID() == args.itemID then
                card = item
                print("found card on server side")
                break
            end
        end

        local modData = card:getModData()

        EZPZBanking_BankServer.setPIN(modData, args.pin)
        card:getModData().pin = args.pin
        syncItemModData(player, card)
    end
end)

Events.OnClientCommand.Add(function(module, command, player, args)
    if module ~= "EZPZBanking" or not args then return end

    if command == "RequestAccountData" then
        local account = EZPZBanking_BankServer.getAccountByID(args.accountID)
        if not account then return end

        sendServerCommand(player, "EZPZBanking", "AccountDetails", {
            accountID = account.accountID,
            balance = account.balance,
            owner = account.owner,
            pin = account.pin
        })
        return
    end

    local accountID = args.accountID
    local amount = args.amount
    if not accountID or not amount or amount <= 0 then return end

    local account = EZPZBanking_BankServer.getAccountByID(accountID)
    if not account then return end

    if command == "DepositMoney" then
        local function collectItemsOfType(container, typeName, results)
            if not container then return end
            local items = container:getItems()
            for i=0, items:size()-1 do
                local item = items:get(i)
                if item:getType() == typeName then
                    table.insert(results, { item = item, container = container })
                end
                if item:IsInventoryContainer() then
                    collectItemsOfType(item:getInventory(), typeName, results)
                end
            end
        end
    
        local moneySingles = {}
        local moneyBundles = {}
    
        collectItemsOfType(player:getInventory(), "Money", moneySingles)
        collectItemsOfType(player:getInventory(), "MoneyBundle", moneyBundles)
    
        local worn = player:getWornItems()
        if worn then
            for i=0, worn:size()-1 do
                local wornItem = worn:get(i):getItem()
                if wornItem and wornItem:IsInventoryContainer() then
                    collectItemsOfType(wornItem:getInventory(), "Money", moneySingles)
                    collectItemsOfType(wornItem:getInventory(), "MoneyBundle", moneyBundles)
                end
            end
        end
    
        local primary = player:getPrimaryHandItem()
        if primary and primary:IsInventoryContainer() then
            collectItemsOfType(primary:getInventory(), "Money", moneySingles)
            collectItemsOfType(primary:getInventory(), "MoneyBundle", moneyBundles)
        end
    
        local secondary = player:getSecondaryHandItem()
        if secondary and secondary:IsInventoryContainer() then
            collectItemsOfType(secondary:getInventory(), "Money", moneySingles)
            collectItemsOfType(secondary:getInventory(), "MoneyBundle", moneyBundles)
        end

        local totalAvailable = #moneySingles + (#moneyBundles * 100)
        if totalAvailable < 1 then return end

        local remaining = amount
        local deposited = 0

        for _, entry in ipairs(moneyBundles) do
            if remaining <= 0 then break end
            local bundle, container = entry.item, entry.container
            if bundle then
                if remaining >= 100 then
                    deposited = deposited + 100
                    remaining = remaining - 100
                    container:Remove(bundle)
                    sendRemoveItemFromContainer(container, bundle)
                else
                    container:Remove(bundle)
                    sendRemoveItemFromContainer(container, bundle)
                    deposited = deposited + remaining
                    local leftover = 100 - remaining
                    for j=1, leftover do
                        container:AddItem("Base.Money")
                        sendAddItemToContainer(container, "Base.Money")
                    end
                    remaining = 0
                end
            end
        end

        for _, entry in ipairs(moneySingles) do
            if remaining <= 0 then break end
            local single, container = entry.item, entry.container
            if single then
                deposited = deposited + 1
                remaining = remaining - 1
                container:Remove(single)
                sendRemoveItemFromContainer(container, single)
            end
        end

        if deposited > 0 then
            EZPZBanking_BankServer.deposit(accountID, deposited)
            local updatedAccount = EZPZBanking_BankServer.getAccountByID(accountID)
            sendServerCommand(player, "EZPZBanking", "AccountUpdated", {
                accountID = accountID,
                balance = updatedAccount.balance
            })
        end
    elseif command == "WithdrawMoney" then
        if account.balance < amount then return end

        local inv = player:getInventory()
        local remaining = amount

        while remaining >= 100 do
            local bundle = instanceItem("Base.MoneyBundle")
            inv:AddItem(bundle)
            sendAddItemToContainer(inv, bundle)
            remaining = remaining - 100
        end
        while remaining > 0 do
            local single = instanceItem("Base.Money")
            inv:AddItem(single)
            sendAddItemToContainer(inv, single)
            remaining = remaining - 1
        end
        EZPZBanking_BankServer.withdraw(accountID, amount)
        local updatedAccount = EZPZBanking_BankServer.getAccountByID(accountID)
        sendServerCommand(player, "EZPZBanking", "AccountUpdated", {
            accountID = accountID,
            balance = updatedAccount.balance
        })
    end
end)