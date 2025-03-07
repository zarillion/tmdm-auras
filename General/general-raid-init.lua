-----------------------------------------------------
------ DEVELOPED FOR <Trash Mob Death Machine> ------
-----------------------------------------------------

local function colorize (name, classFN)
    classFN = classFN or UnitClass(name)
    local color = RAID_CLASS_COLORS[classFN].colorStr
    return string.format("|c%s%s|r", color, name)
end

local PREFIX = 'TMDM_ECWAv1'
local function Emit (message, target)
    C_ChatInfo.SendAddonMessage(PREFIX, message, 'WHISPER', target)
end

--[[

Functions used to run TMDM ECWA version checks across
the entire raid group.

]]--

C_ChatInfo.RegisterAddonMessagePrefix('TMDM_ECWAvc')
aura_env._versions = {}

aura_env.runVersionCheck = function ()
    print('Running TMDM ECWA version check ...')
    local aura_env = aura_env
    aura_env._versions = {}

    for i = 1, 40 do
        local name, realm = UnitName('raid'..i)
        if realm == nil or realm == '' then
            realm = GetRealmName()
        end
        if name then
            aura_env._versions[name..'-'..realm] = 0
            C_ChatInfo.SendAddonMessage('TMDM_ECWAvc', 'request', 'WHISPER', name..'-'..realm)
        end
    end

    C_Timer.After(2, function ()
            local player, realm = UnitName('player')
            if realm == nil or realm == '' then
                realm = GetRealmName()
            end
            player = player..'-'..realm
            local correct = aura_env._versions[player]
            local current = {}
            local outdated = {}
            local missing = {}

            for name, version in pairs(aura_env._versions) do
                if name ~= player then
                    if version == correct then
                        current[#current + 1] = name
                    elseif version == 0 then
                        missing[#missing + 1] = name
                    else
                        outdated[#outdated + 1] = name
                    end
                end
            end

            if #current > 0 then
                print('Current: '..strjoin(', ', unpack(current)))
            end
            if #outdated > 0 then
                print('Outdated: '..strjoin(', ', unpack(outdated)))
            end
            if #missing > 0 then
                print('Missing: '..strjoin(', ', unpack(missing)))
            end
    end)
end

aura_env.recordVersion = function (name, version)
    aura_env._versions[name] = version
end

--[[ aura_env.checkSoulstones

Ensure that each warlock in the raid has a soulstone
out. Any warlock without an active soulstone is
notified with a message and noise.

]]--

aura_env.checkSoulstones = function ()
    local warlocks = {}

    -- find all warlocks
    for i = 1, 40 do
        if select(2, UnitClass('raid'..i)) == 'WARLOCK' then
            warlocks[select(1, UnitName('raid'..i))] = false
        end
    end

    -- find all soulstones
    for i = 1, 40 do
        local caster = select(7, AuraUtil.FindAuraByName('Soulstone', 'raid'..i))
        if caster then
            warlocks[select(1, UnitName(caster))] = true
        end
    end

    -- notify lazy warlocks
    for name, soulstone in pairs(warlocks) do
        if not soulstone then
            Emit('m='..colorize('CAST SOULSTONE!!', 'WARLOCK')..';s=phone', name)
        end
    end
end

--[[ aura_env.onTaunt

Whenever a taunt is used, have that character /yell the
name of the target that was taunted.

]]--

aura_env.taunts = {
    355, -- Taunt (Warrior)
    6795, -- Growl (Druid)
    62124, -- Hand of Reckoning (Paladin)
    56222, -- Dark Command (Death Knight)
    115546, -- Provoke (Monk)
    185245, -- Torment (Demon Hunter)
}

aura_env.onTaunt = function (sourceName, destName)
    Emit('c=YELL Taunted '..destName..'!', sourceName)
end

--[[ aura_env.onTotimDeath/Ankh

Dialog functions for Koko and Promise when Totim does
one of his lightning fast ankhs.

These will only be called if no more than 3 people
have died since the last encounter start or end. This
prevents it from printing all the time during wipes.

]]--

aura_env.deathCount = 0

aura_env.onTotimDeath = function (timeStamp)
    if UnitInParty('Promise') then
        Emit('c=YELL Daddy Totes! NO!!', 'Promise')
    end
    aura_env.lastTotimDeath = timeStamp
end

aura_env.onTotimAnkh = function (timeStamp)
    if UnitInParty('Promise') and aura_env.lastTotimDeath then
        local elapsed = timeStamp - aura_env.lastTotimDeath
        local message = 'c=SAY '..string.format('%.1f', elapsed)..'s, '
        if elapsed < 1 then
            message = message..'impressive!'
        elseif elapsed < 2 then
            message = message..'not bad.'
        elseif elapsed < 5 then
            message = message..'you could do better!'
        else
            message = message..'are you even trying anymore?'
        end
        Emit(message, 'Promise')
    end
end

-------------------------------------------------------------------------------

aura_env.overkillParam = {
    ENVIRONMENTAL_DAMAGE = 14,
    RANGE_DAMAGE = 16,
    SPELL_BUILDING_DAMAGE = 16,
    SPELL_DAMAGE = 16,
    SPELL_PERIODIC_DAMAGE = 16,
    SWING_DAMAGE = 13
}

aura_env.reportPetDeath = function (guid)
    for unit in WA_IterateGroupMembers() do
        local class = UnitClass(unit)
        if class == 'Warlock' or class == 'Hunter' then
            if UnitGUID(unit..'pet') == guid then
                -- we found our pet, its one we actually care about
                Emit('m2=|cffff0000PET DIED!|r;s=panther', UnitName(unit))
                return
            end
        end
    end
end
