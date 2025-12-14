-- EZPZBanking_AccessATMAction
require "TimedActions/ISBaseTimedAction"

EZPZBanking_AccessATMAction = ISBaseTimedAction:derive("EZPZBanking_AccessATMAction")

function EZPZBanking_AccessATMAction:isValid()
    return true
end

function EZPZBanking_AccessATMAction:waitToStart()
    self.character:faceThisObject(self.object)
    return self.character:shouldBeTurning()
end

function EZPZBanking_AccessATMAction:update()
    self.character:faceThisObject(self.object)
end

function EZPZBanking_AccessATMAction:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
end

function EZPZBanking_AccessATMAction:stop()
    ISBaseTimedAction.stop(self)
end

function EZPZBanking_AccessATMAction:perform()
    if #self.cards > 1 then
        EZPZBanking_CardSelectorUI.openSelectorUI(self.character)
    elseif #self.cards == 1 then
        EZPZBanking_ATMUI.openATMUI(self.character, self.cards[1])
    end
    ISBaseTimedAction.perform(self)
end

function EZPZBanking_AccessATMAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    return 30
end

function EZPZBanking_AccessATMAction:new(character, object, cards)
    local o = ISBaseTimedAction.new(self, character)
    setmetatable(o, self)
    self.__index = self

    o.character = character
    o.object = object
    o.cards = cards or {}
    o.maxTime = o:getDuration()

    return o
end