trigger = function(event, ...)
    local aura_env = aura_env

    if event == "ENCOUNTER_START" then
        table.wipe(aura_env.sorters)
        table.wipe(aura_env.coils)
        aura_env.sortingSet = 0
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, _, _, _, destGUID, destName, _, _, spellID = ...
        if subEvent == "SPELL_CAST_START" and spellID == 464399 then -- Electromagnetic Sorting
            table.wipe(aura_env.coils)
            aura_env.sortingSet = aura_env.sortingSet + 1
        elseif subEvent == "SPELL_AURA_APPLIED" and spellID == 465346 then -- Sorted
            table.insert(aura_env.sorters, destGUID)
            if #aura_env.sorters == 1 then
                C_Timer.After(0.2, function()
                    aura_env.AssignSorters(aura_env.sortingSet)
                end)
            elseif #aura_env.sorters == 4 then
                aura_env.AssignSorters(aura_env.sortingSet)
            end
        elseif subEvent == "SPELL_AURA_APPLIED" and spellID == 1218704 then -- Prototype Powercoil
            table.insert(aura_env.coils, destName)
            if #aura_env.coils == 3 then aura_env.WarnPowercoils() end
        end
    end
end
