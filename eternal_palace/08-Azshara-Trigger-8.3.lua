function (event, ...)
    if not UnitIsGroupLeader('player') then return end
    local aura_env = aura_env

    if event == 'ENCOUNTER_START' then
        aura_env.decreeTimer = false
        aura_env.burstCount = 0
        aura_env.burstPlayers = {}
    end

    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        local _, subevent, _, _, _, _, _, _, destName, _, _, spellID, spellName = ...

        if subevent == 'SPELL_AURA_APPLIED' and aura_env.debuffs[spellID] then
            if not aura_env.decreeTimer then
                aura_env.decreeTimer = true
                C_Timer.After(0.3, function ()
                    aura_env.decreeTimer = false
                    aura_env.assignMythicDecrees()
                end)
                C_Timer.After(20, function ()
                    -- remove assigned marks
                    for unit in WA_IterateGroupMembers() do
                        SetRaidTarget(unit, 0)
                    end
                end)
            end
        end

        if subevent == 'SPELL_AURA_APPLIED' and spellName == 'Arcane Burst' then
            aura_env.burstCount = aura_env.burstCount + 1
            aura_env.assignBurstDispel(destName, aura_env.burstCount)
            if aura_env.burstCount == 1 then
                -- sometimes we screw up and get more than 3, so without
                -- knowing how many we'll get we just have to reset the
                -- count after they've all gone out.
                C_Timer.After(3, function ()
                    aura_env.burstCount = 0
                end)
            end
        end

        if subevent == 'SPELL_AURA_REMOVED' and spellName == 'Arcane Burst' then
            aura_env.burstRemoved(destName)
        end

        if subevent == 'SPELL_CAST_SUCCESS' and spellName == 'Final Sacrifice' then
            aura_env.EmitRaid('e=Azshara\'s Devoted energizes the Ward of Power.')
        end

        if subevent == 'SPELL_AURA_APPLIED' and spellName == 'Charged Spear' and destName == 'Graggars' then
            local messages = {'Fuck me ...', 'Goddamn it!', 'WHY ME?', 'Not this shit again!'}
            aura_env.Emit('c=YELL '..messages[random(1, #messages)], 'Graggars')
        end
    end
end
