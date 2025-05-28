trigger = function(event, ...)
    local aura_env = aura_env
    if event == "ENCOUNTER_START" then
        aura_env.MRT()
        aura_env.boot = 0
        aura_env.boots = {}
        aura_env.rocket = 0
        aura_env.gaol = 1
        aura_env.gaols = {}
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, _, _, _, destGUID, destName, _, _, spellID = ...
        if message == "SPELL_AURA_APPLIED" and spellID == 472061 then -- Unstable Crawler Mines
            -- aura_env.EmoteMine(destName, destGUID)
        elseif message == "SPELL_AURA_APPLIED" and spellID == 466509 then -- Finger Gun
            aura_env.GlowFingerGun(destName)
        elseif message == "SPELL_AURA_APPLIED" and spellID == 466545 then -- Spray and Pray
            aura_env.GlowSpray(destName)
        elseif message == "SPELL_AURA_APPLIED" and spellID == 466476 then -- Frostshatter Boots
            table.insert(aura_env.boots, destGUID)
            aura_env.AssignBoots(aura_env.boot, aura_env.boots)
        elseif message == "SPELL_AURA_APPLIED" and spellID == 472631 then -- Earthshaker Gaol
            table.insert(aura_env.gaols, destGUID)
            aura_env.AssignGaols(aura_env.gaol, aura_env.gaols)
        elseif message == "SPELL_CAST_START" and spellID == 466470 then -- Frostshatter Boots
            table.wipe(aura_env.boots)
            aura_env.boot = aura_env.boot + 1
        elseif message == "SPELL_CAST_SUCCESS" and spellID == 474461 then -- Earthshaker Gaol
            aura_env.gaol = aura_env.gaol + 1
            table.wipe(aura_env.gaols)
        elseif message == "SPELL_AURA_APPLIED" and spellID == 467380 then -- Goblin-guided Rocket
            aura_env.rocket = aura_env.rocket + 1
            aura_env.AssignRocket(aura_env.rocket, destName, destGUID)
        elseif message == "SPELL_DAMAGE" and spellID == 469061 then -- Unstable Crawler Mines
            aura_env.EmoteMine(destName, destGUID)
        end
    end
end
