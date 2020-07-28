sellingIsEnabled = false
summoningIsEnabled = false

-- Tests for selling portals requests.
function isSellingRequest(msg, event)
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
    for part in msg:gmatch("%S+") do
        part = part:lower()
        if part == "inv" or part == "invite" then
            hasInvite = true
        end
        if part == "sum" or part == "summon" then
            hasSummon = true
        end
    end
    -- Make the decision based on event type.
    if event == "CHAT_MSG_WHISPER" then
        return hasInvite
    elseif event == "CHAT_MSG_GUILD" then
        return hasInvite and hasSummon
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
    elseif cmd == "sum" or cmd == "summon" then
        summoningIsEnabled = stateEnabler("Summoning mode", summoningIsEnabled, args)
    elseif cmd == "on" then
        sellingIsEnabled = stateSetter("Selling portals mode", true)
        summoningIsEnabled = stateSetter("Summoning mode", true)
    elseif cmd == "off" then
        sellingIsEnabled = stateSetter("Selling portals mode", false)
        summoningIsEnabled = stateSetter("Summoning mode", false)
    else
        print("Syntax: /ai (sell|summon) [on|off]")
    end
end

-- Set up frame and handle events.
local frame = CreateFrame("Frame")
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
    if sellingIsEnabled and isSellingRequest(msg, event) then
        InviteUnit(senderName)
    elseif summoningIsEnabled and isSummoningRequest(msg, event) then
        InviteUnit(senderName)
    end
end)
