trigger = function(event, ...)
    local aura_env = aura_env
    local priest = aura_env.config.priest
    local priest2 = aura_env.config.priest2

    local function UnitInRaidInstance(unit)
        local maxgroup = (select(3, GetInstanceInfo()) == 16) and 4 or 6
        for i = 0, 40 do
            local name, _, subgroup = GetRaidRosterInfo(i)
            if unit == name and subgroup <= maxgroup then
                return true
            end
        end
        return false
    end

    local function RequestPI(delay)
        if priest and #priest > 0 and UnitInRaidInstance(priest) then
            C_Timer.After(delay, function()
                SendChatMessage(aura_env.config.priest_msg, "WHISPER", nil, priest)
            end)
        end
    end

    local function RequestPI2(delay)
        if priest2 and #priest2 > 0 and UnitInRaidInstance(priest2) then
            C_Timer.After(delay, function()
                SendChatMessage(aura_env.config.priest_msg2, "WHISPER", nil, priest2)
            end)
        end
    end

    local function CheckAfflictionCast(spellID)
        if spellID == 205180 then -- Summon: Darkglare
            RequestPI(0)
        end
    end

    local function CheckDemonologyCast(spellID)
        if spellID == 111898 then -- Grimoire: Felguard
            RequestPI(aura_env.config.priest_delay)
        elseif spellID == 265187 then -- Summon Demonic Tyrant
            aura_env.tyrant_count = (aura_env.tyrant_count or 0) + 1
            if aura_env.tyrant_count % 2 == 0 then
                RequestPI2(0)
            end
        end
    end

    local function CheckDestructionCast(spellID)
        aura_env.last_havoc_request = aura_env.last_havoc_request or 0

        if spellID == 80240 then -- Havoc
            -- Request PI after Havoc is cast once every 2 minutes
            if aura_env.last_havoc_request == 0 or (GetTime() - aura_env.last_havoc_request) > 120 then
                RequestPI(0)
                aura_env.last_havoc_request = GetTime()
            end
        end
    end

    if event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
        aura_env.last_havoc_request = 0
        aura_env.tyrant_count = 0
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, _, sourceName, _, _, _, _, _, _, spellID = ...
        if sourceName ~= UnitName("player") then
            return
        end -- ignore other's casts

        if subevent == "SPELL_CAST_SUCCESS" then
            local spec = GetSpecialization()
            if spec == 1 then
                CheckAfflictionCast(spellID)
            elseif spec == 2 then
                CheckDemonologyCast(spellID)
            elseif spec == 3 then
                CheckDestructionCast(spellID)
            end
        end
    end
end
