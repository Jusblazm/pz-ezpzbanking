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
    local descriptor = player:getDescriptor()
    local fullName = descriptor:getForename() .. " " .. descriptor:getSurname()
    local cards = EZPZBanking_Utils.getAllCreditCards(player)

    for _, item in ipairs(cards) do
        local modData = item:getModData()
        if modData and modData.owner == fullName then
            return item
        end
    end
    return nil
end

function EZPZBanking_Utils.getCard(player)
    local cards = EZPZBanking_Utils.getAllCreditCards(player)
    return cards[1] or nil
end

function EZPZBanking_Utils.generateRandomPIN()
    local num = ZombRand(0, 100)
    return string.format("%02d", num)
end

function EZPZBanking_Utils.ensureCardHasData(card)
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

function EZPZBanking_Utils.isAutomaticOwnerPINEnabled()
    return SandboxVars.MailOrderCatalogs and SandboxVars.MailOrderCatalogs.OwnerPIN == true
end

return EZPZBanking_Utils