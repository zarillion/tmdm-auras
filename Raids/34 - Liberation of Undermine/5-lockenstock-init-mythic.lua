local aura_env = aura_env

local RMOB = TMDM.SPECS.MOBILITY.ROLE
local PMOB = TMDM.SPECS.MOBILITY.POSITION

-- spec orders for different mines
local MELEE_ORDER = TMDM.Concat(RMOB.MELEE, RMOB.RANGED, RMOB.HEALER, RMOB.TANK)
local RANGED_ORDER = TMDM.Concat(RMOB.RANGED, RMOB.MELEE, RMOB.HEALER, RMOB.TANK)
local HEALER_ORDER = TMDM.Concat(RMOB.HEALER, RMOB.RANGED, RMOB.MELEE, RMOB.TANK)
local SPECIAL_ORDER = TMDM.Concat(PMOB.RANGED, RMOB.MELEE, { 270, 65 }, RMOB.TANK)

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
    TMDM.Shape({ type = "c", x = -35, y = 45, r = 0, g = 0, b = 1, a = 0.5 }),
    TMDM.Shape({ type = "c", x = 35, y = 45, r = 0, g = 0, b = 1, a = 0.5 }),
    TMDM.Shape({ type = "c", x = -35, y = -30, r = 0, g = 0, b = 1, a = 0.5 }),
    TMDM.Shape({ type = "c", x = 35, y = -30, r = 0, g = 0, b = 1, a = 0.5 }),
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
            { pos = 3, soak = HEALER_ORDER },
            { pos = 2, soak = HEALER_ORDER },
            { pos = 4, soak = HEALER_ORDER },
            { pos = 1, soak = HEALER_ORDER },
        },
        wires = { 3, 4 },
    },
    [2] = {
        mines = {
            { pos = 5, soak = MELEE_ORDER },
            { pos = 7, soak = MELEE_ORDER },
            { pos = 6, soak = MELEE_ORDER },
            { pos = 8, soak = MELEE_ORDER },
        },
        wires = { 1, 2 },
    },
    [3] = {
        mines = {
            { pos = 5, soak = MELEE_ORDER },
            { pos = 4, soak = RANGED_ORDER },
            { pos = 2, soak = RANGED_ORDER },
            { pos = 7, soak = MELEE_ORDER },
        },
    },
    -- Second phase 1
    [4] = {
        mines = {
            { pos = 6, soak = RANGED_ORDER },
            { pos = 8, soak = RANGED_ORDER },
            { pos = 2, soak = MELEE_ORDER },
            { pos = 4, soak = MELEE_ORDER },
        },
        wires = { 1, 3 },
    },
    [5] = {
        mines = {
            { pos = 1, soak = SPECIAL_ORDER },
            { pos = 3, soak = SPECIAL_ORDER },
            { pos = 6, soak = HEALER_ORDER },
            { pos = 8, soak = HEALER_ORDER },
        },
        wires = { 2, 3 },
    },
    [6] = {
        mines = {
            { pos = 5, soak = MELEE_ORDER },
            { pos = 7, soak = MELEE_ORDER },
            { pos = 6, soak = MELEE_ORDER },
            { pos = 8, soak = MELEE_ORDER },
        },
    },
    -- Third phase 1
    [7] = {
        mines = {
            { pos = 6, soak = SPECIAL_ORDER },
            { pos = 8, soak = SPECIAL_ORDER },
            { pos = 1, soak = HEALER_ORDER },
            { pos = 3, soak = HEALER_ORDER },
        },
        wires = { 2, 3 },
    },
    [8] = {
        mines = {
            { pos = 4, soak = HEALER_ORDER },
            { pos = 6, soak = RANGED_ORDER },
            { pos = 8, soak = RANGED_ORDER },
            { pos = 2, soak = HEALER_ORDER },
        },
        wires = { 1, 3 },
    },
}

aura_env.posi = {}
aura_env.nega = {}
aura_env.soakers = {}

function aura_env.UpdatePolarizationGroups()
    table.wipe(aura_env.posi)
    table.wipe(aura_env.nega)

    for unit in WA_IterateGroupMembers() do
        if WA_GetUnitDebuff(unit, 1216911) then -- Posi-Polarization
            table.insert(aura_env.posi, UnitGUID(unit))
        elseif WA_GetUnitDebuff(unit, 1216934) then -- Nega-Polarization
            table.insert(aura_env.nega, UnitGUID(unit))
        end
    end
end

local function AssignFootBlaster(group, order)
    TMDM.SortPlayersBySpec(group, order)
    for _, guid in ipairs(group) do
        local unit = TMDM.GUIDs[guid]
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
    local shapes = {
        BACKGROUND:Serialize(),
        SQUARE:Serialize(),
        CROSS:Serialize(),
        DIAMOND:Serialize(),
        TRIANGLE:Serialize(),
    }
    local texts = {} -- BACK:Serialize() }
    local positions = {}

    for i, mine in ipairs(data.mines) do
        local circle = FOOT_BLASTERS[mine.pos]
        local number = FOOT_BLASTER_NUMS[mine.pos]
        number.text = tostring(i)
        table.insert(shapes, circle:Serialize())
        table.insert(texts, number:Serialize())

        if mine.soak then
            local player = FOOT_BLASTER_NAMES[mine.pos]
            local group = circle.r == 1 and aura_env.nega or aura_env.posi
            local color = circle.r == 1 and "R" or "B"
            player.text = AssignFootBlaster(group, mine.soak)
            table.insert(texts, player:Serialize())
            table.insert(positions, mine.pos .. color .. "=" .. player.text)
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

    -- Notify upcoming soakers with a sound
    local sounds = { "first", "second", "third", "fourth" }
    for i, soaker in ipairs(aura_env.soakers) do
        if i > 1 and soaker ~= "" then
            local sound = "s=smc:" .. sounds[i]
            TMDM.Emit(sound, "WHISPER", soaker)
        end
    end
end

TMDM.TestAssignFootBlasters = aura_env.AssignFootBlasters

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

function aura_env.EmoteVoidBarrage(name)
    TMDM.Emit("e=" .. name .. " triggered a Voidsplash!", "RAID")
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

aura_env.polarizations = {}
aura_env.swaps = {}
aura_env.swapTimer = nil
aura_env.first = true

function aura_env.ApplyPolarization(name, spell)
    local previous = aura_env.polarizations[name]
    if previous and previous ~= spell then table.insert(aura_env.swaps, name) end
    aura_env.polarizations[name] = spell

    if not aura_env.swapTimer then
        aura_env.swapTimer = C_Timer.NewTimer(0.3, function()
            local targets = strjoin(",", unpack(aura_env.swaps))
            TMDM.Emit("s=tmdmmoveluda;m1=MOVE BITCH;m2=SWAP SIDES NOW;f=" .. targets, "RAID")
            table.wipe(aura_env.swaps)
            aura_env.swapTimer = nil

            if aura_env.first then
                local reds = {}
                local blues = {}
                for name, spell in pairs(aura_env.polarizations) do
                    if name ~= "Vyralea" then
                        if spell == 1217357 then
                            table.insert(blues, name)
                        else
                            table.insert(reds, name)
                        end
                    end
                end
                TMDM.Emit(
                    "m3=|cff545dffGO LEFT|r;s=smc:left;f=" .. strjoin(",", unpack(blues)),
                    "RAID"
                )
                TMDM.Emit(
                    "m3=|cffff5454GO RIGHT|r;s=smc:right;f=" .. strjoin(",", unpack(reds)),
                    "RAID"
                )
            end
            aura_env.first = false
        end)
    end
end

-- helps with dead players that didn't get the generator debuff
function aura_env.UpdatePolarization(name, spell)
    if spell == 1216911 then -- pos
        aura_env.polarizations[name] = 1217357
    else -- neg
        aura_env.polarizations[name] = 1217358
    end
end
