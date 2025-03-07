local BUYERS = {'Ajih-Thrall', 'Kamilahaa'}
aura_env.VOID_HEALER = 'Promise'

------------------------------------------------------------------------------

local SAM = C_ChatInfo.SendAddonMessage
local function Emit (msg, t) SAM('TMDM_ECWAv1', msg, 'WHISPER', t) end
local function EmitRaid (msg) SAM('TMDM_ECWAv1', msg, 'RAID') end

local function Colorize (name, upper)
    local _, classFN = UnitClass(name)
    local color = RAID_CLASS_COLORS[classFN].colorStr
    if upper then name = string.upper(name) end
    return string.format("|c%s%s|r", color, name)
end

local function Contains (t, v)
    for i, _v in ipairs(t) do if v == _v then return true end end
    return false
end

local function Find (t, c)
    for i, name in ipairs(t) do
        local class = select(2, UnitClass(name))
        if class == c then return i, name end
    end
end

local function Map (t, fn)
    local _t = {}
    for i, v in ipairs(t) do _t[#_t + 1] = fn(v) end
    return _t
end

aura_env.GetRoles = function ()
    local MELEE = {'WARRIOR', 'DEATHKNIGHT', 'PALADIN', 'ROGUE', 'MONK', 'DEMONHUNTER'}
    local RANGE = {'PRIEST', 'MAGE', 'WARLOCK'}
    local roles = { tanks = {}, heals = {}, melee = {}, range = {} }
    for i = 1, 40 do
        name, _, subgroup, _, _, class, _, _, _, _, _, role = GetRaidRosterInfo(i)
        if name and subgroup < 5 and not Contains(BUYERS, name) then
            if role == 'TANK' then
                roles.tanks[#roles.tanks + 1] = name
            elseif role == 'HEALER' then
                roles.heals[#roles.heals + 1] = name
            elseif Contains(MELEE, class) then
                roles.melee[#roles.melee + 1] = name
            elseif Contains(RANGE, class) then
                roles.range[#roles.range + 1] = name
            else -- HUNTER, SHAMAN, DRUID
                -- Use Details! internals to get the cached spec id
                local spec = _detalhes.cached_specs[UnitGUID('raid'..i)]
                if Contains({103, 255, 263}, spec) then -- Feral, Surv, Enh
                    roles.melee[#roles.melee + 1] = name
                elseif Contains({102, 253, 254, 262}, spec) then -- Bal, BM, Mark, Ele
                    roles.range[#roles.range + 1] = name
                else -- default to range
                    print('FAILED TO GET ROLE (default range):', name)
                    roles.range[#roles.range + 1] = name
                end
            end
        end
    end

    table.sort(roles.tanks)
    table.sort(roles.heals)
    table.sort(roles.melee)
    table.sort(roles.range)

    local RANGE_SWAPS = {'HUNTER', 'DRUID', 'SHAMAN', 'PRIEST', 'MAGE', 'WARLOCK'}
    local MELEE_SWAPS = {'HUNTER', 'DRUID', 'SHAMAN', 'DEMONHUNTER', 'MONK', 'WARRIOR', 'ROGUE', 'PALADIN', 'DEATHKNIGHT'}

    -- Balance the melee/range teams (should be 8/7)
    if #roles.melee < 6 then
        while #roles.melee < 6 do
            for i, class in ipairs(RANGE_SWAPS) do
                local index, name = Find(roles.range, class)
                if index then
                    table.remove(roles.range, index)
                    roles.melee[#roles.melee + 1] = name
                    break
                end
            end
        end
    elseif #roles.melee > 8 then
        while #roles.melee > 8 do
            for i, class in ipairs(MELEE_SWAPS) do
                local index, name = Find(roles.melee, class)
                if index then
                    table.remove(roles.melee, index)
                    roles.range[#roles.range + 1] = name
                    break
                end
            end
        end
    end

    -- Report the teams to raid chat
    SendChatMessage('MELEE: '..strjoin(', ', unpack(roles.melee)), 'RAID')
    SendChatMessage('RANGE: '..strjoin(', ', unpack(roles.range)), 'RAID')
    SendChatMessage('BUYER: '..strjoin(', ', unpack(BUYERS)), 'RAID')

    return roles
end

aura_env.OnUnstableNightmare = function (target)
    aura_env.nightCount = aura_env.nightCount + 1
    aura_env.exposed[target] = true

    local team = aura_env.roles.melee
    local queue = aura_env.meleeQ
    if aura_env.orbCount == 2 or aura_env.orbCount == 5 then
        team = aura_env.roles.range -- melee is doing void
        queue = aura_env.rangeQ
    end

    for i, name in ipairs(team) do
        Emit('m2=>> '..Colorize(target)..' <<;d=6.5', name)
    end

    aura_env.UpdateTeamDisplays()

    for i, name in ipairs(aura_env.roles.heals) do
        Emit('g='..target..';d=5', name)
    end

    if aura_env.nightCount < 5 and queue[1] then
        Emit('s=bikehorn', queue[1])
    end
end

aura_env.OnUnstableVita = function (target)
    aura_env.exposed[target] = true
    for i, name in ipairs(aura_env.roles.range) do
        Emit('m2=>> '..Colorize(target)..' <<;d=6.5', name)
    end
    aura_env.UpdateTeamDisplays()
    if aura_env.rangeQ[1] then
        Emit('s=bikehorn', aura_env.rangeQ[1])
        for i, name in ipairs(aura_env.roles.heals) do
            Emit('g='..aura_env.rangeQ[1]..';d=5', name)
        end
    end
end

aura_env.OnUnstableVoid = function (target)
    aura_env.voidCount = aura_env.voidCount + 1
    aura_env.UpdateTeamDisplays()
    if aura_env.voidCount < 6 and aura_env.meleeQ[1] then
        Emit('s=bikehorn', aura_env.meleeQ[1])
        for i, name in ipairs(aura_env.roles.heals) do
            Emit('g='..aura_env.meleeQ[1]..';d=5', name)
        end
    end
end

aura_env.OnCorruptedExistence = function (target)
    for i, name in ipairs(aura_env.roles.heals) do
        Emit('g='..target..';d=14', name)
    end
end

local function UpdateQueue(queue, team, size)
    -- Remove exposed and dead people
    for i = size, 1, -1 do
        if queue[i] and (aura_env.exposed[queue[i]] or UnitIsDead(queue[i])) then
            table.remove(queue, i)
        end
    end

    -- Refill the queue
    if #queue < size then
        for i, name in ipairs(team) do
            if not (aura_env.exposed[name] or UnitIsDead(name)) and not Contains(queue, name) then
                queue[#queue + 1] = name
                if #queue == size then break end
            end
        end
    end
end

aura_env.UpdateTeamDisplays = function (auto)
    local aura_env = aura_env
    if not aura_env then return end

    -- Populate the queues
    UpdateQueue(aura_env.meleeQ, aura_env.roles.melee, 3)
    UpdateQueue(aura_env.rangeQ, aura_env.roles.range, 3)

    -- Throttle display updates
    if GetTime() - aura_env.lastUpdate < 0.25 then
        if not auto then
            -- Schedule another automated call in 1 second
            C_Timer.After(0.5, function () aura_env.UpdateTeamDisplays(true) end)
        end
        return
    end

    -- Display melee queue
    if #aura_env.meleeQ then
        local meleeQ = strjoin('\n', unpack(Map(aura_env.meleeQ, Colorize)))
        for i, name in ipairs(aura_env.roles.melee) do
            Emit('m3='..meleeQ..';d=6.5', name)
        end
    end

    -- Display range queue
    if #aura_env.rangeQ then
        local rangeQ = strjoin('\n', unpack(Map(aura_env.rangeQ, Colorize)))
        for i, name in ipairs(aura_env.roles.range) do
            Emit('m3='..rangeQ..';d=6.5', name)
        end
    end

    aura_env.lastUpdate = GetTime()
end
