sellingIsEnabled = false

function isInvitationRequest(msg, event)
    local org = false
    local uc = false
    local tb = false

    -- Determine which keywords are present.
    for part in msg:gmatch("%S+") do
        part = part:lower()
        if (part == "org") then
            org = true
        end
        if (part == "uc") then
            uc = true
        end
        if (part == "tb") then
            tb = true
        end
    end
    -- Decide if it is an invitation request based on the context and keywords.
    return org or uc or tb
end

SLASH_AUTOINVITE1 = "/autoinvite"
SLASH_AUTOINVITE2 = "/ai"
function SlashCmdList.AUTOINVITE(msg, editbox)
    sellingIsEnabled = not sellingIsEnabled
    if sellingIsEnabled then
        print("Selling portals is ENABLED.")
    else
        print("Selling portals is DISABLED.")
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_SAY")
frame:RegisterEvent("CHAT_MSG_YELL")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:SetScript("OnEvent", function(self, event, ...)
    local msg = select(1, ...)
    --local senderGuid = select(12, ...)
    local senderName = select(2, ...)
    --local playerGuid = UnitGUID('player')
    if not sellingIsEnabled then
        return
    end
    -- Ignore if message isn't an invitation request.
    if not isInvitationRequest(msg, event) then
        return
    end
    -- Do the invite!
    InviteUnit(senderName)
end)
