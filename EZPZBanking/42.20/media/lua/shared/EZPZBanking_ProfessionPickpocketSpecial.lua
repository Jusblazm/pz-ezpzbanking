-- EZPZBanking_ProfessionPickpocketSpecial
local WALLET_CHANCE = 0.3
local MULTI_WALLET_CHANCE = 0.05

local function OnWeaponHitCharacter(attacker, target, weapon, damage)
    if not attacker or not instanceof(attacker, "IsoPlayer") then return end
    if attacker:getDescriptor():getCharacterProfession():getName() ~= "pickpocket" then return end
    if not target:isAlive() then return end
    if not attacker:isDoShove() then return end
    if attacker:isAimAtFloor() then return end

    local zModData = target:getModData()

    if zModData.walletChecked then return end

    if ZombRandFloat(0.0, 1.0) <= WALLET_CHANCE then      
        sendClientCommand("EZPZBanking", "PickpocketZombie", { female = target:isFemale() })

        if ZombRandFloat(0.0, 1.0) > MULTI_WALLET_CHANCE then
            zModData.walletChecked = true
        end
    end
end

Events.OnWeaponHitCharacter.Add(OnWeaponHitCharacter)