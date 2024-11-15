-- MIT License
--
-- Copyright (c) 2024 Swonk
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

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
