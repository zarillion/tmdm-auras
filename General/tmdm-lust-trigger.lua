trigger = function(event, ...)
    local aura_env = aura_env

    if event == "ENCOUNTER_START" then
        aura_env.fired = false
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, srcName, _, _, _, _, _, _, spellID = ...
        if subEvent == "SPELL_CAST_SUCCESS" and TMDM.Contains(aura_env.LUSTS, spellID) then
            aura_env.ApesTogetherStrong(srcName)
        end
    end
end
