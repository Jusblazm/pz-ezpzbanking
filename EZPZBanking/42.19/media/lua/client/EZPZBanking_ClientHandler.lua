-- EZPZBanking_ClientHandler
Events.OnServerCommand.Add(function(module, command, args)
    if module ~= "EZPZBanking" then return end

    if command == "AccountUpdated" then
        require "EZPZBanking_BankServer"
        local account = EZPZBanking_BankServer.getAccountByID(args.accountID)
        if account then
            account.balance = args.balance
        end
    end

    if command == "AccountDetails" then
        require "EZPZBanking_BankServer"
        local account = EZPZBanking_BankServer.getAccountByID(args.accountID)
        if account then
            account.balance = args.balance
            account.owner = args.owner
            account.pin = args.pin
        end
    end
end)