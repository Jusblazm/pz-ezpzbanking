-- EZPZBanking_BankServer
EZPZBanking_BankServer = {}

function EZPZBanking_BankServer.getAccountID(player)
    local steamID = player:getSteamID()
    local characterName = player:getFullName()

    return steamID .. "_" .. characterName
end

function EZPZBanking_BankServer.ensureData()
    local bankData = ModData.get("BankAccounts")
    if not bankData then
        ModData.add("BankAccounts", {accounts = {}})
        bankData = ModData.get("BankAccounts")
    elseif not bankData.accounts then
        bankData.accounts = {}
    end
    return bankData
end

local function saveData()
    local bankData = EZPZBanking_BankServer.ensureData()
    ModData.transmit("BankAccounts")
end

local function loadData()
    local bankData = ModData.get("BankAccounts")
    if bankData and bankData.accounts then
        return bankData
    else
        return EZPZBanking_BankServer.ensureData()
    end
end

function EZPZBanking_BankServer.getOrCreateAccount(player)
    local bankData = EZPZBanking_BankServer.ensureData()
    local id = EZPZBanking_BankServer.getAccountID(player)

    if not bankData.accounts[id] then
        bankData.accounts[id] = {
            accountID = id,
            balance = 0,
            pin = "11",
            owner = player:getFullName(),
            isStolen = false,
            attempts = 0
        }
        ModData.transmit("BankAccounts")
    end
    return bankData.accounts[id]
end

function EZPZBanking_BankServer.getOrCreateAccountByID(modData)
    local bankData = EZPZBanking_BankServer.ensureData()
    local id = modData.accountID
    local owner = modData.owner
    local pin = modData.pin
    local isStolen = modData.isStolen
    local attempts = modData.attempts
    if not bankData.accounts[id] then
        local isFakeCard = id:sub(1, 5) == "FAKE_"
        local startingBalance = isFakeCard and ZombRand(5, 501) or 0

        bankData.accounts[id] = {
            accountID = id,
            balance = startingBalance,
            pin = pin or 11,
            owner = owner or "Unknown",
            isStolen = isStolen or false,
            attempts = attempts or 0
        }
        ModData.transmit("BankAccounts")
    else
        bankData.accounts[id].pin = modData.pin or 11
    end
    return bankData.accounts[id]
end

function EZPZBanking_BankServer.getAccountByID(id)
    local bankData = EZPZBanking_BankServer.ensureData()
    return bankData.accounts[id]
end

function EZPZBanking_BankServer.deposit(id, amount)
    if not amount or amount <= 0 then return false end

    local account = EZPZBanking_BankServer.getAccountByID(id)
    if not account then return false end

    account.balance = account.balance + amount
    ModData.transmit("BankAccounts")
    return true
end

function EZPZBanking_BankServer.withdraw(id, amount)
    if not amount or amount <= 0 then return false end

    local account = EZPZBanking_BankServer.getAccountByID(id)
    if not account then return false end
    if account.balance < amount then return false end

    account.balance = account.balance - amount
    ModData.transmit("BankAccounts")
    return true
end

function EZPZBanking_BankServer.getBalance(modData)
    local account = EZPZBanking_BankServer.getOrCreateAccountByID(modData)
    return account.balance or 0
end

function EZPZBanking_BankServer.setBalance(modData, newBalance)
    local account = EZPZBanking_BankServer.getOrCreateAccountByID(modData)
    account.balance = newBalance
    ModData.transmit("BankAccounts")
    return true
end

function EZPZBanking_BankServer.getPIN(modData)
    local account = EZPZBanking_BankServer.getOrCreateAccountByID(modData)
    return account.pin or "Unknown"
end

function EZPZBanking_BankServer.setPIN(modData, newPin)
    local account = EZPZBanking_BankServer.getOrCreateAccountByID(modData)
    account.pin = newPin
    ModData.transmit("BankAccounts")
end

function EZPZBanking_BankServer.printAllAccounts()
    local bankData = EZPZBanking_BankServer.ensureData()
    print("=== All Bank Accounts ===")
    for id, account in pairs(bankData.accounts) do
        print("Account ID: ", id)
        print("Owner: ", account.owner)
        print("Balance: $", account.balance)
        print("PIN: ", account.pin)
        print("---------------------------")
    end
end

Events.EveryHours.Add(saveData)
Events.OnInitGlobalModData.Add(loadData)

return EZPZBanking_BankServer