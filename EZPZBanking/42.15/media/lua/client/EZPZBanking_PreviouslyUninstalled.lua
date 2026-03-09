-- EZPZBanking_PreviouslyUninstalled
local EZPZBanking_Utils = require("EZPZBanking_Utils")

local function checkIfPreviouslyUninstalled(playerIndex, playerObj)
    if isClient() then return end
    if not playerObj or playerObj:isDead() then return end
    local playerData = playerObj:getModData()
    if not playerData.wasPreviouslyUninstalled then return end

    EZPZBanking_Utils.addEZPZBankingProfessions(playerObj)
    EZPZBanking_Utils.addEZPZBankingTraits(playerObj)

    playerData.wasPreviouslyUninstalled = nil
end

Events.OnCreatePlayer.Add(checkIfPreviouslyUninstalled)