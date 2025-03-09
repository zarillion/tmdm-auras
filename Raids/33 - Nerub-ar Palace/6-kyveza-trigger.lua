trigger = function(event, ...)
    local aura_env = aura_env

    if event == "ENCOUNTER_START" then
        aura_env.count = 0
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID = ...
        if message == "SPELL_CAST_SUCCESS" and spellID == aura_env.ASSASSINATION_CAST then
            aura_env.count = 0
        elseif message == "SPELL_AURA_APPLIED" and spellID == aura_env.ASSASSINATION_DEBUFF then
            aura_env.count = aura_env.count + 1
            local rt = "{rt" .. aura_env.markers[aura_env.count] .. "}"
            aura_env.Emit("d=8;m=" .. rt .. " ASSASSINATION " .. rt, destName)
            SendChatMessage(rt .. ": " .. destName, "RAID")
        end
    end
end
