local aura_env = aura_env

aura_env.ASSASSINATION_CAST = 440650
aura_env.ASSASSINATION_DEBUFF = 436870
aura_env.QUEENSBANE_DEBUFF = 437343

aura_env.count = 0
aura_env.markers = {
    1, -- star
    2, -- circle
    4, -- triangle
    6, -- square
    7, -- cross
}

aura_env.Emit = function (message, target)
    C_ChatInfo.SendAddonMessage('TMDM_ECWAv1', message, 'WHISPER', target)
end
