-- EZPZBanking_Main
require "ISUI/EZPZBanking_ATMUI"
require "ISUI/EZPZBanking_CardSelectorUI"
require "ISUI/EZPZBanking_SettingsUI"
require "ISUI/EZPZBanking_UninstallUI"
require "ISUI/AdminPanel/EZPZBanking_ISEZPZBankingAdminUI"

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

        -- close UninstallUI
        if EZPZBanking_UninstallUI.instance and EZPZBanking_UninstallUI.instance:isVisible() then
            EZPZBanking_UninstallUI.instance:setVisible(false)
            EZPZBanking_UninstallUI.instance:removeFromUIManager()
            EZPZBanking_UninstallUI.instance = nil
        end

        -- close ISEZPZBankingAdminUI
        -- if EZPZBanking_ISEZPZBankingAdminUI.instance and EZPZBanking_ISEZPZBankingAdminUI.instance:isVisible() then
        --     EZPZBanking_ISEZPZBankingAdminUI.instance:setVisible(false)
        --     EZPZBanking_ISEZPZBankingAdminUI.instance:removeFromUIManager()
        --     EZPZBanking_ISEZPZBankingAdminUI.instance = nil
        -- end
    end
end

Events.OnKeyPressed.Add(onGlobalKeyPressed)

local function onInitGlobalModData()
    ModData.request("BankAccounts")
end

local function onReceiveGlobalModData(module, data)
    if module == "BankAccounts" then
        ModData.add("BankAccounts", data)
    end
end

Events.OnInitGlobalModData.Add(onInitGlobalModData)
Events.OnReceiveGlobalModData.Add(onReceiveGlobalModData)