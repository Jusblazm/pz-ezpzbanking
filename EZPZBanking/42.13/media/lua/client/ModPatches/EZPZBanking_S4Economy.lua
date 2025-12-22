-- -- EZPZBanking_S4Economy
-- local EZPZBanking_BankServer = require("EZPZBanking_BankServer")
-- require("EZPZBanking_Hooks")

-- --[[
--     this patch ensures S4_Economy and EZPZBanking share the same bank account
-- ]]

-- -- stops infinite sync loop
-- local syncingFromS4Economy = false

-- local function setupS4EconomyHooks()
--     if not getActivatedMods():contains("\\S4_Economy") then
--         print("[EZPZBanking] General: S4 Economy is not installed")
--         return
--     end
--     print("[EZPZBanking] General: S4 Economy detected, enabling hooks")

--     EZPZBanking_Hooks.wrapFunction(EZPZBanking_BankServer, "deposit")
--     EZPZBanking_Hooks.wrapFunction(EZPZBanking_BankServer, "withdraw")
--     EZPZBanking_Hooks.wrapFunction(EZPZBanking_BankServer, "setBalance")

--     EZPZBanking_Hooks.add("deposit", function(result, accountID, amount)
--         local success = result[1]
--         if not syncingFromS4Economy and success and amount and amount > 0 then
--             local cardModData = ModData.get("S4_CardData")
--             if cardModData then
--                 local account = EZPZBanking_BankServer.getAccountByID(accountID)
--                 local owner = account and account.owner
--                 if owner then
--                     local normalizedOwner = owner:lower():gsub("%s+", "")
--                     for cardNum, cardInfo in pairs(cardModData) do
--                         if cardInfo.Master then
--                             local normalizedMaster = cardInfo.Master:lower():gsub("%s+", "")
--                             if normalizedMaster == normalizedOwner then
--                                 cardInfo.Money = (cardInfo.Money or 0) + amount
--                                 ModData.transmit("S4_CardData")
--                                 print("[EZPZBanking] General: Synced deposit to S4Economy. Balance: " .. tostring(cardInfo.Money))
--                                 break
--                             end
--                         end
--                     end
--                 end
--             else
--                 print("[EZPZBanking] Warning: Could not access S4_CardData global ModData")
--             end
--         end
--     end)

--     EZPZBanking_Hooks.add("withdraw", function(result, accountID, amount)
--         local success = result[1]
--         if not syncingFromS4Economy and success and amount and amount > 0 then
--             local cardModData = ModData.get("S4_CardData")
--             if cardModData then
--                 local account = EZPZBanking_BankServer.getAccountByID(accountID)
--                 local owner = account and account.owner
--                 if owner then
--                     local normalizedOwner = owner:lower():gsub("%s+", "")
--                     for cardNum, cardInfo in pairs(cardModData) do
--                         if cardInfo.Master then
--                             local normalizedMaster = cardInfo.Master:lower():gsub("%s+", "")
--                             if normalizedMaster == normalizedOwner then
--                                 cardInfo.Money = (cardInfo.Money or 0) - amount
--                                 ModData.transmit("S4_CardData")
--                                 print("[EZPZBanking] General: Synced withdraw to S4Economy. Balance: " .. tostring(cardInfo.Money))
--                                 break
--                             end
--                         end
--                     end
--                 end
--             else
--                 print("[EZPZBanking] Warning: Could not access S4_CardData global ModData")
--             end
--         end
--     end)

--     EZPZBanking_Hooks.add("setBalance", function(result, card, newBalance)
--         local success = result[1]
--         if not syncingFromS4Economy and success then
--             local cardModData = ModData.get("S4_CardData")
--             if cardModData then
--                 local account = EZPZBanking_BankServer.getOrCreateAccountByID(card)
--                 local owner = account and account.owner
--                 if owner then
--                     local normalizedOwner = owner:lower():gsub("%s+", "")
--                     for cardNum, cardInfo in pairs(cardModData) do
--                         if cardInfo.Master then
--                             local normalizedMaster = cardInfo.Master:lower():gsub("%s+", "")
--                             if normalizedMaster == normalizedOwner then
--                                 cardInfo.Money = newBalance
--                                 ModData.transmit("S4_CardData")
--                                 print("[EZPZBanking] General: Synced balance to S4Economy. Balance: " .. tostring(cardInfo.Money))
--                                 break
--                             end
--                         end
--                     end
--                 end
--             else
--                 print("[EZPZBanking] Warning: Could not access S4_CardData global ModData")
--             end
--         end
--     end)

--     local original_InsertCard = S4_ATM_Info.InsertCard
--     local original_ReturnCard = S4_ATM_Info.ReturnCard
--     local original_ActionDeposit = S4_ATM_Deposit.ActionDeposit
--     local original_ActionWithdraw = S4_ATM_Withdraw.ActionWithdraw
--     local original_PasswordAction = S4_ATM_Password.PasswordAction

--     local function saveCustomCardData(item, AtmModData)
--         if item and AtmModData then
--             local modData = item:getModData()
--             if modData then
--                 AtmModData.CustomCardData = {
--                     accountID = modData.accountID,
--                     balance = modData.balance,
--                     pin = modData.pin,
--                     owner = modData.owner,
--                     last4 = modData.last4,
--                     attempts = modData.attempts,
--                     isStolen = modData.isStolen,
--                     websiteURL = modData.websiteURL
--                 }
--             end
--         end
--     end

--     local function restoreCustomCardData(newCard, AtmModData)
--         if newCard and AtmModData and AtmModData.CustomCardData then
--             local modData = newCard:getModData()
--             local savedData = AtmModData.CustomCardData
--             modData.accountID = savedData.accountID
--             modData.balance = savedData.balance
--             modData.pin = savedData.pin
--             modData.owner = savedData.owner
--             modData.last4 = savedData.last4
--             modData.attempts = savedData.attempts
--             modData.isStolen = savedData.isStolen
--             modData.websiteURL = savedData.websiteURL

--             AtmModData.CustomCardData = nil
--             S4_Utils.SnycObject(newCard)
--         end
--     end

--     function S4_ATM_Info:InsertCard(item)
--         local AtmModData = self.AtmUI.Obj:getModData()
--         if item and AtmModData then
--             saveCustomCardData(item, AtmModData)
--         end
--         original_InsertCard(self, item)

--         local returnedCardNum = AtmModData and AtmModData.S4CardNumber
--         if returnedCardNum and returnedCardNum ~= "Null" then
--             for i=0, self.player:getInventory():getItems():size()-1 do
--                 local invItem = self.player:getInventory():getItems():get(i)
--                 local modData = invItem:getModData()
--                 if modData and modData.S4CardNumber == returnedCardNum then
--                     restoreCustomCardData(invItem, AtmModData)
--                     break
--                 end
--             end
--         end
--     end

--     function S4_ATM_Info:ReturnCard(CardNum)
--         original_ReturnCard(self, CardNum)

--         local AtmModData = self.AtmUI.Obj:getModData()
--         if AtmModData and AtmModData.CustomCardData then
--             for i=0, self.player:getInventory():getItems():size()-1 do
--                 local invItem = self.player:getInventory():getItems():get(i)
--                 local modData = invItem:getModData()
--                 if modData and modData.S4CardNumber == CardNum then
--                     restoreCustomCardData(invItem, AtmModData)
--                     break
--                 end
--             end
--         end
--     end

--     function S4_ATM_Deposit:ActionDeposit()
--         local depositAmount = self.CashValue
--         original_ActionDeposit(self)

--         if depositAmount and depositAmount > 0 then
--             local AtmModData = self.AtmUI.Obj:getModData()
--             if AtmModData and AtmModData.CustomCardData then
--                 local currentBalance = AtmModData.CustomCardData.balance or 0
--                 local newBalance = currentBalance + depositAmount
--                 AtmModData.CustomCardData.balance = newBalance

--                 syncingFromS4Economy = true
--                 EZPZBanking_BankServer.setBalance(AtmModData.CustomCardData, newBalance)
--                 syncingFromS4Economy = false

--                 print("[EZPZBanking] General: Synced deposit via setBalance. Balance: " .. tostring(newBalance))
--             else
--                 print("[EZPZBanking] Warning: No CustomCardData found in AtmModData (deposit)")
--             end
--         end
--     end

--     function S4_ATM_Withdraw:ActionWithdraw()
--         local withdrawn = 0
--         local AtmModData = self.AtmUI.Obj:getModData()
--         local Text = self.MoneyEntry:getText()
--         if Text == "" then Text = "0" end
--         local filteredText = Text:gsub("[^%d]", "")
--         if filteredText == "" then filteredText = "0" end
--         filteredText = filteredText:gsub("^0+", "")
--         if filteredText == "" then filteredText = "0" end
--         local Value = tonumber(filteredText) or 0
--         if Value > 0 then
--             withdrawn = Value
--         end
--         original_ActionWithdraw(self)

--         if withdrawn > 0 and AtmModData and AtmModData.CustomCardData then
--             local currentBalance = AtmModData.CustomCardData.balance or 0
--             print("current balance is " .. tostring(currentBalance))
--             local newBalance = currentBalance - withdrawn
--             print("new balance is " .. tostring(newBalance))
--             if newBalance < 0 then newBalance = 0 end
--             AtmModData.CustomCardData.balance = newBalance

--             syncingFromS4Economy = true
--             EZPZBanking_BankServer.setBalance(AtmModData.CustomCardData, newBalance)
--             print("set balance on account " .. tostring(AtmModData.CustomCardData.accountID) .. " to " .. tostring(newBalance))
--             syncingFromS4Economy = false

--             print("[EZPZBanking] General: Synced withdraw via setBalance. Balance: " .. tostring(newBalance))
--         else
--             print("[EZPZBanking] Warning: No CustomCardData found in AtmModData (withdraw)")
--         end
--     end

--     function S4_ATM_Password:PasswordAction()
--         original_PasswordAction(self)

--         if self.AtmUI and self.FirstPassword == self.DumpPassword and self.AtmUI.CardNumber and self.AtmUI.CardPassword then
--             local cardNum = self.AtmUI.CardNumber
--             local tries = 0

--             local function deferredSync()
--                 tries = tries + 1
--                 local cardModData = ModData.get("S4_CardData")[cardNum]
--                 if cardModData and cardModData.Money then
--                     local s4Balance = cardModData.Money
--                     local AtmModData = self.AtmUI.Obj:getModData()
--                     if AtmModData and AtmModData.CustomCardData then
--                         syncingFromS4Economy = true
--                         EZPZBanking_BankServer.setBalance(AtmModData.CustomCardData, s4Balance)
--                         AtmModData.CustomCardData.balance = s4Balance
--                         syncingFromS4Economy = false
--                         print("[EZPZBanking] General: Synced new card creation balance of (" .. tostring(s4Balance) .. ") from S4Economy to EZPZBanking")
--                     end
--                     Events.OnTick.Remove(deferredSync)
--                 elseif tries > 60 then
--                     print("[EZPZBanking] Warning: Failed to sync new card balance, timed out")
--                     Events.OnTick.Remove(deferredSync)
--                 end
--             end

--             Events.OnTick.Add(deferredSync)
--         end
--     end
-- end

-- Events.OnGameStart.Add(setupS4EconomyHooks)