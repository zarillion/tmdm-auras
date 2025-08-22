local aura_env = aura_env

--[[

CCs:
  1: "<player>:<id> <player>:<id>" # 0:27
  2: "<player>:<id> <player>:<id>" # 1:12
  3: "<player>:<id> <player>:<id>" # 1:28
  4: "<player>:<id> <player>:<id>" # 1:57
  5: "<player>:<id> <player>:<id>" # 2:12
  6: "<player>:<id> <player>:<id>" # 2:26
  7: "<player>:<id> <player>:<id>" # 4:16
  8: "<player>:<id> <player>:<id>" # 4:31
  9: "<player>:<id> <player>:<id>" # 4:46

PYLONS:
  "{square}": ""
  "{triangle}": ""
  "{diamond}": ""

]]

--[[

CC Extension:
    Oppressing Roar	    406971      2:00

Knockback:
    Wing Buffet	        357214      1:00
    Typhoon	            61391       0:30

Stun:
    Leg Sweep	        119381      1:00
    Chaos Nova	        179057      0:45
    Shockwave	        46968       0:45
    Frostwyrm's Fury	279302      1:30
    Capacitor Totem	    192058      1:00
    Shadowfury	        30283       0:45

Other:
    Ring of Peace	    116844      0:45
    Binding Shot	    109248      0:45
    Gravity Lapse	    449700      0:40
    Tail Swipe	        368970      1:00
    Sigil of Chains	    202138      1:00
    Ursol's Vortex	    102793      1:00
    Champion's Spear	376079      1:30
    Gorefiend's Grasp	108199      2:00

]]

aura_env.assignments = {}

local function ParseAbilities(line)
    local abilities = {}

    for _, assignment in ipairs({ strsplit(" ", line) }) do
        local player, ability = strsplit(":", assignment)
        player = player:match("|c%x%x%x%x%x%x%x%x([^|]+)|r")
        table.insert(abilities, { player = player, ability = tonumber(ability) })
    end

    return abilities
end

aura_env.MRT = function()
    if C_AddOns.IsAddOnLoaded("TMDMEncounterClient") then
        local assignments = TMDM.ParseMRTNote()

        for set, abilities in pairs(assignments.CCs) do
            assignments.CCs[set] = ParseAbilities(abilities)
        end

        aura_env.assignments = assignments
    end
end

aura_env.NotifyCCs = function(set)
    local abilities = aura_env.assignments.CCs[tostring(set)]
    local messages = {}

    for _, assignment in ipairs(abilities) do
        local icon = C_Spell.GetSpellInfo(assignment.ability).iconID
        local name = TMDM.Colorize(assignment.player, false, 4)
        table.insert(messages, name .. " |T" .. icon .. ":0|t")
    end

    TMDM.Emit("d=8;m3=" .. strjoin(" => ", unpack(messages)), "RAID")
end

TMDM.ArazCCs = function(set)
    aura_env.MRT()
    aura_env.NotifyCCs(set)
end
