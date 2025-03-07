local Emit = C_ChatInfo.SendAddonMessage
local PREFIX = "TMDM_ECWAv1"
local VECTORS = {} -- all vector instances
local ONPLAYER = {} -- vectors currently on players

local GROUPS = {
    "{diamond} SW {diamond}",
    "{cross} SE {cross}",
    "{square} NW {square}",
    "{triangle} NE {triangle}",
}

local function Colorize(name, upper)
    local _, classFN = UnitClass(name)
    local color = RAID_CLASS_COLORS[classFN].colorStr
    if upper then
        name = string.upper(name)
    end
    return string.format("|c%s%s|r", color, name)
end

local function GetRaidSubgroup(name)
    for i = 0, 40 do
        local _name, _, subgroup = GetRaidRosterInfo(i)
        if name == _name then
            return subgroup
        end
    end
    return -1
end

local function GetVectorByFlags(flags)
    -- Find the vector instance this player received. The source args are
    -- all empty except the raid flags, which are set to the flags of the
    -- last vector owner! (i.e. we can match on last-raid-marker)
    flags = bit.band(flags, COMBATLOG_OBJECT_RAIDTARGET_MASK)
    for i, vector in ipairs(VECTORS) do
        if not vector["active"] and vector["flags"] == flags then
            return vector
        end
    end
    print("vector with matching flags not found!!!!!")
end

local function GetVectorTarget(i)
    local name, _, subgroup, _, _, _, _, online, dead, _, _, role = GetRaidRosterInfo(i)
    if name == nil or subgroup > 4 or not online or dead or role == "TANK" then
        return
    end

    for i, vector in ipairs(VECTORS) do
        if name == vector["name"] or name == vector["next"] then
            return
        end
    end

    local stacks = select(3, AuraUtil.FindAuraByName("Lingering Infection", "raid" .. i, "HARMFUL"))
    return { name = name, group = subgroup, stacks = stacks or 0 }
end

local function AssignVectorNext(vector)
    local targets = {} -- potential targets
    local group = vector["group"]

    -- Get a table of all possible recipients, excluding people who
    -- are in group 5+, offline, dead, tank or already have a vector
    for i = 1, 40 do
        local target = GetVectorTarget(i)
        if target then
            targets[#targets + 1] = target
        end
    end

    if #targets == 0 then
        return -- out of players to pass to, sounds like a wipe inc!!
    end

    -- Sort all targets, prioritizing people in the same group as
    -- the vector with the fewest stacks of infection.
    table.sort(targets, function(a, b)
        if a["group"] ~= b["group"] then
            if a["group"] == group then
                return true
            end
            if b["group"] == group then
                return false
            end
            return a["group"] < b["group"]
        end
        if a["stacks"] ~= b["stacks"] then
            return a["stacks"] < b["stacks"]
        end
        return a["name"] < b["name"]
    end)

    -- Next victim found! Sucks to be them!
    vector["next"] = targets[1]["name"]

    -- Send out notifications
    --local mark = '{rt'..GetRaidTargetIndex(vector['name'])..'}'
    local curr = Colorize(vector["name"], true)
    local next = Colorize(vector["next"], true)
    Emit(PREFIX, "m=PASS TO " .. next .. ";d=10", "WHISPER", vector["name"])
    Emit(PREFIX, "m=GET FROM " .. curr .. ";d=10;s=bikehorn", "WHISPER", vector["next"])
end

local function AssignVectorGroups()
    local assigned = {} -- group# = true/false

    -- figure out which groups already have a mark, and unassign duplicates
    for i, vector in ipairs(VECTORS) do
        if assigned[vector["group"]] then
            vector["group"] = nil
        else
            assigned[vector["group"]] = true
        end
    end

    -- assign missing groups to unassigned vectors
    for i, vector in ipairs(VECTORS) do
        if vector["group"] then
            -- tell vector to stay where they are
            local message = "m=KEEP AT " .. GROUPS[vector["group"]] .. ";d=10"
            Emit(PREFIX, message, "WHISPER", vector["name"])
        else
            for i = 1, 4 do
                if not assigned[i] then
                    vector["group"] = i
                    assigned[i] = true
                    break
                end
            end

            -- tell vector where to take their debuff
            local message = "m=TAKE TO " .. GROUPS[vector["group"]] .. ";d=10"
            Emit(PREFIX, message, "WHISPER", vector["name"])
        end
    end
end

aura_env.onVectorApplied = function(name, flags)
    if #VECTORS < 4 then
        -- initialize vector instance, mark it as on a player and even out
        -- the group assignments if this is the 4th (and last) one
        VECTORS[#VECTORS + 1] = {
            name = name,
            next = nil, -- suggested next target
            group = GetRaidSubgroup(name),
            active = true, -- on player or in-flight
            flags = nil, -- raid marker flags of vectored player
        }
        --ONPLAYER[#ONPLAYER + 1] = VECTORS[#VECTORS]
        if #VECTORS == 4 then
            AssignVectorGroups()
        end
        -- else
        --     local vector = GetVectorByFlags(flags)
        --     if vector ~= nil then
        --         vector['name'] = name
        --         vector['active'] = true
        --         vector['flags'] = nil
        --
        --         ONPLAYER[#ONPLAYER + 1] = vector
        --         C_Timer.After(0.3, function ()
        --             -- Without deaths, all four vectors will jump around the same time.
        --             -- Wait 300ms to give them all a chance to land on players.
        --             AssignVectorNext(vector)
        --         end)
        --
        --         -- If the player is currently assigned to receive a debuff from
        --         -- someone, we need to re-assign that vector.
        --         for i, v in ipairs(VECTORS) do
        --             if v['next'] == name then
        --                 AssignVectorNext(v) -- should be ok to do immediately?
        --             end
        --         end
        --     end
    end
end

aura_env.onVectorRemoved = function(name, flags)
    -- find first registered vector on this player and mark it as in-flight
    -- for i, vector in ipairs(ONPLAYER) do
    --     if vector['name'] == name then
    --         -- remove from ordered ONPLAYER table
    --         table.remove(ONPLAYER, i)
    --
    --         -- clear assignments from target and next target
    --         Emit(PREFIX, 'm=', 'WHISPER', vector['name'])
    --         if vector['next'] then
    --             Emit(PREFIX, 'm=', 'WHISPER', vector['next'])
    --         end
    --
    --         -- deactivate vector and save the raid marker flags of the owner
    --         vector['name'] = nil
    --         vector['next'] = nil
    --         vector['active'] = false
    --         vector['flags'] = bit.band(flags, COMBATLOG_OBJECT_RAIDTARGET_MASK)
    --         return
    --     end
    -- end
end

aura_env.onEncounterStart = function()
    VECTORS = {}
    ONPLAYER = {}

    -- clear star, circle, diamond and triangle from all players
    local mark = nil
    for i = 1, 20 do
        mark = GetRaidTargetIndex("raid" .. i)
        if mark ~= nil and mark > 0 and mark < 5 then
            SetRaidTarget("raid" .. i, 0)
        end
    end
end
