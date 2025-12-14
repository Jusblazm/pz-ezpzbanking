-- EZPZBanking_ContextMenu
-- local EZPZBanking_ATMUI = require("EZPZBanking_ATMUI")
-- local EZPZBanking_CardSelectorUI = require("EZPZBanking_CardSelectorUI")
local EZPZBanking_Utils = require("EZPZBanking_Utils")

local function onFillWorldObjectContextMenu(playerIndex, context, worldObjects, test)
    local player = getSpecificPlayer(playerIndex)

    for _, obj in ipairs(worldObjects) do
        local sprite = obj:getSprite()
        if sprite then
            local spriteName = sprite:getName()

            -- handle ATM logic
            if spriteName and EZPZBanking_Utils.isValidATMSprite(spriteName) then
                if EZPZBanking_Utils.isATMPowered(obj) then
                    local cards = EZPZBanking_Utils.getAllCreditCards(player)
                    if #cards > 0 then
                        context:addOption(getText("ContextMenu_EZPZBanking_ATM_UseATM"), obj, function()
                            local frontSquare = EZPZBanking_Utils.getFrontSquareOfATM(obj)

                            if frontSquare and frontSquare:isFree(false) then
                                ISTimedActionQueue.add(ISWalkToTimedAction:new(player, frontSquare))
                                ISTimedActionQueue.add(EZPZBanking_AccessATMAction:new(player, obj, cards))
                            else
                                local square = obj:getSquare()
                                local fallback = AdjacentFreeTileFinder.Find(square, player)
                                if fallback then
                                    ISTimedActionQueue.add(ISWalkToTimedAction:new(player, fallback))
                                    ISTimedActionQueue.add(EZPZBanking_AccessATMAction:new(player, obj, cards))
                                else
                                    player:Say(getText("IGUI_EZPZBanking_PlayerText_CantReachATM"))
                                end
                            end
                        end)
                    end
                    break
                end
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)