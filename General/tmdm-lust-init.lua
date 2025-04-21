local aura_env = aura_env

aura_env.fired = false
aura_env.LUSTS = {
    -- 5697, -- Unending Breath
    2825, -- Bloodlust
    32182, -- Heroism
    80353, -- Time Warp
    264667, -- Primal Rage
    390386, -- Fury of the Aspects
    466904, -- Harrier's Cry
}

local function Emit(message)
    TMDM.Emit(message, "RAID")
end

local function GenerateRandomBananas()
    local bananas = {}

    for _ = 1, 16 do
        local shape = TMDM.Shape({
            type = 133979,
            x = math.random(-100, 100),
            y = math.random(-100, 100),
            scale = math.random() * 2 + 0.5,
            -- angle = math.random() * 2 * math.pi,
        })
        table.insert(bananas, shape:Serialize())
    end

    return bananas
end

local function GetPlayers()
    local players = {}
    for unit in WA_IterateGroupMembers() do
        local name = UnitName(unit)
        table.insert(players, name)
    end
    return players
end

local function GetRandomPlayers(count)
    local players = GetPlayers()
    local chosen = {}
    for _ = 1, count do
        if #players > 0 then
            local index = math.random(#players)
            table.insert(chosen, table.remove(players, index))
        end
    end
    return strjoin(",", unpack(chosen))
end

local EMOTE = "e=%s's lust for blood summons something in the distance ..."

function aura_env.ApesTogetherStrong(name)
    if aura_env.fired then return end

    -- 1 in 100 chance of happening
    -- if math.random(100) ~= 100 then return end

    aura_env.fired = true

    local emote = string.format(EMOTE, TMDM.Colorize(name))
    local bananas = GenerateRandomBananas()

    Emit(strjoin(";", emote, "s=tmdmlust"))

    -- Bananas
    C_Timer.After(10, function()
        Emit("d=10;z=" .. bananas[1])
    end)
    C_Timer.After(15, function()
        -- Emit("z=" .. table.concat(bananas, ",", 1, 2))
    end)
    C_Timer.After(17, function()
        -- Emit("z=" .. table.concat(bananas, ",", 1, 3))
    end)
    C_Timer.After(18, function()
        -- Emit("z=" .. table.concat(bananas, ",", 1, 4))
    end)
    C_Timer.After(20, function()
        Emit("d=10;z=" .. table.concat(bananas, ",", 1, 3))
    end)
    C_Timer.After(22, function()
        -- Emit("z=" .. table.concat(bananas, ",", 1, 7))
    end)
    C_Timer.After(24, function()
        -- Emit("z=" .. table.concat(bananas, ",", 1, 9))
    end)
    C_Timer.After(27, function()
        -- Emit("z=" .. table.concat(bananas, ",", 1, 11))
    end)
    C_Timer.After(31, function()
        Emit("d=10;z=" .. table.concat(bananas, ",", 1, 5))
    end)
    C_Timer.After(34, function()
        -- Emit("z=" .. table.concat(bananas, ",", 1, 13))
    end)
    C_Timer.After(37, function()
        -- Emit("z=" .. table.concat(bananas, ",", 1, 16))
    end)

    -- Messages
    C_Timer.After(5, function()
        Emit("m=Lust?")
    end)
    C_Timer.After(10, function()
        Emit("m=Lust????")
    end)
    C_Timer.After(15, function()
        Emit("m=LUST?!?!?")
    end)
    C_Timer.After(27, function()
        Emit("m1=|cffff0000! LUST !|r;d=1")
    end)
    C_Timer.After(28, function()
        Emit("m2=|cffff0000!! LUST !!|r;d=1")
    end)
    C_Timer.After(29, function()
        Emit("m3=|cffff0000!!! LUST !!!|r;d=1")
    end)
    C_Timer.After(31, function()
        Emit("m=|cffff0000!!! LUUST !!!|r;d=1")
    end)
    C_Timer.After(33, function()
        Emit("m=|cffff0000!!! LUUUST !!!|r;d=1")
    end)
    C_Timer.After(35, function()
        Emit("m=|cffff0000!!! LUUUUST !!!|r;d=1")
    end)

    -- Chats
    C_Timer.After(6, function()
        Emit("c=SAY:ook-ook?;f=" .. GetRandomPlayers(1))
    end)
    C_Timer.After(9, function()
        -- Emit("c=SAY:ook-ook?;f=" .. GetRandomPlayers(2))
    end)
    C_Timer.After(12, function()
        Emit("c=SAY:ook-ook?;f=" .. GetRandomPlayers(3))
    end)
    C_Timer.After(15, function()
        -- Emit("c=YELL:OOK-OOK;f=" .. GetRandomPlayers(4))
    end)
    C_Timer.After(17, function()
        Emit("c=YELL:OOK-OOK;f=" .. GetRandomPlayers(5))
    end)
    C_Timer.After(19, function()
        Emit("c=YELL:ME LIKE ELON MUSK;f=" .. GetRandomPlayers(1))
    end)
    C_Timer.After(21, function()
        Emit("c=YELL:OOK-OOK;f=" .. GetRandomPlayers(7))
    end)
    C_Timer.After(23, function()
        -- Emit("c=YELL:OOKA-OOKA;f=" .. GetRandomPlayers(8))
    end)
    C_Timer.After(25, function()
        Emit("c=YELL:UNGA-BUNGA;f=" .. GetRandomPlayers(5))
    end)
    C_Timer.After(27, function()
        Emit("c=YELL:APES TOGETHER STRONG;f=" .. GetRandomPlayers(5))
    end)
    C_Timer.After(29, function()
        Emit("c=YELL:OOUUUUK;f=" .. GetRandomPlayers(5))
    end)
    C_Timer.After(31, function()
        Emit("c=YELL:TRUMP;f=" .. GetRandomPlayers(1))
    end)
    C_Timer.After(33, function()
        Emit("c=YELL:OOKA-OOKA;f=" .. GetRandomPlayers(5))
    end)
    C_Timer.After(35, function()
        Emit("c=YELL:IMMA OOK YOU IN THE DOOKER;f=" .. GetRandomPlayers(4))
    end)
    C_Timer.After(37, function()
        Emit("c=YELL:ME OOKERED OUT;f=" .. GetRandomPlayers(2))
    end)
    C_Timer.After(39, function()
        Emit("c=YELL:OOK MISS DWARFDOOK;f=" .. GetRandomPlayers(1))
    end)
end
