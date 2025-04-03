local aura_env = aura_env

aura_env.assignments = {}
aura_env.soaker = 0
aura_env.set = 0

local function Emit(message, target)
    if target then
        C_ChatInfo.SendAddonMessage("TMDMv1", message, "WHISPER", target)
    else
        C_ChatInfo.SendAddonMessage("TMDMv1", message, "RAID")
    end
end

local function UnitDebuff(unit, spell)
    return AuraUtil.FindAuraByName(spell, unit, "HARMFUL")
end

local function ParsePlayers(line)
    local players = {}
    for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|r") do
        table.insert(players, name)
    end
    return players
end

--[[
mines:
  melee: "<playerlist>"
  ranged: "<playerlist>"
]]

aura_env.MRT = function()
    if C_AddOns.IsAddOnLoaded("TMDMEncounterClient") then
        local assignments = TMDM.ParseMRTNote()
        assignments.mines.melee = ParsePlayers(assignments.mines.melee)
        assignments.mines.ranged = ParsePlayers(assignments.mines.ranged)
        aura_env.assignments = assignments
    end
end

local MESSAGE = {
    "m=|T4624638:0|t SOAK MINE |T4624638:0|t",
    "c=SAY:Here I go soakin' again!",
    "s=bikehorn",
}

local SANARC_MESSAGE = {
    "m=|T4624638:0|t SNIFF FOOT-BLASTER |T4624638:0|t",
    "c=YELL:Feet? FEET?!? FEEEEEEEEEET!!!!!",
    "s=moan",
}

aura_env.AssignSoaker = function(set, soaker)
    if (set == 3 or set == 4 or set == 7 or set == 8) and soaker > 3 then
        return -- only 3 soakers on these sets
    elseif soaker > 4 then
        return -- only need 4 soaks (will be called again after 4th mine)
    end

    local soakers = aura_env.assignments.mines.melee
    if soaker > 2 then
        soakers = aura_env.assignments.mines.ranged
    end

    for _, name in ipairs(soakers) do
        if not (UnitIsDead(name) or UnitDebuff(name, "Unstable Shrapnel")) then
            if name == "Sanarc" then
                Emit(strjoin(";", unpack(SANARC_MESSAGE)), name)
            else
                Emit(strjoin(";", unpack(MESSAGE)), name)
            end
            SendChatMessage("Foot-Blaster: " .. name, "RAID")
            return
        end
    end
end

aura_env.EmoteShrapnel = function(name)
    Emit("e=" .. name .. " triggered a Foot-Blaster!")
end
