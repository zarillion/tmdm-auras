aura_env.lastYellTime = 0
aura_env.reportNextWormhole = false
aura_env.phase = 1
aura_env.gigaCount = 1
aura_env.gigaSet = 0

-- icon -> phase -> set
aura_env.GIGA_LOCATIONS = {
    [1] = {
        [1] = { "BACK CORNER", "MID LEFT", "MID RIGHT", "STAIR LEFT", "STAIR RIGHT" },
        [2] = { "PILLAR LEFT", "BACK CORNER", "MID LEFT", "MID RIGHT", "STAIR LEFT", "STAIR RIGHT", "BACK CORNER" },
    },
    [2] = {
        [1] = { "BACK CORNER", "PILLAR RIGHT", "NEXT TO CORNER", "PILLAR LEFT", "BACK CORNER" },
        [2] = {
            "RUBBLE LEFT",
            "RUBBLE RIGHT",
            "NEXT TO CORNER",
            "PILLAR RIGHT",
            "PILLAR LEFT",
            "BACK CORNER",
            "RUBBLE LEFT",
        },
    },
    [3] = {
        [1] = { "BACK CORNER", "PILLAR LEFT", "NEXT TO CORNER", "PILLAR RIGHT", "BACK CORNER" },
        [2] = {
            "RUBBLE RIGHT",
            "RUBBLE LEFT",
            "NEXT TO CORNER",
            "PILLAR LEFT",
            "PILLAR RIGHT",
            "BACK CORNER",
            "RUBBLE RIGHT",
        },
    },
}

local DBM_OPTIONS = {
    Yell284168 = false, -- shrunk
    Yell284168shortyell = false, -- shrunk
    Yell286105 = false, -- tampering
    Yell287114 = false, -- miscalculated teleport
    Yell289023 = false, -- enormous
}

aura_env.setDBMOptions = function()
    for option, value in pairs(DBM_OPTIONS) do
        C_ChatInfo.SendAddonMessage("TMDM_ECWAv1", "bm=2276:" .. option .. "=" .. tostring(value), "RAID")
    end
end

--------------------------------------------------------------------------------

trigger = function(event, ...)
    if not UnitIsGroupLeader("player") then
        return
    end

    local Emit = C_ChatInfo.SendAddonMessage
    local PREFIX = "TMDM_ECWAv1"
    local aura_env = aura_env

    if event == "ENCOUNTER_START" then
        aura_env.reportNextWormhole = false
        aura_env.phase = 1
        aura_env.gigaCount = 1
        aura_env.gigaSet = 0
        aura_env.setDBMOptions()
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, _, sourceName, _, sourceRaidFlags, _, destName, _, _, _, spellName = ...
        if subevent == "SPELL_CAST_START" and spellName == "Evasive Maneuvers!" then
            aura_env.reportNextWormhole = true
            aura_env.phase = 2
            aura_env.gigaSet = 0
        end

        if subevent == "SPELL_CAST_START" and spellName == "World Enlarger" then
            for i = 1, 30 do
                local name = UnitName("raid" .. i)
                if name ~= nil then
                    if not AuraUtil.FindAuraByName("Gigavolt Charge", "raid" .. i, "HARMFUL") then
                        Emit(PREFIX, "m=STAND STILL!;d=3;s=boxingarenagong", "WHISPER", name)
                    end
                end
            end
        end

        if subevent == "SPELL_CAST_START" and spellName == "Wormhole Generator" and aura_env.reportNextWormhole then
            for i = 1, 30 do
                local name = UnitName("raid" .. i)
                if name ~= nil then
                    if not AuraUtil.FindAuraByName("Gigavolt Charge", "raid" .. i, "HARMFUL") then
                        if AuraUtil.FindAuraByName("Shrunk", "raid" .. i, "HARMFUL") then
                            Emit(PREFIX, "s=bikehorn;m=|cffff0000GET OUT!|r;d=5", "WHISPER", name)
                        else
                            Emit(PREFIX, "s=bikehorn;m=|cffff0000STAND STILL!|r;d=5", "WHISPER", name)
                        end
                    end
                end
            end
            aura_env.reportNextWormhole = false
        end

        if subevent == "SPELL_AURA_APPLIED" and spellName == "Gigavolt Charge" then
            if aura_env.gigaCount == 1 then
                aura_env.gigaSet = aura_env.gigaSet + 1
                C_Timer.After(3, function()
                    aura_env.gigaCount = 1
                end)
            end
            local location = aura_env.GIGA_LOCATIONS[aura_env.gigaCount][aura_env.phase][aura_env.gigaSet]
            local marker = "{rt" .. aura_env.gigaCount .. "}"
            if aura_env.gigaCount == 1 then
                Emit(PREFIX, "m=" .. marker .. " " .. location .. " " .. marker .. ";d=15", "WHISPER", "Zarillion")
            end
            aura_env.gigaCount = aura_env.gigaCount + 1
        end
    end

    if GetTime() - aura_env.lastYellTime > 2 then
        -- check for people in bots and shrunk people
        for i = 1, 30 do
            local name = UnitName("raid" .. i)
            if name ~= nil then
                if AuraUtil.FindAuraByName("Tampering!", "raid" .. i, "HARMFUL") then
                    Emit(PREFIX, "c=YELL " .. name, "WHISPER", name)
                elseif AuraUtil.FindAuraByName("Shrunk", "raid" .. i, "HARMFUL") then
                    Emit(PREFIX, "c=SAY s", "WHISPER", name)
                end
            end
        end
        aura_env.lastYellTime = GetTime()
    end
end
