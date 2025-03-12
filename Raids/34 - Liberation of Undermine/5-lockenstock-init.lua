local aura_env = aura_env

aura_env.melee = {}
aura_env.ranged = {}

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

aura_env.MRT = function()
    if C_AddOns.IsAddOnLoaded("MRT") and VExRT.Note.Text1 then
        table.wipe(aura_env.melee)
        table.wipe(aura_env.ranged)

        local row = 0
        local text = VExRT.Note.Text1

        for line in text:gmatch("[^\r\n]+") do
            line = strtrim(line)
            if strlower(line) == "minestart" then
                row = 1
            elseif strlower(line) == "mineend" then
                row = 0
            elseif row == 1 then
                for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
                    table.insert(aura_env.melee, name)
                end
                row = 2
            elseif row == 2 then
                for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
                    table.insert(aura_env.ranged, name)
                end
            end
        end
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

    local soakers = aura_env.melee
    if soaker > 2 then
        soakers = aura_env.ranged
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
