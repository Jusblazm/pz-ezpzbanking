-- EZPZBanking_CreditCardStart
local function giveCreditCardOnStart(playerIndex, playerObj)
    if not playerObj or playerObj:isDead() then return end

    local function sendNextTick()
        local playerData = playerObj:getModData()
        if playerData.hasCreditCard then return end

        sendClientCommand("EZPZBanking", "GiveCreditCardOnStart", {})
        Events.OnTick.Remove(sendNextTick)
    end
    Events.OnTick.Add(sendNextTick)
end

Events.OnCreatePlayer.Add(giveCreditCardOnStart)