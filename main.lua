sellingIsEnabled = false
sellingBVPSummonsIsEnabled = false
sellingDMSummonsIsEnabled = false
sellingZGSummonsIsEnabled = false
summoningIsEnabled = false
raidIsEnabled = false

-- Tests for selling portals requests.
function isSellingRequest(msg, event)
    -- Abort if mode is not enabled.
    if not sellingIsEnabled then
        return false
    end
    -- Abort if not a desirable event type.
    if event == "CHAT_MSG_GUILD" then
        return false
    end
    -- Scan for keywords and make the decision.
    for part in msg:gmatch("%S+") do
        part = part:lower()
        if part == "org" then return true
        elseif part == "uc" then return true
        elseif part == "tb" then return true
        end
    end
    return false
end

-- Tests for summon requests.
function isSummoningRequest(msg, event)
    -- Scan for keywords.
    local hasInvite = false
    local hasSummon = false
    local hasRaid = false
    for part in msg:gmatch("%S+") do
        part = part:lower()
        if part == "i" or part == "inv" or part == "invite" then
            hasInvite = true
        end
        if part == "sg" or part == "sum" or part == "summon" then
            hasSummon = true
        end
        if part == "rg" or part == "raid" then
            hasRaid = true
        end
    end
    -- Make the decision based on event type.
    if event == "CHAT_MSG_WHISPER" then
        return hasInvite and (summoningIsEnabled or raidIsEnabled)
    elseif event == "CHAT_MSG_GUILD" then
        return hasInvite and ((summoningIsEnabled and hasSummon) or (raidIsEnabled and hasRaid))
    else
        return false
    end
end

-- Tests for selling summon requests.
function isSellingSummonsRequest(msg, event)
    -- Scan for keywords.
    local hasInvite = false
    local hasInviteNA = false
    local hasBVP = false
    local hasDM = false
    local hasZG = false
    for part in msg:gmatch("%S+") do
        part = part:lower()
        if part == "i" then
            hasInvite = true
        elseif part == "inv" or part == "invite" or part == "wtb" then
            hasInvite = true
            hasInviteNA = true
        end
        if part == "bvp" or part == "sf" or part == "sfs" or part == "songflower" then
            hasBVP = true
        end
        if part == "dm" or part == "dmt" or part == "dire" or part == "maul" then
            hasDM = true
        end
        if part == "zg" or part == "heart" or part == "isle" or part == "island" then
            hasZG = true
        end
    end
    -- Make the decision.
    if not hasInvite then
        return false
    end
    if (not (event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_GUILD")) and (not hasInviteNA) then
        return false
    end
    if hasBVP and sellingBVPSummonsIsEnabled then
        return true
    elseif hasDM and sellingDMSummonsIsEnabled then
        return true
    elseif hasZG and sellingZGSummonsIsEnabled then
        return true
    else
        return false
    end
end

-- Determines the desired state from arguments passed to slash commands.
function stateEnabler(what, currentState, args)
    if args == "on" then
        return stateSetter(what, true)
    elseif args == "off" then
        return stateSetter(what, false)
    elseif args == "" or args == "toggle" then
        return stateSetter(what, not currentState)
    else
        return stateSetter(what, currentState)
    end
end

function stateSetter(what, desiredState)
    if desiredState then
        print(what .. " is ENABLED.")
        return true
    else
        print(what .. " is DISABLED.")
        return false
    end
end

-- Set up slash commands.
SLASH_AUTOINVITE1 = "/autoinvite"
SLASH_AUTOINVITE2 = "/ai"
function SlashCmdList.AUTOINVITE(msg, editbox)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
    if cmd == "s" or cmd == "sell" then
        sellingIsEnabled = stateEnabler("Selling portals mode", sellingIsEnabled, args)
    elseif cmd == "sg" or cmd == "sum" or cmd == "summon" then
        summoningIsEnabled = stateEnabler("Summoning group mode", summoningIsEnabled, args)
        if summoningIsEnabled then
            raidIsEnabled = false
        end
    elseif cmd == "sbvp" or cmd == "sellbvp" then
        sellingBVPSummonsIsEnabled = stateEnabler("Selling BVP Summons mode", sellingBVPSummonsIsEnabled, args)
    elseif cmd == "sdm" or cmd == "selldm" then
        sellingDMSummonsIsEnabled = stateEnabler("Selling DM Summons mode", sellingDMSummonsIsEnabled, args)
    elseif cmd == "szg" or cmd == "sellzg" then
        sellingZGSummonsIsEnabled = stateEnabler("Selling ZG Summons mode", sellingZGSummonsIsEnabled, args)
    elseif cmd == "rg" or cmd == "raid" then
        raidIsEnabled = stateEnabler("Raid group mode", raidIsEnabled, args)
        if raidIsEnabled then
            summoningIsEnabled = false
        end
    elseif cmd == "on" then
        sellingIsEnabled = stateSetter("Selling portals mode", true)
    elseif cmd == "off" then
        sellingIsEnabled = stateSetter("Selling portals mode", false)
    else
        print("Syntax: /ai (sell|summon|raid) [on|off]")
    end
end

-- Set up frame and handle events.
local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:RegisterEvent("CHAT_MSG_SAY")
frame:RegisterEvent("CHAT_MSG_YELL")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("CHAT_MSG_GUILD")
frame:SetScript("OnEvent", function(self, event, ...)
    local msg = select(1, ...)
    --local senderGuid = select(12, ...)
    local senderName = select(2, ...)
    --local playerGuid = UnitGUID('player')
    -- Ignore if message isn't an invitation request.
    if isSellingRequest(msg, event) then
        InviteUnit(senderName)
    elseif isSummoningRequest(msg, event) then
        InviteUnit(senderName)
    elseif isSellingSummonsRequest(msg, event) then
        InviteUnit(senderName)
    end
end)
