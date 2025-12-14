-- EZPZBanking_PayAtThePump
local EZPZBanking_BankServer = require("EZPZBanking_BankServer")

-- allows Rick's Pay & Pump to pay using Mail Order Catalog's bank accounts
local function useBankAccountsInsteadOfPayAtThePumpCards()
    if not getActivatedMods():contains("\\RicksMLC_PayAtThePump") then
        print("[EZPZBanking] General: Rick's Pay & Pump is not installed")
        return
    end
    print("[EZPZBanking] General: Rick's Pay & Pump is installed, allowing it to access bank accounts")

    local original_RicksMLC_PayAtPumpAPI_reduceCreditBalances = RicksMLC_PayAtPumpAPI.reduceCreditBalances

    function RicksMLC_PayAtPumpAPI.reduceCreditBalances(amount)
        if not SandboxVars.RicksMLC_PayAtThePump.AllowCreditCards then return amount end

        local player = getPlayer()
        if not player then return amount end

        local itemContainer = player:getInventory()
        local itemList = itemContainer:getAllEval(RicksMLC_PayAtThePump.findValidCreditCardClosure)

        if SandboxVars.RicksMLC_PayAtThePump.AutoSearchForMoney and itemList:isEmpty() then
            itemList = itemContainer:getAllEvalRecurse(RicksMLC_PayAtThePump.findValidCreditCardClosure)
        end

        if not itemList:isEmpty() then
            for i=0, itemList:size()-1 do
                local card = itemList:get(i)
                modData = card:getModData()
                local balance = EZPZBanking_BankServer.getBalance(modData)

                if balance > 0 then
                    if balance >= amount then
                        EZPZBanking_BankServer.setBalance(modData, balance - amount)
                        return 0
                    else
                        EZPZBanking_BankServer.setBalance(modData, 0)
                        amount = amount - balance
                    end
                end
            end
        end
        return amount
    end

    local original_RicksMLC_PayAtThePump_changeCreditBalance = RicksMLC_PayAtThePump.changeCreditBalance

    function RicksMLC_PayAtThePump.changeCreditBalance(creditCard, amount)
        local modData = creditCard:getModData()["RicksMLC_CreditCardz"]
        local remainAmount = 0

        if not modData then
            modData = {Balance = 0}
            creditCard:getModData()["RicksMLC_CreditCardz"] = modData
        end

        modData.Balance = modData.Balance + amount
        if modData.Balance < 0 then
            remainAmount = math.abs(modData.Balance)
            modData.Balance = 0 
        end
        creditCard:getModData()["RicksMLC_CreditCardz"].Balance = modData.Balance

        --[[
            remove card name change for two reasons
            1. messes up Mail Order Catalog bank accounts (could fix, but for this quick patch it's too much)
            2. easy way to figure out if a card is worth hacking or not
        ]]

        -- local creditCardName = creditCard:getDisplayName()
        -- creditCardName = addOrReplaceAfterLastColon(creditCardName, "Balance $" .. string.format("%.2f", creditCard:getModData()["RicksMLC_CreditCardz"].Balance))
        -- creditCard:setName(creditCardName)
        -- creditCard:setCustomName(true)

        return remainAmount
    end
end

Events.OnGameStart.Add(useBankAccountsInsteadOfPayAtThePumpCards)