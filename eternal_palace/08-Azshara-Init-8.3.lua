aura_env.burstDispels = {'Zarillion', 'Omegapasta', 'Totimp'}

-------------------------------------------------------------------------------

aura_env.decreeTimer = false
aura_env.burstCast = 0
aura_env.burstCount = 0
aura_env.burstPlayers = {}

aura_env.debuffs = {
    [299249] = true, -- Suffer!
    [299251] = true, -- Obey!
    [299252] = true, -- March!
    [299253] = true, -- Stay!
    [299255] = true, -- Stand Alone!
    [299254] = true  -- Stand Together!
}

local function Colorize (name, upper)
    local _, classFN = UnitClass(name)
    local color = RAID_CLASS_COLORS[classFN].colorStr
    if upper then name = string.upper(name) end
    return string.format("|c%s%s|r", color, name)
end

local PREFIX = 'TMDM_ECWAv1'
local function Emit (message, target)
    C_ChatInfo.SendAddonMessage(PREFIX, message, 'WHISPER', target)
end

local function EmitRaid (message)
    C_ChatInfo.SendAddonMessage(PREFIX, message, 'RAID')
end

aura_env.Emit = Emit
aura_env.EmitRaid = EmitRaid

-------------------------------------------------------------------------------

local function Suffer(unit) return WA_GetUnitDebuff(unit, 299249) end
local function Obey(unit) return WA_GetUnitDebuff(unit, 299251) end
local function March(unit) return WA_GetUnitDebuff(unit, 299252) end
local function Stay(unit) return WA_GetUnitDebuff(unit, 299253) end
local function Alone(unit) return WA_GetUnitDebuff(unit, 299255) end
local function Together(unit) return WA_GetUnitDebuff(unit, 299254) end

-- march + alone x3
-- march + together x4
-- obey + together x2
-- stay + alone x2
-- stay + together x2
-- suffer + alone x3
-- suffer + together x4

aura_env.assignMythicDecrees = function ()
    local soloSoak = 0
    local grpSoak = 0
    local stayAlone = 0
    local marks = { [1]={}, [2]={}, [3]={}, [4]={}, [5]={}, [7]={}, [8]={} }

    for unit in WA_IterateGroupMembers() do
        local name = UnitName(unit)
        local suffer = Suffer(unit)
        local obey = Obey(unit)
        local march = March(unit)
        local stay = Stay(unit)
        local alone = Alone(unit)
        local together = Together(unit)

        if march and alone then
            Emit('m2=RUN FAR AWAY;d=19', name)
        elseif march and together then
            -- run clockwise around the star orb
            Emit('m2={rt1} RUN CLOCKWISE {rt1};d=19', name)
        elseif obey and together then
            Emit('m2={rt6} MOVE FORWARD {rt6};d=19', name)
        elseif stay and alone then
            -- soak skull and moon next to the stack point
            stayAlone = stayAlone + 1
            if stayAlone == 1 then
                Emit('m2={rt8} << SOLO SOAK;d=19', name)
                SetRaidTarget(unit, 8)
                marks[8][1] = name
            else
                Emit('m2=SOLO SOAK >> {rt5};d=19', name)
                SetRaidTarget(unit, 5)
                marks[5][1] = name
            end
        elseif stay and together then
            Emit('m2={rt6} MOVE FORWARD {rt6};d=19', name)
        elseif suffer and alone then
            -- solo soak the 3 western orbs
            soloSoak = soloSoak + 1
            local markID = ({4,7,3})[soloSoak] -- triangle, cross, diamond
            local marker = '{rt'..markID..'}'
            Emit('m2='..marker..' SOLO SOAK '..marker..';d=19', name)
            SetRaidTarget(unit, markID)
            marks[markID][1] = name
        elseif suffer and together then
            -- soak star and circle in pairs of two
            grpSoak = grpSoak + 1
            local markID = ({1,2})[(grpSoak % 2) + 1] -- star, circle
            local marker = '{rt'..markID..'}'
            Emit('m2='..marker..' GROUP SOAK '..marker..';d=19', name)
            marks[markID][#marks[markID] + 1] = name
        end
    end

    local report = 'DECREE: '
    for i = 1, 8 do
        if i ~= 6 then
            report = report..'{rt'..i..'} '
            for i, name in ipairs(marks[i]) do
                report = report..name..' '
            end
        end
    end
    SendChatMessage(report, 'RAID')
end

-------------------------------------------------------------------------------

aura_env.assignBurstDispel = function (target, num)
    aura_env.burstPlayers[num] = target
    if num == 1 then
        aura_env.notifyBurst(1)
    else
        -- The first dispeller has the first burst player displayed. If we
        -- tell them to wait, it will overwrite it, but we can notify everyone
        -- else to wait.
        if target ~= aura_env.burstDispels[1] then
            Emit('m3=WAIT ('..num..');d=10', target)
        end
    end
end

aura_env.burstRemoved = function (target)
    local removedIndex = 0
    for i = 1, 10 do
        if aura_env.burstPlayers[i] == target then
            aura_env.burstPlayers[i] = nil
            removedIndex = i
        end
    end

    Emit('m3=DONE!;s=bell', target)
    local dispel = aura_env.burstDispels[removedIndex]
    if dispel and dispel ~= target then
        Emit('m3=DONE!;s=bell', dispel)
    end

    for i = 1, 10 do
        if aura_env.burstPlayers[i] then
            if i > removedIndex then
                aura_env.notifyBurst(i)
            end
            break
        end
    end
end

aura_env.notifyBurst = function (num)
    local dispel = aura_env.burstDispels[num]
    local target = aura_env.burstPlayers[num]
    if dispel and target then
        if dispel == target then
            Emit('m3=DISPEL YOURSELF ('..num..');c=SAY DISPEL '..num..';s=bikehorn', target)
        else
            Emit('m3=GET DISPEL ('..num..');c=SAY DISPEL '..num..';s=bikehorn', target)
            Emit('m3=DISPEL '..Colorize(target, 1)..';s=bikehorn', dispel)
        end
    end
end
