trigger = function(event, ...)
    local aura_env = aura_env

    local function Emit(message, target)
        C_ChatInfo.SendAddonMessage("TMDM_ECWAv1", message, "WHISPER", target)
    end

    local function AssignDosages()
        if #aura_env.dosages == 0 then
            return
        end

        local unassigned = {}

        local function AssignLocked(player)
            for marker, locks in pairs(aura_env.locked) do
                for i, lock in ipairs(locks) do
                    if lock == player then
                        table.insert(aura_env.assignments[marker], player)
                        return
                    end
                end
            end
            table.insert(unassigned, player)
        end

        local function AssignUnlocked(player)
            for marker, assignments in pairs(aura_env.assignments) do
                if #assignments < 2 then
                    table.insert(assignments, player)
                    return
                end
            end
        end

        -- Assign locked players
        for i, player in ipairs(aura_env.dosages) do
            AssignLocked(player)
        end

        -- Assign left-over players
        for i, player in ipairs(unassigned) do
            AssignUnlocked(player)
        end

        -- Send out assignment messages
        for marker, assignments in pairs(aura_env.assignments) do
            local rt = "{rt" .. marker .. "}"
            SendChatMessage(rt .. ": " .. (assignments[1] or "(none)") .. " " .. (assignments[2] or "(none)"), "RAID")
            for i, player in ipairs(assignments) do
                Emit("c=SAY " .. rt .. ";m=" .. rt .. " DOSAGE " .. rt .. ";d=8", player)
                C_Timer.After(4, function()
                    Emit("c=SAY {rt" .. marker .. "}", player)
                end)
            end
        end

        -- Reset for next set
        aura_env.dosages = {}
        aura_env.assignments = { [6] = {}, [4] = {}, [3] = {}, [7] = {} }
    end

    if event == "ENCOUNTER_START" then
        aura_env.MRT()
        aura_env.dosages = {}
        aura_env.assignments = { [6] = {}, [4] = {}, [3] = {}, [7] = {} }
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID = ...
        if message == "SPELL_AURA_APPLIED" and spellID == 440421 then -- Experimental Dosage
            table.insert(aura_env.dosages, destName)
            if #aura_env.dosages == 1 then
                C_Timer.After(0.5, AssignDosages)
            elseif #aura_env.dosages == 8 then
                AssignDosages()
            end
        end
    end
end
