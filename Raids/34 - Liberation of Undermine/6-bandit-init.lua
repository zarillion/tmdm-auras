local aura_env = aura_env

aura_env.combo = 0

aura_env.REWARDS = {
    461101, -- Gold + Shock
    461389, -- Gold + Flame
    461395, -- Gold + Bomb
    461091, -- Shock + Bomb
    461176, -- Flame + Bomb
    461083, -- Shock + Flame
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
    local message = "m2=" .. combo .. ";d=30;b=::30:1:1:.4"
    Emit(message)
end

aura_env.StopDisplayCombo = function()
    Emit("b=;m2=")
end
