function (event, ...)
    local aura_env = aura_env

    if event == "ENCOUNTER_START" then
        aura_env.MRT()
        aura_env.counter = 0
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, _, _, _, _, _, _, _, spellID = ...
        if message == "SPELL_CAST_SUCCESS" and spellID == 1217231 then -- Foot-Blasters
            aura_env.AssignSoaker()
            aura_env.counter = 0
        elseif message == "SPELL_AURA_APPLIED" and spellID == 1218342 then -- Unstable Shrapnel
            aura_env.counter = aura_env.counter + 1
            if aura_env.counter < 4 then
                C_Timer.After(2.5, aura_env.AssignSoaker)
            end
        end
    end
end
