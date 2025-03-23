trigger = function(event, ...)
    local aura_env = aura_env
    if event == "ENCOUNTER_START" then
        aura_env.MRT()
        aura_env.rocket = 0
        aura_env.mineSet = 0
        aura_env.mineSoaker = 0
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, _, _, _, _, destName, _, _, spellID = ...
        if message == "SPELL_AURA_APPLIED" and spellID == 472061 then -- Unstable Crawler Mines
            aura_env.EmoteMine(destName)
        elseif message == "SPELL_AURA_APPLIED" and spellID == 467380 then -- Goblin-guided Rocket
            aura_env.rocket = aura_env.rocket + 1
            aura_env.AssignRocket(aura_env.rocket, destName)
        elseif message == "SPELL_CAST_SUCCESS" and spellID == 472458 then -- Unstable Crawler Mines
            aura_env.mineSet = aura_env.mineSet + 1
            aura_env.mineSoaker = 1
            aura_env.AssignSoaker(aura_env.mineSet, aura_env.mineSoaker, 0)
        elseif message == "UNIT_DIED" and destName == "Unstable Crawler Mine" then
            aura_env.mineSoaker = aura_env.mineSoaker + 1
            aura_env.AssignSoaker(aura_env.mineSet, aura_env.mineSoaker, 3)
        end
    end
end
