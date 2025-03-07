--------------------------------------------------------------------------------
-------------------- DEVELOPED FOR <Trash Mob Death Machine> -------------------
--------------------------------------------------------------------------------

-- This person will escort certain soulblights and the soulbomb in phase 2,
-- as well as soak orbs in phase 3.
local THIRD_TANK = "Razïmus"

-- These people will be picked as soulblight escorts
local ESCORTS = {
    THIRD_TANK,
    "Emp",
    "Omegapasta",
    "Phanita",
    "Zarillion",
    "Deepcast",
    "Cís",
    "Aziet",
    "Kokochan",
    "Totim",
    "Holyñova",
    "Promise",
}

local SOULBLIGHT_INFO = {
    "BACK LEFT > STACK > CONE",
    "BACK RIGHT > BAIT > CONE",
    "FRONT > CONE",
    "STACK > CONE > BACK LEFT",
    "FRONT > CONE",
    "BAIT BEHIND 5 > CONE",
    "STACK > CONE > BACK LEFT",
    "STACK > CONE > BACK RIGHT",
    "BACK LEFT",
    "BACK RIGHT",
    "FRONT LEFT",
    "FRONT RIGHT",
}

--------------------------------------------------------------------------------

local aura_env = aura_env
local PREFIX = "TMDM_ECWAv1"
local function colorize(name, upper)
    local _, classFN = UnitClass(name)
    local color = RAID_CLASS_COLORS[classFN].colorStr
    if upper then
        name = string.upper(name)
    end
    return string.format("|c%s%s|r", color, name)
end

--------------------------------------------------------------------------------

local DBM_OPTIONS = {
    announceother257869target = false, -- rage announce
    announceother257931target = false, -- fear announce
    SetIconGift = false, -- haste/crit orbs
    SetIconOnAvatar = false, -- tank circle
    SpecWarn248165dodge = true, -- dodge cone warning
    SpecWarn251570moveto = true, -- move with soulbomb warning
    SpecWarn257869moveaway = true, -- move with rage warning
    SpecWarn257931moveto = false, -- move with fear warning
    Yell248396 = false, -- soulblight /say
    Yell257869shortyell = false, -- rage /say
    Yell257931combo = false, -- fear combo yell
    Yell257931shortyell = false, -- fear /say
    Yell258646position = false, -- sky /say
    Yell258647position = false, -- sea /say
}

aura_env.setDBMOptions = function()
    for option, value in pairs(DBM_OPTIONS) do
        SendAddonMessage(PREFIX, "bm=2092:" .. option .. "=" .. tostring(value), "RAID")
    end
end

--------------------------------------------------------------------------------

local GIFT_OF_THE_SKY = select(3, GetSpellInfo(258646))
local GIFT_OF_THE_SEA = select(3, GetSpellInfo(258647))

aura_env.warnGiftSky = function(name)
    local texture = "|T" .. GIFT_OF_THE_SKY .. ":0|t"
    SendAddonMessage(PREFIX, "m=" .. texture .. " LEFT " .. texture, "WHISPER", name)
end

aura_env.warnGiftSea = function(name)
    local texture = "|T" .. GIFT_OF_THE_SEA .. ":0|t"
    SendAddonMessage(PREFIX, "m=" .. texture .. " RIGHT " .. texture, "WHISPER", name)
end

--------------------------------------------------------------------------------

local function assignEscort(target, canEscortMechanic)
    for i, escort in ipairs(ESCORTS) do
        if
            escort ~= target
            and UnitIsVisible(escort)
            and not UnitIsDead(escort)
            and not UnitDebuff(escort, "Sargeras' Rage")
            and canEscortMechanic(escort)
        then
            return escort
        end
    end
    return THIRD_TANK -- good luck!!
end

--------------------------------------------------------------------------------

local SOULBLIGHTS = {} -- {{target=, escort=}, {target=, escort=}, ...}
local SOULBLIGHT_MARKS = {
    { "square", 6 },
    { "triangle", 4 },
    { "diamond", 3 },
    { "cross", 7 },
}

local function canEscortSoulblight(name)
    if UnitDebuff(name, "Soulblight") then
        return false
    end
    for i, soulblight in ipairs(SOULBLIGHTS) do
        if soulblight.escort == name then
            return false
        end
    end
    return true
end

local function notifySoulblight(number, soulblight)
    local duration = math.floor(8 - (GetTime() - soulblight.time) + 1)
    local markName, markID = unpack(SOULBLIGHT_MARKS[(number - 1) % 4 + 1])
    local chat = "YELL Soulblight " .. number
    local msg = "SOULBLIGHT " .. number
    if soulblight.escort then
        msg = msg .. " (" .. colorize(soulblight.escort, true) .. ")"
    end
    msg = "{" .. markName .. "} " .. msg .. " {" .. markName .. "}"
    msg = msg .. "\n" .. (SOULBLIGHT_INFO[number] or "YOLO")
    local data = "m=" .. msg .. ";c=" .. chat .. ";d=" .. duration
    SetRaidTarget(soulblight.target, markID)
    SendAddonMessage(PREFIX, data, "WHISPER", soulblight.target)
end

local function notifySoulblightEscort(number, soulblight)
    local duration = math.floor(8 - (GetTime() - soulblight.time) + 3)
    local mark = SOULBLIGHT_MARKS[(number - 1) % 4 + 1][1]
    local msg = "ESCORT " .. colorize(soulblight.target, true) .. " (" .. number .. ")"
    local data = "m={" .. mark .. "} " .. msg .. " {" .. mark .. "};s=bikehorn;d=" .. duration
    SendAddonMessage(PREFIX, data, "WHISPER", soulblight.escort)
end

aura_env.soulblightNum = 0
aura_env.assignSoulblight = function(name)
    aura_env.soulblightNum = aura_env.soulblightNum + 1
    local number = aura_env.soulblightNum
    if number == 1 then
        SOULBLIGHTS = {} -- new pull, clear out any escorts
    end

    -- create our soulblight record and assign an escort if required
    local soulblight = { target = name, escort = nil, time = GetTime() }
    if number > 4 and UnitDebuff(name, "Sargeras' Fear") then
        soulblight.escort = assignEscort(name, canEscortSoulblight)
        notifySoulblightEscort(number, soulblight)
    end
    notifySoulblight(number, soulblight)
    SOULBLIGHTS[#SOULBLIGHTS + 1] = soulblight

    -- if we were already escorting someone, replace that escort
    for i, soulblight in ipairs(SOULBLIGHTS) do
        if soulblight.escort == name then
            soulblight.escort = assignEscort(name, canEscortSoulblight)
            notifySoulblight(i, soulblight)
            notifySoulblightEscort(i, soulblight)
        end
    end
end

aura_env.clearSoulblight = function(name)
    SetRaidTarget(name, 0)

    -- free up our escort (if any)
    for i, soulblight in ipairs(SOULBLIGHTS) do
        if soulblight.target == name then
            soulblight.escort = nil
        end
    end
end

--------------------------------------------------------------------------------

local SENTENCE1 = nil
local SENTENCE2 = nil

local SENTENCE_CLASS_PRIORITY = {
    2, -- warrior
    1, -- paladin
    3, -- hunter
    1, -- rogue
    1, -- priest
    1, -- death knight
    2, -- shaman
    3, -- mage
    -100, -- warlock
    2, -- monk
    2, -- druid
    2, -- demon hunter
}

local function notifySentenceBreak(name, count)
    local inst = count == 4 and "AFTER BLADES" or "NOW"
    local msg = "m=|cff00ff00BREAK " .. inst .. "!|r;s=phone;d=15"
    if UnitDebuff(name, "Sargeras' Fear") then
        msg = msg .. ";c=YELL ESCORT ME!!"
    end
    SendAddonMessage(PREFIX, msg, "WHISPER", name)
end

local function notifySentenceHold(name)
    local msg = "m=|cffff0000DON'T BREAK!|r;d=15"
    SendAddonMessage(PREFIX, msg, "WHISPER", name)
end

local function getSentencePriority(name, count)
    local fearStacks = select(4, UnitDebuff(name, "Crushing Fear")) or 0
    local rageStacks = select(4, UnitDebuff(name, "Unleashed Rage")) or 0
    local clsPriority = SENTENCE_CLASS_PRIORITY[select(3, UnitClass(name))]
    return (fearStacks + rageStacks) * 100 + clsPriority
end

aura_env.sentenceNum = 0
aura_env.assignSentence = function(name)
    aura_env.sentenceNum = aura_env.sentenceNum + 1
    if aura_env.sentenceNum % 2 == 1 then
        SENTENCE1 = name
        C_Timer.After(1, function()
            -- we only got one (probably on tank during mass death)
            if aura_env.sentenceNum % 2 == 1 then
                aura_env.sentenceNum = aura_env.sentenceNum + 1
            end
        end)
    else
        SENTENCE2 = name

        if aura_env.sentenceNum == 2 then
            notifySentenceBreak(SENTENCE1, aura_env.sentenceNum)
            notifySentenceBreak(SENTENCE2, aura_env.sentenceNum)
        else
            local priority1 = getSentencePriority(SENTENCE1, aura_env.sentenceNum)
            local priority2 = getSentencePriority(SENTENCE2, aura_env.sentenceNum)
            if priority1 > priority2 then
                notifySentenceBreak(SENTENCE1, aura_env.sentenceNum)
                notifySentenceHold(SENTENCE2)
            else
                notifySentenceHold(SENTENCE1)
                notifySentenceBreak(SENTENCE2, aura_env.sentenceNum)
            end
        end

        if UnitInParty("Promise") then -- notify wife
            SendAddonMessage(PREFIX, "s=airhorn;c=YELL 2 CHAINZ - Watch Out (Explicit)!", "WHISPER", "Promise")
        end
    end
end

--------------------------------------------------------------------------------

aura_env.emoteCrushingFear = function(name, stacks)
    local message = colorize(name) .. " is drowned in Crushing Fear"
    if stacks > 1 then
        message = message .. " (" .. stacks .. ")"
    end
    SendAddonMessage(PREFIX, "e=" .. message .. "!", "RAID")
end

aura_env.emoteUnleashedRage = function(name, stacks)
    local message = colorize(name) .. " is filled with Unleashed Rage"
    if stacks > 1 then
        message = message .. " (" .. stacks .. ")"
    end
    SendAddonMessage(PREFIX, "e=" .. message .. "!", "RAID")
end

aura_env.emoteEmberOfRage = function(name, stacks)
    local message = colorize(name) .. " is hit by an Ember of Rage"
    if stacks > 1 then
        message = message .. " (" .. stacks .. ")"
    end
    SendAddonMessage(PREFIX, "e=" .. message .. "!", "RAID")
end

--------------------------------------------------------------------------------
