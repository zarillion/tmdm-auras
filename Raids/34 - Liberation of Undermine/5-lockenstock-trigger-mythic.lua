trigger = function(event, ...)
    local aura_env = aura_env

    if event == "ENCOUNTER_START" then
        aura_env.mineSet = 0
        table.wipe(aura_env.screwups)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, _, _, _, destGUID, destName, _, _, spellID = ...
        if message == "SPELL_CAST_START" and spellID == 1217231 then -- Foot-Blasters
            aura_env.mineSet = aura_env.mineSet + 1
            aura_env.UpdatePolarizationGroups()
            aura_env.AssignFootBlasters(aura_env.mineSet)
            aura_env.NotifyFootBlaster()
        elseif message == "SPELL_AURA_APPLIED" and spellID == 1218342 then -- Unstable Shrapnel
            aura_env.EmoteShrapnel(destName)

            if aura_env.timer then aura_env.timer:Cancel() end
            aura_env.timer = C_Timer.NewTimer(2, function()
                aura_env.NotifyFootBlaster()
                aura_env.timer = nil
            end)
        elseif message == "SPELL_AURA_APPLIED" and spellID == 1216509 then -- Screw Up
            table.insert(aura_env.screwups, destGUID)
        elseif message == "SPELL_CAST_SUCCESS" and spellID == 466765 then -- Beta Launch
            table.wipe(aura_env.screwups) -- reset baits
        end
    end
end
