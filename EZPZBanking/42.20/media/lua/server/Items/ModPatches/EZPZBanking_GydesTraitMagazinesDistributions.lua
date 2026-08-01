-- EZPZBanking_GydesTraitMagazinesDistributions
if not getActivatedMods():contains("GydeTraitMags") then
    print("[EZPZBanking] General: Gyde Trait Magazines is not installed, distribution aborted")
    return
end

if not GydeTraitMags or not SandboxVars or not SandboxVars.GydeTraitMags then
    print("[EZPZBanking] Warning: Sandbox Vars or GydeTraitMags wasn't found, distribution aborted")
    return
end

require "Items/ProceduralDistributions"
require "Items/SuburbsDistributions"
require "Items/ItemPicker"

local sBvars = SandboxVars.GydeTraitMags

local spawnRateMultipliers = {
    [1] = 0.05,
    [2] = 0.25,
    [3] = 0.5,
    [4] = 1,
    [5] = 2,
}

local function getSpawnRateMultiplier()
    return spawnRateMultipliers[sBvars.SpawnRate] or 1
end

local function insertItem(distributionTable, item, baseChance)
    local chance = baseChance * getSpawnRateMultiplier()
    table.insert(distributionTable.items, item)
    table.insert(distributionTable.items, chance)
end

Events.OnInitGlobalModData.Add(function()
    local magazineType = "Base.CreditCardThiefMagazine"

    insertItem(SuburbsDistributions["all"]["postbox"], magazineType, 0.15)
    insertItem(ProceduralDistributions["list"]["ShelfGeneric"], magazineType, 0.2)
    insertItem(ProceduralDistributions["list"]["MagazineRackMixed"], magazineType, 0.7)
    insertItem(ProceduralDistributions["list"]["MagazineRackNewspaper"], magazineType, 0.7)
    insertItem(ProceduralDistributions["list"]["CrateBooks"], magazineType, 0.5)
    insertItem(ProceduralDistributions["list"]["LibraryBooks"], magazineType, 1)
    insertItem(ProceduralDistributions["list"]["BookstoreBooks"], magazineType, 1.2)
    insertItem(ProceduralDistributions["list"]["PostOfficeBooks"], magazineType, 0.4)

    insertItem(ProceduralDistributions["list"]["PoliceEvidence"], magazineType, 1)
    insertItem(ProceduralDistributions["list"]["PoliceLockers"], magazineType, 0.5)
    insertItem(ProceduralDistributions["list"]["CrateRandomJunk"], magazineType, 0.7)
    insertItem(ProceduralDistributions["list"]["DerelictHouseJunk"], magazineType, 0.9)
    insertItem(ProceduralDistributions["list"]["DerelictHouseSquatter"], magazineType, 1.7)

    ItemPickerJava.Parse()
end)