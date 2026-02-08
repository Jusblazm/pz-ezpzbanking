-- EZPZBanking_ProfessionBankManagerSpecial
local function giveBankManagerMoneyOnStart(playerIndex, playerObj)
    if not playerObj or playerObj:isDead() then return end

    local function sendNextTick()
        if playerObj:getDescriptor():getCharacterProfession() ~= "ezpzbanking:bankmanager" then return end
        local playerData = playerObj:getModData()
        if playerData.hasBankManagerReward then return end

        sendClientCommand("EZPZBanking", "GiveBankManagerReward", {})
        Events.OnTick.Remove(sendNextTick)
    end
    Events.OnTick.Add(sendNextTick)
end

Events.OnCreatePlayer.Add(giveBankManagerMoneyOnStart)