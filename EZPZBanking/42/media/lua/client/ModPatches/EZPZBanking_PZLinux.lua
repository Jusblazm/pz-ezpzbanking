-- EZPZBanking_PZLinux
local EZPZBanking_Utils = require("EZPZBanking_Utils")
local EZPZBanking_BankServer = require("EZPZBanking_BankServer")
require("EZPZBanking_Hooks")

--[[
    this patch ensures PZLinux and EZPZBanking share the same bank account
]]

-- stops infinite sync loop
local syncingFromPZLinux = false

local function setupPZLinuxHooks()
    if not getActivatedMods():contains("\\B42_PZLinux") then
        print("[EZPZBanking] General: PZLinux is not installed")
        return
    end
    print("[EZPZBanking] General: PZLinux detected, enabling hooks")

    EZPZBanking_Hooks.wrapFunction(EZPZBanking_BankServer, "deposit")
    EZPZBanking_Hooks.wrapFunction(EZPZBanking_BankServer, "withdraw")
    EZPZBanking_Hooks.wrapFunction(EZPZBanking_BankServer, "setBalance")

    EZPZBanking_Hooks.add("deposit", function(result, accountID, amount)
        local success = result[1]
        if success and amount and amount > 0 then
            local player = getPlayer()
            local modData = player:getModData()
            local newBalance = EZPZBanking_BankServer.getAccountByID(accountID).balance
            modData.PZLinuxBank = newBalance
            print("[EZPZBanking] General: Synced deposit to PZLinux. Balance: " .. tostring(newBalance))
        end
    end)

    EZPZBanking_Hooks.add("withdraw", function(result, accountID, amount)
        local success = result[1]
        if success and amount and amount > 0 then
            local player = getPlayer()
            local modData = player:getModData()
            local newBalance = EZPZBanking_BankServer.getAccountByID(accountID).balance
            modData.PZLinuxBank = newBalance
            print("[EZPZBanking] General: Synced withdraw to PZLinux. Balance: " .. tostring(newBalance))
        end
    end)

    EZPZBanking_Hooks.add("setBalance", function(result, card, newBalance)
        local success = result[1]
        if not syncingFromPZLinux and success then
            local player = getPlayer()
            local modData = player:getModData()
            modData.PZLinuxBank = newBalance
            print("[EZPZBanking] General: Synced balance to PZLinux. Balance: " .. tostring(newBalance))
        end
    end)

    local original_saveAtmBalance = saveAtmBalance
    function saveAtmBalance(balance)
        if original_saveAtmBalance then
            original_saveAtmBalance(balance)
        end

        if balance then
            local player = getPlayer()
            local card = EZPZBanking_Utils.getPlayerCard(player)
            if card then
                local modData = card:getModData()
                syncingFromPZLinux = true
                EZPZBanking_BankServer.setBalance(modData, balance)
                syncingFromPZLinux = false
                print("[EZPZBanking] General: Synced bank accounts between PZLinux and EZPZBanking")
            else
                print("[EZPZBanking] General: No Credit Card found")
            end
        end
    end
end

Events.OnGameStart.Add(setupPZLinuxHooks)