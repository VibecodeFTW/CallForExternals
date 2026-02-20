-- Load saved variables or create defaults
local function LoadSavedTriggers()
    if not KeywordTriggersDB then
        KeywordTriggersDB = {}
    end

-- If DB is empty, load your static defaults
    if next(KeywordTriggersDB) == nil then
        KeywordTriggersDB["innervate"] = "Innervate"
        KeywordTriggersDB["power infusion"] = "Power Infusion"
        KeywordTriggersDB["pi"] = "Power Infusion"
        KeywordTriggersDB["bloodlust"] = "Bloodlust"
        KeywordTriggersDB["lust"] = "Bloodlust"
        KeywordTriggersDB["md"] = "Misdirection"
        KeywordTriggersDB["misdirect"] = "Misdirection"
        KeywordTriggersDB["ss"] = "Soulstone"
        KeywordTriggersDB["soulstone"] = "Soulstone"
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")

loader:SetScript("OnEvent", function(self, event, addon)
    if addon == "CallForExternals" then
        LoadSavedTriggers()
    end
end)

-- Create a frame to listen for events
local frame = CreateFrame("Frame")

-- Function to display a message in the middle of the screen
local function ShowLargeMessage(msg)
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetSize(500, 100)
    f:SetPoint("CENTER")
    local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text:SetPoint("CENTER")

    -- Set font size to 40
    local font, _, flags = text:GetFont()
    text:SetFont(font, 40, flags)
    text:SetText(msg)

    -- Fade out after 3 seconds
    C_Timer.After(3, function() f:Hide() end)
end


-- Event handler for chat messages
frame:SetScript("OnEvent", function(self, event, msg, sender)
    local lowerMsg = msg:lower()

    for keyword, spellName in pairs(KeywordTriggersDB) do
        if lowerMsg:find(keyword) then
            ShowLargeMessage(spellName .. " from " .. sender .. "!")
            break
        end
    end
end)

-- Register chat events
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("CHAT_MSG_PARTY")
frame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
frame:RegisterEvent("CHAT_MSG_RAID")
frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
frame:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")
frame:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER")

SLASH_TRIGGERS1 = "/triggers"

SlashCmdList["TRIGGERS"] = function(msg)
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")

    if cmd == "add" then
        local keyword, spell = rest:match("^(%S+)%s+(.+)$")
        if keyword and spell then
            keyword = keyword:lower()
            KeywordTriggersDB[keyword] = spell
            print("|cff00ff00Added trigger:|r", keyword, "→", spell)
        else
            print("Usage: /triggers add <keyword> <Spell Name>")
        end

    elseif cmd == "remove" then
        local keyword = rest:lower()
        if KeywordTriggersDB[keyword] then
            KeywordTriggersDB[keyword] = nil
            print("|cffff0000Removed trigger:|r", keyword)
        else
            print("Keyword not found:", keyword)
        end

    elseif cmd == "list" then
        print("|cffffff00Current Triggers:|r")
        for k, v in pairs(KeywordTriggersDB) do
            print("  " .. k .. " → " .. v)
        end

    else
        print("Commands:")
        print("  /triggers add <keyword> <Spell Name>")
        print("  /triggers remove <keyword>")
        print("  /triggers list")
    end
end