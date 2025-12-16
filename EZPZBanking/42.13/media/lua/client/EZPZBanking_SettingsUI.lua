-- EZPZBanking_SettingsUI
EZPZBanking_SettingsUI = {}

local ISCollapsableWindow = ISCollapsableWindow

EZPZBanking_SettingsUI.SettingsWindow = ISCollapsableWindow:derive("SettingsWindow")

function EZPZBanking_SettingsUI.SettingsWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end

function EZPZBanking_SettingsUI.SettingsWindow:setPlayer(player)
    self.player = player
end

function EZPZBanking_SettingsUI.SettingsWindow:getPlayer()
    return self.player
end

function EZPZBanking_SettingsUI.SettingsWindow:setCard(card)
    self.card = card
end

function EZPZBanking_SettingsUI.SettingsWindow:getCard()
    return self.card
end

function EZPZBanking_SettingsUI.SettingsWindow:setReturnToATM(flag)
    self.returnToATM = flag == true
end

function EZPZBanking_SettingsUI.SettingsWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local player = self:getPlayer()
    local card = self:getCard()

    local padding = 10
    local y = 30
    local btnW = 150
    local btnH = 25
    local labelSpacing = 6

    local modData = card and card:getModData() or nil

    self.pinEntry = ISTextEntryBox:new("", padding, y, 100, 25)
    self.pinEntry:initialise()
    self.pinEntry:instantiate()
    self.pinEntry:setOnlyNumbers(true)
    self.pinEntry:setMaxTextLength(2)
    self:addChild(self.pinEntry)

    y = y + 30

    self.pinErrorLabel = ISLabel:new(padding, y, 20, getText("UI_EZPZBanking_SettingsUI_PINError"), 1, 0.2, 0.2, 1, UIFont.Small, true)
    self.pinErrorLabel:initialise()
    self.pinErrorLabel:setVisible(false)
    self:addChild(self.pinErrorLabel)

    y = y + self.pinErrorLabel:getHeight() + labelSpacing

    self.updatePinButton = ISButton:new(padding, y, 120, 25, getText("UI_EZPZBanking_SettingsUI_UpdatePIN"), self, function()
        -- if not modData then return end

        local newPin = self.pinEntry:getInternalText()
        if #newPin ~= 2 or not tonumber(newPin) then
            self.pinErrorLabel:setVisible(true)
            return
        end

        self.pinErrorLabel:setVisible(false)
        modData.pin = newPin
        EZPZBanking_BankServer.setPIN(modData, newPin)
    end)
    self.updatePinButton:initialise()
    if not self.card then
        self.updatePinButton.enable = false
    end
    self:addChild(self.updatePinButton)

    y = y + btnH + 15

    self.orderCardButton = ISButton:new(padding, y, btnW, btnH, getText("UI_EZPZBanking_SettingsUI_OrderCard"), self, function()
        if not player or player:isDead() then return end
        sendClientCommand("EZPZBanking", "OrderCreditCard", {})

        print("[EZPZBanking] General: New credit card ordered")

    end)
    self.orderCardButton:initialise()
    self:addChild(self.orderCardButton)

    y = y + btnH + 15

    ----------------------------------------------------------------
    -- REPORT STOLEN (PLACEHOLDER)
    ----------------------------------------------------------------
    self.reportStolenButton = ISButton:new(padding, y, btnW, btnH, getText("UI_EZPZBanking_SettingsUI_ReportStolen"), self, function()
        print("[EZPZBanking] Debug: Card has been reported stolen!")
    end)
    self.reportStolenButton:initialise()
    self.reportStolenButton.enable = false
    self:addChild(self.reportStolenButton)

    y = y + btnH + 15
    ----------------------------------------------------------------
    -- BACK BUTTON
    ----------------------------------------------------------------
    self.backButton = ISButton:new(padding, y, 80, 25, getText("UI_EZPZBanking_SettingsUI_Back"), self, self.onBack)
    self.backButton:initialise()
    if not self.returnToATM or not self.card then
        self.backButton.enable = false
    end
    self:addChild(self.backButton)

    -- self.closeButton = ISButton:new(padding + 80, y, 80, 25, getText("UI_EZPZBanking_SettingsUI_Close"), self, self.close)
    -- self.closeButton:initialise()
    -- self:addChild(self.closeButton)
end

function EZPZBanking_SettingsUI.SettingsWindow:onBack()
    if not self.returnToATM or not self.card then return end
    local player = self:getPlayer()
    local card = self:getCard()

    self:setVisible(false)
    self:removeFromUIManager()
    EZPZBanking_SettingsUI.instance = nil
    local EZPZBanking_ATMUI = require("EZPZBanking_ATMUI")
    EZPZBanking_ATMUI.openATMUI(player, card)
end

function EZPZBanking_SettingsUI.openSettingsUI(player, card, returnToATM)
    if EZPZBanking_SettingsUI.instance then return end
    if not player or player:isDead() then return end

    local width = 300
    local height = 250
    local x = getCore():getScreenWidth() / 2 - width / 2
    local y = getCore():getScreenHeight() / 2 - height / 2

    local panel = EZPZBanking_SettingsUI.SettingsWindow:new(x, y, width, height)
    panel:setPlayer(player)
    panel:setCard(card)
    panel:setReturnToATM(returnToATM == true)
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    panel:setResizable(false)
    panel:setTitle(getText("UI_EZPZBanking_ATMUI_ATMTitle"))

    EZPZBanking_SettingsUI.instance = panel
end

return EZPZBanking_SettingsUI
