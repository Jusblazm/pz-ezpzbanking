local function giveBankManagerMoneyOnStart(playerIndex, playerObj)
    if not playerObj or playerObj:isDead() then return end

    local tickCount = 0
    local DELAYED_TICK = 3

    local function sendAfterDelayedTicks()
        tickCount = tickCount + 1
        if tickCount < DELAYED_TICK then return end

        if playerObj:getDescriptor():getCharacterProfession():getName() ~= "bankmanager" then 
            Events.OnTick.Remove(sendAfterDelayedTicks)
            return
        end
        local playerData = playerObj:getModData()
        if playerData.hasBankManagerReward then 
            Events.OnTick.Remove(sendAfterDelayedTicks)
            return
        end

        sendClientCommand("EZPZBanking", "GiveBankManagerReward", {})
        Events.OnTick.Remove(sendAfterDelayedTicks)
    end
    Events.OnTick.Add(sendAfterDelayedTicks)
end

Events.OnCreatePlayer.Add(giveBankManagerMoneyOnStart)