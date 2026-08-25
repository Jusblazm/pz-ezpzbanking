-- -- EZPZBanking_ISEZPZBankingAdminUI
-- EZPZBanking_ISEZPZBankingAdminUI = {}

-- local ISCollapsableWindow = ISCollapsableWindow

-- EZPZBanking_ISEZPZBankingAdminUI.Window = ISCollapsableWindow:derive("Window")

-- function EZPZBanking_ISEZPZBankingAdminUI.Window:new(x, y, width, height)
--     local o = ISCollapsableWindow:new(x, y, width, height)
--     setmetatable(o, self)
--     self.__index = self
--     return o
-- end

-- function EZPZBanking_ISEZPZBankingAdminUI.Window:createChildren()
--     ISCollapsableWindow.createChildren(self)
    
--     local y = 20
--     local x = 20

--     self.playerList = ISComboBox:new(x, y, 100, 25)
--     self.playerList:initialise()
--     self.playerList:instantiate()
--     self:addChild(self.playerList)

--     y = y + 40

--     self.amountLabel = ISLabel:new(x, y, 20, getText("UI_EZPZBanking_ISEZPZBankingAdminUI_Amount"), 1, 1, 1, 1, UIFont.Small, true)
--     self:addChild(self.amountLabel)

--     y = y + 18

--     self.amountEntry = ISTextEntryBox:new("", x, y, 100, 25)
--     self.amountEntry:initialise()
--     self.amountEntry:instantiate()
--     self.amountEntry:setOnlyNumbers(true)
--     self.amountEntry:setTooltip(getText("Tooltip_EZPZBanking_ATMUI_AmountEntry_Normal"))
--     self:addChild(self.amountEntry)

--     y = y + 40

--     self.confirmButton = ISButton:new(x, y, 80, 25, getText("UI_EZPZBanking_Generic_ConfirmButton"), self, function()
--         self:onConfirm()
--     end)
--     self.confirmButton:initialise()
--     self.confirmButton:instantiate()
--     self:addChild(self.confirmButton)

--     self:populatePlayers()
-- end

-- function EZPZBanking_ISEZPZBankingAdminUI.Window:populatePlayers()
--     self.playerList:clear()

--     local players = getOnlinePlayers()
--     if not players then return end

--     for i=0, players:size()-1 do
--         local player = players:get(i)
--         local username = player:getUsername()

--         self.playerList:addOptionWithData(username, player)
--     end
-- end

-- function EZPZBanking_ISEZPZBankingAdminUI.Window:onConfirm()
--     local selectedPlayer = self.playerList:getOptionData(self.playerList.selected)

--     if not selectedPlayer then
--         print("[EZPZBanking] Error: No player selected")
--         return
--     end

--     local amount = tonumber(self.amountEntry:getText())

--     if not amount or amount <= 0 then
--         print("[EZPZBanking] Error: Invalid amount")
--         return
--     end

--     EZPZBanking_API.giveMoney(selectedPlayer, amount)
--     print(string.format("[EZPZBanking] Debug: Sent %d to %s", amount, selectedPlayer:getUsername()))
-- end

-- function EZPZBanking_ISEZPZBankingAdminUI.openAdminUI()
--     if EZPZBanking_ISEZPZBankingAdminUI.instance and EZPZBanking_ISEZPZBankingAdminUI.instance:isVisible() then return end

--     local width = 300
--     local height = 200
--     local x = getCore():getScreenWidth() / 2 - width / 2
--     local y = getCore():getScreenHeight() / 2 - height / 2

--     local panel = EZPZBanking_ISEZPZBankingAdminUI.Window:new(x, y, width, height)
--     panel:initialise()
--     panel:addToUIManager()
--     panel:setVisible(true)
--     panel:setResizable(false)
--     panel:setTitle(getText("UI_EZPZBanking_ISEZPZBankingAdminUI_AdminTitle"))

--     EZPZBanking_ISEZPZBankingAdminUI.instance = panel
-- end

-- return EZPZBanking_ISEZPZBankingAdminUI