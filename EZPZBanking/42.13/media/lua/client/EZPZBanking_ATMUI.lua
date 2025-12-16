-- EZPZBanking_ATMUI
EZPZBanking_ATMUI = {}

local EZPZBanking_BankServer = require("EZPZBanking_BankServer")
local EZPZBanking_Utils = require("EZPZBanking_Utils")
local EZPZBanking_SettingsUI = require("EZPZBanking_SettingsUI")

local ISCollapsableWindow = ISCollapsableWindow

EZPZBanking_ATMUI.ATMWindow = ISCollapsableWindow:derive("ATMWindow")

function EZPZBanking_ATMUI.ATMWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end

function EZPZBanking_ATMUI.ATMWindow:setPlayer(player)
    self.player = player
end

function EZPZBanking_ATMUI.ATMWindow:getPlayer()
    return self.player
end

function EZPZBanking_ATMUI.ATMWindow:setCard(card)
    self.card = card
end

function EZPZBanking_ATMUI.ATMWindow:getCard()
    return self.card
end

function EZPZBanking_ATMUI.ATMWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- PIN entry box
    self.pinEntry = ISTextEntryBox:new("", 10, 30, 100, 25)
    self.pinEntry:initialise()
    self.pinEntry:instantiate()
    self.pinEntry:setOnlyNumbers(true)
    self.pinEntry:setMaxTextLength(2)
    self.pinEntry:setTooltip(getText("Tooltip_EZPZBanking_ATMUI_PinEntry_Normal"))
    self:addChild(self.pinEntry)

    -- submit button
    self.submitButton = ISButton:new(120, 30, 80, 25, getText("UI_EZPZBanking_ATMUI_SubmitButton"), self, function()
        self:onSubmitPIN()
    end)
    self.submitButton:initialise()
    self.submitButton:instantiate()
    self:addChild(self.submitButton)

    -- simple settings button
    if EZPZBanking_Utils.canUseATMSettings() and EZPZBanking_Utils.isCardOwner(self:getPlayer(), self:getCard()) then
        self.settingsButton = ISButton:new(10, 65, 80, 25, getText("UI_EZPZBanking_ATMUI_SettingsButton"), self, function()
            self:onOpenSettings()
        end)
        self.settingsButton:initialise()
        self.settingsButton:instantiate()
        self:addChild(self.settingsButton)
    end

    -- placeholder
    -- self.unlockedLabel = ISLabel:new(10, 70, 20, "Access Granted", 1, 1, 1, 1, UIFont.Medium, true)
    -- self.unlockedLabel:setVisible(false)
    -- self:addChild(self.unlockedLabel)
end

function EZPZBanking_ATMUI.ATMWindow:onSubmitPIN()
    local player = self:getPlayer()
    local enteredPinStr = self.pinEntry:getText()

    if not enteredPinStr or not enteredPinStr:match("^%d%d$") then
        self.pinEntry:setText("")
        self.pinEntry:setTooltip(getText("Tooltip_EZPZBanking_ATMUI_PinEntry_Error"))
        return
    end

    local enteredPin = tonumber(enteredPinStr)

    local card = self:getCard()
    if not card then
        self.pinEntry:setVisible(false)
        self.submitButton:setVisible(false)
        self:addChild(ISLabel:new(10, 70, 20, getText("UI_EZPZBanking_ATMUI_NoCardFound"), 1, 1, 1, 1, UIFont.Medium, true))
        return
    end

    local modData = card:getModData()
    EZPZBanking_Utils.ensureCardHasData(card)

    local actualPinStr = modData.pin
    local actualPin = tonumber(actualPinStr)
    local descriptor = player:getDescriptor()
    local playerFullName = descriptor:getForename() .. " " .. descriptor:getSurname()
    local isOwner = modData.owner == playerFullName
    local pinCorrect = false

    if isOwner then
        if EZPZBanking_Utils.isAutomaticOwnerPINEnabled() then
            pinCorrect = true
        else
            if enteredPinStr == actualPinStr then
                pinCorrect = true
            end
        end
    else
        local hackingLevel = 0
        local pinRange = 0
        if HackingSkill and Perks.Hacking then
            hackingLevel = HackingSkill_API.getLevel(player)
            pinRange = math.floor(hackingLevel * 2)
        end

        if player:hasTrait(EZPZBankingTraits.CreditCardThief) then
            pinRange = pinRange + 5
        end

        if math.abs(enteredPin - actualPin) <= pinRange then
            pinCorrect = true
        end
    end

    if pinCorrect then
        self.pin = true
        self.pinEntry:setVisible(false)
        self.submitButton:setVisible(false)
        if self.settingsButton then
            self.settingsButton:setVisible(false)
        end
        if isOwner then
            modData.attempts = 0
        end
        self:createBankUI()
    else
        modData.attempts = (modData.attempts or 0) + 1
        self.pinEntry:setText("")
        self.pinEntry:setTooltip(getText("Tooltip_EZPZBanking_ATMUI_PinEntry_Incorrect") .. tostring(modData.attempts) .. "/3")

        if HackingSkill and Perks.Hacking then
            HackingSkill_API.addXP(player, 2)
        end

        if modData.attempts >= 3 then
            player:getInventory():Remove(card)
            self.pinEntry:setVisible(false)
            self.submitButton:setVisible(false)
            self:addChild(ISLabel:new(10, 70, 20, getText("UI_EZPZBanking_ATMUI_CardDestroyed"), 1, 0, 0, 1, UIFont.Medium, true))
            print("[EZPZBanking] General: Credit Card destroyed due to 3 failed PIN attempts.")
        end
    end
    if isDebugEnabled() then
        EZPZBanking_BankServer.printAllAccounts()
    end
end

function EZPZBanking_ATMUI.ATMWindow:onOpenSettings()
    local player = self:getPlayer()
    local card = self:getCard()
    if not player or player:isDead() then return end

    self:setVisible(false)
    self:removeFromUIManager()
    EZPZBanking_ATMUI.instance = nil

    EZPZBanking_SettingsUI.openSettingsUI(player, card, true)
end

function EZPZBanking_ATMUI.ATMWindow:createBankUI()
    local x = 10
    local y = 100

    -- bank balance
    self.balanceLabel = ISLabel:new(x, y, 20, getText("UI_EZPZBanking_ATMUI_Balance" .. "0"), 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.balanceLabel)

    -- transaction entry
    self.amountEntry = ISTextEntryBox:new("", x, y + 30, 100, 25)
    self.amountEntry:initialise()
    self.amountEntry:instantiate()
    self.amountEntry:setOnlyNumbers(true)
    self.amountEntry:setTooltip(getText("Tooltip_EZPZBanking_ATMUI_AmountEntry_Normal"))
    self:addChild(self.amountEntry)

    -- deposit button
    self.depositButton = ISButton:new(x + 110, y + 30, 80, 25, getText("UI_EZPZBanking_ATMUI_DepositButton"), self, function()
        self:onDeposit()
    end)
    self.depositButton:initialise()
    self.depositButton:instantiate()
    self:addChild(self.depositButton)

    -- withdraw button
    self.withdrawButton = ISButton:new(x + 200, y + 30, 80, 25, getText("UI_EZPZBanking_ATMUI_WithdrawButton"), self, function()
        self:onWithdraw()
    end)
    self.withdrawButton:initialise()
    self.withdrawButton:instantiate()
    self:addChild(self.withdrawButton)

    self:updateBalanceLabel()
end

function EZPZBanking_ATMUI.ATMWindow:updateBalanceLabel()
    local player = self:getPlayer()
    local card = self:getCard()
    local account = EZPZBanking_BankServer.getAccountByID(card:getModData().accountID)
    local balance = account and tonumber(account.balance or 0) or 0
    local formatBalance = string.format("%.2f", balance)
    self.balanceLabel:setName(getText("UI_EZPZBanking_ATMUI_Balance") .. formatBalance)
end

function EZPZBanking_ATMUI.ATMWindow:delayedBalanceUpdate(delayTicks)
    local ticks = 0
    
    local function onTick()
        ticks = ticks + 1
        if ticks >= delayTicks then
            Events.OnTick.Remove(onTick)
            self:updateBalanceLabel()
        end
    end
    Events.OnTick.Add(onTick)
end

function EZPZBanking_ATMUI.ATMWindow:delayBalanceUpdateUntil(expectedBalance, maxTicks)
    local ticks = 0

    local function onTick()
        tick = ticks + 1

        local card = self:getCard()
        if not card then
            Events.OnTick.Remove(onTick)
            return
        end

        local account = EZPZBanking_BankServer.getAccountByID(card:getModData().accountID)
        if not account then return end

        local serverBalance = tonumber(account.balance or 0)

        if math.abs(serverBalance - expectedBalance) < 0.001 then
            Events.OnTick.Remove(onTick)
            self:updateBalanceLabel()
            return
        end

        if ticks >= maxTicks then
            Events.OnTick.Remove(onTick)
            self:updateBalanceLabel()
        end
    end
    Events.OnTick.Add(onTick)
end

function EZPZBanking_ATMUI.ATMWindow:onDeposit()
    local amount = tonumber(self.amountEntry:getText())
    if not amount or amount <= 0 then return end

    local card = self:getCard()
    if not card then return end

    local modData = card:getModData()
    local account = EZPZBanking_BankServer.getAccountByID(modData.accountID)
    if not account then return end

    local expectedBalance = account.balance + amount

    sendClientCommand("EZPZBanking", "DepositMoney", {
        accountID = modData.accountID,
        amount = amount
    })
    -- self:delayedBalanceUpdate(15)
    self:delayBalanceUpdateUntil(expectedBalance, 120)
end

function EZPZBanking_ATMUI.ATMWindow:onWithdraw()
    local amount = tonumber(self.amountEntry:getText())
    if not amount or amount <= 0 then return end

    local card = self:getCard()
    if not card then return end

    local modData = card:getModData()
    local account = EZPZBanking_BankServer.getAccountByID(modData.accountID)
    if not account then return end

    if account.balance < amount then
        self.amountEntry:setTooltip(getText("Tooltip_EZPZBanking_ATMUI_AmountEntry_Insufficient"))
        return
    end

    local expectedBalance = account.balance - amount

    sendClientCommand("EZPZBanking", "WithdrawMoney", {
        accountID = modData.accountID,
        amount = amount
    })
    -- self:delayedBalanceUpdate(15)
    self:delayBalanceUpdateUntil(expectedBalance, 120)
end

function EZPZBanking_ATMUI.openATMUI(player, card)
    if EZPZBanking_ATMUI.instance and EZPZBanking_ATMUI.instance:isVisible() then
        return
    end

    card = card or EZPZBanking_Utils.getCard(player)
    if not card then
        print("[EZPZBanking] General: No Credit Card found.")

        if panel.pinEntry then panel.pinEntry:setVisible(false) end
        if panel.submitButton then panel.submitButton:setVisible(false) end
        local noCardLabel = ISLabel:new(10, 70, 20, getText("UI_EZPZBanking_ATMUI_NoCardFound"), 1, 1, 1, 1, UIFont.Medium, true)
        panel:addChild(noCardLabel)
        return
    end

    local width = 300
    local height = 200
    local x = getCore():getScreenWidth() / 2 - width / 2
    local y = getCore():getScreenHeight() / 2 - height / 2

    local panel = EZPZBanking_ATMUI.ATMWindow:new(x, y, width, height)
    panel:setPlayer(player)
    panel:setCard(card)
    panel:initialise()
    panel:addToUIManager()
    panel:setVisible(true)
    panel:setResizable(false)
    panel:setTitle(getText("UI_EZPZBanking_ATMUI_ATMTitle"))

    EZPZBanking_ATMUI.instance = panel

    local modData = card:getModData()
    EZPZBanking_Utils.ensureCardHasData(card)
    local account = EZPZBanking_BankServer.getOrCreateAccountByID(modData)

    if isDebugEnabled() then
        print("[EZPZBanking] Debug: Credit Card Owner: " .. tostring(modData.owner))
        print("[EZPZBanking] Debug: Credit Card Account ID: " .. tostring(modData.accountID))
        print("[EZPZBanking] Debug: Credit Card Number: **** **** **** " .. tostring(modData.last4))
        print("[EZPZBanking] Debug: Credit Card PIN: " .. tostring(modData.pin))
        print("[EZPZBanking] Debug: Credit Card Attempts: " .. tostring(modData.attempts) .. "/3")
        local descriptor = player:getDescriptor()
        print("[EZPZBanking] Debug: I own this Credit Card: " .. tostring(modData.owner == descriptor:getForename() .. " " .. descriptor:getSurname()))
        print("[EZPZBanking] Debug: This Credit Card is stolen: " .. tostring(modData.isStolen))
    end
end

return EZPZBanking_ATMUI