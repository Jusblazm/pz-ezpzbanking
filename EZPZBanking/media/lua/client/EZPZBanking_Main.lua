-- EZPZBanking_Main
require "ISUI/EZPZBanking_ATMUI"
require "ISUI/EZPZBanking_CardSelectorUI"
require "ISUI/EZPZBanking_SettingsUI"

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

        -- close SettingsUI
        if EZPZBanking_SettingsUI.instance and EZPZBanking_SettingsUI.instance:isVisible() then
            EZPZBanking_SettingsUI.instance:setVisible(false)
            EZPZBanking_SettingsUI.instance:removeFromUIManager()
            EZPZBanking_SettingsUI.instance = nil
        end
    end
end

Events.OnKeyPressed.Add(onGlobalKeyPressed)

local function updateWarning(playerIndex, playerObj)
    print("[EZPZBanking] Warning: This version of EZPZ Banking is no longer supported. Please update to the newest version to get new features and continued support")
end

Events.OnCreatePlayer.Add(updateWarning)