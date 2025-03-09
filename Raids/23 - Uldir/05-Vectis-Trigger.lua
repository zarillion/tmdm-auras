trigger = function(event, ...)
    if not UnitIsGroupLeader("player") then
        return
    end

    if event == "ENCOUNTER_START" then
        aura_env.onEncounterStart()
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, _, _, _, sourceRaidFlags, _, destName, _, destRaidFlags, _, spellName = ...
        if subevent == "SPELL_AURA_APPLIED" and spellName == "Omega Vector" then
            aura_env.onVectorApplied(destName, sourceRaidFlags)
        end
        if subevent == "SPELL_AURA_REMOVED" and spellName == "Omega Vector" then
            aura_env.onVectorRemoved(destName, destRaidFlags)
        end
    end
end
