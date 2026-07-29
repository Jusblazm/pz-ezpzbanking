-- EZPZBanking_Utils
local EZPZBanking_Utils = {}

EZPZBanking_Utils.validATMSprites = {
    ["location_business_bank_01_64"] = true, -- standalone
    ["location_business_bank_01_65"] = true, -- standalone
    ["location_business_bank_01_66"] = true, -- in wall
    ["location_business_bank_01_67"] = true, -- in wall
}

EZPZBanking_Utils.ATMFacingDirections = {
    ["location_business_bank_01_64"] = 1, -- East
    ["location_business_bank_01_65"] = 2, -- South
    ["location_business_bank_01_66"] = 1, -- East
    ["location_business_bank_01_67"] = 2, -- South
}

function EZPZBanking_Utils.isValidATMSprite(spriteName)
    return EZPZBanking_Utils.validATMSprites[spriteName] == true
end

function EZPZBanking_Utils.getFrontSquareOfATM(obj)
    return EZPZBanking_Utils.getFrontSquareFromDirectionTable(obj, EZPZBanking_Utils.ATMFacingDirections)
end

function EZPZBanking_Utils.getFrontSquareFromDirectionTable(obj, directionTable)
    local sprite = obj:getSprite()
    if not sprite then return nil end

    local spriteName = sprite:getName()
    local dir = directionTable[spriteName]
    if not dir then return nil end

    local dx, dy = 0, 0
    if dir == 0 then dy = -1
    elseif dir == 1 then dx = 1
    elseif dir == 2 then dy = 1
    elseif dir == 3 then dx = -1
    end

    local square = obj:getSquare()
    return getCell():getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
end

local function isSquarePowered(square)
    return (
        (SandboxVars.AllowExteriorGenerator and square:haveElectricity()) or
        (SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier and not square:isOutside())
    )
end

-- required for ATM outside of post office in Ekron
-- it's part of the building, but not defined as part of the building
local function isNearbySquarePowered(square, radius)
    if not square then return false end
    radius = radius or 1

    for dx = -radius, radius do
        for dy = -radius, radius do
            local checkSquare = getCell():getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
            if checkSquare and isSquarePowered(checkSquare) then
                return true
            end
        end
    end
    return false
end

function EZPZBanking_Utils.isATMPowered(obj)
    if not obj then return false end
    local square = obj:getSquare()
    if not square then return false end
    return isNearbySquarePowered(square, 3)
end

function EZPZBanking_Utils.getAllCreditCards(player)
    local function collectAllItems(container, results)
        if not container then return end
        local items = container:getItems()
        for i=0, items:size()-1 do
            local item = items:get(i)
            table.insert(results, item)
            if item:IsInventoryContainer() then
                collectAllItems(item:getInventory(), results)
            end
        end
    end
    
    local cards = {}
    local allItems = {}
    collectAllItems(player:getInventory(), allItems)

    local worn = player:getWornItems()
    if worn then
        for i=0, worn:size()-1 do
            local wormItem = worn:get(i):getItem()
            if wornItem and wornItem:IsInventoryContainer() then
                collectAllItems(wornItem:getInventory(), allItems)
            end
        end
    end

    local primary = player:getPrimaryHandItem()
    if primary and primary:IsInventoryContainer() then
        collectAllItems(primary:getInventory(), allItems)
    end

    local secondary = player:getSecondaryHandItem()
    if secondary and secondary:IsInventoryContainer() then
        collectAllItems(secondary:getInventory(), allItems)
    end

    for _, item in ipairs(allItems) do
        if item and item:getType() == "CreditCard" then
            table.insert(cards, item)
        end
    end
    return cards
end

function EZPZBanking_Utils.getPlayerCard(player)
    local cards = EZPZBanking_Utils.getAllCreditCards(player)

    for _, card in ipairs(cards) do
        if EZPZBanking_Utils.isCardOwner(player, card) then
            return card
        end
    end
    return nil
end

function EZPZBanking_Utils.getCard(player)
    local cards = EZPZBanking_Utils.getAllCreditCards(player)
    return cards[1] or nil
end

function EZPZBanking_Utils.getCardByAccountID(player, accountID)
    if not player or not accountID then return nil end

    local cards = EZPZBanking_Utils.getAllCreditCards(player)
    if not cards then return nil end

    for _, card in ipairs(cards) do
        if card and card:getType() == "CreditCard" then
            local modData = card:getModData()
            if modData and modData.accountID == accountID then
                return card
            end
        end
    end
    return nil
end

function EZPZBanking_Utils.hasEZPZBankingModData(card)
    if not card or card:getType() ~= "CreditCard" then return false end
    
    local modData = card:getModData()
    if not modData then return false end

    if modData.owner and modData.last4 and modData.attempts then
        return true
    end
    return false
end

function EZPZBanking_Utils.isCardOwner(player, card)
    if not player or not card then return false end

    local modData = card:getModData()
    if not modData then return false end
    local descriptor = player:getDescriptor()
    local playerFullName = descriptor:getForename() .. " " .. descriptor:getSurname()

    return modData.owner == playerFullName
end

function EZPZBanking_Utils.generateRandomPIN()
    local num = ZombRand(0, 100)
    return string.format("%02d", num)
end

function EZPZBanking_Utils.ensureCardHasData(card)
    if isClient() then return end

    local modData = card:getModData()
    if not modData.pin then
        modData.pin = EZPZBanking_Utils.generateRandomPIN()
    end
    if not modData.attempts then
        modData.attempts = 0
    end
    if not modData.last4 then
        modData.last4 = tostring(ZombRand(1000, 9999))
    end
    if not modData.owner then
        local name = card:getName() or ""
        local found = name:match('Credit Card%s*%("%s*(.-)%s*"%)') or name:match("Credit Card[:%s]*(.+)")
        modData.owner = found or "Unknown"
    end
    if not modData.accountID then
        modData.accountID = "FAKE_" .. tostring(ZombRand(100000, 999999)) .. "_" .. modData.owner
    end
    if not modData.isStolen then
        modData.isStolen = false
    end
end

function EZPZBanking_Utils.createCreditCard(player)
    if isClient() then return end
    if not player or player:isDead() then return nil end

    local inv = player:getInventory()
    local item = inv:AddItem("Base.CreditCard")
    
    local owner = nil
    local desc = player:getDescriptor()
    if desc then
        owner = desc:getForename() .. " " .. desc:getSurname()
        item:setName("Credit Card: " .. owner)
        -- item:setName("Credit Card (\"" .. owner .. "\")")
    end
    local modData = item:getModData()
    modData.owner = owner
    modData.accountID = player:getSteamID() .. "_" .. owner
    modData.last4 = tostring(ZombRand(1000, 9999))
    modData.pin = "11"
    modData.isStolen = false
    modData.attempts = 0
    modData.websiteURL = "knoxbank.com/account"

    EZPZBanking_BankServer.getOrCreateAccount(player)
    sendAddItemToContainer(inv, item)
    syncItemModData(player, item)
end

function EZPZBanking_Utils.isAutomaticOwnerPINEnabled()
    return SandboxVars.EZPZBanking and SandboxVars.EZPZBanking.OwnerPIN == true
end

function EZPZBanking_Utils.canUseATMSettings()
    local gameVersion = getCore():getVersionNumber()
    local MailOrderCatalogs = nil

    if gameVersion and tonumber(gameVersion) >= 42 then
        MailOrderCatalogs = "\\JusMailOrderCatalogs"
    else
        MailOrderCatalogs = "JusMailOrderCatalogs"
    end

    return not getActivatedMods():contains(MailOrderCatalogs)
end

function EZPZBanking_Utils.hasEZPZBankingProfession(player)
    local professions = EZPZBankingProfessions
    for _, profession in pairs(professions) do
        if player:getDescriptor():isCharacterProfession(profession) then
            return true
        end
    end
    return false
end

function EZPZBanking_Utils.removeEZPZBankingProfessions(player)
    if not EZPZBanking_Utils.hasEZPZBankingProfession(player) then return end
    local professions = EZPZBankingProfessions
    local playerData = player:getModData()

    playerData.previouslyHadEZPZBankingProfession = player:getDescriptor():getCharacterProfession():toString()
    
    player:getDescriptor():setCharacterProfession(CharacterProfession.UNEMPLOYED)
end

function EZPZBanking_Utils.addEZPZBankingProfessions(player)
    local playerData = player:getModData()
    if not playerData.previouslyHadEZPZBankingProfession then return end

    if player:getDescriptor():isCharacterProfession(CharacterProfession.UNEMPLOYED) then
        local professionList = CharacterProfessionDefinition.getProfessions()
        for i=0, professionList:size()-1 do
            local profession = professionList:get(i)
            if profession:getType():toString() == playerData.previouslyHadEZPZBankingProfession then
                player:getDescriptor():setCharacterProfession(profession:getType())
            end
        end
    end
    playerData.previouslyHadEZPZBankingProfession = nil
end

function EZPZBanking_Utils.hasEZPZBankingTrait(player)
    local traits = EZPZBankingTraits
    for _, trait in pairs(traits) do
        if player:hasTrait(trait) then
            return true
        end
    end
    return false
end

function EZPZBanking_Utils.removeEZPZBankingTraits(player)
    if not EZPZBanking_Utils.hasEZPZBankingTrait(player) then return end
    local traits = EZPZBankingTraits
    local playerData = player:getModData()

    playerData.previouslyHadEZPZBankingTraits = {}
    for _, trait in pairs(traits) do
        if player:hasTrait(trait) then
            table.insert(playerData.previouslyHadEZPZBankingTraits, trait:toString())
            player:getCharacterTraits():remove(trait)
        end
    end
end

function EZPZBanking_Utils.addEZPZBankingTraits(player)
    local playerData = player:getModData()
    if not playerData.previouslyHadEZPZBankingTraits then return end

    local traitList = CharacterTraitDefinition.getTraits()
    for _, traitName in ipairs(playerData.previouslyHadEZPZBankingTraits) do
        for i=0, traitList:size()-1 do
            local trait = traitList:get(i)
            if trait:getType():toString() == traitName then
                player:getCharacterTraits():add(trait:getType())
            end
        end
    end
    playerData.previouslyHadEZPZBankingTraits = nil
end

return EZPZBanking_Utils