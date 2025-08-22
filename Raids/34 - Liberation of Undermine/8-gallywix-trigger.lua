trigger = function(event, ...)
    local aura_env = aura_env
    if event == "ENCOUNTER_START" then
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, srcName, _, _, _, destName, _, _, spellID = ...
        if message == "SPELL_AURA_APPLIED" and spellID == 466246 then -- Focused Detonation
            TMDM.Emit("d=15;g=" .. destName .. "::1:0:.2:::3", "RAID")
        end
    end
end
