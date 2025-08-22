trigger = function(event, ...)
    local aura_env = aura_env
    if event == "ENCOUNTER_START" then
        aura_env.soak = 0
        aura_env.harvest = 0
        aura_env.MRT()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, _, _, _, _, _, _, _, spellID, _, _, _, amount = ...
        if message == "SPELL_CAST_START" and spellID == 1228216 then -- Arcane Obliteration
            aura_env.soak = aura_env.soak + 1
            if aura_env.soak == 1 then
                TMDM.Emit("m=|cff00ff00MELEE SOAK|r;s=smc:soak;f=r:MELEE", "RAID")
                TMDM.Emit("m=|cffff0000DON'T SOAK|r;s=smc:out;f=r:RANGED", "RAID")
            elseif aura_env.soak == 2 then
                TMDM.Emit("m=|cff00ff00RANGED SOAK|r;s=smc:soak;f=r:RANGED", "RAID")
                TMDM.Emit("m=|cffff0000DON'T SOAK|r;s=smc:out;f=r:MELEE", "RAID")
            else
                TMDM.Emit("m=EVERYONE SOAK;s=smc:soak", "RAID")
            end
        elseif message == "SPELL_CAST_START" and spellID == 1228213 then -- Astral Harvest
            aura_env.harvest = aura_env.harvest + 1
            aura_env.NotifyCCs(aura_env.harvest)
        end
    end
end
