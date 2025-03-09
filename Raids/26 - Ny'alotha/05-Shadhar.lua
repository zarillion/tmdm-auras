trigger = function(event, ...)
    if not UnitIsGroupLeader("player") then
        return
    end
    local aura_env = aura_env

    local function Emit(message, target)
        C_ChatInfo.SendAddonMessage("TMDM_ECWAv1", message, "WHISPER", target)
    end

    local function Colorize(name)
        local _, classFN = UnitClass(name)
        local color = RAID_CLASS_COLORS[classFN].colorStr
        return string.format("|c%s%s|r", color, string.upper(name))
    end

    local function AssignExternalCD(destName)
        -- assign tiger's lusts first because of the movement speed
        for i, name in ipairs(aura_env.tigerLusts) do
            if (GetTime() - aura_env.lastSupportCast[name]) > 29 and not UnitIsDead(name) then
                Emit("m2=TIGER'S LUST: " .. Colorize(destName) .. ";s=bikehorn", name)
                Emit("m2=TIGER'S LUST: " .. Colorize(name), destName)
                return
            end
        end

        -- assign blessing of freedom
        for i, name in ipairs(aura_env.freedoms) do
            if (GetTime() - aura_env.lastSupportCast[name]) > 24 and not UnitIsDead(name) then
                Emit("m2=BLESSING OF FREEDOM: " .. Colorize(destName) .. ";s=bikehorn", name)
                Emit("m2=BLESSING OF FREEDOM: " .. Colorize(name), destName)
                return
            end
        end

        Emit("m=|cFFFF0000NO FREEDOM AVAILABLE!!|r;s=wilhelmscream", destName)
    end

    if event == "ENCOUNTER_START" then
        aura_env.fixateCount = 0
        aura_env.lastSupportCast = {}
        aura_env.freedoms = {}
        aura_env.tigerLusts = {}
        aura_env.targetClasses = { "WARRIOR", "PALADIN", "ROGUE", "PRIEST", "DEATHKNIGHT", "MAGE", "MONK" }

        -- figure out what CDs we have
        for i = 1, 40 do
            name, _, subgroup, _, _, class = GetRaidRosterInfo(i)
            if name and subgroup < 5 then
                if class == "PALADIN" then
                    aura_env.freedoms[#aura_env.freedoms + 1] = name
                    aura_env.lastSupportCast[name] = 0
                elseif class == "MONK" then
                    aura_env.tigerLusts[#aura_env.tigerLusts + 1] = name
                    aura_env.lastSupportCast[name] = 0
                end
            end
        end
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, _, sourceName, _, _, _, destName, _, _, spellID, spellName = ...

        -- watch for freedom and tiger's lust casts to track CDs
        if subevent == "SPELL_CAST_SUCCESS" and (spellID == 1044 or spellID == 116841) then
            aura_env.lastSupportCast[sourceName] = GetTime()
        end

        -- assign a cd to each fixated person
        if subevent == "SPELL_AURA_APPLIED" and spellID == 318078 then
            aura_env.fixateCount = aura_env.fixateCount + 1
            Emit("m1=FIXATE " .. aura_env.fixateCount .. ";d=10;s=wilhelmscream", destName)
            SendChatMessage("Fixate " .. aura_env.fixateCount .. ": " .. destName, "RAID")

            -- see if they can get themselves, then assign others
            local class = select(2, UnitClass(destName))
            if class == "PALADIN" and (GetTime() - aura_env.lastSupportCast[destName]) > 24 then
                Emit("m2=BLESSING OF FREEDOM: " .. Colorize(destName), destName)
            elseif class == "MONK" and (GetTime() - aura_env.lastSupportCast[destName]) > 29 then
                Emit("m2=TIGER'S LUST: " .. Colorize(destName), destName)
            else
                for i, c in ipairs(aura_env.targetClasses) do
                    if class == c then
                        AssignExternalCD(destName)
                    end
                end
            end
        end
    end
end
