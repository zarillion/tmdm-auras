trigger = function(event, ...)
    if not UnitIsGroupLeader("player") then
        return
    end

    local aura_env = aura_env

    local function Emit(message, target)
        C_ChatInfo.SendAddonMessage("TMDM_ECWAv1", message, "WHISPER", target)
    end

    local function EmitRaid(message, target)
        C_ChatInfo.SendAddonMessage("TMDM_ECWAv1", message, "RAID")
    end

    local function UnitPercent(unit)
        local cur = UnitHealth(unit)
        local max = UnitHealthMax(unit)
        if cur > 0 and max > 0 then
            return (cur / max) * 100
        end
        return 100
    end

    local function IterateActiveGroup(includeDead, maxSubGroup)
        maxSubGroup = maxSubGroup or 4
        local i = 0
        local function SpecPosition(spec)
            for _, id in ipairs({ 62, 63, 64, 102, 105, 253, 254, 256, 257, 258, 262, 264, 265, 266, 267 }) do
                if spec == id then
                    return "RANGED"
                end
            end
            return "MELEE"
        end
        return function()
            while i < 40 do
                i = i + 1
                local name, _, subgroup, _, _, class, _, online, isDead, _, _, role = GetRaidRosterInfo(i)
                if subgroup <= maxSubGroup and online and (not isDead or includeDead) then
                    local spec = Details.cached_specs[UnitGUID("raid" .. i)]
                    local position = spec and SpecPosition(spec) or nil
                    return name, class, role, spec, position, subgroup
                end
            end
        end
    end

    local function AssignChain(player, position, stacks)
        local set = aura_env.chains_set
        local count = aura_env.chain_count

        -- Skip ranged on set 2 that do not need to reset
        if set == 2 and position == "RANGED" and stacks < 2 then
            return
        end
        -- Do not assign Rolanor to right side on set 1
        if player == "Rolanor" and set == 1 and count >= 4 then
            return
        end
        -- Do not assign Graggars/Bpaptu to right side on set 2
        if (player == "Graggars" or player == "Bpaptu") and set == 2 and count >= 4 then
            return
        end
        -- Do not assign Saeyra to right side on set 1 or 3
        if player == "Saeyra" and (set == 1 or set == 3) and count >= 4 then
            return
        end
        -- Do not assign Arimist on set 3 to either side
        if player == "Arimist" and set == 3 then
            return
        end

        aura_env.chain_count = aura_env.chain_count + 1
        if aura_env.chain_count <= 4 then
            print("LEFT:", player)
            Emit("m1=<< LEFT (1) <<;c=YELL LEFT;s=bikehorn;d=7", player)
            C_Timer.After(3, function()
                Emit("c=YELL LEFT", player)
            end)
        elseif aura_env.chain_count <= 8 then
            print("RIGHT:", player)
            Emit("m1=>> RIGHT (2) >>;c=YELL RIGHT;s=bikehorn;d=7", player)
            C_Timer.After(3, function()
                Emit("c=YELL RIGHT", player)
            end)
        end
    end

    local function AssignChains()
        if WA_GetUnitBuff("boss1", 350857) then
            return
        end -- Banshee Shroud = final chains
        aura_env.chains_set = aura_env.chains_set + 1
        aura_env.chain_count = 0

        -- Query eligible debuffs
        local debuffs = {}
        for name, _, _, _, position in IterateActiveGroup() do
            debuffs[#debuffs + 1] = {
                name,
                position,
                select(3, WA_GetUnitDebuff(name, 347807)) or 0,
                UnitIsGroupLeader(name) and 100 or math.random(100), -- random
            }
        end

        -- Sort debuffs by stack count, then name
        table.sort(debuffs, function(a, b)
            if a[3] ~= b[3] then
                return a[3] > b[3]
            end
            if a[4] ~= b[4] then
                return a[4] < b[4]
            end
            return a[1] < b[1] -- order by name last
        end)

        -- Assign chain soaks left/right
        for i, debuff in ipairs(debuffs) do
            AssignChain(debuff[1], debuff[2], debuff[3])
        end
    end

    if event == "ENCOUNTER_START" then
        aura_env.chains_set = 0
        aura_env.veil_count = 1
        aura_env.stopCalled = false
        aura_env.lastPercentUpdate = GetTime()
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, _, _, _, _, _, destName, _, _, spellID = ...

        if subevent == "SPELL_CAST_START" and spellID == 349419 then -- Domination Chains
            AssignChains()
        end

        if subevent == "SPELL_CAST_START" and spellID == 347726 then -- Veil of Darkness P1
            aura_env.veil_count = aura_env.veil_count + 1
        end

        if subevent == "SPELL_AURA_APPLIED" and spellID == 351451 then -- Curse of Lethargy
            for name, class in IterateActiveGroup() do
                if
                    class == "DRUID"
                    or class == "SHAMAN"
                    or class == "MAGE"
                    or class == "PALADIN"
                    or class == "MONK"
                then
                    Emit("g=" .. destName .. ";d=6;m=DECURSE NAO!", name)
                end
            end
        end

        if subevent == "SPELL_AURA_REMOVED" and spellID == 351451 then -- Curse of Lethargy
            EmitRaid("g=" .. destName .. ";d=0")
        end

        local boss = UnitPercent("boss1")
        if boss < 85 and boss >= 84 then
            if not aura_env.stopCalled then
                EmitRaid("m1=|cFFFF0000SLOW DPS|r;s=bikehorn")
                aura_env.stopCalled = true
            end

            if GetTime() - aura_env.lastPercentUpdate > 0.2 then
                EmitRaid("m2=>> " .. string.format("%.2f", boss) .. " <<")
                aura_env.lastPercentUpdate = GetTime()
            end
        end
    end
end
