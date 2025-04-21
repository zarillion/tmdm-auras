trigger = function(event, ...)
    local aura_env = aura_env

    if event == "ENCOUNTER_START" then
        aura_env.mineSet = 0
        aura_env.first = true
        table.wipe(aura_env.screwups)
        table.wipe(aura_env.polarizations)
        table.wipe(aura_env.swaps)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, _, _, _, destGUID, destName, _, _, spellID = ...
        if message == "SPELL_CAST_START" and spellID == 1217231 then -- Foot-Blasters
            aura_env.mineSet = aura_env.mineSet + 1
            aura_env.UpdatePolarizationGroups()
            aura_env.AssignFootBlasters(aura_env.mineSet)
            aura_env.NotifyFootBlaster()
        elseif message == "SPELL_AURA_APPLIED" and (spellID == 1217357 or spellID == 1217358) then -- Polarization Generator
            aura_env.ApplyPolarization(destName, spellID)
        elseif message == "SPELL_AURA_APPLIED" and (spellID == 1216911 or spellID == 1216934) then -- Polarization
            aura_env.UpdatePolarization(destName, spellID)
        elseif message == "SPELL_AURA_APPLIED" and spellID == 1216509 then -- Screw Up
            table.insert(aura_env.screwups, destGUID)
        elseif message == "SPELL_CAST_SUCCESS" and spellID == 466765 then -- Beta Launch
            table.wipe(aura_env.screwups) -- reset baits
        elseif message == "SPELL_DAMAGE" and spellID == 1216706 then -- Void Barrage
            aura_env.EmoteVoidBarrage(destName)
        elseif message == "SPELL_AURA_APPLIED" and spellID == 1218342 then -- Unstable Shrapnel
            aura_env.EmoteShrapnel(destName)

            if aura_env.timer then aura_env.timer:Cancel() end
            aura_env.timer = C_Timer.NewTimer(2, function()
                aura_env.NotifyFootBlaster()
                aura_env.timer = nil
            end)
        end
    end
end
