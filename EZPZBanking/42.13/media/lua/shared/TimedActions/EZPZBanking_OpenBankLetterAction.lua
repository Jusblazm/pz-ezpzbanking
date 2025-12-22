-- EZPZBanking_OpenBankLetterAction
require "TimedActions/ISBaseTimedAction"

EZPZBanking_OpenBankLetterAction = ISBaseTimedAction:derive("EZPZBanking_OpenBankLetterAction")

function EZPZBanking_OpenBankLetterAction:isValid()
    return self.item and self.character:getInventory():contains(self.item)
end

function EZPZBanking_OpenBankLetterAction:perform()
    ISBaseTimedAction.perform(self)
end

function EZPZBanking_OpenBankLetterAction:complete()

    local inv = self.character:getInventory()

    local creditCard = instanceItem("Base.CreditCard")

    inv:Remove(self.item)
    sendRemoveItemFromContainer(inv, self.item)

    inv:AddItem(creditCard)
    sendAddItemToContainer(inv, creditCard)
end

function EZPZBanking_OpenBankLetterAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    return 50
end

function EZPZBanking_OpenBankLetterAction:new(character, item)
    local o = ISBaseTimedAction.new(self, character)
    o.character = character
    o.item = item
    o.maxTime = o:getDuration()
    return o
end