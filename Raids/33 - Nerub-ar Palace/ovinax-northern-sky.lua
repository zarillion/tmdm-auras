aura_env.loaded = C_AddOns.IsAddOnLoaded("NorthernSkyMedia")
aura_env.debug = false
aura_env.diff = {

    [14] = 1, -- Normal
    [15] = 1, -- Heroic
    [16] = 2, -- Mythic
    [0] = 2, -- Debug
    [1] = 2, -- Debug
}
aura_env.type = {
    -- phase 1 == Fixate side, phase 2 == Spider side, 3 == Interrupt Side
    [1] = {  -- type of eggs in each area 1 = Fixate, 2 = Tank, 3 = Interrupt, 4 = Tank+Interrupt, 5 = Tank+Fixate, 6 = Fixate+Interrupt
        1,
        5, 4, 6, 1,
        6, 2, 1, 3, 5, 4,
        1
    },
    [2] = {
        2,
        5, 4, 6, 4,
        6, 2, 1, 2, 5, 3,
        2
    },
    [3] = {
        3,
        4, 5, 6, 1,
        6, 3, 2, 3, 5, 4,
        3
    },
}

aura_env.order = { -- order of eggs being broken
    [1] = {
        [1] = {2, 3, 1, 6},
        [2] = {4, 11, 5, 10},
        [3] = {9, 8, 12, 7},
    },
    [2] = {
        [1] = {2, 3, 1, 6},
        [2] = {4, 5, 11, 10},
        [3] = {12, 9, 8, 7},
    },
    [3] = {
        [1] = {2, 1, 3, 6},
        [2] = {4, 11, 5, 10},
        [3] = {8, 12, 7, 9},
    },

}

aura_env.phaseorder = {1, 2, 3}

aura_env.castID = aura_env.debug and 8936 or 442526
aura_env.blood = aura_env.debug and 48438 or 442432
aura_env.debuff = aura_env.debug and 774 or 440421
aura_env.delay = aura_env.debug and 3 or 0.2

aura_env.spec = {

    -- Tanks
    [250]  =  1, -- Blood DK
    [581]  =  2, -- Veng DH
    [268]  =  3, -- Brewmaster
    [66]   =  4, -- Prot Pally
    [83]   =  5, -- Prot Warrior
    [104]  =  6, -- Guardian Druid

    -- Melee
    [251]  = 7, -- Death Knight: Frost
    [252]  = 8, -- Death Knight: Unholy
    [259]  = 9, -- Rogue: Assassination
    [260]  = 10, -- Rogue: Outlaw
    [261]  = 11, -- Rogue: Subtlety
    [263]  = 12, -- Shaman: Enhancement
    [103]  = 13, -- Druid: Feral
    [70]   = 14, -- Paladin: Retribution
    [255]  = 15, -- Hunter: Survival
    [269]  = 16, -- Monk: Windwalker
    [577]  = 17, -- Demon Hunter: Havoc
    [71]   = 18, -- Warrior: Arms
    [72]   = 19, -- Warrior: Fury

    -- Healers
    [1468] = 20, -- Evoker: Preservation
    [270]  = 21, -- Monk: Mistweaver
    [105]  = 22, -- Druid: Restoration
    [264]  = 23, -- Shaman: Restoration
    [65]   = 24, -- Paladin: Holy
    [256]  = 25, -- Priest: Discipline
    [257]  = 26, -- Priest: Holy

    -- Ranged
    [262]  = 27, -- Shaman: Elemental
    [258]  = 28, -- Priest: Shadow
    [265]  = 29, -- Warlock: Affliction
    [266]  = 30, -- Warlock: Demonology
    [267]  = 31, -- Warlock: Destruction
    [64]   = 32, -- Mage: Frost
    [62]   = 33, -- Mage: Arcane
    [63]   = 34, -- Mage: Fire
    [253]  = 35, -- Hunter: Beast Mastery
    [254]  = 36, -- Hunter: Marksmanship
    [102]  = 39, -- Druid: Balance
    [1473] = 37, -- Evoker: Augmentation
    [1467] = 38, -- Evoker: Devastation

}



aura_env.MRT = function()
    if C_AddOns.IsAddOnLoaded("MRT") and VMRT.Note.Text1 then
        local text = _G.VMRT.Note.Text1
        local list = false
        aura_env.found = false
        text = text:gsub("||r", "") -- clean colorcode
        text = text:gsub("||c%x%x%x%x%x%x%x%x", "") -- clean colorcode
        for line in text:gmatch('[^\r\n]+') do
            line = strtrim(line) --trim whitespace
            --check for start/end of the name list
            if strlower(line) == "nsstart" then
                list = true
            elseif strlower(line) == "nsend" then
                list = false
                aura_env.found = true
            end
            local phaseorder = false
            local phase = 0
            if list then
                line = line:gsub("{.-}", "") -- cleaning markers from line
                local pos = 0
                if string.find(line, "phaseorder") then
                    phaseorder = true
                    aura_env.phaseorder = {}
                elseif string.find(line, "phase1") then
                    phase = 1
                    aura_env.order[1] = {
                        [1] = {}, [2] = {}, [3] = {}
                    }
                elseif string.find(line, "phase2") then
                    phase = 2
                    aura_env.order[2] = {
                        [1] = {}, [2] = {}, [3] = {}
                    }
                elseif string.find(line, "phase3") then
                    phase = 3
                    aura_env.order[3] = {
                        [1] = {}, [2] = {}, [3] = {}
                    }

                    -- not a great way to do this but it works
                elseif string.find(line, "star") then
                    for name in line:gmatch("%S+") do
                        if UnitInRaid(name) then
                            aura_env.prio[1] = name
                            break
                        end
                    end
                elseif string.find(line, "orange") then
                    for name in line:gmatch("%S+") do
                        if UnitInRaid(name) then
                            aura_env.prio[2] = name
                            break
                        end
                    end
                elseif string.find(line, "purple") then
                    for name in line:gmatch("%S+") do
                        if UnitInRaid(name) then
                            aura_env.prio[3] = name
                            break
                        end
                    end
                elseif string.find(line, "green") then
                    for name in line:gmatch("%S+") do
                        if UnitInRaid(name) then
                            aura_env.prio[4] = name
                            break
                        end
                    end
                end
                local num = 0
                for name in line:gmatch("%S+") do -- finding all remaining strings
                    if phaseorder and name ~= "phaseorder" then
                        local i = tonumber(name)
                        table.insert(aura_env.phaseorder, i)
                    elseif phase ~= 0 and not string.find(name, "phase") then
                        local i = tonumber(name)
                        local wave = math.ceil(i/4)
                        table.insert(aura_env.order[phase][wave], i)
                    end
                end
            end
        end
    end
end

---------------------

function(e, ...)
    if e == "NSAPI_ENCOUNTER_START" and ... then
        aura_env.casts = 0
        aura_env.phase = 0
        aura_env.phasenum = 0
        local diff = select(3, GetInstanceInfo()) or 0
        aura_env.multiplier = aura_env.diff[diff]
        aura_env.affected = {}
        aura_env.specs = NSAPI:GetSpecs()
        aura_env.prio = {
            [1] = "",
            [2] = "",
            [3] = "",
            [4] = "",
        }
        aura_env.MRT()

    elseif e == "ENCOUNTER_END" and aura_env.next then
        aura_env.next:Cancel()

    elseif e == "UNIT_SPELLCAST_SUCCEEDED" then
        local u, cast, spellID = ... -- Unit event
        if spellID == aura_env.blood then
            aura_env.casts = 0
            aura_env.phasenum = aura_env.phasenum+1
            aura_env.phase = aura_env.phaseorder[aura_env.phasenum] -- actual phase we are in depends on the order the user determines
            local aura_env = aura_env
            WeakAuras.ScanEvents("NS_OVINAX_NEXT", 55, aura_env.id)
        end
    elseif e == "NS_OVINAX_NEXT" then
        local duration, id = ...
        aura_env.casts = aura_env.casts and aura_env.casts+1 or 1
        if aura_env.id == id then
            if aura_env.config.enabled then -- only need to do this calculation if map is enabled
                if aura_env.casts <= 3 then
                    for i =1, 12 do
                        local num = 0
                        local type = 1 -- hide icon by default
                        for k, v in ipairs(aura_env.order[aura_env.phase][aura_env.casts]) do
                            if v == i then
                                type = 3 -- pre highlight with border if this is part of the next debuffs
                                num = k -- put number next to the icon
                                break
                            end
                        end
                        if type ~= 3 and aura_env.casts ~= 3 then
                            for j = aura_env.casts+1, 3 do
                                if tContains(aura_env.order[aura_env.phase][j], i) then
                                    type = 0 -- show icon if it's still being done in the future
                                    break
                                end
                            end
                        end
                        WeakAuras.ScanEvents("NS_OVINAX_EGG", i, aura_env.type[aura_env.phase][i], duration, type, aura_env.phase, num)
                    end
                else
                    WeakAuras.ScanEvents("NS_OVINAX_HIDE", true)
                end
            end
        end

    elseif e == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID = ... -- full CLEU
        if spellID == aura_env.debuff then
            local now = GetTime()
            if not aura_env.last or aura_env.last < now - 5 then
                aura_env.last = now
                aura_env.affected = {}
                local aura_env = aura_env
                C_Timer.After(aura_env.delay, function()
                        WeakAuras.ScanEvents("NS_ASSIGN_EVENT", aura_env.id)
                end)
                if aura_env.casts <= 2 then
                    aura_env.next = C_Timer.NewTimer(20, function() WeakAuras.ScanEvents("NS_OVINAX_NEXT", 50, aura_env.id) end)
                end
            end
            local i = UnitInRaid(destName)
            local unit = i and "raid"..i
            if unit and UnitExists(unit) then
                local G = destGUID or UnitGUID(unit)
                local spec = (aura_env.specs and aura_env.specs[unit]) or (NSAPI and NSAPI:GetSpecs(unit)) or WeakAuras.SpecForUnit(unit)
                local prio = spec and aura_env.spec and aura_env.spec[spec] or 0
                if prio == 0 then
                    print("no spec information found for:", WA_ClassColorName(destName), "You should probably reload/relog, can also be caused by ignore list.")
                    table.insert(aura_env.affected, {unit, G, prio})
                else
                    table.insert(aura_env.affected, {unit, G, prio})
                end
            end
        end
    elseif e == "NS_ASSIGN_EVENT" and aura_env.id == ... then
        local duration = 8 -- edit this if it gets nerfed or smth, cba checking debuff after it was removed from private aura
        table.sort(aura_env.affected,
            function(a, b)
                if a[3] == b[3] then -- sort by GUID if same spec
                    return a[2] < b[2]
                else
                    return a[3] < b[3]
                end

        end) -- a < b low first, a > b high first


        if #aura_env.affected > 5 then -- prevent error on heroic/wipes
            if aura_env.prio[1] or aura_env.prio[2] or aura_env.prio[3] or aura_env.prio[4] then -- Hard assign certain players specified through the note
                for k=1, 4 do
                    local i = k*2 -- this results in numbers 2, 4, 6, 8 which are the hard assign spots
                    local unit = aura_env.prio[k]
                    if unit and UnitExists(unit) and aura_env.affected[i] and UnitExists(aura_env.affected[i][1]) then
                        if UnitIsUnit(aura_env.affected[i][1], unit) or UnitIsUnit(aura_env.affected[i-1][1], unit) then
                            -- do nothing as the person alaready got assigned to the correct mark
                        else
                            -- unit isn't assigned to the mark (might not be assigned at all)
                            for j, v in ipairs(aura_env.affected) do
                                if UnitIsUnit(aura_env.affected[j][1], unit) then
                                    local temp = aura_env.affected[i]
                                    aura_env.affected[i] = v
                                    aura_env.affected[j] = temp
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end

        local me = 0
        for i, v in ipairs(aura_env.affected) do
            if UnitIsUnit(v[1], "player") then
                me = math.ceil(i/aura_env.multiplier)
                local partner = aura_env.multiplier > 1 and (i % 2 == 1 and i+1 or i-1) or 0
                partner = aura_env.affected[partner] and aura_env.affected[partner][1] or (aura_env.multiplier > 1 and "???") or ""
                WeakAuras.ScanEvents("NS_OVINAX_PARTNER", partner, me, duration)
            end
        end

        if aura_env.config.enabled then -- This is only relevant to the map display
            for i = 1, math.floor(#aura_env.affected/aura_env.multiplier) do
                local type = aura_env.order[aura_env.phase][aura_env.casts][i]
                local status = i == me and 4 or 2
                WeakAuras.ScanEvents("NS_OVINAX_EGG", type, aura_env.type[aura_env.phase][type], duration, status, aura_env.phase, i)
            end
            -- originally the following part was made if not enough people pressed macro but I'm keeping it to cover cases where a lot of people are dead somehow
            if #aura_env.affected < 4*aura_env.multiplier then
                for i = math.ceil((#aura_env.affected/aura_env.multiplier)+0.1), 4 do
                    local type = aura_env.order[aura_env.phase][aura_env.casts][i]
                    local status = i == me and 4 or 5
                    WeakAuras.ScanEvents("NS_OVINAX_EGG", type, aura_env.type[aura_env.phase][type], duration, status, aura_env.phase, i)
                end
            end
            WeakAuras.ScanEvents("NS_OVINAX_EGGDUR", duration, GetTime()+duration)
        end
    end
end
























































