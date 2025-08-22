trigger = function(event, ...)
    local aura_env = aura_env
    if event == "ENCOUNTER_START" then
        aura_env.pylon = 0
        aura_env.wave = 0
        aura_env.MRT()
    elseif event == "CHAT_MSG_RAID_BOSS_WHISPER" then
        local message = ...
        if message:match("1246921") then -- Pylons spawning?
            aura_env.pylon = aura_env.pylon + 1
            aura_env.AssignPylonSoakers(aura_env.pylon)
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, _, _, _, _, destName, _, _, spellID, _, _, _, amount = ...
        if message == "SPELL_AURA_APPLIED" and spellID == 1247045 then -- Hyper Infusion
            if amount == 4 then
                TMDM.Emit("c=SAY:5", "WHISPER", destName)
            elseif amount == 9 then
                TMDM.Emit("c=YELL:10", "WHISPER", destName)
            end
        elseif message == "SPELL_CAST_START" and spellID == 1227226 then -- Writhing Wave
            aura_env.wave = aura_env.wave + 1
            if aura_env.wave % 2 == 1 then
                TMDM.Emit("m=MELEE SOAK", "RAID")
            else
                TMDM.Emit("m=RANGED SOAK", "RAID")
            end
        end
    end
end
