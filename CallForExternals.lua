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

local CFE_LargeMessageFrame = CFE_LargeMessageFrame or nil
local CFE_LargeMessageTimer = nil

function ShowLargeMessage(msg)
    if not CFE_LargeMessageFrame then
        CFE_LargeMessageFrame = CreateFrame("Frame", "CFE_LargeMessageFrame", UIParent, "BackdropTemplate")
        CFE_LargeMessageFrame:SetSize(600, 50)
        CFE_LargeMessageFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })

        CFE_LargeMessageFrame:SetMovable(true)
        CFE_LargeMessageFrame:EnableMouse(true)
        CFE_LargeMessageFrame:RegisterForDrag("LeftButton")
        CFE_LargeMessageFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        CFE_LargeMessageFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
            CFE_SavedPosition = { point, relativePoint, xOfs, yOfs }
        end)

        if CFE_SavedPosition then
            CFE_LargeMessageFrame:ClearAllPoints()
            CFE_LargeMessageFrame:SetPoint(
                CFE_SavedPosition[1],
                UIParent,
                CFE_SavedPosition[2],
                CFE_SavedPosition[3],
                CFE_SavedPosition[4]
            )
        else
            CFE_LargeMessageFrame:SetPoint("CENTER")
        end

        CFE_LargeMessageFrame.text = CFE_LargeMessageFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        CFE_LargeMessageFrame.text:SetPoint("CENTER")
        CFE_LargeMessageFrame.text:SetJustifyH("CENTER")
        CFE_LargeMessageFrame.text:SetJustifyV("MIDDLE")
    end

    CFE_LargeMessageFrame.text:SetText(msg)
    CFE_LargeMessageFrame:Show()
    CFE_LargeMessageFrame:SetAlpha(1)

    -- Cancel any previous timer
    if CFE_LargeMessageTimer then
        CFE_LargeMessageTimer:Cancel()
    end

    -- Start a new 3-second timer
    CFE_LargeMessageTimer = C_Timer.NewTimer(3, function()
        if CFE_LargeMessageFrame:IsShown() then
            CFE_LargeMessageFrame:Hide()
        end
    end)
end


-- Create a frame to listen for events
local frame = CreateFrame("Frame")



-- Event handler for chat messages
frame:SetScript("OnEvent", function(self, event, msg, sender)
    local lowerMsg = msg:lower()
    for keyword, spellName in pairs(KeywordTriggersDB) do
        local pattern = "%f[%a]" .. keyword:lower() .. "%f[%A]"
        if lowerMsg:match(pattern) then
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