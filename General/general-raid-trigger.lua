function (event, ...)
    if not UnitIsGroupLeader('player') then
        return
    end

    if event == 'TMDM_ECWA_VERSION_CHECK' then
        aura_env.runVersionCheck()
    end

    if event == 'CHAT_MSG_ADDON' then
        local prefix, message, channel, sender = ...

        -- watch for DBM countdowns to check for soulstones
        if prefix == 'D4' and strsub(message, 1, 2) == 'PT' then
            local delim = strsub(message, 3, 3)
            local type, length, _ = string.split(delim, message, 3)
            if tonumber(length) >= 9 then
                aura_env.checkSoulstones()
            end
        end

        if prefix == 'TMDM_ECWAvc' and message ~= 'request' then
            aura_env.recordVersion(sender, message)
        end
    end

    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        local timeStamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, spellName = ...

        -- watch for taunts
        if subevent == 'SPELL_CAST_SUCCESS' and strsub(sourceGUID, 1, 6) == 'Player' then
            for i = 1, #aura_env.taunts do
                if spellID == aura_env.taunts[i] then
                    aura_env.onTaunt(sourceName, destName)
                    break
                end
            end
        end

        -- watch for pet deaths
        if strsub(subevent, -7) == '_DAMAGE' and strsub(destGUID, 1, 3) == 'Pet' then
            local overkill = select(aura_env.overkillParam[subevent], ...)
            if overkill > 0 then
                aura_env.reportPetDeath(destGUID)
            end
        end

        -- count total deaths this pull
        if subevent == 'UNIT_DIED' and strsub(destGUID, 1, 6) == 'Player' then
            aura_env.deathCount = aura_env.deathCount + 1
        end

        -- watch for Totim's deaths and ankhs
        if aura_env.deathCount <= 3 then
            if subevent == 'UNIT_DIED' and destName == 'Totimp' then
                aura_env.onTotimDeath(timeStamp)
            end
            --if subevent == 'SPELL_CAST_SUCCESS' and sourceName == 'Totim' and spellID == 21169 then
            --    aura_env.onTotimAnkh(timeStamp)
            --end
        end
    end

    if event == 'START_TIMER' then
        local timerType, _, totalTime = ...
        if timerType == TIMER_TYPE_PLAYER_COUNTDOWN and totalTime >= 9 then
            aura_env.checkSoulstones()
        end
    end

    if event == 'ENCOUNTER_START' or event == 'ENCOUNTER_END' then
        aura_env.deathCount = 0
    end

    return false
end
