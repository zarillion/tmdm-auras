local aura_env = aura_env

local BACKGROUND = TMDM.Shape({ type = -1, scale = 8 })
local DIAMOND = TMDM.Shape({ type = "rt3", x = 105, y = -70 })
local TRIANGLE = TMDM.Shape({ type = "rt4", x = -105, y = -70 })
local SQUARE = TMDM.Shape({ type = "rt6", x = -105, y = 70 })
local CROSS = TMDM.Shape({ type = "rt7", x = 105, y = 70 })

local WIRE_TRANSFERS = {
    TMDM.Line({ x1 = -35, y1 = 10, x2 = -35, y2 = 128, thickness = 50, r = 0.5, g = 1, b = 1 }),
    TMDM.Line({ x1 = 35, y1 = 10, x2 = 35, y2 = 128, thickness = 50, r = 0.5, g = 1, b = 1 }),
    TMDM.Line({ x1 = -35, y1 = -10, x2 = -35, y2 = -128, thickness = 50, r = 0.5, g = 1, b = 1 }),
    TMDM.Line({ x1 = 35, y1 = -10, x2 = 35, y2 = -128, thickness = 50, r = 0.5, g = 1, b = 1 }),
}

local FOOT_BLASTERS = {
    TMDM.Shape({ type = "c", x = -35, y = 105, r = 1, g = 0, b = 0, a = 0.5 }),
    TMDM.Shape({ type = "c", x = 35, y = 105, r = 1, g = 0, b = 0, a = 0.5 }),
    TMDM.Shape({ type = "c", x = -35, y = 45, r = 1, g = 0, b = 0, a = 0.5 }),
    TMDM.Shape({ type = "c", x = 35, y = 45, r = 1, g = 0, b = 0, a = 0.5 }),
    TMDM.Shape({ type = "c", x = -35, y = -30, r = 1, g = 0, b = 0, a = 0.5 }),
    TMDM.Shape({ type = "c", x = 35, y = -30, r = 1, g = 0, b = 0, a = 0.5 }),
    TMDM.Shape({ type = "c", x = -35, y = -90, r = 1, g = 0, b = 0, a = 0.5 }),
    TMDM.Shape({ type = "c", x = 35, y = -90, r = 1, g = 0, b = 0, a = 0.5 }),
}

local FOOT_BLASTER_NUMS = {
    TMDM.Text({ text = "1", x = -35, y = 105 }),
    TMDM.Text({ text = "2", x = 35, y = 105 }),
    TMDM.Text({ text = "3", x = -35, y = 45 }),
    TMDM.Text({ text = "4", x = 35, y = 45 }),
    TMDM.Text({ text = "5", x = -35, y = -30 }),
    TMDM.Text({ text = "6", x = 35, y = -30 }),
    TMDM.Text({ text = "7", x = -35, y = -90 }),
    TMDM.Text({ text = "8", x = 35, y = -90 }),
}

local FOOT_BLASTER_NAMES = {
    TMDM.Text({ text = "", x = -35, y = 82, size = 14 }),
    TMDM.Text({ text = "", x = 35, y = 82, size = 14 }),
    TMDM.Text({ text = "", x = -35, y = 22, size = 14 }),
    TMDM.Text({ text = "", x = 35, y = 22, size = 14 }),
    TMDM.Text({ text = "", x = -35, y = -53, size = 14 }),
    TMDM.Text({ text = "", x = 35, y = -53, size = 14 }),
    TMDM.Text({ text = "", x = -35, y = -113, size = 14 }),
    TMDM.Text({ text = "", x = 35, y = -113, size = 14 }),
}

--[[

FOOT BLASTER NUMBERS

    ||  1  ||  2  ||
    ||  3  ||  4  ||
    ||============||
    ||  5  ||  6  ||
    ||  7  ||  8  ||

WIRE TRANSFER NUMBERS

    ||  1  ||  2  ||
    ||============||
    ||  3  ||  4  ||

]]

local FOOT_BLASTER_SETS = {
    -- First phase 1
    [1] = {
        mines = {
            { pos = 3, soak = true },
            { pos = 2, soak = true },
            { pos = 4, soak = true },
            { pos = 1, soak = true },
        },
        wires = { 3, 4 },
    },
    [2] = {
        mines = {
            { pos = 5, soak = true },
            { pos = 7, soak = true },
            { pos = 6, soak = true },
            { pos = 8, soak = true },
        },
        wires = { 1, 2 },
    },
    -- Second phase 1
    [3] = {
        mines = {
            { pos = 6, soak = true },
            { pos = 2, soak = true },
            { pos = 4, soak = true },
            { pos = 8, soak = false },
        },
        wires = { 1, 3 },
    },
    [4] = {
        mines = {
            { pos = 5, soak = true },
            { pos = 1, soak = true },
            { pos = 3, soak = true },
            { pos = 7, soak = false },
        },
        wires = { 2, 4 },
    },
    -- Third phase 1
    [5] = {
        mines = {
            { pos = 3, soak = true },
            { pos = 2, soak = true },
            { pos = 4, soak = true },
            { pos = 1, soak = true },
        },
        wires = { 3, 4 },
    },
    [6] = {
        mines = {
            { pos = 1, soak = true },
            { pos = 3, soak = true },
            { pos = 6, soak = true },
            { pos = 8, soak = true },
        },
    },
}

aura_env.soakers = {}

local function Shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

local function AssignFootBlaster(roster)
    for _, unit in ipairs(roster) do
        local name = UnitName(unit)
        local debuffed = WA_GetUnitDebuff(unit, 1218342)
        local assigned = TMDM.Contains(aura_env.soakers, name)
        local isDead = UnitIsDead(unit)
        if not (debuffed or assigned or isDead) then
            table.insert(aura_env.soakers, name)
            return TMDM.Colorize(name, nil, 3)
        end
    end
    table.insert(aura_env.soakers, "")
    return "RIP"
end

function aura_env.AssignFootBlasters(set)
    table.wipe(aura_env.soakers)

    local data = FOOT_BLASTER_SETS[set]
    if not data then return end

    local lines = {}
    local shapes =
        { BACKGROUND:Serialize(), SQUARE:Serialize(), CROSS:Serialize(), DIAMOND:Serialize(), TRIANGLE:Serialize() }
    local texts = {}
    local positions = {}

    local roster = {}
    for unit in WA_IterateGroupMembers() do
        local role = UnitGroupRolesAssigned(unit)
        if role ~= "TANK" then table.insert(roster, unit) end
    end
    roster = Shuffle(roster)

    for i, mine in ipairs(data.mines) do
        local circle = FOOT_BLASTERS[mine.pos]
        local number = FOOT_BLASTER_NUMS[mine.pos]
        number.text = tostring(i)
        table.insert(shapes, circle:Serialize())
        table.insert(texts, number:Serialize())

        if mine.soak then
            local player = FOOT_BLASTER_NAMES[mine.pos]
            player.text = AssignFootBlaster(roster)
            table.insert(texts, player:Serialize())
            table.insert(positions, mine.pos .. "=" .. player.text)
        end
    end

    print("Foot-Blaster: " .. strjoin(" ", unpack(positions)))

    for _, wire in ipairs(data.wires or {}) do
        table.insert(lines, WIRE_TRANSFERS[wire]:Serialize())
    end

    local fields = {
        "d=15",
        "z=" .. strjoin(",", unpack(shapes)),
        "t=" .. strjoin(",", unpack(texts)),
    }

    if #lines > 0 then table.insert(fields, "l=" .. strjoin(",", unpack(lines))) end

    TMDM.Emit(strjoin(";", unpack(fields)), "RAID")

    -- Notify first soaker
    aura_env.NotifyFootBlaster(true)

    -- Notify upcoming soakers with a sound
    local sounds = { "second", "third", "fourth" }
    for i, soaker in ipairs(aura_env.soakers) do
        if soaker ~= "" then
            local sound = "s=smc:" .. sounds[i]
            TMDM.Emit(sound, "WHISPER", soaker)
        end
    end
end

TMDM.TestHeroicFootBlasters = aura_env.AssignFootBlasters

local MINE_MESSAGE = {
    "m=|T4624638:0|t SOAK MINE |T4624638:0|t",
    "c=SAY:Here I go soakin' again!",
}

local SANARC_MESSAGE = {
    "m=|T4624638:0|t SNIFF FOOT-BLASTER |T4624638:0|t",
    "c=YELL:Feet? FEET?!? FEEEEEEEEEET!!!!!",
}

function aura_env.NotifyFootBlaster(first)
    local name = table.remove(aura_env.soakers, 1)
    if name and name ~= "" then
        local message = name == "Sanarc" and SANARC_MESSAGE or MINE_MESSAGE
        local sound = first and "s=smc:first" or "s=smc:pop"
        TMDM.Emit(strjoin(";", sound, unpack(message)), "WHISPER", name)
    end
end

function aura_env.EmoteShrapnel(name)
    TMDM.Emit("e=" .. name .. " triggered a Foot-Blaster!", "RAID")
end

aura_env.screwups = {} -- guids targeted by screw up

function aura_env.NotifyScrewUps()
    local baits = {}
    for unit in WA_IterateGroupMembers() do
        local name = UnitName(unit)
        local guid = UnitGUID(unit)
        local targeted = TMDM.Contains(aura_env.screwups, guid)
        local ranged = TMDM.SPECS.POSITION[TMDM.UnitSpec(unit)] == "RANGED"
        if ranged and not targeted then table.insert(baits, name) end
    end

    if #baits > 0 then
        local message = {
            "f=" .. strjoin(",", unpack(baits)),
            "m3=OOK-OOK BAIT SCREW UP",
            "s=smc:bait",
        }
        TMDM.Emit(strjoin(";", unpack(message)), "RAID")
    end
end
