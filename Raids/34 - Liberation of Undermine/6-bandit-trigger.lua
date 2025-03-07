trigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, _, _, _, _, destName, _, _, spellID = ...
        if message == "SPELL_AURA_APPLIED" and spellID == 471927 then -- Withering Flame
            C_ChatInfo.SendAddonMessage("TMDMv1", "m=GET OUT!;s=bikehorn", "WHISPER", destName)
        end
    end
end
