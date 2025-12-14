-- EZPZBanking_API
EZPZBanking_API = {}

--- registers a new ATM sprite
-- @param spriteName (string) The sprite name, e.g. "my_custom_atm_sprite"
-- @param facingDir (number) The facing direction: 0 = North, 1 = East, 2 = South, 3 = West
function EZPZBanking_API.RegisterATM(spriteName, facingDir)
    if not spriteName or type(spriteName) ~= "string" then
        print("[EZPZBanking] Error -> Invalid spriteName passed to RegisterATM")
        return
    end
    if type(facingDir) ~= "number" or facingDir < 0 or facingDir > 3 then
        print("[EZPZBanking] Error -> Invalid facingDir passed to RegisterATM (must be 0=North, 1=East, 2=South, 3=West)")
        return
    end

    -- insert into ATM tables
    MailOrderCatalogs_Utils.validATMSprites[spriteName] = true
    MailOrderCatalogs_Utils.ATMFacingDirections[spriteName] = facingDir
end