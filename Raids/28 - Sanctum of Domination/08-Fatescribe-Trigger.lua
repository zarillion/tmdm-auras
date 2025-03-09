trigger = function(event, ...)
    if not UnitIsGroupLeader("player") then
        return
    end

    local HEROIC = 15
    local MYTHIC = 16
    local aura_env = aura_env

    local function Emit(message, target)
        C_ChatInfo.SendAddonMessage("TMDM_ECWAv1", message, "WHISPER", target)
    end

    local function EmitRaid(message)
        C_ChatInfo.SendAddonMessage("TMDM_ECWAv1", message, "RAID")
    end

    local function UnitPercent(unit)
        local cur = UnitHealth(unit)
        local max = UnitHealthMax(unit)
        if cur > 0 and max > 0 then
            return cur / max
        end
        return 1
    end

    local function GetClass(player)
        return select(2, UnitClass(player))
    end

    local function GetRole(player)
        for i = 1, 40 do
            name, _, _, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)
            if name == player then
                -- Let raid leader focus as backup on intermissions
                if UnitIsGroupLeader(name) and aura_env.affset < 3 and role == "DAMAGER" then
                    return "HEALER"
                end
                return role
            end
        end
        return "UNKNOWN"
    end

    local function AssignRune(player, position)
        if position == 0 then
            Emit("m=BACKUP RUNE DUTY;d=10;s=moan", player)
        else
            local marker = aura_env.aff_markers[position]
            local markrt = "{rt" .. tostring(marker) .. "}"
            SetRaidTarget(player, marker)
            Emit(
                "m1=" .. markrt .. " RUNE DUTY BIATCH (" .. position .. ") " .. markrt .. ";m3=(>^.(>O.o)>;d=30;s=moan",
                player
            )
        end
    end

    local function AssignRunes()
        table.sort(aura_env.debuffs, function(a, b)
            return aura_env.rune_classes[a[2]] > aura_env.rune_classes[b[2]]
        end)

        local diff = aura_env.difficulty
        local set = aura_env.affset
        local rune = 6

        for i, debuff in ipairs(aura_env.debuffs) do
            -- On heroic, assign the tank if there are 6 or fewer debuffs
            -- On mythic intermissions, always assign the tank to the inner-most ring
            if debuff[3] == "TANK" and ((diff == MYTHIC and set < 3) or #aura_env.debuffs <= 6) then
                AssignRune(debuff[1], 1)
            elseif debuff[3] == "DAMAGER" or (debuff[3] == "HEALER" and #aura_env.debuffs <= 7) then
                -- Assign all 6 runes on heroic
                -- Assign outer 5 on mythic intermissions and all 6 in p3
                if (diff == HEROIC and rune > 0) or (diff == MYTHIC and (rune > 1 or (rune > 0 and set > 2))) then
                    AssignRune(debuff[1], rune)
                    rune = rune - 1
                else
                    AssignRune(debuff[1], 0) -- backups
                end
            elseif debuff[3] == "HEALER" then
                -- Assign extra healers as backups
                AssignRune(debuff[1], 0)
            end
        end

        aura_env.affset = aura_env.affset + 1
        aura_env.debuffs = {}
    end

    if event == "ENCOUNTER_START" then
        aura_env.affset = 1
        aura_env.debuffs = {}
        aura_env.p1StopCalled = false
        aura_env.p2StopCalled = false
        aura_env.difficulty = select(3, GetInstanceInfo())
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, _, _, _, _, _, destName, _, _, spellID = ...

        local boss = UnitPercent("boss1")
        if boss and boss < 0.74 and not aura_env.p1StopCalled then
            EmitRaid("m=|cFFFF0000KILL THE ADD YOU APES|r;s=bikehorn")
            aura_env.p1StopCalled = true
        end
        if boss and boss < 0.43 and not aura_env.p2StopCalled then
            EmitRaid("m=|cFFFF0000STOP MONKEYS, KILL THE ADD|r;s=bikehorn")
            aura_env.p2StopCalled = true
        end

        if subevent == "SPELL_AURA_APPLIED" and spellID == 354365 then -- Grim Portent
            Emit("m=FIND YOUR RUNE!;s=bikehorn;d=8", destName)
        end

        if subevent == "SPELL_AURA_APPLIED" and spellID == 354964 then -- Runic Affinity
            aura_env.debuffs[#aura_env.debuffs + 1] = { destName, GetClass(destName), GetRole(destName) }
            if #aura_env.debuffs == 1 then
                C_Timer.After(1, AssignRunes)
            end
        end

        if subevent == "SPELL_AURA_REMOVED" and spellID == 354964 then
            SetRaidTarget(destName, 0)
        end
    end
end
