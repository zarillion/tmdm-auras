function (event, ...)
    if not UnitIsGroupLeader('player') then return end
    local aura_env = aura_env

    if event == 'ENCOUNTER_START' then
        aura_env.earlyBOP = false
        aura_env.decreeTimer = false
        aura_env.burstCount = 0
        aura_env.burstPlayers = {}
        aura_env.lastWardTime = 0
        aura_env.difficulty = select(3, GetInstanceInfo())
        aura_env.setPhase(1)
    end

    if event == 'ENCOUNTER_END' then
        print('ENCOUNTER_END')
        aura_env.lastWardTime = 0
        aura_env.setPhase(0)
        if aura_env.swapTimer then
            aura_env.swapTimer:Cancel()
        end
    end

    -----------------------------------------------------------------------
    ------------------------------- MYTHIC --------------------------------
    -----------------------------------------------------------------------

    if aura_env.difficulty == 16 then
        if event == 'CHAT_MSG_ADDON' then
            local prefix, message, channel, sender = ...
            if prefix == 'Transcriptor' and message:find("299094") then
                if DBM:AntiSpam(4, 'TMDMBeckon:'..sender) then
                    -- A player has been whispered by Azshara for Beckon
                    aura_env.notifyBeckon(sender)
                end
            end
        end

        if event == 'UNIT_SPELLCAST_SUCCEEDED' then
            local _, _, spellID = ...
            if spellID == 302034 then -- hidden cast that starts phase 3
                aura_env.setPhase(3)
                aura_env.markImps()
            end
        end

        if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
            local _, subevent, _, _, _, _, _, _, destName, _, _, spellID, spellName = ...

            if subevent == 'SPELL_CAST_START' and spellName == 'Beckon' then
                aura_env.beckonCast = aura_env.beckonCast + 1
                aura_env.beckonCount = 0
            end

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

            -- as soon as stacks expire in p4, notify to soak again
            if subevent == 'SPELL_AURA_REMOVED' and spellName == 'Drained Soul' then
                if aura_env.phase == 4 and not UnitIsDead(destName) then
                    aura_env.Emit('m1=SOAK WARDS!!;s=hyena', destName)
                end
            end

            if subevent == 'SPELL_AURA_APPLIED' and spellID == 300502 then
                aura_env.setPhase(2) -- starts when Azshara gets Arcane Mastery
                aura_env.markImps()
            elseif subevent == 'SPELL_CAST_START' and spellID == 301431 then
                aura_env.setPhase(4) -- starts with the first Overload cast

                -- notify all people without stacks to soak at the start of p4
                for unit in WA_IterateGroupMembers() do
                    if not WA_GetUnitDebuff(unit, 'Drained Soul') and not UnitIsDead(unit) then
                        aura_env.Emit('m1=SOAK WARDS!!;s=hyena', UnitName(unit))
                    end
                end
            end

            if subevent == 'SPELL_CAST_SUCCESS' and spellName == 'Final Sacrifice' then
                aura_env.EmitRaid('e=Azshara\'s Devoted energizes the Ward of Power.')
            end

            if subevent == 'SPELL_AURA_APPLIED' and spellName == 'Charged Spear' and destName == 'Graggars' then
                local messages = {'Fuck me ...', 'Goddamn it!', 'WHY ME?', 'Not this shit again!'}
                aura_env.Emit('c=YELL '..messages[random(1, #messages)], 'Graggars')
            end

            if subevent == 'SPELL_AURA_APPLIED' and spellName == 'Charged Spear' then
                aura_env.spearCount = aura_env.spearCount + 1
                if aura_env.phase == 3 and aura_env.spearCount == 3 then
                    C_Timer.After(15, function ()
                        aura_env.Emit('m2=WINDRUSH;s=sonar', aura_env.windrush)
                    end)
                    aura_env.swapTimer = C_Timer.NewTimer(19, function ()
                        aura_env.swapTimer = nil
                        aura_env.EmitRaid('m2=SWAP SIDES;s=sonar')
                        C_Timer.After(1, function () aura_env.Emit('m2=|cffff0000SWAP SIDES!|r;s=sonar', 'Nellow') end)
                        C_Timer.After(2, function () aura_env.Emit('m2=|cff00ff00SWAP SIDES!!|r;s=sonar', 'Nellow') end)
                        C_Timer.After(3, function () aura_env.Emit('m2=|cff0000ffSWAP SIDES!!!|r;s=sonar', 'Nellow') end)
                    end)
                end
            end

            -- check for and announce assigned ward soaks every 1 second
            if GetTime() - aura_env.lastWardTime > 1 then
                aura_env.checkWards()
                aura_env.lastWardTime = GetTime()
            end
        end
    end

    -----------------------------------------------------------------------
    ------------------------------- HEROIC --------------------------------
    -----------------------------------------------------------------------

    if aura_env.difficulty == 15 then
        if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
            local _, subevent, _, _, _, _, _, _, _, _, _, spellID = ...

            if subevent == 'SPELL_AURA_APPLIED' and aura_env.debuffs[spellID] then
                if not aura_env.decreeTimer then
                    aura_env.decreeTimer = true
                    C_Timer.After(0.3, function ()
                        aura_env.decreeTimer = false
                        aura_env.assignHeroicDecrees()
                    end)
                end
            end
        end
    end
end
