--[[

SO YOU REMEMBER ZAR. The combat log in game will only include the -realm for player
names if they are not on the same server as you. The Blizzard functions work with
the names in the in-game combat log as-is.

]]

-------------------------------------------------------------------------------

local function Emit(message, target)
    C_ChatInfo.SendAddonMessage("TMDM_ECWAv1", message, "WHISPER", target)
end

local function EmitRaid(message)
    C_ChatInfo.SendAddonMessage("TMDM_ECWAv1", message, "RAID")
end

-------------------------------------------------------------------------------

-- See also WA_ClassColorName(unit)
local function Colorize(unit)
    local _, classFN = UnitClass(unit)
    local color = RAID_CLASS_COLORS[classFN].colorStr
    return string.format("|c%s%s|r", color, string.upper(unit))
end

-- Return true if the table `t` contains value `v`
local function Contains(t, v)
    for i, _v in ipairs(t) do
        if v == _v then
            return true
        end
    end
    return false
end

-- Return a new table of values transformed by `fn`
local function Map(t, fn)
    local _t = {}
    for i, v in ipairs(t) do
        _t[#_t + 1] = fn(v)
    end
    return _t
end

-------------------------------------------------------------------------------

--[[
Iterate over the group (a better WA_IterateGroupMembers; requires Details!).
Excludes dead members and members in unused subgroups.

Return:
    name,
    class (DEATHKNIGHT, WARRIOR, ...),
    role (TANK, HEALER, DAMAGER),
    spec (integer),
    position (MELEE, RANGED),
    subgroup (1 => maxSubGroup)
]]
local function IterateActiveGroup(includeDead, maxSubGroup)
    maxSubGroup = maxSubGroup or 4
    local i = 0
    local function SpecPosition(spec)
        for _, id in ipairs({ 62, 63, 64, 102, 105, 253, 254, 256, 257, 258, 262, 264, 265, 266, 267 }) do
            if spec == id then
                return "RANGED"
            end
        end
        return "MELEE"
    end
    return function()
        while i < 40 do
            i = i + 1
            local name, _, subgroup, _, _, class, _, online, isDead, _, _, role = GetRaidRosterInfo(i)
            if subgroup <= maxSubGroup and online and (not isDead or includeDead) then
                local spec = Details.cached_specs[UnitGUID("raid" .. i)]
                local position = spec and SpecPosition(spec) or nil
                return name, class, role, spec, position, subgroup
            end
        end
    end
end

-------------------------------------------------------------------------------

-- Return uppercase class name (DEATHKNIGHT, WARRIOR, WARLOCK, etc)
local function UnitClassName(unit)
    return select(2, UnitClass(unit))
end

-- Return health of the unit as a value from 0 to 100
local function UnitPercent(unit)
    local cur = UnitHealth(unit)
    local max = UnitHealthMax(unit)
    if cur > 0 and max > 0 then
        return (cur / max) * 100
    end
    return 100
end

-- Return 'TANK', 'HEALER' or 'DAMAGER'
local function UnitRole(unit)
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)
        if name == unit then
            return role
        end
    end
end

-- Returns specialization number (requires Details!)
-- https://wowpedia.fandom.com/wiki/SpecializationID
local function UnitSpecID(unit)
    return Details.cached_specs[UnitGUID(unit)]
end

-- Return subgroup of the raid as 1 => 8
local function UnitSubgroup(unit)
    for i = 0, 40 do
        local name, _, subgroup = GetRaidRosterInfo(i)
        if unit == name then
            return subgroup
        end
    end
end

-- Return true if the unit is in the raid instance
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
