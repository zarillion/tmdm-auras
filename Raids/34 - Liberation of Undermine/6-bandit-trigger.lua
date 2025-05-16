trigger = function(event, ...)
    local aura_env = aura_env
    if event == "ENCOUNTER_START" then
        aura_env.combo = 0
        table.wipe(aura_env.fixates)
    elseif event == "TMDM_NOTIFY" then
        local sender = ...
        aura_env.NotifyDispel(strsplit("-", sender))
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID = ...
        if message == "SPELL_AURA_APPLIED" and spellID == 471927 then -- Withering Flame
            TMDM.Emit("c=SAY:FLAME ON!;s=tmdmporkchop", "WHISPER", destName)
        elseif message == "SPELL_AURA_APPLIED" and spellID == 460973 then -- Dark Lined Cuirass
            aura_env.MarkReelAssistant(destGUID)
        elseif message == "SPELL_AURA_REMOVED" and spellID == 471927 then -- Withering Flame
            aura_env.ClearDispel(destName)
        elseif message == "SPELL_CAST_SUCCESS" and spellID == 465009 then -- Explosive Gaze
            aura_env.fixates[srcGUID] = destName
        elseif message == "SPELL_CAST_SUCCESS" and spellID == 460674 then -- Pay-Line
            TMDM.Emit("s=smc:coin", "RAID")
        elseif message == "SPELL_CAST_SUCCESS" and spellID == 461060 then -- Spin To Win!
            aura_env.combo = aura_env.combo + 1
            aura_env.DisplayCombo(aura_env.combo)
        elseif message == "SPELL_CAST_START" and srcName == "One-Armed Bandit" then -- Reward casts
            for _, spell in ipairs(aura_env.REWARDS) do
                if spell == spellID then
                    aura_env.StopDisplayCombo()
                    break
                end
            end
        elseif message == "SPELL_INSTAKILL" and srcName:find("Dynamite Booty") then
            aura_env.EmoteExplosiveGaze(srcGUID)
        elseif message == "SPELL_AURA_APPLIED" then
            aura_env.NotifyToken(destName, spellID)
        end
    end
end
