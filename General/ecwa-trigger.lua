trigger = function(event, ...)
    -- watch for mythic+ key queries in party chat
    if event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
        local message = ...
        if message == "!keys" or message == "?keys" then
            aura_env.printMythicPlusKey("PARTY")
        end
    end

    -- listen for addon messages from the party or raid leader
    if event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        if aura_env.isValidAddonMessage(prefix, channel, sender) then
            return aura_env.processAddonMessage(prefix, message, sender)
        end
    end
end
