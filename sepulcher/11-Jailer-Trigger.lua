function (event, ...)
    local aura_env = aura_env

    local function Emit (message, target)
        C_ChatInfo.SendAddonMessage('TMDM_ECWAv1', message, 'WHISPER', target)
    end

    if event == "ENCOUNTER_START" and ... then
        aura_env.MRT()
        aura_env.p4 = false
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and ... then
        local _, message, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellid = ...
        if message == "SPELL_CAST_SUCCESS" then
            if spellid == 368383 or spellid == 363772 then --Diverted Life Shield / Death Sentence
                aura_env.p4 = true --disable p4
            elseif aura_env.mcasts[spellid] and not aura_env.melee[srcGUID] then
                aura_env.melee[srcGUID] = true
            end
        elseif message == "SPELL_AURA_APPLIED" and spellid == 360281 then --Rune of Damnation
            local theTime = GetTime()
            if not aura_env.last or aura_env.last < theTime - 5 then
                aura_env.last = theTime

                aura_env.sides = {
                    [1] = { --default
                        [1] = {"FRONT", 1},
                        [2] = {"LEFT", 2},
                        [3] = {"RIGHT", 3},
                        [4] = {"BACK CENTER", 5},
                        [5] = {"BACK RIGHT", 6},
                        [6] = {"BACK LEFT", 4},
                    },
                    [2] = { --priority
                        [1] = {"FRONT", 1},
                        [2] = {"LEFT", 2},
                        [3] = {"BACK LEFT", 4},
                        [4] = {"BACK CENTER", 5},
                        [5] = {"RIGHT", 3},
                        [6] = {"BACK RIGHT", 6},
                    },
                }

                aura_env.count = 1
                aura_env.standard = {}
                aura_env.priority = {}

                C_Timer.After(0.2, function()
                        WeakAuras.ScanEvents("DAMNATION_CHECK", true)
                end)
            end

            local i = UnitInRaid(destName)
            local unit = i and "raid"..i
            if unit then
                local combatType = aura_env.check(unit)
                combatType = combatType or "r"

                if aura_env.list[unit] then
                    table.insert(aura_env.priority, {unit, destName, combatType, aura_env.list[unit]})

                    local toDelete = aura_env.sides[2][aura_env.count][1]
                    for k, v in ipairs(aura_env.sides[1]) do
                        if v[1] == toDelete then
                            table.remove(aura_env.sides[1], k)
                            break
                        end
                    end

                    aura_env.count = aura_env.count + 1
                else
                    table.insert(aura_env.standard, {unit, destName, combatType})
                end
            end
        end

    elseif event == "DAMNATION_CHECK" then
        table.sort(aura_env.standard, function(a, b) return a[3] < b[3] end) --melee 1st
        table.sort(aura_env.priority, function(a, b) return a[4] < b[4] end) --MRT note priority

        local standard = aura_env.sides[1]
        local priority = aura_env.sides[2]

        local players = {
            [1] = "Player1",
            [2] = "Player2",
            [3] = "Player3",
            [4] = "Player4",
            [5] = "Player5",
            [6] = "Player6"
        }

        for i, data in ipairs(aura_env.priority) do
            local unit, destName = data[1], data[2]
            if unit then
                local side, pattern = priority[i][1], priority[i][2]
                players[pattern] = destName
                Emit("m=JUMP "..side.."!;s=bikehorn;d=6;c=YELL "..side, destName)
                C_Timer.After(3, function () Emit("c=YELL "..side, destName) end)
                print("priority", i, unit, destName, side, pattern)
            end
        end

        for i, data in ipairs(aura_env.standard) do
            local unit, destName = data[1], data[2]
            if unit then
                local side, pattern = standard[i][1], standard[i][2]
                players[pattern] = destName
                Emit("m=JUMP "..side.."!;s=bikehorn;d=6;c=YELL "..side, destName)
                C_Timer.After(3, function () Emit("c=YELL "..side, destName) end)
                print("standard", i, unit, destName, side, pattern)
            end
        end

        print(strjoin(';', unpack(players)))
        C_ChatInfo.SendAddonMessage("TMDM_DAMNATION", strjoin(';', unpack(players)), "RAID")
    end
end

