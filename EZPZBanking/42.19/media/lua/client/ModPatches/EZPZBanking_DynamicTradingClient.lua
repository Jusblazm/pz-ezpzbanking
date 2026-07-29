-- -- EZPZBanking_DynamicTradingClient

-- --[[
--     this patch allows Dynamic Trading to 
--     use EZPZ Banking's bank system in its UI.
-- ]]

-- local function patchDynamicTradingUIWithEZPZBankingAccounts()
--     if not getActivatedMods():contains("\\DynamicTrading") then
--         print("[EZPZBanking] General: Dynamic Trading is not installed")
--         return
--     end

--     local EZPZBanking_BankServer = require("EZPZBanking_BankServer")

--     function DT_TradingWindow:getPlayerWealth(player)
--         if not player then return 0 end

--         local accountID = EZPZBanking_BankServer.getAccountID(player)
--         local balance = EZPZBanking_BankServer.getBalanceByID(accountID)
--         return balance
--     end

--     print("[EZPZBanking] General: Dynamic Trading detected, allowing Dynamic Trading to read EZPZ Banking's bank accounts")
-- end

-- Events.OnGameStart.Add(patchDynamicTradingUIWithEZPZBankingAccounts)