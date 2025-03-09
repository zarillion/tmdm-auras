trigger = function(event, ...)
    if not UnitIsGroupLeader("player") then
        return
    end

    local PREFIX = "TMDM_ECWAv1"
    local aura_env = aura_env

    local function Colorize(name)
        local _, classFN = UnitClass(name)
        local color = RAID_CLASS_COLORS[classFN].colorStr
        return string.format("|c%s%s|r", color, string.upper(name))
    end

    local function Emit(message, target)
        C_ChatInfo.SendAddonMessage(PREFIX, message, "WHISPER", target)
    end

    local function EmitRaid(message, target)
        C_ChatInfo.SendAddonMessage(PREFIX, message, "RAID")
    end

    local function IsInner(player)
        for i, class in ipairs(aura_env.inners) do
            if class == select(2, UnitClass(player)) then
                return true
            end
        end
        return false
    end

    local function EmitPositions(inner, outer)
        EmitRaid("m1=OUTER: " .. Colorize(outer) .. ";m3=INNER: " .. Colorize(inner) .. ";d=20")
        Emit("s=wilhelmscream", inner)
        Emit("s=wilhelmscream", outer)
    end

    if event == "ENCOUNTER_START" then
        aura_env.debuffs = {}
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, _, _, _, _, _, destName, _, _, spellID = ...

        if subevent == "SPELL_AURA_APPLIED" and spellID == 350469 then -- Malevolence
            aura_env.debuffs[#aura_env.debuffs + 1] = destName
            if #aura_env.debuffs == 2 then
                local debuff1 = aura_env.debuffs[1]
                local debuff2 = aura_env.debuffs[2]
                if IsInner(debuff2) and select(2, UnitClass(debuff1)) ~= "PRIEST" then
                    EmitPositions(debuff2, debuff1)
                else
                    EmitPositions(debuff1, debuff2)
                end
                aura_env.debuffs = {}
            end
        end

        if subevent == "SPELL_AURA_REMOVED" and spellID == 350469 then
            EmitRaid("m1=;m3=")
        end

        if subevent == "SPELL_CAST_START" and (spellID == 351066 or spellID == 351067 or spellID == 351073) then
            EmitRaid("m2=|cFFFFFF00!!|r |cFFFF0000DEFENSIVES|r |cFFFFFF00!!|r;s=bikehorn") -- Shatter
        end
    end
end
