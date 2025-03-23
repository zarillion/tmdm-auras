local aura_env = aura_env

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
