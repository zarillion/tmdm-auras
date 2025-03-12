trigger = function(event, ...)
    local aura_env = aura_env

    if event == "ENCOUNTER_START" then
        aura_env.MRT()
        aura_env.soaker = 0
        aura_env.set = 0
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, _, _, _, _, destName, _, _, spellID = ...
        if message == "SPELL_CAST_SUCCESS" and spellID == 1217231 then -- Foot-Blasters
            aura_env.soaker = 1
            aura_env.set = aura_env.set + 1
            aura_env.AssignSoaker(aura_env.set, aura_env.soaker)
        elseif message == "SPELL_AURA_APPLIED" and spellID == 1218342 then -- Unstable Shrapnel
            aura_env.EmoteShrapnel(destName)
            aura_env.soaker = aura_env.soaker + 1

            if aura_env.timer then
                aura_env.timer:Cancel()
            end
            aura_env.timer = C_Timer.NewTimer(2, function()
                aura_env.AssignSoaker(aura_env.set, aura_env.soaker)
                aura_env.timer = nil
            end)
        end
    end
end
