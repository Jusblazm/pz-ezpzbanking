-- EZPZBanking_ISAdminPanelUI
local originalCreate = ISAdminPanelUI.create

function ISAdminPanelUI:create()
    originalCreate(self)

    local btnW = 200
    local btnH = getTextManager():getFontHeight(UIFont.Small) + 6
    local padding = 10
    local x = padding + 1
    local y = getTextManager():getFontHeight(UIFont.Medium) + padding * 2 + 1

    self.ezpzbankingAdminBtn = ISButton:new(x, y, btnW, btnH, getText("UI_EZPZBanking_ISEZPZBankingAdminUI_AdminPanelButton"), self, ISAdminPanelUI.onOptionMouseDown)

    self.ezpzbankingAdminBtn.internal = "EZPZBANKING"
    self.ezpzbankingAdminBtn:initialise()
    self.ezpzbankingAdminBtn:instantiate()
    self.ezpzbankingAdminBtn.borderColor = self.buttonBorderColor
    self.ezpzbankingAdminBtn.tooltip = getText("Tooltip_EZPZBanking_AdminPanelUI_AdminPanelButton")

    self:addChild(self.ezpzbankingAdminBtn)

    --[[
        remainder of this function is code from TIS found in IsAdminPanel
        used to reorder the panel and ensure that buttons are organized 
        and not overlapping each other.
        minor variable tweaks and checks for the cancel button were added by me.
    ]]
    -- local width = 0
    local bottom = 0
    local buttonValue = 0
    local columnCount = 2
    local buttons = {}

    for _, child in pairs(self:getChildren()) do
        if child ~= self.cancel then
            -- width = math.max(width, child:getWidth())
            table.insert(buttons, child)
        end
    end

    table.sort(buttons, function(a, b)
        return string.sort(b.title, a.title)
    end)

    for _, child in ipairs(buttons) do
        child:setWidth(btnW)
        child:setX(x + math.fmod(buttonValue, columnCount) * (btnW + padding))
        child:setY(y + math.floor(buttonValue / columnCount) * (btnH + padding))
        bottom = math.max(bottom, child:getBottom())
        buttonValue = buttonValue + 1
    end

    self:setWidth(x * 2 + btnW * columnCount + padding * (columnCount - 1))

    self.cancel:setX((self:getWidth() - btnW) / 2)
    self.cancel:setY(bottom + padding)

    self:setHeight(self.cancel:getBottom() + padding + 1)

    self:updateButtons()
end

local originalMouseDown = ISAdminPanelUI.onOptionMouseDown

function ISAdminPanelUI:onOptionMouseDown(button, x, y)
    if button.internal == "EZPZBANKING" then
        EZPZBanking_ISEZPZBankingAdminUI.openAdminUI()
    end

    originalMouseDown(self, button, x, y)
end