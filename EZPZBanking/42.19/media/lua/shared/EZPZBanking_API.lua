-- EZPZBanking_API
EZPZBanking_API = {}

--- registers a new ATM sprite
-- @param spriteName (string) The sprite name, e.g., "my_custom_atm_sprite"
-- @param facingDir (number) The facing direction: 0 = North, 1 = East, 2 = South, 3 = West
function EZPZBanking_API.registerATM(spriteName, facingDir)
    if not spriteName or type(spriteName) ~= "string" then
        print("[EZPZBanking] Error: Invalid spriteName passed to registerATM")
        return
    end
    if type(facingDir) ~= "number" or facingDir < 0 or facingDir > 3 then
        print("[EZPZBanking] Error: Invalid facingDir passed to registerATM (must be 0=North, 1=East, 2=South, 3=West)")
        return
    end

    -- insert into ATM tables
    EZPZBanking_Utils.validATMSprites[spriteName] = true
    EZPZBanking_Utils.ATMFacingDirections[spriteName] = facingDir
end

--- deposit money into a player's bank account
-- @param player (IsoPlayer) the player object
-- @param amount (number) amount of money to deposit
function EZPZBanking_API.deposit(player, amount)
    if not player or not player:getModData() then
        print("[EZPZBanking] Error: Invalid player passed to deposit")
        return
    end
    if type(amount) ~= "number" or amount <= 0 then
        print("[EZPZBanking] Error: Invalid amount passed to deposit")
        return
    end

    local card = EZPZBanking_Utils.getPlayerCard(player)
    local accountID

    if card then
        local modData = card:getModData()
        accountID = modData.accountID
    else
        local account = EZPZBanking_BankServer.getAccountByPlayer(player)
        if account then
            accountID = account.accountID
        end
    end

    if not accountID then
        print("[EZPZBanking] Error: No account found for player")
        return
    end

    sendClientCommand("EZPZBanking", "DepositMoney", {
        accountID = accountID,
        amount = amount
    })
end

--- withdraw money from a player's bank account
-- @param player (IsoPlayer) the player object
-- @param amount (number) amount of money to withdraw
function EZPZBanking_API.withdraw(player, amount)
    if not player then
        print("[EZPZBanking] Error: Invalid player passed to withdraw")
        return
    end
    if type(amount) ~= "number" or amount <= 0 then
        print("[EZPZBanking] Error: Invalid amount passed to withdraw")
        return
    end

    local card = EZPZBanking_Utils.getPlayerCard(player)
    local accountID

    if card then
        local modData = card:getModData()
        accountID = modData.accountID
    else
        local account = EZPZBanking_BankServer.getAccountByPlayer(player)
        if account then
            accountID = account.accountID
        end
    end

    if not accountID then
        print("[EZPZBanking] Error: No account found for player")
        return
    end

    sendClientCommand("EZPZBanking", "WithdrawMoney", {
        accountID = accountID,
        amount = amount
    })
end

--- gets the player's PIN
-- @param player (IsoPlayer) the player object
function EZPZBanking_API.getPIN(player)
    local account = EZPZBanking_BankServer.getAccountByPlayer(player)
    return account.pin
end

--- gives money directly to a player's bank account
-- @param player (IsoPlayer) the player object
-- @param amount (number) amount of money to deposit
function EZPZBanking_API.giveMoney(player, amount)
    if not player then
        print("[EZPZBanking] Error: Invalid player passed to giveMoney")
        return
    end
    if type(amount) ~= "number" or amount <= 0 then
        print("[EZPZBanking] Error: Invalid amount passed to giveMoney")
        return
    end

    local account = EZPZBanking_BankServer.getAccountByPlayer(player)
    if not account then return end

    sendClientCommand("EZPZBanking", "GiveAccountPayment", {
        accountID = account.accountID,
        amount = amount
    })
end