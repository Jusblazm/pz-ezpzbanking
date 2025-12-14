-- EZPZBanking_CreditCardStart

local function giveCreditCardOnStart(playerIndex, playerObj)
    if not playerObj or playerObj:isDead() then return end

    local playerData = playerObj:getModData()
    if playerData.hasCreditCard then return end

    sendClientCommand("EZPZBanking", "GiveCreditCardOnStart", {
        x = playerObj:getX(),
        y = playerObj:getY(),
        z = playerObj:getZ()
    })
end

Events.OnCreatePlayer.Add(giveCreditCardOnStart)