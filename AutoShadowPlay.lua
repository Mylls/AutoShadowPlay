local frame = CreateFrame("Frame")

-- Register for combat log events to detect PvP kills and other PvP events
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:RegisterEvent("BATTLEFIELDS_SHOW")
frame:RegisterEvent("PET_BATTLE_OVER")

frame:SetScript("OnEvent", function(self, event)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, _, _, _, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()

        -- Check for player kills specifically from you (the player)
        if subEvent == "PARTY_KILL" and sourceGUID == UnitGUID("player") then
            -- Check if the killed entity is a player and an enemy
            if destFlags and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
                -- Take a screenshot
                Screenshot()
                print("PvP Kill detected: Screenshot taken for kill on " .. (destName or "unknown"))
            end
        end

        -- Check if the player has died
        if subEvent == "UNIT_DIED" then
            local destGUID = select(8, CombatLogGetCurrentEventInfo())
            if destGUID == UnitGUID("player") then
                Screenshot()
                print("Player died: Screenshot taken.")
            end
        end
    elseif event == "PLAYER_LEAVING_WORLD" then
        -- Take a screenshot after leaving a battleground or arena
        if IsInBattleground() or IsInArena() then
            Screenshot()
            print("Leaving battleground or arena: Screenshot taken.")
        end
    elseif event == "BATTLEFIELDS_SHOW" then
        -- Take a screenshot after capturing an objective in a battleground
        Screenshot()
        print("Objective captured: Screenshot taken.")
    elseif event == "PET_BATTLE_OVER" then
        -- Take a screenshot after a battle pet fight
        Screenshot()
        print("Battle pet fight finished: Screenshot taken.")
    end
end)

-- Utility function to check if the player is in a battleground or arena
function IsInBattleground()
    return select(2, IsInInstance()) == "pvp"
end

function IsInArena()
    return select(2, IsInInstance()) == "arena"
end
