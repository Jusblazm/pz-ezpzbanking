if debugScenarios == nil then
    debugScenarios = {}
end

debugScenarios.JusblazmScenario = {
    name = "Jusblazm's Debug Scenario",
    --	forceLaunch = true, -- use this to force the launch of THIS scenario right after main menu was loaded, save more clicks! Don't do multiple scenarii with this options
    startLoc = {x=8074, y=11734, z=0 }, -- rosewood police station (PC)
    -- startLoc = {x=8176, y=11260, z=0}, -- rosewood gas station (ATM)
    -- startLoc = {x=9997, y=13121, z=0}, -- houses for alarms
    -- startLoc = {x=8093, y=11513, z=0}, -- rosewood bookstore
    setSandbox = function()
        SandboxVars.Speed = 3;
        SandboxVars.Zombies = 6; -- 6 = no zombies, 1 = insane (then 2 = low, 3 normal, 4 high..)
        SandboxVars.Distribution = 1;
        SandboxVars.Survivors = 1;
        SandboxVars.DayLength = 3;
        SandboxVars.StartYear = 1;
        SandboxVars.StartMonth = 7;
        SandboxVars.StartDay = 9;
        SandboxVars.StartTime = 2;
        SandboxVars.VehicleEasyUse = true;
        SandboxVars.WaterShutModifier = 2;
        SandboxVars.ElecShutModifier = 2;
        SandboxVars.WaterShut = 2;
        SandboxVars.ElecShut = 2;
        -- 		SandboxVars.FoodLoot = 2;
        -- 		SandboxVars.WeaponLoot = 2;
        -- 		SandboxVars.OtherLoot = 2;
        SandboxVars.LiteratureLoot = 6;
        SandboxVars.LootItemRemovalList = "";
        SandboxVars.Temperature = 3;
        SandboxVars.Rain = 3;
        SandboxVars.ErosionSpeed = 3;
        SandboxVars.StatsDecrease = 3;
        SandboxVars.NatureAbundance = 3;
        SandboxVars.Alarm = 6;
        SandboxVars.LockedHouses = 6;
        SandboxVars.FoodRotSpeed = 3;
        SandboxVars.FridgeFactor = 3;
        SandboxVars.Farming = 3;
        SandboxVars.LootRespawn = 1;
        SandboxVars.StarterKit = false;
        SandboxVars.Nutrition = true;
        SandboxVars.TimeSinceApo = 1;
        SandboxVars.PlantResilience = 3;
        SandboxVars.PlantAbundance = 3;
        SandboxVars.EndRegen = 3;
        SandboxVars.CarSpawnRate = 5;
        SandboxVars.LockedCar = 3;
        SandboxVars.CarAlarm = 2;
        SandboxVars.ChanceHasGas = 1;
        SandboxVars.InitialGas = 2;
        SandboxVars.CarGeneralCondition = 1;
        SandboxVars.RecentlySurvivorVehicles = 2;
        SandboxVars.VehicleStoryChance = 1;
        SandboxVars.AllowMiniMap = true;
        SandboxVars.MapAllKnown = true;

        SandboxVars.MultiplierConfig = {
            XPMultiplierGlobal = 1,
            XPMultiplierGlobalToggle = true,
        }

        SandboxVars.ZombieLore = {
            Speed = 2,
            Strength = 2,
            Toughness = 2,
            Transmission = 1,
            Mortality = 5,
            Reanimate = 3,
            Cognition = 3,
            Memory = 2,
            Sight = 3,
            Hearing = 3,
            ThumpNoChasing = 0,
        }
    end,
    onStart = function()
        local player = getPlayer()

        local item = player:getInventory():AddItem("Base.CreditCard")
        if item then
            local owner = nil
            local desc = player:getDescriptor()
            if desc then
                owner = desc:getForename() .. " " .. desc:getSurname()
                item:setName("Credit Card: " .. owner)
            end
            local modData = item:getModData()
            modData.owner = owner
            modData.accountID = player:getSteamID() .. "_" .. owner
            modData.last4 = tostring(ZombRand(1000, 9999))
            modData.pin = "11"
            modData.isStolen = false
            modData.attempts = 0
            modData.websiteURL = "knoxbank.com/account"
        end

        local EZPZBanking_BankServer = require("EZPZBanking_BankServer");
        EZPZBanking_BankServer.getOrCreateAccount(player);

        -- local dye = player:getInventory():AddItem("Base.IndustrialDye")

        player:getInventory():AddItems("Base.Money", 200);
        player:getInventory():AddItem("Base.WalkieTalkie5");
        player:getInventory():AddItem("Base.PetrolCan");
        player:getInventory():AddItem("Base.Fork");
        player:getInventory():AddItem("Base.CreditCard");
        player:getInventory():AddItem("Base.BiteMeCostumesAndMoreCatalog1");
        player:getInventory():AddItem("Base.Bag_NormalHikingBag");
        -- player:getInventory():AddItem("RiskyInvestment.PDA");
        player:setUnlimitedCarry(true);
        player:setPerkLevelDebug(Perks.Hacking, 10);

        local clim = getClimateManager();
        local w = clim:getWeatherPeriod();
        if w:isRunning() then
            clim:stopWeatherAndThunder();
        end

        -- remove fog
        local var = clim:getClimateFloat(5);
        var:setEnableOverride(true);
        var:setOverride(0, 1);
    end
}