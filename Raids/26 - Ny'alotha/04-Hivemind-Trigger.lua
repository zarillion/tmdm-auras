trigger = function(event, ...)
    if not UnitIsGroupLeader("player") then
        return
    end

    local PREFIX = "TMDM_ECWAv1"
    local aura_env = aura_env

    local function EmitRaid(message, target)
        C_ChatInfo.SendAddonMessage(PREFIX, message, "RAID")
    end

    if event == "ENCOUNTER_START" then
        aura_env.eruptionCount = 0
        aura_env.frenzyCount = 0
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, _, sourceName, _, _, _, _, _, _, spellID, spellName = ...

        if subevent == "SPELL_CAST_SUCCESS" and spellID == 310402 then
            aura_env.frenzyCount = aura_env.frenzyCount + 1
            if aura_env.frenzyCount == 4 then
                EmitRaid("m=|cFF00FF00HEALTHSTONE|r;s=moan")
            end
            if aura_env.frenzyCount == 6 then
                EmitRaid("m=|cFFFF0000PERSONALS|r;s=wilhelmscream")
            end
        end

        if subevent == "SPELL_CAST_START" and spellID == 307582 then
            aura_env.eruptionCount = aura_env.eruptionCount + 1
            if aura_env.eruptionCount < 3 then
                C_Timer.After(15, function()
                    EmitRaid("m=|cFFFF0000PERSONALS|r;s=wilhelmscream")
                end)
            end
        end
    end
end
