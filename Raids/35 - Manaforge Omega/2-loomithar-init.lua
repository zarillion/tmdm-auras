local aura_env = aura_env

--[[

PYLONS:
  '{square}': "<playerlist>"
  '{triangle}': "<playerlist>"
  '{diamond}': "<playerlist>"
  '{cross}': "<playerlist>"
  BACKUPS: "<playerlist>"

]]

aura_env.assignments = {}

local function ParsePlayers(line)
    local players = {}
    for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|r") do
        table.insert(players, name)
    end
    return players
end

aura_env.MRT = function()
    if C_AddOns.IsAddOnLoaded("TMDMEncounterClient") then
        local assignments = TMDM.ParseMRTNote()

        for pylon, players in pairs(assignments.PYLONS) do
            assignments.PYLONS[pylon] = ParsePlayers(players)
        end

        assignments.PYLONS.BACKUPS = ParsePlayers(assignments.PYLONS.BACKUPS)

        aura_env.assignments = assignments
    end
end

local function CanSoak(player)
    -- Hyper Infusion debuff
    return not UnitIsDead(player) and not WA_GetUnitDebuff(player, 1247045)
end

local function AssignPylonSoaker(player, backups)
    if CanSoak(player) then return player end

    while #backups > 0 do
        local backup = table.remove(backups, 1)
        if CanSoak(backup) then return backup end
    end
end

local SOUNDS = {
    ["{square}"] = "smc:06",
    ["{triangle}"] = "smc:04",
    ["{diamond}"] = "smc:03",
    ["{cross}"] = "smc:07",
}

local function NotifySoaker(player, pylon, order)
    local message = pylon .. " SOAK " .. order .. " " .. pylon
    TMDM.Emit("m=" .. message .. ";d=10;s=" .. SOUNDS[pylon], "WHISPER", player)
end

aura_env.AssignPylonSoakers = function(pylon)
    print("Assigning pylon set " .. pylon)

    local first, second
    local backups = { unpack(aura_env.assignments.PYLONS.BACKUPS) }

    for pylon, soakers in pairs(aura_env.assignments.PYLONS) do
        if pylon % 2 == 1 then
            first = AssignPylonSoaker(soakers[1], backups)
            second = AssignPylonSoaker(soakers[2], backups)
        else
            first = AssignPylonSoaker(soakers[3], backups)
            second = AssignPylonSoaker(soakers[4], backups)
        end

        -- Notify soakers
        NotifySoaker(first, pylon, "FIRST")
        NotifySoaker(second, pylon, "SECOND")

        -- Send assignment to chat
        local msg = strjoin(" ", "PYLON", pylon, (first or "(none)"), (second or "(none)"))
        SendChatMessage(msg, "RAID")
    end
end
