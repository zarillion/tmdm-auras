function (event, ...)
    if not UnitIsGroupLeader('player') then
        return
    end

    local PREFIX = 'TMDM_ECWAv1'
    local aura_env = aura_env
    local BOSS = 242682497

    local function Emit (message, target)
        C_ChatInfo.SendAddonMessage(PREFIX, message, 'WHISPER', target)
    end

    local function EmitRaid (message, target)
        C_ChatInfo.SendAddonMessage(PREFIX, message, 'RAID')
    end

    local function SendDeliriumTeam()
        for unit in WA_IterateGroupMembers() do
            if not (WA_GetUnitDebuff(unit, 'Fear Realm') or UnitIsDead(unit)) then
                Emit('m=ENTER DELIRIUM REALM;s=sonar', UnitName(unit))
            end
        end
    end

    if event == 'ENCOUNTER_START' then
        aura_env.startTime = GetTime()
        aura_env.stopCalled = false
        aura_env.dreadCount = 0
        aura_env.tentCount = 0
        aura_env.manicCount = 0
        aura_env.passCount = 0
        aura_env.deliriumCount = 0
        aura_env.infernalTimer = nil
    end

    if event == 'ENCOUNTER_END' then
        if aura_env.infernalTimer then
            aura_env.infernalTimer:Cancel()
            aura_env.infernalTimer = nil
        end
    end

    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        local _, subevent, _, _, sourceName, _, _, _, _, _, _, spellID, spellName = ...
        local health = UnitHealth('boss1')
        if health ~= 0 and health < BOSS * .88 and not aura_env.stopCalled then
            EmitRaid('m=|cFFFF0000STOP DPS|r;s=bikehorn')
            aura_env.stopCalled = true
        end

        if subevent == 'SPELL_CAST_START' and spellName == 'Dread' then
            aura_env.dreadCount = aura_env.dreadCount + 1
            if aura_env.dreadCount == 3 then
                EmitRaid('m=|cFFFF0000PERSONALS|r;s=wilhelmscream')
            end
        end

        if subevent == 'SPELL_CAST_START' and spellName == 'Manic Dread' then
            aura_env.manicCount = aura_env.manicCount + 1
            if aura_env.manicCount == 1 then
                EmitRaid('m=|cFF00FF00HEALTHSTONE|r;s=moan')
            end
            if aura_env.manicCount == 2 then
                EmitRaid('m=|cFFFF0000PERSONALS|r;s=wilhelmscream')
            end
            if aura_env.manicCount == 3 then
                EmitRaid('m=|cFF00FF00HEALTH POTION|r;s=moan')
            end
        end

        if subevent == 'SPELL_CAST_SUCCESS' and sourceName == 'Za\'qul' and spellName == 'Crushing Grasp' then
            aura_env.tentCount = aura_env.tentCount + 1
            if aura_env.tentCount == 3 then
                EmitRaid('m=|cFF00FF00BURN|r;s=sonar')
            end
        end

        if subevent == 'SPELL_CAST_SUCCESS' and spellName == 'Dark Passage' then
            aura_env.passCount = aura_env.passCount + 1
            local emote = 'Za\'qul opens a passage to the Fear Realm.'
            if aura_env.passCount == 2 then
                EmitRaid('m=EXIT REALM;e='..emote..';s=sonar')
            else
                EmitRaid('e='..emote)
            end
        end

        if subevent == 'SPELL_CAST_SUCCESS' and sourceName == 'Zarillion' and spellName == 'Summon Infernal' and not aura_env.infernalTimer then
            aura_env.infernalTimer = C_Timer.NewTimer(130, function ()
                Emit('m=SUMMON INFERNAL;s=bikehorn', sourceName)
            end)
        end

        -- check for p3
        if health ~= 0 and health < BOSS * .5 then
            -- send first team at 4:35
            if (GetTime() - aura_env.startTime) > 275 and aura_env.deliriumCount == 0 then
                aura_env.deliriumCount = aura_env.deliriumCount + 1
                SendDeliriumTeam()
            end
            -- send second team at 6:15
            if (GetTime() - aura_env.startTime) > 375 and aura_env.deliriumCount == 1 then
                aura_env.deliriumCount = aura_env.deliriumCount + 1
                SendDeliriumTeam()
            end
        end
    end
end
