trigger = function(event, ...)
    if not UnitIsGroupLeader("player") then
        return
    end

    local PREFIX = "TMDM_ECWAv1"
    local aura_env = aura_env

    local function Emit(message, target)
        C_ChatInfo.SendAddonMessage(PREFIX, message, "WHISPER", target)
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, _, _, _, _, _, _, _, _, spellID, spellName = ...
        if subevent == "SPELL_AURA_APPLIED_DOSE" then
        end
    end
end
