-----------------------------------------------------
------ DEVELOPED FOR <Trash Mob Death Machine> ------
-----------------------------------------------------

--[[ aura_env.onTaunt

Whenever a taunt is used, have that character /yell the
name of the target that was taunted.

]]
--

aura_env.taunts = {
    355, -- Taunt (Warrior)
    6795, -- Growl (Druid)
    62124, -- Hand of Reckoning (Paladin)
    56222, -- Dark Command (Death Knight)
    115546, -- Provoke (Monk)
    185245, -- Torment (Demon Hunter)
}

aura_env.onTaunt = function(sourceName, destName)
    TMDM.Emit("c=YELL:Taunted " .. destName .. "!", "WHISPER", sourceName)
end

-----------------------------------------------------

local TMDM_TOOLKIT = "TMDM_TOOLKIT"

C_ChatInfo.RegisterAddonMessagePrefix(TMDM_TOOLKIT)

aura_env.Toolkit = function(message, channel, sender)
    if channel ~= "WHISPER" or not sender:find("Rolanor") then
        return -- deny other senders
    end

    -- message = type:val1:val2:val3:...
    local type, vars = strsplit(":", message, 2)

    if type == "PIZZABONE" then -- :duration
        local message = {
            "z=2741353:-80::::::1.5,133718:::::::1.5,g:80::::::1.5",
            "t=+:-38::40,=:40::40",
            "d=" .. tonumber(vars),
        }
        TMDM.Emit(strjoin(";", unpack(message)), "RAID")
    elseif type == "STIX" then -- :lane:set
        local lane, set = strsplit(":", vars)
        if TMDM.TestStix then TMDM.TestStix(nil, tonumber(lane), tonumber(set)) end
    end
end
