local aura_env = aura_env

aura_env.soakers = {}

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
        aura_env.soakers = {}

        local list = false
        local text = VExRT.Note.Text1

        for line in text:gmatch("[^\r\n]+") do
            line = strtrim(line)
            if strlower(line) == "minestart" then
                list = true
            elseif strlower(line) == "mineend" then
                list = false
            elseif list then
                for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
                    table.insert(aura_env.soakers, name)
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
    "c=YELL:Foot-Blaster?!? It has foot in the name, I'm sniffing it!",
    "s=moan",
}

aura_env.AssignSoaker = function()
    for _, name in ipairs(aura_env.soakers) do
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
