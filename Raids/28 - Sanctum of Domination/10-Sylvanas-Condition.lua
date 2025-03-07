-- Fired when Veil of Darkness is about to cast

if not UnitIsGroupLeader('player') then return end

local aura_env = aura_env

local function Emit (message, target)
    C_ChatInfo.SendAddonMessage('TMDM_ECWAv1', message, 'WHISPER', target)
end

local function IterateActiveGroup (includeDead, maxSubGroup)
    maxSubGroup = maxSubGroup or 4
    local i = 0
    local function SpecPosition (name, spec)
        if name == 'Bpaptu' and aura_env.veil_count == 3 then return 'RANGED' end
        for _, id in ipairs({62,63,64,102,105,253,254,256,257,258,262,264,265,266,267}) do
            if spec == id then return 'RANGED' end
        end
        return 'MELEE'
    end
    return function ()
        while i < 40 do
            i = i + 1
            local name, _, subgroup, _, _, class, _, online, isDead, _, _, role = GetRaidRosterInfo(i)
            if subgroup <= maxSubGroup and online and (not isDead or includeDead) then
                local spec = Details.cached_specs[UnitGUID('raid'..i)]
                local position = spec and SpecPosition(name, spec) or nil
                return name, class, role, spec, position, subgroup
            end
        end
    end
end

if aura_env.veil_count < 4 then
    local marker = aura_env.veil_markers[aura_env.veil_count] or 6
    for name, _, _, _, position in IterateActiveGroup() do
        if position == 'RANGED' then
            Emit('m3=BAIT VEIL @ {rt'..marker..'};s=moan;d=10', name)
        end
    end
end