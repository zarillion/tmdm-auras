trigger = function(event, ...)
    local aura_env = aura_env

    if event == "ENCOUNTER_START" then
        aura_env.mark = 0
        table.wipe(aura_env.amps)
        aura_env.SortRoster()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, _, _, _, destGUID, _, _, _, spellID = ...
        if message == "SPELL_AURA_REMOVED" and spellID == 1214829 then -- Feedback Nullifier
            aura_env.MarkAmplifier(destGUID)
        end
    elseif event == "UNIT_HEALTH" then
        local unit = ...
        if unit == "boss1" then return end
        local name = UnitName(unit)
        local mark = GetRaidTargetIndex(unit)
        if name == "Amplifier" and mark then aura_env.CheckAmplifier(unit, mark) end
    end
end
