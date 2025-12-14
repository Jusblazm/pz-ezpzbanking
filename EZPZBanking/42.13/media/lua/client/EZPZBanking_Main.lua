-- EZPZBanking_Main
require "EZPZBanking_ATMUI"
require "EZPZBanking_CardSelectorUI"

-- unified ESC key handler
local function onGlobalKeyPressed(key)
    if key == Keyboard.KEY_ESCAPE then
        -- close ATMUI
        if EZPZBanking_ATMUI.instance and EZPZBanking_ATMUI.instance:isVisible() then
            EZPZBanking_ATMUI.instance:setVisible(false)
            EZPZBanking_ATMUI.instance:removeFromUIManager()
            EZPZBanking_ATMUI.instance = nil
        end

        -- close CardSelectorUI
        if EZPZBanking_CardSelectorUI.instance and EZPZBanking_CardSelectorUI.instance:isVisible() then
            EZPZBanking_CardSelectorUI.instance:setVisible(false)
            EZPZBanking_CardSelectorUI.instance:removeFromUIManager()
            EZPZBanking_CardSelectorUI.instance = nil
        end
    end
end

Events.OnKeyPressed.Add(onGlobalKeyPressed)