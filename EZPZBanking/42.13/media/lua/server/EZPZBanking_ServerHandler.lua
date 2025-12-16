-- EZPZBanking_ServerHandler
local EZPZBanking_BankServer = require("EZPZBanking_BankServer")

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

        local item = inv:AddItem("Base.CreditCard")
        if item then
            local owner = nil
            local desc = player:getDescriptor()
            if desc then
                owner = desc:getForename() .. " " .. desc:getSurname()
                item:setName("Credit Card: " .. owner)
            end
            local modData = item:getModData()
            modData.owner = owner
            modData.accountID = player:getSteamID() .. "_" .. owner
            modData.last4 = tostring(ZombRand(1000, 9999))
            modData.pin = "11"
            modData.isStolen = false
            modData.attempts = 0
            modData.websiteURL = "knoxbank.com/account"

            EZPZBanking_BankServer.getOrCreateAccount(player)

            player:sendObjectChange("addItem", { item = item })
        end
        playerData.hasCreditCard = true
    end
end)


Events.OnClientCommand.Add(function(module, command, player, args)
    if module ~= "EZPZBanking" or not args then return end

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
                    container:Remove(bundle)
                    deposited = deposited + 100
                    remaining = remaining - 100
                else
                    container:Remove(bundle)
                    deposited = deposited + remaining
                    local leftover = 100 - remaining
                    for j=1, leftover do
                        container:AddItem("Base.Money")
                    end
                    remaining = 0
                end
            end
        end

        for _, entry in ipairs(moneySingles) do
            if remaining <= 0 then break end
            local single, container = entry.item, entry.container
            if single then
                container:Remove(single)
                deposited = deposited + 1
                remaining = remaining - 1
            end
        end

        if deposited > 0 then
            EZPZBanking_BankServer.deposit(accountID, deposited)
        end
    elseif command == "WithdrawMoney" then
        if account.balance < amount then return end

        local remaining = amount
        while remaining >= 100 do
            player:getInventory():AddItem("Base.MoneyBundle")
            remaining = remaining - 100
        end
        while remaining > 0 do
            player:getInventory():AddItem("Base.Money")
            remaining = remaining - 1
        end
        EZPZBanking_BankServer.withdraw(accountID, amount)
    end
end)

Events.OnClientCommand.Add(function(module, command, player, args)
    if module == "EZPZBanking" and command == "OrderCreditCard" then
        if not player or player:isDead() then return end
        local inv = player:getInventory()
        local item = inv:AddItem("Base.CreditCard")
        
        local owner = nil
        local desc = player:getDescriptor()
        if desc then
            owner = desc:getForename() .. " " .. desc:getSurname()
            item:setName("Credit Card: " .. owner)
        end
        local modData = item:getModData()
        modData.owner = owner
        modData.accountID = player:getSteamID() .. "_" .. owner
        modData.last4 = tostring(ZombRand(1000, 9999))
        modData.pin = "11"
        modData.isStolen = false
        modData.attempts = 0
        modData.websiteURL = "knoxbank.com/account"

        EZPZBanking_BankServer.getOrCreateAccount(player)
        -- self:setCard(item)
        -- self:loadWebsite("knoxbank.com")
    end
end)