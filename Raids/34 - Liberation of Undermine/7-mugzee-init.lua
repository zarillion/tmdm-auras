local aura_env = aura_env

aura_env.assignments = {}

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
  final: "<playerlist>"
groups:
  - marks: {square} {diamond} {star}
    heal: "<playerlist>"
    dps: "<playerlist>"
  - marks: {triangle} {cross} {circle}
    heal: "<playerlist>"
    dps: "<playerlist>"

]]

aura_env.MRT = function()
    if C_AddOns.IsAddOnLoaded("TMDMEncounterClient") then
        local assignments = TMDM.ParseMRTNote()

        assignments.mines.melee = ParsePlayers(assignments.mines.melee)
        assignments.mines.ranged = ParsePlayers(assignments.mines.ranged)
        assignments.mines.final = ParsePlayers(assignments.mines.final)

        for _, group in ipairs(assignments.groups) do
            group.marks = strsplit(" ", group.marks)
            group.heal = ParsePlayers(group.heal)
            group.dps = ParsePlayers(group.dps)
        end

        aura_env.assignments = assignments
    end
end

aura_env.EmoteMine = function(target)
    local name = WA_ClassColorName(target)
    if name and name ~= "" then
        Emit("e=" .. name .. " triggered an Unstable Crawler Mine!")
    end
end

local ROCKET_YELLS = {
    "Help me take this rocket to the face!",
    "Here I go blastin' off again!",
    "I will not freeze like a deer!",
    "I definitely know where the markers are!",
    "TIME TO SOAK FRIENDOS! GET OVER HERE!",
}

aura_env.AssignRocket = function(rocket, target)
    local msg = ROCKET_YELLS[math.random(#ROCKET_YELLS)]
    if rocket == 1 then
        Emit("m=GO TO {moon};s=bikehorn;d=7;c=YELL:" .. msg, target)
    elseif rocket == 2 then
        Emit("m=GO TO {skull};s=bikehorn;d=7;c=YELL:" .. msg, target)
    else
        Emit("m=TOWARDS BOSS;s=bikehorn;d=7;c=YELL:" .. msg, target)
    end
end

aura_env.EmitSoaker = function(list)
    for _, player in ipairs(list) do
        if not UnitDebuff(player, "Unstable Crawler Mines") then
            Emit("c=YELL:MINE MINE MINE!;m3=TOUCH NEXT MINE;s=wilhelmscream", player)
            return
        end
    end
end

aura_env.AssignSoaker = function(set, soaker, delay)
    if set > 3 or soaker > 4 then
        return -- run for your lives
    end

    local soakers = aura_env.assignments.mines.melee
    if set == 3 then
        soakers = aura_env.assignments.mines.final
    elseif soaker > 2 then
        soakers = aura_env.assignments.mines.ranged
    end

    if aura_env.soakTimer then
        aura_env.soakTimer:Cancel()
    end
    aura_env.soakTimer = C_Timer.NewTimer(delay, function()
        aura_env.EmitSoaker(soakers)
        aura_env.soakTimer = nil
    end)
end
