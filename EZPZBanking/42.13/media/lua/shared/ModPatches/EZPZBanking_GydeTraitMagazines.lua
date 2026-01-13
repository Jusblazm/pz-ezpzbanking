-- EZPZBanking_GydeTraitMagazines

--[[
    this patch adds a magazine for credit card thief 
    in the same style as Gyde's Trait Magazines
]]

local function addCreditCardThiefMagazine()

    if not getActivatedMods():contains("\\GydeTraitMags") then
        print("[EZPZBanking] General: Gyde Trait Magazines is not installed")
        return
    end

    if not GydeTraitMags or not GydeTraitMags.magazineTraits then
        print("[EZPZBanking] Gyde Trait Magazines detected, but tables not yet available")
        return
    end

    GydeTraitMags.magazineTraits["Base.CreditCardThiefMagazine"] = EZPZBankingTraits.CreditCardThief
    print("[EZPZBanking] General: Gyde Trait Magazines detected, creating a Credit Card Thief Trait Magazine")
end

Events.OnGameBoot.Add(addCreditCardThiefMagazine)