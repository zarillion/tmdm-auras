local aura_env = aura_env

--[[

rescuers: "<playerlist>"
gaols:
  - LEFT: "<playerlist>"
    RIGHT: "<playerlist>"

  - '{square}': "<playerlist>"
    '{triangle}': "<playerlist>"
    '{diamond}': "<playerlist>"

  - '{cross}': "<playerlist>"
    '{star}': "<playerlist>"
    '{circle}': "<playerlist>"
    '{moon}': "<playerlist>"

]]

aura_env.assignments = {}

local function ParsePlayers(line)
    local players = {}
    for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|r") do
        table.insert(players, name)
    end
    return players
end

aura_env.MRT = function()
    if C_AddOns.IsAddOnLoaded("TMDMEncounterClient") then
        local assignments = TMDM.ParseMRTNote()

        for _, set in ipairs(assignments.gaols) do
            for key, value in pairs(set) do
                set[key] = ParsePlayers(value)
            end
        end

        assignments.rescuers = ParsePlayers(assignments.rescuers)
        aura_env.assignments = assignments
    end
end

aura_env.EmoteMine = function(name, guid)
    if guid:find("Creature-") then return end
    if name and name ~= "" then
        name = WA_ClassColorName(name)
        TMDM.Emit("e=" .. name .. " triggered an Unstable Crawler Mine!", "RAID")
    end
end

---------------------------- GOBLIN-GUIDED ROCKET ----------------------------

local ROCKET_YELLS = {
    "Help me take this rocket to the face!",
    "Here I go blastin' off again!",
    "I will not freeze like a deer!",
    "I definitely know where the markers are!",
    "TIME TO SOAK FRIENDOS! GET OVER HERE!",
}

local ROCKET_POSITIONS = {
    "JUST THE TIP",
    "GO TO {skull}",
    "{cross} BETWEEN GAOLS {star}",
}

local ROCKET_PRIO = {
    581, -- Vengeance Demon Hunter
    268, -- Brewmaster Monk
    73, -- Protection Warrior
    104, -- Guardian Druid
    66, -- Protection Paladin
    250, -- Blood Death Knight
    70, -- Retribution Paladin
    259, -- Assassination Rogue
    260, -- Outlaw Rogue
    261, -- Subtlety Rogue
    255, -- Survival Hunter
    577, -- Havoc Demon Hunter
    253, -- Beast Mastery Hunter
    254, -- Marksmanship Hunter
    62, -- Arcane Mage
    63, -- Fire Mage
    64, -- Frost Mage
    65, -- Holy Paladin
}

aura_env.AssignRocket = function(rocket, name, guid)
    local msg = ROCKET_YELLS[math.random(#ROCKET_YELLS)]
    local pos = ROCKET_POSITIONS[min(3, rocket)]
    TMDM.Emit("m=" .. pos .. ";s=blast;d=7;c=YELL:" .. msg, "WHISPER", name)

    local group = {}
    for unit in TMDM.IterateRaidMembers() do
        if not WA_GetUnitDebuff(unit, 469076) then table.insert(group, UnitGUID(unit)) end
    end
    TMDM.SortPlayersBySpec(group, ROCKET_PRIO)

    local soakers = {}
    for _, player in ipairs(group) do
        if player ~= guid then
            local name = UnitName(TMDM.GUIDs[player])
            table.insert(soakers, name)
        end

        -- assign soakers to first set + target
        if rocket == 1 and #soakers == 5 then break end
    end

    local message = {
        "s=bikehorn;d=7",
        "m=!! |cffff0000SOAK ROCKET|r !!",
        "f=" .. strjoin(",", unpack(soakers)),
    }

    TMDM.Emit(strjoin(";", unpack(message)), "RAID")
end

------------------------------ EARTHSHAKER GOAL ------------------------------

aura_env.gaols = {}

local GAOLS = {
    [1] = {
        shapes = {
            TMDM.Shape({ type = -2, y = -180, scale = 20 }),
            TMDM.Shape({ type = "c", y = 60, r = 0.8, g = 0, b = 0, a = 0.4, scale = 3 }),
        },
        gaols = {
            TMDM.Shape({ type = "c", x = -45, y = 10, a = 0.2, scale = 2.5 }),
            TMDM.Shape({ type = "c", x = 45, y = 10, a = 0.2, scale = 2.5 }),
        },
        texts = {
            TMDM.Text({ text = "L", x = -45, y = 10, size = 30 }),
            TMDM.Text({ text = "R", x = 45, y = 10, size = 30 }),
        },
        positions = { "LEFT", "RIGHT" },
        sounds = { "smc:left", "smc:right" },
    },
    [2] = {
        shapes = {
            TMDM.Shape({ type = -2, x = 90, y = -60, scale = 13, angle = 180 }),
            TMDM.Shape({
                type = "c",
                x = 90,
                y = -37,
                r = 0.8,
                g = 0,
                b = 0,
                a = 0.4,
                scale = 2,
            }),
        },
        markers = {
            TMDM.Shape({ type = "rt8", x = 90, y = -37, scale = 0.75 }),
            TMDM.Shape({ type = "rt6", x = -45, y = 20, scale = 0.75 }),
            TMDM.Shape({ type = "rt4", x = 0, y = 60, scale = 0.75 }),
            TMDM.Shape({ type = "rt3", x = 60, y = 60, scale = 0.75 }),
        },
        gaols = {
            TMDM.Shape({ type = "c", x = -45, y = 20, a = 0.2, scale = 1.6 }),
            TMDM.Shape({ type = "c", x = 0, y = 60, a = 0.2, scale = 1.6 }),
            TMDM.Shape({ type = "c", x = 60, y = 60, a = 0.2, scale = 1.6 }),
        },
        positions = { "{square}", "{triangle}", "{diamond}" },
        sounds = { "smc:06", "smc:04", "smc:03" },
    },
    [3] = {
        shapes = {
            TMDM.Shape({ type = -2, x = 30, y = -90, scale = 13, angle = -90 }),
            TMDM.Shape({
                type = "c",
                x = 6,
                y = -90,
                r = 0.8,
                g = 0,
                b = 0,
                a = 0.4,
                scale = 2,
            }),
        },
        markers = {
            TMDM.Shape({ type = "rt8", x = 6, y = -90, scale = 0.75 }),
            TMDM.Shape({ type = "rt7", x = -65, y = 60, scale = 0.75 }),
            TMDM.Shape({ type = "rt1", x = -10, y = 75, scale = 0.75 }),
            TMDM.Shape({ type = "rt2", x = 40, y = 50, scale = 0.75 }),
            TMDM.Shape({ type = "rt5", x = 80, y = 10, scale = 0.75 }),
        },
        gaols = {
            TMDM.Shape({ type = "c", x = -65, y = 60, a = 0.2, scale = 1.6 }),
            TMDM.Shape({ type = "c", x = -10, y = 75, a = 0.2, scale = 1.6 }),
            TMDM.Shape({ type = "c", x = 40, y = 50, a = 0.2, scale = 1.6 }),
            TMDM.Shape({ type = "c", x = 80, y = 10, a = 0.2, scale = 1.6 }),
        },
        positions = { "{cross}", "{star}", "{circle}", "{moon}" },
        sounds = { "smc:07", "smc:01", "smc:02", "smc:05" },
    },
}

local function NotifyGaol(set, position, names)
    local data = GAOLS[set]
    if not data then return end

    -- colorize our gaol vs. others
    for i, gaol in ipairs(data.gaols) do
        if i == position then
            gaol.r = 0.8
            gaol.g = 0.6
            gaol.b = 0
            gaol.a = 0.8
        else
            gaol.r = 1
            gaol.g = 1
            gaol.b = 1
            gaol.a = 0.2
        end
    end

    local display = TMDM.SerializeDisplay({
        shapes = TMDM.Concat(data.shapes, data.gaols, data.markers or {}),
        texts = data.texts,
    })

    local sound = data.sounds[position]
    local title = data.positions[position]
    local banner = title .. " GAOL"
    if set > 1 then banner = banner .. " " .. title end

    local message = {
        display,
        "d=6",
        "m=" .. banner,
        "f=" .. strjoin(",", unpack(names)),
        "s=" .. sound,
    }

    TMDM.Emit(strjoin(";", unpack(message)), "RAID")
end

aura_env.AssignGaols = function(set, targets)
    if #targets ~= set + 1 then return end -- wait for all targeted

    local assignments = aura_env.assignments.gaols[set]
    local soakers = {}
    local assigned = {}

    -- make copy and count gaols
    for position, names in pairs(assignments) do
        soakers[position] = {}
        soakers[position].gaols = 0
        for _, name in ipairs(names) do
            table.insert(soakers[position], name)
            if TMDM.Contains(targets, UnitGUID(name)) then
                soakers[position].gaols = soakers[position].gaols + 1
                table.insert(assigned, UnitGUID(name))
            end
        end
    end

    -- balance gaols
    for position, names in pairs(soakers) do
        if names.gaols == 0 then
            for _position, _names in pairs(soakers) do
                if position ~= _position and _names.gaols > 1 then
                    for i, name in ipairs(_names) do
                        if i > 1 and TMDM.Contains(targets, UnitGUID(name)) then
                            -- make the swap
                            names[i], _names[i] = _names[i], names[i]
                            names.gaols = names.gaols + 1
                            _names.gaols = _names.gaols - 1
                            break
                        end
                    end
                end
                if names.gaols ~= 0 then break end
            end
        end
    end

    -- assign leftovers
    for _, guid in ipairs(targets) do
        if not TMDM.Contains(assigned, guid) then
            local name = UnitName(TMDM.GUIDs[guid])
            for _, names in pairs(soakers) do
                if names.gaols == 0 then
                    table.insert(names, name)
                    names.gaols = 1
                    break
                end
            end
        end
    end

    -- send notifications
    for i, position in ipairs(GAOLS[set].positions) do
        local names = soakers[position]
        SendChatMessage(position .. ": " .. strjoin(", ", unpack(names)), "RAID")
        NotifyGaol(set, i, names)
    end
end

----------------------------- FROSTSHATTER BOOTS -----------------------------

aura_env.AssignBoots = function(set, targets) end

-- External assignments
-- Rescue assignments

-- table.wipe(TMDM.GUIDs)
-- for unit in TMDM.IterateGroupMembers() do
--     TMDM.GUIDs[UnitGUID(unit)] = unit
-- end

-- aura_env.MRT()
-- aura_env.AssignGaols(
--     3,
--     { UnitGUID("Funnyfatguy"), UnitGUID("Pandice"), UnitGUID("Honduh"), UnitGUID("Zarillion") }
-- )
