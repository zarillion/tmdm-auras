function (event, ...)
    if not UnitIsGroupLeader('player') then return end
    local aura_env = aura_env

    if event == 'ENCOUNTER_START' then
        aura_env.lastUpdate = GetTime()
        aura_env.orbCount = 0
        aura_env.nightCount = 0
        aura_env.voidCount = 0
        aura_env.roles = aura_env.GetRoles()
        aura_env.meleeQ = {}
        aura_env.rangeQ = {}
        aura_env.exposed = {}
    end

    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        local _, subevent, _, _, sourceName, _, _, destGUID, destName, _, _, spellID, spellName = ...

        if subevent == 'SPELL_CAST_SUCCESS' and spellID == 306090 then -- Draw Vita
            aura_env.orbCount = aura_env.orbCount + 1
            aura_env.nightCount = 0
            aura_env.voidCount = 0
        end

        if subevent == 'SPELL_CAST_SUCCESS' and spellID == 306733 then -- Void Empowered
            if UnitInParty(VOID_HEALER) and not aura_env.exposed[aura_env.VOID_HEALER] then
                table.insert(aura_env.meleeQ, 1, aura_env.VOID_HEALER)
            end
            aura_env.OnUnstableVoid(nil)
        end

        if subevent == 'SPELL_AURA_APPLIED' and spellID == 306279 then -- Instability Exposure
            aura_env.exposed[destName] = true
            aura_env.UpdateTeamDisplays()
        end

        if subevent == 'SPELL_AURA_REMOVED' and spellID == 306279 then -- Instability Exposure
            aura_env.exposed[destName] = false
            aura_env.UpdateTeamDisplays()
        end

        if subevent == 'SPELL_AURA_APPLIED' and spellID == 313077 then -- Unstable Nightmare
            aura_env.OnUnstableNightmare(destName)
        end

        if subevent == 'SPELL_AURA_APPLIED' and spellID == 306273 then -- Unstable Vita
            aura_env.OnUnstableVita(destName)
        end

        if strsub(subevent, 1, 6) == 'SPELL_' and spellID == 306634 then -- Unstable Void
            aura_env.exposed[destName] = true
            aura_env.OnUnstableVoid(destName)
        end

        if subevent == 'SPELL_AURA_APPLIED' and spellID == 316065 then -- Corrupted Existence
            aura_env.OnCorruptedExistence(destName)
        end

        if subevent == 'SPELL_CAST_SUCCESS' and spellID == 306733 then -- Void Empowered
            -- No debuff goes out, but the void circles begin to appear
            aura_env.UpdateTeamDisplays()
        end

        if subevent == 'UNIT_DIED' and strsub(destGUID, 1, 6) == 'Player' then
            aura_env.UpdateTeamDisplays()
        end
    end
end
