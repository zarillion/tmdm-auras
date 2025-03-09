local aura_env = aura_env

aura_env.combo = 0

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
    local combo = COMBOS[i] or "WE'RE FUCKED?!"
    local message = "m2=" .. combo .. ";d=30"
    Emit(message)
end
