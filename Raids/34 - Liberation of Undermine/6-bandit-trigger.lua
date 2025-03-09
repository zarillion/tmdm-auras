trigger = function(event, ...)
    local aura_env = aura_env
    if event == "ENCOUNTER_START" then
        aura_env.combo = 0
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, srcName, _, _, _, destName, _, _, spellID = ...
        if message == "SPELL_AURA_APPLIED" and spellID == 471927 then -- Withering Flame
            C_ChatInfo.SendAddonMessage("TMDMv1", "c=SAY:FLAME ON!;s=bikehorn", "WHISPER", destName)
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
        end
    end
end
