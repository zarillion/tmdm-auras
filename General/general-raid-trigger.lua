trigger = function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, sourceGUID, sourceName, _, _, _, destName, _, _, spellID = ...

        -- watch for taunts
        if subevent == "SPELL_CAST_SUCCESS" and strsub(sourceGUID, 1, 6) == "Player" then
            for i = 1, #aura_env.taunts do
                if spellID == aura_env.taunts[i] then
                    aura_env.onTaunt(sourceName, destName)
                    break
                end
            end
        end
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        if prefix == "TMDM_TOOLKIT" then aura_env.Toolkit(message, channel, sender) end
    end

    return false
end
