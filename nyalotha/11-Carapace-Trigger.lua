function (event, ...)
    if not UnitIsGroupLeader('player') then return end

    local aura_env = aura_env
    local SAM = C_ChatInfo.SendAddonMessage
    local function Emit (m, t) SAM('TMDM_ECWAv1', m, 'WHISPER', t) end
    local function EmitRaid (m) SAM('TMDM_ECWAv1', m, 'RAID') end
    local function EmitHeals (m)
        for i, n in ipairs(aura_env.healers) do Emit(m, n) end
    end

    if event == 'ENCOUNTER_START' then
        aura_env.healers = {}
        for i = 1, 40 do
            name, _, subgroup, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)
            if name and subgroup < 5 and role == 'HEALER' then
                aura_env.healers[#aura_env.healers + 1] = name
            end
        end
    end

    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        local _, subevent, _, _, sourceName, _, _, _, destName, _, _, spellID, spellName = ...

        -- if subevent == 'SPELL_AURA_APPLIED' and spellID == 306973 then -- Madness Bomb
        --     EmitHeals('g='..destName..';d=12')
        -- end
    end
end
