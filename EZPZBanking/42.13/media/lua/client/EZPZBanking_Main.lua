-- EZPZBanking_Main
require "EZPZBanking_ATMUI"
require "EZPZBanking_CardSelectorUI"
require "EZPZBanking_SettingsUI"

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

Events.OnServerCommand.Add(function(module, command, args)
    if module ~= "EZPZBanking" then return end

    if command == "AccountUpdated" then
        require "EZPZBanking_BankServer"
        local account = EZPZBanking_BankServer.getAccountByID(args.accountID)
        if account then
            account.balance = args.balance
        end
    end

    if command == "AccountDetails" then
        require "EZPZBanking_BankServer"
        local account = EZPZBanking_BankServer.getAccountByID(args.accountID)
        if account then
            account.balance = args.balance
            account.owner = args.owner
            account.pin = args.pin
        end
    end
end)

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