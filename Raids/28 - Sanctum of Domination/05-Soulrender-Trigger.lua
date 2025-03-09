trigger = function(event, ...)
    if not UnitIsGroupLeader("player") then
        return
    end

    local PREFIX = "TMDM_ECWAv1"
    local aura_env = aura_env

    local function Emit(message, target)
        C_ChatInfo.SendAddonMessage(PREFIX, message, "WHISPER", target)
    end

    local function EmitRaid(message, target)
        C_ChatInfo.SendAddonMessage(PREFIX, message, "RAID")
    end

    local function EmitShackle(wave, shackle)
        if wave < 7 then
            local target = aura_env.shackles[wave][shackle]
            if target then
                local marker = "{rt" .. tostring(aura_env.shackle_markers[shackle]) .. "}"
                Emit("m=" .. marker .. " GRAB CHAIN " .. marker .. ";s=bikehorn", target)
                if shackle == 1 then
                    EmitRaid("m2=|cFFFFFF00!!|r |cFFFF0000DEFENSIVES|r (" .. tostring(wave) .. ") |cFFFFFF00!!|r")
                end
            end
        end
    end

    if event == "ENCOUNTER_START" then
        aura_env.shackles_wave = 0
        aura_env.shackles_count = 1
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, _, _, _, _, _, destName, _, _, spellID = ...

        if subevent == "SPELL_AURA_APPLIED" and spellID == 350415 then -- Warmonger's Shackles
            aura_env.shackles_wave = aura_env.shackles_wave + 1
            aura_env.shackles_count = 1
            EmitShackle(aura_env.shackles_wave, aura_env.shackles_count)
        end

        if subevent == "SPELL_AURA_REMOVED_DOSE" and spellID == 350415 then -- Warmonger's Shackles
            aura_env.shackles_count = aura_env.shackles_count + 1
            EmitShackle(aura_env.shackles_wave, aura_env.shackles_count)
        end
    end
end
