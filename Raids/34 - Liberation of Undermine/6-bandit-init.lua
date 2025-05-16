local aura_env = aura_env

aura_env.mark = 0 -- 0-2
aura_env.combo = 0
aura_env.fixates = {}

aura_env.REWARDS = {
    464772, -- Shock + Flame
    464801, -- Shock + Bomb
    464804, -- Flame + Bomb
    464806, -- Gold + Flame
    464809, -- Gold + Shock
    464810, -- Gold + Bomb
    465309, -- Cheat to Win!
}

-- Token debuffs (mob, player)
local FLAME = { 464475, 472828 }
local SHOCK = { 464476, 472783 }
local COIN = { 464482, 472832 }
local BOMB = { 464484, 472837 }

local COMBOS = {
    { FLAME, COIN, msg = "|cffee5555Flame|r + |cfffff468Coin|r" },
    { COIN, SHOCK, msg = "|cfffff468Coin|r + |cff5555eeShock|r" },
    { FLAME, BOMB, msg = "|cffee5555Flame|r + |cffc69b6dBomb|r" },
    { SHOCK, FLAME, msg = "|cff5555eeShock|r + |cffee5555Flame|r" },
    { SHOCK, BOMB, msg = "|cff5555eeShock|r + |cffc69b6dBomb|r" },
    { COIN, BOMB, msg = "|cfffff468Coin|r + |cffc69b6dBomb|r" },
}

local function GetBossUnit(guid)
    for i = 1, 16 do
        if UnitGUID("boss" .. i) == guid then return "boss" .. i end
    end

    for i = 1, 8 do
        if UnitGUID("arena" .. i) == guid then return "arena" .. i end
    end
end

aura_env.DisplayCombo = function(i)
    local combo = COMBOS[i].msg or "{skull} PUSH P2 OR DIE {skull}"
    TMDM.Emit("m2=" .. combo .. ";d=20;b=::30:1:1:.4", "RAID")
end

aura_env.StopDisplayCombo = function()
    TMDM.Emit("b=;m2=", "RAID")
end

aura_env.NotifyDispel = function(name)
    local message = {
        "g=" .. name .. "::0:1:1:::3",
        "f=r:HEALER,c:WARLOCK," .. name,
        "d=15",
    }
    TMDM.Emit(strjoin(";", unpack(message)), "RAID")
end

aura_env.ClearDispel = function(name)
    local message = {
        "g=" .. name,
        "f=r:HEALER,c:WARLOCK," .. name,
        "d=0",
    }
    TMDM.Emit(strjoin(";", unpack(message)), "RAID")
end

local MARKS = { 8, 7, 6 } -- skull, cross, square

aura_env.MarkReelAssistant = function(guid)
    -- Cycle through the marks for unmarked amplifiers
    local unit = GetBossUnit(guid)
    local mark = GetRaidTargetIndex(unit)
    if not mark then
        SetRaidTarget(unit, MARKS[aura_env.mark + 1])
        aura_env.mark = (aura_env.mark + 1) % 3

        C_Timer.After(1, function()
            for _, spell in ipairs(COMBOS[aura_env.combo]) do
                if WA_GetUnitAura(unit, spell[1]) then
                    TMDM.Emit("d=10;g=" .. guid .. ":-1:1:0:1:::5", "RAID")
                    break
                end
            end
        end)
    end
end

aura_env.EmoteExplosiveGaze = function(guid)
    local target = aura_env.fixates[guid]
    if target then
        local msg = "e=" .. TMDM.Colorize(target) .. "'s kiting is *not* air-tight."
        TMDM.Emit(msg, "RAID")
    end
end

local PLAYER_TOKENS = { FLAME[2], BOMB[2], SHOCK[2], COIN[2] }

aura_env.NotifyToken = function(name, spellID)
    if TMDM.Contains(PLAYER_TOKENS, spellID) then
        for _, spell in ipairs(COMBOS[aura_env.combo]) do
            if spellID == spell[2] then
                TMDM.Emit("m3=|cff00ff00TURN IN TOKEN|r;s=bikehorn;c=SAY:I HAVE TOKEN!", "WHISPER", name)
                return
            end
        end
        TMDM.Emit("m3=|cffff0000DO NOT TURN IN|r;s=airhorn;c=YELL:NOT TURNING IN!", "WHISPER", name)
    end
end
