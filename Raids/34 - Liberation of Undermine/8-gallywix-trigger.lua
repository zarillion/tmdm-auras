trigger = function(event, ...)
    local aura_env = aura_env
    if event == "ENCOUNTER_START" then
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, message, _, _, srcName, _, _, _, destName, _, _, spellID = ...
    end
end
