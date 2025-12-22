-- EZPZBanking_CreditCardStart
local EZPZBanking_BankServer = require("EZPZBanking_BankServer")

local function giveCreditCardOnStart(playerIndex, playerObj)
    if not playerObj or playerObj:isDead() then return end

    local playerData = playerObj:getModData()
    if playerData.hasCreditCard then
        return
    end

    local inv = playerObj:getInventory()

    for i=0, inv:getItems():size()-1 do
        local item = inv:getItems():get(i)
        if item:getType() == "CreditCard" then
            playerData.hasCreditCard = true
            return
        end
    end

    local item = inv:AddItem("Base.CreditCard")
    if item then
        local owner = nil
        local desc = playerObj:getDescriptor()
        if desc then
            owner = desc:getForename() .. " " .. desc:getSurname()
            item:setName("Credit Card: " .. owner)
        end
        local modData = item:getModData()
        modData.owner = owner
        modData.accountID = playerObj:getSteamID() .. "_" .. owner
        modData.last4 = tostring(ZombRand(1000, 9999))
        modData.pin = "11"
        modData.isStolen = false
        modData.attempts = 0
        modData.websiteURL = "knoxbank.com/account"

        EZPZBanking_BankServer.getOrCreateAccount(playerObj)
    end
    playerData.hasCreditCard = true
end

Events.OnCreatePlayer.Add(giveCreditCardOnStart)