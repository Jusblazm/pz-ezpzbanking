-- -- EZPZBanking_ISAdminPanelUI
-- local originalCreate = ISAdminPanelUI.create

-- function ISAdminPanelUI:create()
--     originalCreate(self)

--     local btnWid = 200
--     local btnHgt = getTextManager():getFontHeight(UIFont.Small) + 6
--     local padding = 10
--     local x = padding + 1
--     local y = getTextManager():getFontHeight(UIFont.Medium) + padding * 2 + 1

--     self.ezpzbankingAdminBtn = ISButton:new(x, y, btnWid, btnHgt, getText("UI_EZPZBanking_ISEZPZBankingAdminUI_AdminPanelButton"), self, ISAdminPanelUI.onOptionMouseDown)

--     self.ezpzbankingAdminBtn.internal = "EZPZBANKING"
--     self.ezpzbankingAdminBtn:initialise()
--     self.ezpzbankingAdminBtn:instantiate()
--     self.ezpzbankingAdminBtn.borderColor = self.buttonBorderColor
--     self.ezpzbankingAdminBtn.tooltip = getText("Tooltip_EZPZBanking_AdminPanelUI_AdminPanelButton")

--     self:addChild(self.ezpzbankingAdminBtn)
-- end

-- local originalMouseDown = ISAdminPanelUI.onOptionMouseDown

-- function ISAdminPanelUI:onOptionMouseDown(button, x, y)
--     if button.internal == "EZPZBANKING" then
--         EZPZBanking_ISEZPZBankingAdminUI.openAdminUI()
--     end

--     originalMouseDown(self, button, x, y)
-- end