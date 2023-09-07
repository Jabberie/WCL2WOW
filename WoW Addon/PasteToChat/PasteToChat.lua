-- Create a frame for manually pasting text
local PasteClipboardFrame = CreateFrame("Frame", "PasteClipboardFrame", UIParent, "BackdropTemplate")
PasteClipboardFrame:SetSize(450, 200) -- Adjusted size to accommodate the title bar
PasteClipboardFrame:SetPoint("CENTER")
PasteClipboardFrame:Hide()

-- Set the backdrop properties (black background)
PasteClipboardFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 20, bottom = 4 } -- Adjusted top inset for the title bar
})
-- Set the background color to black
PasteClipboardFrame:SetBackdropColor(0, 0, 0, 1) -- Black background

-- Create a title bar
local titleBar = CreateFrame("Frame", "PasteClipboardTitleBar", PasteClipboardFrame, "BackdropTemplate")
titleBar:SetSize(450, 20) -- Title bar height
titleBar:SetPoint("TOP", 0, 0)
titleBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
titleBar:SetBackdropColor(0, 0, 0, 1) -- Black background
titleBar.text = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
titleBar.text:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
titleBar.text:SetText("Paste Clipboard to Chat") -- Title text

-- Create a frame for the text edit box with its own border and padding
local editBoxFrame = CreateFrame("Frame", "PasteClipboardEditBoxFrame", PasteClipboardFrame, "BackdropTemplate")
editBoxFrame:SetSize(430, 125)
editBoxFrame:SetPoint("TOPLEFT", 10, -25)
editBoxFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 } -- 2-pixel padding
})
editBoxFrame:SetBackdropColor(0, 0, 0, 1) -- Black background

-- Create an edit box within the edit box frame
local editBox = CreateFrame("EditBox", "PasteClipboardEditBox", editBoxFrame)
editBox:SetMultiLine(true)
editBox:SetMaxLetters(0)
editBox:SetFontObject(ChatFontNormal)
editBox:SetWidth(420) -- Adjusted width to fit the reduced frame size and added padding
editBox:SetHeight(105) -- Adjusted height to fit the reduced frame size and added padding
editBox:SetPoint("TOPLEFT", 5, -5) -- Adjusted position for padding
editBox:SetAutoFocus(false)
editBox:SetScript("OnEscapePressed", function(self) self:GetParent():GetParent():Hide() end)

-- Set default text in the edit box
editBox:SetText("Paste your clipboard contents here...")
editBox:SetTextColor(1, 1, 1) -- Set text color to white

-- Clear the default text when the edit box is focused
editBox:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == "Paste your clipboard contents here..." then
        self:SetText("")
    end
end)

-- Create "Send to Say" button
local sendToSayButton = CreateFrame("Button", "PasteClipboardSendToSayButton", PasteClipboardFrame, "UIPanelButtonTemplate")
sendToSayButton:SetText("Send to Say")
sendToSayButton:SetWidth(100)
sendToSayButton:SetHeight(25)
sendToSayButton:SetPoint("BOTTOMLEFT", 10, 10)

-- Create "Send to Party" button
local sendToPartyButton = CreateFrame("Button", "PasteClipboardSendToPartyButton", PasteClipboardFrame, "UIPanelButtonTemplate")
sendToPartyButton:SetText("Send to Party")
sendToPartyButton:SetWidth(100)
sendToPartyButton:SetHeight(25)
sendToPartyButton:SetPoint("BOTTOMLEFT", 120, 10)

-- Create "Send to Raid" button
local sendToRaidButton = CreateFrame("Button", "PasteClipboardSendToRaidButton", PasteClipboardFrame, "UIPanelButtonTemplate")
sendToRaidButton:SetText("Send to Raid")
sendToRaidButton:SetWidth(100)
sendToRaidButton:SetHeight(25)
sendToRaidButton:SetPoint("BOTTOMLEFT", 230, 10)

-- Create "Send to Guild" button
local sendToGuildButton = CreateFrame("Button", "PasteClipboardSendToGuildButton", PasteClipboardFrame, "UIPanelButtonTemplate")
sendToGuildButton:SetText("Send to Guild")
sendToGuildButton:SetWidth(100)
sendToGuildButton:SetHeight(25)
sendToGuildButton:SetPoint("BOTTOMLEFT", 340, 10)

-- Function to send one line of text to the selected channel
local function SendToChannel(channel)
    local text = editBox:GetText()
    if text and text ~= "" then
        local lines = {strsplit("\n", text)}
        if #lines > 0 then
            SendChatMessage(lines[1], channel)
            table.remove(lines, 1)
            editBox:SetText(table.concat(lines, "\n"))
        end
    end
end

sendToSayButton:SetScript("OnClick", function() SendToChannel("SAY") end)
sendToPartyButton:SetScript("OnClick", function() SendToChannel("PARTY") end)
sendToRaidButton:SetScript("OnClick", function() SendToChannel("RAID") end)
sendToGuildButton:SetScript("OnClick", function() SendToChannel("GUILD") end)

-- Create a close button to hide the frame
local closeButton = CreateFrame("Button", "PasteClipboardCloseButton", PasteClipboardFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", 0, 0)
closeButton:SetScript("OnClick", function() PasteClipboardFrame:Hide() end)

-- Function to show the paste frame
local function ShowPasteFrame()
    editBox:SetText("") -- Clear any previous content
    PasteClipboardFrame:Show()
end

-- Register a slash command to show the paste frame
SLASH_PASTETOCHAT1 = "/pastetochat"
SlashCmdList["PASTETOCHAT"] = ShowPasteFrame
