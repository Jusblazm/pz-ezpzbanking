-- EZPZBanking_CardSelectorUI
EZPZBanking_CardSelectorUI = {}

local EZPZBanking_ATMUI = require("EZPZBanking_ATMUI")
local EZPZBanking_Utils = require("EZPZBanking_Utils")

EZPZBanking_CardSelectorUI.Window = ISCollapsableWindow:derive("CardSelectorWindow")

function EZPZBanking_CardSelectorUI.Window:new(x, y, width, height, player)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.minimumWidth = 300
    o.maximumWidth = 300
    o.minimumHeight = 100
    return o
end

function EZPZBanking_CardSelectorUI.Window:createChildren()
    ISCollapsableWindow.createChildren(self)

    local inv = self.player:getInventory():getItems()
    local cardY = 30
    local spacing = 35

    for i=0, inv:size()-1 do
        local item = inv:get(i)
        if item:getType() == "CreditCard" then
            EZPZBanking_Utils.ensureCardHasData(item)
            local modData = item:getModData()
            attemptsLabel = getText("UI_EZPZBanking_CardSelectorUI_Attempts")
            local label = string.format("%s - **** %s | %s %d/3", modData.owner, modData.last4, attemptsLabel, modData.attempts)

            local button = ISButton:new(10, cardY, self.width - 20, 25, label, self, function()
                self:onCardSelected(item)
            end)
            button:initialise()
            button:instantiate()
            self:addChild(button)

            cardY = cardY + spacing
        end
        self.minimumHeight = math.min(math.max(cardY + 10, 100), 500)
    end

    if cardY == 30 then
        local noCardsLabel = ISLabel:new(10, 30, 20, getText("UI_EZPZBanking_CardSelectorUI_NoCardsFound"), 1, 1, 1, 1, UIFont.Medium, true)
        self:addChild(noCardsLabel)
    end
end

function EZPZBanking_CardSelectorUI.Window:onResize()
    ISCollapsableWindow.onResize(self)

    -- enforce maximum width
    if self.maximumWidth and self.width > self.maximumWidth then
        self.width = self.maximumWidth
        if self.javaObject then
            self.javaObject:setWidthOnly(self.width)
        end
    end

    -- enforce maximum height
    if self.maximumHeight and self.height > self.maximumHeight then
        self.height = self.maximumHeight
        if self.javaObject then
            self.javaObject:setHeightOnly(self.height)
        end
    end
    self:updateScrollbars()
end

function EZPZBanking_CardSelectorUI.Window:onCardSelected(card)
    self:setVisible(false)
    self:removeFromUIManager()
    EZPZBanking_ATMUI.openATMUI(self.player, card)
end

function EZPZBanking_CardSelectorUI.openSelectorUI(player)
    local width = 300
    local height = 500
    local x = getCore():getScreenWidth() / 2 - width / 2
    local y = getCore():getScreenHeight() / 2 - height / 2

    local panel = EZPZBanking_CardSelectorUI.Window:new(x, y, width, height, player)
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    panel:setResizable(true)
    panel:setTitle(getText("UI_EZPZBanking_CardSelectorUI_CardSelectorTitle"))
end

return EZPZBanking_CardSelectorUI