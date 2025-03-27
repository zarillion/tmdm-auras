local aura_env = aura_env

-- use liquid WAs for junk bar and avoid nameplates

local SPEC_ORDER = { -- left to right
    255, -- Survival Hunter
    577, -- Havoc Demon Hunter
    269, -- Windwalker Monk
    260, -- Outlaw Rogue
    71, -- Arms Warrior
    72, -- Fury Warrior
    259, -- Assassination Rogue
    261, -- Subtlety Rogue
    103, -- Feral Druid
    263, -- Enhancement Shaman
    70, -- Retribution Paladin
    251, -- Frost Death Knight
    252, -- Unholy Death Knight

    253, -- Beast Mastery Hunter
    254, -- Marksmanship Hunter
    265, -- Affliction Warlock
    266, -- Demonology Warlock
    267, -- Destruction Warlock
    62, -- Arcane Mage
    63, -- Fire Mage
    64, -- Frost Mage
    262, -- Elemental Shaman
    258, -- Shadow Priest
    102, -- Balance Druid
    1467, -- Devastation Evoker
    1473, -- Augmentation Evoker

    105, -- Restoration Druid
    1468, -- Preservation Evoker
    256, -- Discipline Priest
    257, -- Holy Priest
    264, -- Restoration Shaman
    65, -- Holy Paladin
    270, -- Mistweaver Monk

    268, -- Brewmaster Monk
    250, -- Blood Death Knight
    581, -- Vengeance Demon Hunter
    66, -- Protection Paladin
    104, -- Guardian Druid
    73, -- Protection Warrior
}

local SORTING_SETS = {
    [1] = { "PURPLE", "GREEN", "RED", "BLUE" },

    [2] = { "PURPLE", "GREEN", "RED", "BLUE" },
    [3] = { "BLUE", "PURPLE", "GREEN", "RED" },
    [4] = { "RED", "BLUE", "PURPLE", "GREEN" },
    [5] = { "GREEN", "RED", "BLUE", "PURPLE" },

    [6] = { "PURPLE", "GREEN", "RED", "BLUE" },
    [7] = { "BLUE", "PURPLE", "GREEN", "RED" },
    [8] = { "RED", "BLUE", "PURPLE", "GREEN" },
    [9] = { "GREEN", "RED", "BLUE", "PURPLE" },
}

-- {circle} == .97, .55, 0
-- {star} == 1, .92, .24
-- {diamond} == .87, .36, .94
-- {square} == 0, .56, 1
-- {triangle} == 0, .81, 0
-- {cross} == 1, .28, .2
-- {moon} == .65, .78, .86

local SORTING_LANES = {
    PURPLE = { mark = "{rt3}", r = 0.87, g = 0.36, b = 0.94 },
    GREEN = { mark = "{rt4}", r = 0, g = 0.81, b = 0 },
    BLUE = { mark = "{rt6}", r = 0, g = 0.56, b = 1 },
    RED = { mark = "{rt7}", r = 1, g = 0.28, b = 0.2 },
}

aura_env.sorters = {}
aura_env.coils = {}

local function Emit(message, target)
    if target then
        C_ChatInfo.SendAddonMessage("TMDMv1", message, "WHISPER", target)
    else
        C_ChatInfo.SendAddonMessage("TMDMv1", message, "RAID")
    end
end

local function AssignSorter(name, pos, set)
    local lane = SORTING_LANES[SORTING_SETS[set][pos]]
    local shapes = {
        TMDM.Shape({ type = "t", x = -75, y = -30, a = 0.4, scale = 1.5, angle = 2.3 }),
        TMDM.Shape({ type = "t", x = -27, y = -58, a = 0.4, scale = 1.5, angle = 2.9 }),
        TMDM.Shape({ type = "t", x = 27, y = -58, a = 0.4, scale = 1.5, angle = -2.9 }),
        TMDM.Shape({ type = "t", x = 75, y = -30, a = 0.4, scale = 1.5, angle = -2.3 }),
        TMDM.Shape({ type = "g", y = 20, scale = 2 }),
    }

    shapes[pos].r = lane.r
    shapes[pos].g = lane.g
    shapes[pos].b = lane.b
    shapes[pos].a = 1

    for i, shape in ipairs(shapes) do
        shapes[i] = shape:Serialize()
    end

    local banner = "m=" .. lane.mark .. lane.mark .. lane.mark
    local diagram = "z=" .. strjoin(",", unpack(shapes))
    local message = strjoin(";", banner, diagram, "d=10")

    Emit(message, name)
end

aura_env.AssignSorters = function(set)
    if #aura_env.sorters == 0 then return end

    TMDM.SortPlayersBySpec(aura_env.sorters, SPEC_ORDER)

    local names = {}
    for i, guid in ipairs(aura_env.sorters) do
        local name = UnitName(TMDM.GUIDs[guid])
        AssignSorter(name, i, set)
        table.insert(names, name)
    end

    SendChatMessage("LANES: " .. strjoin(" ", unpack(names)), "RAID")
    table.wipe(aura_env.sorters)
end

aura_env.WarnPowercoils = function()
    local glows = {
        aura_env.coils[1] .. "::1:0:0:::2",
        aura_env.coils[2] .. "::1:0:0:::2",
        aura_env.coils[3] .. "::1:0:0:::2",
    }
    local players = strjoin(",", unpack(aura_env.coils))

    Emit("f=Zarillion,r:HEALER;d=10;g=" .. strjoin(",", unpack(glows)))
    Emit("m=DEFENSIVES;s=bikehorn;d=10;f=" .. players)
end

TMDM.TestAssignSorter = AssignSorter
