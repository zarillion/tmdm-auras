local aura_env = aura_env

aura_env.combo = 0

aura_env.REWARDS = {
    464772, -- Shock + Flame
    464801, -- Shock + Bomb
    464804, -- Flame + Bomb
    464806, -- Gold + Flame
    464809, -- Gold + Shock
    464810, -- Gold + Bomb
    465309, -- Cheat to Win!
}

local COMBOS = {
    "|cfffff468Gold|r + |cff5555eeShock|r",
    "|cfffff468Gold|r + |cffc69b6dBomb|r",
    "|cffee5555Flame|r + |cffc69b6dBomb|r",
    "|cffee5555Flame|r + |cfffff468Gold|r",
    "|cff5555eeShock|r + |cffc69b6dBomb|r",
    "|cff5555eeShock|r + |cffee5555Flame|r",
}

aura_env.DisplayCombo = function(i)
    local combo = COMBOS[i] or "{skull} PUSH P2 OR DIE {skull}"
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
