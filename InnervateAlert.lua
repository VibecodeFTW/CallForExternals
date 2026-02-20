-- Create a frame to listen for events
local frame = CreateFrame("Frame")
-- Function to display a large message in the middle of the screen
local function ShowLargeMessage(msg)
local f = CreateFrame("Frame", nil, UIParent)
f:SetSize(500, 100)
f:SetPoint("CENTER")
local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("CENTER")
text:SetText(msg)
-- Fade out after 3 seconds
C_Timer.After(3, function() f:Hide() end)
end
-- Event handler for whispers
frame:SetScript("OnEvent", function(self, event, msg, sender)
if event == "CHAT_MSG_WHISPER" then
if msg:lower():find("innervate") then
ShowLargeMessage("Innervate from " .. sender .. "!")
end
end
end)
-- Register the whisper event
frame:RegisterEvent("CHAT_MSG_WHISPER")