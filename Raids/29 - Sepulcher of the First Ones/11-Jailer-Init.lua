local aura_env = aura_env

aura_env.count = 1
aura_env.list = {}
aura_env.standard = {}
aura_env.priority = {}

aura_env.sides = {
    [1] = { --default
        [1] = { "FRONT", 1 },
        [2] = { "LEFT", 2 },
        [3] = { "RIGHT", 3 },
        [4] = { "BACK CENTER", 5 },
        [5] = { "BACK RIGHT", 6 },
        [6] = { "BACK LEFT", 4 },
    },
    [2] = { --priority
        [1] = { "FRONT", 1 },
        [2] = { "LEFT", 2 },
        [3] = { "BACK LEFT", 4 },
        [4] = { "BACK CENTER", 5 },
        [5] = { "RIGHT", 3 },
        [6] = { "BACK RIGHT", 6 },
    },
}

--MELEE / RANGE
--INSPECT LIB
aura_env.inspect = LibStub:GetLibrary("LibGroupInSpecT-1.1", true)
aura_env.openraid = LibStub:GetLibrary("LibOpenRaid-1.0", true)
aura_env.specToType = {
    --Death Knight
    [250] = "m", --Blood
    [251] = "m", --Frost
    [252] = "m", --Unholy
    --Demon Hunter
    [577] = "m", --Havoc
    [581] = "m", --Vengeance
    --Druid
    [102] = "r", --Balance
    [103] = "m", --Feral
    [104] = "m", --Guardian
    [105] = "r", --Restoration
    --Hunter
    [253] = "r", --Beast Mastery
    [254] = "r", --Marksmanship
    [255] = "m", --Survival
    --Mage
    [62] = "r", --Arcane
    [63] = "r", --Fire
    [64] = "r", --Frost
    --Monk
    [268] = "m", --Brewmaster
    [270] = "m", --Mistweaver
    [269] = "m", --Windwalker
    --Paladin
    [65] = "m", --Holy
    [66] = "m", --Protection
    [70] = "m", --Retribution
    --Priest
    [256] = "r", --Discipline
    [257] = "r", --Holy
    [258] = "r", --Shadow
    --Rogue
    [259] = "m", --Assassination
    [260] = "m", --Outlaw
    [261] = "m", --Subtlety
    --Shaman
    [262] = "r", --Elemental
    [263] = "m", --Enhancement
    [264] = "r", --Restoration
    --Warlock
    [265] = "r", --Affliction
    [266] = "r", --Demonology
    [267] = "r", --Destruction
    --Warrior
    [71] = "m", --Arms
    [72] = "m", --Fury
    [73] = "m", --Protection
}

aura_env.classToType = {
    [1] = "m", --Warrior
    [2] = "m", --Paladin
    --[3] = "", --Hunter
    [4] = "m", --Rogue
    [5] = "r", --Priest
    [6] = "m", --Death Knight
    --[7] = "", --Shaman
    [8] = "r", --Mage
    [9] = "r", --Warlock
    [10] = "m", --Monk
    --[11] = "", --Druid
    [12] = "m", --Demon Hunter
}

--NO LIB (SKADA/RECOUNT USERS OMEGAKEK)
aura_env.melee = {
    ["TANK"] = true,
    [1] = true, --Warrior
    [2] = true, --Paladin
    [4] = true, --Rogue
    [6] = true, --Death Knight
    [10] = true, --Monk
    [12] = true, --Demon Hunter
}
aura_env.mcasts = {
    [17364] = true, --Stormstrike
    [5217] = true, --Tiger's Fury
    [259491] = true, --Serpent Sting
}

aura_env.check = function(unit)
    if unit then
        local name, realm = UnitName(unit)
        if name then
            local myrealm = GetNormalizedRealmName()
            local fullname = format("%s-%s", name, realm or myrealm)

            local class = select(3, UnitClass(unit))
            local GUID = UnitGUID(unit)
            local role = UnitGroupRolesAssigned(unit)

            if aura_env.openraid then
                if aura_env.openraid.GetUnitInfo then
                    local info = aura_env.openraid.GetUnitInfo(unit)
                    if info and info.specId and aura_env.specToType[info.specId] then
                        return aura_env.specToType[info.specId], info.specId
                    end
                elseif aura_env.openraid.playerInfoManager then
                    local info = aura_env.openraid.playerInfoManager.GetPlayerInfo(name)
                        or aura_env.openraid.playerInfoManager.GetPlayerInfo(fullname)
                    if info and info.specId and aura_env.specToType[info.specId] then
                        return aura_env.specToType[info.specId], info.specId
                    end
                end
            end

            if aura_env.inspect and GUID then
                local info = aura_env.inspect:GetCachedInfo(GUID)
                if info and info.global_spec_id and aura_env.specToType[info.global_spec_id] then
                    return aura_env.specToType[info.global_spec_id], info.global_spec_id
                end
            end

            if VExRT and VExRT.ExCD2 and VExRT.ExCD2.gnGUIDs then
                local spec = VExRT.ExCD2.gnGUIDs[name] or VExRT.ExCD2.gnGUIDs[fullname]
                if spec and aura_env.specToType[spec] then
                    return aura_env.specToType[spec], spec
                end
            end

            if class and aura_env.classToType[class] then
                return aura_env.classToType[class], 0
            end

            if aura_env.melee[class] or aura_env.melee[GUID] or aura_env.melee[role] then
                return "m", 0
            end
        end
    end
end

aura_env.list = {}
aura_env.MRT = function()
    if (C_AddOns.IsAddOnLoaded("MRT") or C_AddOns.IsAddOnLoaded("ExRT")) and VExRT.Note.Text1 then
        aura_env.list = {}
        local count = 1

        local list = false
        local text = VExRT.Note.Text1
        for line in text:gmatch("[^\r\n]+") do
            line = strtrim(line) --trim whitespace
            --check for start/end of the name list
            if strlower(line) == "pstart" then
                list = true
            elseif strlower(line) == "pend" then
                list = false
            end

            if list then
                for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
                    local i = UnitInRaid(name)
                    local unit = i and "raid" .. i
                    if unit then
                        aura_env.list[unit] = count
                        count = count + 1
                    end
                end
            end
        end
    end
end
