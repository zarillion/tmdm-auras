trigger = function(event, ...)
    if not UnitIsGroupLeader("player") then
        return
    end

    local PREFIX = "TMDM_ECWAv1"
    local aura_env = aura_env

    local function Emit(message, target)
        C_ChatInfo.SendAddonMessage(PREFIX, message, "WHISPER", target)
    end

    local function GetRole(player)
        for i = 1, 40 do
            name, _, _, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)
            if name == player then
                return role
            end
        end
        return "UNKNOWN"
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, _, _, _, _, _, destName, _, _, spellID = ...

        if subevent == "SPELL_AURA_APPLIED" and spellID == 351827 then
            if GetRole(destName) ~= "TANK" then
                Emit("m1=RUN TO THE EDGE/WALL;s=moan", destName)
            end
        end

        if subevent == "SPELL_AURA_APPLIED" and spellID == 350713 then
            if select(2, UnitClass(destName)) == "WARLOCK" then
                Emit("m2=DISPEL YOURSELF NOOB;s=wilhelmscream", destName)
            end
        end
    end
end
