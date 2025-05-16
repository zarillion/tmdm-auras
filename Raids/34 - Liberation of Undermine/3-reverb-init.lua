local aura_env = aura_env

aura_env.mark = 0 -- 0-7
aura_env.amps = {}
aura_env.roster = {}

local ROLE = TMDM.SPECS.MOBILITY.ROLE
local SPEC_ORDER = TMDM.Concat(ROLE.RANGED, ROLE.MELEE, ROLE.HEALER, ROLE.TANK)

local function UnitBuff(unit, spell)
    return AuraUtil.FindAuraByName(spell, unit, "HELPFUL")
end

local function UnitDebuffStacks(unit, spell)
    local _, _, stacks = AuraUtil.FindAuraByName(spell, unit, "HARMFUL")
    return stacks or 0
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
    return (value / total) > 0.85
end

aura_env.SetRoster = function()
    table.wipe(aura_env.roster)
    for i = 1, 20 do
        aura_env.roster[#aura_env.roster + 1] = UnitGUID("raid" .. i)
    end

    TMDM.SortPlayersBySpec(aura_env.roster, SPEC_ORDER)
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
    for _, guid in ipairs(aura_env.roster) do
        local unit = TMDM.GUIDs[guid]
        local name = UnitName(unit)
        local elapsed = GetTime() - (TIMERS[name] or 0)
        if name and not UnitIsDead(unit) and elapsed > 60 then
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
        local command = "c=YELL:" .. chat .. ";s=airhorn;m1=" .. message .. ";m2=" .. message .. ";m3=" .. message
        local name = AssignClicker()
        if name then
            SendChatMessage("CLICKING " .. marker .. " " .. name, "RAID_WARNING")
            TMDM.Emit(command, "WHISPER", name)
        end
    end
    state.high = isHigh
end
