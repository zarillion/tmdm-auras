function (event, ...)
    local timeStamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, spellName, _, _, stacks = ...

    if not UnitIsGroupLeader('player') then
        return
    end

    if spellID == 257299 and subevent == 'SPELL_AURA_APPLIED' then
        aura_env.emoteEmberOfRage(destName, 1)
    elseif spellID == 257299 and subevent == 'SPELL_AURA_APPLIED_DOSE' then
        aura_env.emoteEmberOfRage(destName, stacks)
    end

    if select(3, GetInstanceInfo()) == 16 then -- mythic
        if event == 'ENCOUNTER_START' then
            aura_env.soulblightNum = 0
            aura_env.sentenceNum = 0
            aura_env.setDBMOptions()
        end

        if subevent == 'SPELL_AURA_APPLIED' then
            if spellName == 'Gift of the Sky' then aura_env.warnGiftSky(destName) end
            if spellName == 'Gift of the Sea' then aura_env.warnGiftSea(destName) end
            if spellName == 'Soulblight' then aura_env.assignSoulblight(destName) end
            if spellName == 'Sentence of Sargeras' then aura_env.assignSentence(destName) end
            if spellID == 257930 then aura_env.emoteCrushingFear(destName, 1) end
            if spellID == 257911 then aura_env.emoteUnleashedRage(destName, 1) end
        end

        if subevent == 'SPELL_AURA_APPLIED_DOSE' then
            if spellID == 257930 then aura_env.emoteCrushingFear(destName, stacks) end
            if spellID == 257911 then aura_env.emoteUnleashedRage(destName, stacks) end
        end

        if subevent == 'SPELL_AURA_REMOVED' then
            if spellName == 'Soulblight' then aura_env.clearSoulblight(destName) end
        end
    end

    return false
end
