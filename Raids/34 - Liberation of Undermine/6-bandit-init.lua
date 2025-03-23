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

local function Emit(message, target)
    if target then
        C_ChatInfo.SendAddonMessage("TMDMv1", message, "WHISPER", target)
    else
        C_ChatInfo.SendAddonMessage("TMDMv1", message, "RAID")
    end
end

local COMBOS = {
    "|cffee5555Flame|r + |cfffff468Gold|r",
    "|cff5555eeShock|r + |cfffff468Gold|r",
    "|cffee5555Flame|r + |cffc69b6dBomb|r",
    "|cff5555eeShock|r + |cffee5555Flame|r",
    "|cff5555eeShock|r + |cffc69b6dBomb|r",
    "|cfffff468Gold|r + |cffc69b6dBomb|r",
}

aura_env.DisplayCombo = function(i)
    local combo = COMBOS[i] or "{skull} PUSH P2 OR DIE {skull}"
    Emit("m2=" .. combo .. ";d=10;b=::30:1:1:.4")
end

aura_env.StopDisplayCombo = function()
    print("Stopping display ...")
    Emit("b=;m2=")
end
