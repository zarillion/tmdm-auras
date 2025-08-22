trigger = function(event, ...)
    local aura_env = aura_env
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID = ...
        if message == "SPELL_AURA_APPLIED" and spellID == 1241303 then -- Arcanoshield
            TMDM.Emit("b=boss1:3", "RAID")
        elseif message == "SPELL_AURA_REMOVED" and spellID == 1241303 then -- Arcanoshield
            TMDM.Emit("b=", "RAID")
        end
    end
end
