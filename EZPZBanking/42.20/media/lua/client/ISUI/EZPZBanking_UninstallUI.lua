-- EZPZBanking_UninstallUI
EZPZBanking_UninstallUI = {}

local EZPZBanking_Utils = require("EZPZBanking_Utils")

local ISCollapsableWindow = ISCollapsableWindow

EZPZBanking_UninstallUI.Window = ISCollapsableWindow:derive("Window")

function EZPZBanking_UninstallUI.Window:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end

function EZPZBanking_UninstallUI.Window:setPlayer(player)
    self.player = player
end

function EZPZBanking_UninstallUI.Window:getPlayer()
    return self.player
end

function EZPZBanking_UninstallUI.Window:createChildren()
    ISCollapsableWindow.createChildren(self)
    self:createStaticChildren()
    self:refreshUI()
end

function EZPZBanking_UninstallUI.Window:createStaticChildren()
    self.professionLabel = ISLabel:new(10, 20, 20, "", 1, 1, 1, 1, UIFont.Small, true)
    self.professionLabel:initialise()
    self:addChild(self.professionLabel)

    self.traitLabel = ISLabel:new(10, 40, 20, "", 1, 1, 1, 1, UIFont.Small, true)
    self.traitLabel:initialise()
    self:addChild(self.traitLabel)

    self.warningLabel = ISLabel:new(10, 60, 20, "", 1, 1, 1, 1, UIFont.Small, true)
    self.warningLabel:initialise()
    self:addChild(self.warningLabel)
end

function EZPZBanking_UninstallUI.Window:refreshUI()
    local player = self:getPlayer()

    local hasProfession = EZPZBanking_Utils.hasEZPZBankingProfession(player)
    local hasTrait = EZPZBanking_Utils.hasEZPZBankingTrait(player)

    self.professionLabel:setName("Has EZPZ Banking Occupation? " .. tostring(hasProfession))
    self.traitLabel:setName("Has EZPZ Banking Trait? " .. tostring(hasTrait))

    local isSafe = not hasProfession and not hasTrait
    local keyWord = isSafe and "safe" or "not safe"

    self.warningLabel:setName("It is " .. keyWord .. " to remove EZPZ Banking")

    if isSafe then
        self.warningLabel:setColor(0, 1, 0, 1)
    else
        self.warningLabel:setColor(1, 0, 0, 1)
    end

    self:clearControls()
    self:createControls(isSafe)
end

function EZPZBanking_UninstallUI.Window:createUnsafeControls(y)
    self.confirmButton = ISButton:new(10, y, 80, 25, getText("UI_EZPZBanking_Generic_ConfirmButton"), self, function() 
        self:onConfirmButton()
    end)
    self.confirmButton:initialise()
    self.confirmButton:instantiate()
    self:addChild(self.confirmButton)
    self.confirmButton.enable = false

    self.cancelButton = ISButton:new(100, y, 80, 25, getText("UI_EZPZBanking_Generic_CancelButton"), self, function()
        self:setVisible(false)
        self:removeFromUIManager()
        EZPZBanking_UninstallUI.instance = nil
    end)
    self.cancelButton:initialise()
    self.cancelButton:instantiate()
    self:addChild(self.cancelButton)

    y = y - 35

    self.confirmTickBox = ISTickBox:new(10, y, 200, 20, "", self, self.onConfirmChanged)
    self.confirmTickBox:addOption(getText("UI_EZPZBanking_UninstallUI_FinalConfirmation"))
    self.confirmTickBox:setSelected(1, false)
    self:addChild(self.confirmTickBox)
end

function EZPZBanking_UninstallUI.Window:createSafeControls(y)
    self.closeButton = ISButton:new(10, y, 80, 25, getText("UI_EZPZBanking_Generic_CloseButton"), self, function()
        self:setVisible(false)
        self:removeFromUIManager()
        EZPZBanking_UninstallUI.instance = nil
    end)
    self.closeButton:initialise()
    self.closeButton:instantiate()
    self:addChild(self.closeButton)
end

function EZPZBanking_UninstallUI.Window:createControls(isSafe)
    local y = self.height - 35

    if not isSafe then
        self:createUnsafeControls(y)
    else
        self:createSafeControls(y)
    end
end

function EZPZBanking_UninstallUI.Window:clearControls()
    local controls = {
        "confirmButton",
        "cancelButton",
        "confirmTickBox",
        "closeButton"
    }

    for _, name in ipairs(controls) do
        if self[name] then
            self:removeChild(self[name])
            self[name] = nil
        end
    end
end

function EZPZBanking_UninstallUI.Window:onConfirmChanged(index, selected)
    self.confirmButton.enable = selected
    if selected then
        self.confirmButton.backgroundColor = { r = 0, g = 1, b = 0, a = 0.2 }
        self.confirmButton.backgroundColorMouseOver = { r = 0, g = 1, b = 0, a = 0.4 }
        self.confirmButton.borderColor = { r = 0, g = 1, b = 0, a = 1 }
    else
        self.confirmButton.backgroundColor = { r = 0, g = 0, b = 0, a = 1 }
        self.confirmButton.backgroundColorMouseOver = { r = 0.3, g = 0.3, b = 0.3, a = 1 }
        self.confirmButton.borderColor = { r = 0.7, g = 0.7, b = 0.7, a = 1 }
    end
end

function EZPZBanking_UninstallUI.Window:onConfirmButton()
    playerData = self:getPlayer():getModData()
    EZPZBanking_Utils.removeEZPZBankingProfessions(self:getPlayer())
    EZPZBanking_Utils.removeEZPZBankingTraits(self:getPlayer())
    playerData.wasPreviouslyUninstalled = true
    self:refreshUI()
end

function EZPZBanking_UninstallUI.openUninstallUI(player)
    if EZPZBanking_UninstallUI.instance and EZPZBanking_UninstallUI.instance:isVisible() then return end
    if not player or player:isDead() then return end

    local width = 300
    local height = 200
    local x = getCore():getScreenWidth() / 2 - width / 2
    local y = getCore():getScreenHeight() / 2 - height / 2

    local panel = EZPZBanking_UninstallUI.Window:new(x, y, width, height)
    panel:setPlayer(player)
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    panel:setResizable(false)
    panel:setTitle(getText("UI_EZPZBanking_UninstallUI_Title"))

    EZPZBanking_UninstallUI.instance = panel
end

return EZPZBanking_UninstallUI