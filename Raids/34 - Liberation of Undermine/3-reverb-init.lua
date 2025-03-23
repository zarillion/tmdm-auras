local aura_env = aura_env

local LOR = LibStub:GetLibrary("LibOpenRaid-1.0", true)

aura_env.mark = 0 -- 0-7
aura_env.amps = {}
aura_env.roster = {}

aura_env.clickers = {
    253, -- Beast Mastery Hunter
    254, -- Marksmanship Hunter
    265, -- Affliction Warlock
    266, -- Demonology Warlock
    267, -- Destruction Warlock
    62, -- Arcane Mage
    63, -- Fire Mage
    64, -- Frost Mage
    262, -- Elemental Shaman
    258, -- Shadow Priest
    102, -- Balance Druid
    1467, -- Devastation Evoker
    1473, -- Augmentation Evoker

    255, -- Survival Hunter
    577, -- Havoc Demon Hunter
    269, -- Windwalker Monk
    260, -- Outlaw Rogue
    71, -- Arms Warrior
    72, -- Fury Warrior
    259, -- Assassination Rogue
    261, -- Subtlety Rogue
    103, -- Feral Druid
    263, -- Enhancement Shaman
    70, -- Retribution Paladin
    251, -- Frost Death Knight
    252, -- Unholy Death Knight

    105, -- Restoration Druid
    1468, -- Preservation Evoker
    256, -- Discipline Priest
    257, -- Holy Priest
    264, -- Restoration Shaman
    65, -- Holy Paladin
    270, -- Mistweaver Monk

    268, -- Brewmaster Monk
    250, -- Blood Death Knight
    581, -- Vengeance Demon Hunter
    66, -- Protection Paladin
    104, -- Guardian Druid
    73, -- Protection Warrior
}

local function Emit(message, target)
    if target then
        C_ChatInfo.SendAddonMessage("TMDMv1", message, "WHISPER", target)
    else
        C_ChatInfo.SendAddonMessage("TMDMv1", message, "RAID")
    end
end

local function IndexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then return i end
    end
    return nil
end

local function UnitBuff(unit, spell) return AuraUtil.FindAuraByName(spell, unit, "HELPFUL") end

local function UnitDebuffStacks(unit, spell)
    local _, _, stacks = AuraUtil.FindAuraByName(spell, unit, "HARMFUL")
    return stacks or 0
end

local function GetUnitSpec(unit)
    local info = LOR.GetUnitInfo(unit)
    if info then return info.specId end
end

local function GetBossUnit(guid)
    for i = 1, 16 do
        if UnitGUID("boss" .. i) == guid then return "boss" .. i end
    end

    for i = 1, 8 do
        if UnitGUID("arena" .. i) == guid then return "arena" .. i end
    end
end

local function IsHighHP(unit)
    local value = UnitHealth(unit)
    local total = UnitHealthMax(unit)
    return (value / total) > 0.8
end

aura_env.SortRoster = function()
    table.wipe(aura_env.roster)
    for i = 1, 20 do
        aura_env.roster[#aura_env.roster + 1] = "raid" .. i
    end

    table.sort(aura_env.roster, function(a, b)
        local specA = GetUnitSpec(a) or aura_env.clickers[#aura_env.clickers]
        local specB = GetUnitSpec(b) or aura_env.clickers[#aura_env.clickers]
        return IndexOf(aura_env.clickers, specA) < IndexOf(aura_env.clickers, specB)
    end)
end

aura_env.MarkAmplifier = function(guid)
    -- Cycle through the marks for unmarked amplifiers
    local unit = GetBossUnit(guid)
    local mark = GetRaidTargetIndex(unit)
    if not mark then
        SetRaidTarget(unit, aura_env.mark + 1)
        aura_env.mark = (aura_env.mark + 1) % 8
    end

    aura_env.amps[guid] = { high = IsHighHP(unit) }
end

local TIMERS = {}

local function AssignClicker()
    for _, unit in ipairs(aura_env.roster) do
        local name = UnitName(unit)
        local elapsed = GetTime() - (TIMERS[name] or 0)
        if name and not UnitIsDead(unit) and elapsed > 30 then
            local stacks = UnitDebuffStacks(unit, "Lingering Voltage")
            if stacks == 0 then
                TIMERS[name] = GetTime()
                return name
            end
        end
    end
end

aura_env.CheckAmplifier = function(unit, mark)
    local guid = UnitGUID(unit)
    local state = aura_env.amps[guid]
    local isHigh = IsHighHP(unit)
    local highEnergy = UnitPower("boss1", Enum.PowerType.Energy) >= 90
    local phase2 = UnitBuff("boss1", "Sound Cloud") ~= nil
    if not state.high and isHigh and not (highEnergy or phase2) then
        local marker = "{rt" .. mark .. "}"
        local message = marker .. " CLICK " .. marker
        local chat = "CLICKING " .. marker .. "!"
        local command = "c=YELL:" .. chat .. ";s=airhorn;m=" .. message
        local name = AssignClicker()
        if name then Emit(command, name) end
    end
    state.high = isHigh
end
