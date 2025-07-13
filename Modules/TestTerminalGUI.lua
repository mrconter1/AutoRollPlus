-- Test Terminal GUI
-- A terminal-like interface for running and tracking AutoRoll tests

local TestTerminalGUI = {}

-- GUI state
local terminalFrame = nil
local outputText = ""
local scrollFrame = nil
local isRunning = false
local autoClearCheckbox = nil
local autoClearEnabled = true

-- Terminal colors
local COLORS = {
    normal = "|cFFFFFFFF",
    success = "|cFF00FF00",
    error = "|cFFFF0000",
    warning = "|cFFFFFF00",
    info = "|cFF00FFFF",
    header = "|cFFFFD700",
    reset = "|r"
}

-- Initialize the terminal GUI
function TestTerminalGUI:Initialize()
    if terminalFrame then
        terminalFrame:Show()
        return
    end
    
    -- Create main frame
    terminalFrame = CreateFrame("Frame", "AutoRollTestTerminal", UIParent, "BackdropTemplate")
    terminalFrame:SetSize(800, 600)
    terminalFrame:SetPoint("CENTER", UIParent, "CENTER")
    terminalFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    terminalFrame:SetBackdropColor(0, 0, 0, 0.9)
    terminalFrame:EnableMouse(true)
    -- Dragging disabled to improve text selection
    -- terminalFrame:SetMovable(true)
    -- terminalFrame:RegisterForDrag("LeftButton")
    -- terminalFrame:SetScript("OnDragStart", terminalFrame.StartMoving)
    -- terminalFrame:SetScript("OnDragStop", terminalFrame.StopMovingOrSizing)
    
    -- Title bar
    local titleBar = CreateFrame("Frame", nil, terminalFrame, "BackdropTemplate")
    titleBar:SetSize(784, 30)
    titleBar:SetPoint("TOP", terminalFrame, "TOP", 0, -8)
    titleBar:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    titleBar:SetBackdropColor(0.1, 0.1, 0.1, 1)
    
    -- Title text
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
    titleText:SetText(COLORS.header .. "AutoRoll Test Terminal" .. COLORS.reset)
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -5, 0)
    closeButton:SetScript("OnClick", function() terminalFrame:Hide() end)
    
    -- Output scroll frame (takes up most of the space)
    scrollFrame = CreateFrame("ScrollFrame", "TestTerminalScrollFrame", terminalFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", terminalFrame, "BOTTOMRIGHT", -35, 55)
    
    -- Output text (using EditBox for selectable text)
    local outputFrame = CreateFrame("Frame", nil, scrollFrame)
    outputFrame:SetSize(scrollFrame:GetWidth(), 1)
    scrollFrame:SetScrollChild(outputFrame)
    
    local outputEditBox = CreateFrame("EditBox", nil, outputFrame)
    outputEditBox:SetPoint("TOPLEFT", outputFrame, "TOPLEFT", 5, -5)
    outputEditBox:SetPoint("TOPRIGHT", outputFrame, "TOPRIGHT", -5, -5)
    outputEditBox:SetMultiLine(true)
    outputEditBox:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    outputEditBox:SetText("")
    outputEditBox:SetAutoFocus(false)
    outputEditBox:EnableMouse(true)
    outputEditBox:SetScript("OnEditFocusLost", function() outputEditBox:ClearFocus() end)
    outputEditBox:SetScript("OnEnterPressed", function() outputEditBox:ClearFocus() end)
    outputEditBox:SetScript("OnEscapePressed", function() outputEditBox:ClearFocus() end)
    outputEditBox:SetScript("OnTextChanged", function(self, userInput) 
        -- Only prevent changes if user is typing (not from our SetText calls)
        if userInput then
            outputEditBox:SetText(outputText)
            outputEditBox:SetCursorPosition(0)
        end
    end)
    
    -- Store reference to output
    self.outputEditBox = outputEditBox
    self.outputFrame = outputFrame
    
    -- Button panel at bottom
    local buttonPanel = CreateFrame("Frame", nil, terminalFrame, "BackdropTemplate")
    buttonPanel:SetSize(784, 40)
    buttonPanel:SetPoint("BOTTOM", terminalFrame, "BOTTOM", 0, 8)
    buttonPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    buttonPanel:SetBackdropColor(0.05, 0.05, 0.05, 1)
    
    -- Create run button
    local runButton = CreateFrame("Button", nil, buttonPanel, "GameMenuButtonTemplate")
    runButton:SetSize(120, 25)
    runButton:SetPoint("LEFT", buttonPanel, "LEFT", 10, 0)
    runButton:SetText("Run All Tests")
    runButton:SetScript("OnClick", function() 
        if not isRunning then
            self:ExecuteCommand("runAllProfiles")
        end
    end)
    
    -- Create reload button
    local reloadButton = CreateFrame("Button", nil, buttonPanel, "GameMenuButtonTemplate")
    reloadButton:SetSize(120, 25)
    reloadButton:SetPoint("LEFT", runButton, "RIGHT", 10, 0)
    reloadButton:SetText("Reload")
    reloadButton:SetScript("OnClick", function() 
        -- Set flag to reopen test dialog after reload
        if not AutoRollPlus_PCDB then
            AutoRollPlus_PCDB = {}
        end
        AutoRollPlus_PCDB.openTestDialogOnLoad = true
        ReloadUI()
    end)
    
    -- Create auto-clear checkbox
    autoClearCheckbox = CreateFrame("CheckButton", nil, buttonPanel, "ChatConfigCheckButtonTemplate")
    autoClearCheckbox:SetSize(25, 25)
    autoClearCheckbox:SetPoint("RIGHT", buttonPanel, "RIGHT", -10, 0)
    autoClearCheckbox:SetChecked(autoClearEnabled)
    autoClearCheckbox:SetScript("OnClick", function(self)
        autoClearEnabled = self:GetChecked()
    end)
    
    -- Auto-clear label
    local autoClearLabel = buttonPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    autoClearLabel:SetPoint("RIGHT", autoClearCheckbox, "LEFT", -5, 0)
    autoClearLabel:SetText("Auto-clear")
    autoClearLabel:SetTextColor(1, 1, 1)
    
    -- Initial welcome message
    self:AddOutput(COLORS.header .. "AutoRoll Test Terminal v1.0" .. COLORS.reset)
    self:AddOutput(COLORS.info .. "Simple test runner with auto-clear option" .. COLORS.reset)
    self:AddOutput(COLORS.info .. "Select text directly in this window and press Ctrl+C to copy" .. COLORS.reset)
    self:AddOutput("")
    
    terminalFrame:Show()
end



-- Add text to output
function TestTerminalGUI:AddOutput(text)
    if outputText == "" then
        outputText = text
    else
        outputText = outputText .. "\n" .. text
    end
    
    if self.outputEditBox then
        self.outputEditBox:SetText(outputText)
        
        -- Force the frame to update its size
        self.outputEditBox:SetWidth(scrollFrame:GetWidth() - 20)
        
        -- Resize output frame and EditBox to fit content
        -- Calculate height based on line count
        local lineCount = 1
        for _ in outputText:gmatch("\n") do
            lineCount = lineCount + 1
        end
        local lineHeight = 14 -- Approximate line height for the font
        local textHeight = lineCount * lineHeight
        
        -- Set EditBox height to match content
        self.outputEditBox:SetHeight(textHeight)
        
        -- Set frame height (with padding)
        self.outputFrame:SetHeight(math.max(textHeight + 20, scrollFrame:GetHeight()))
        
        -- Force scroll frame to update
        scrollFrame:UpdateScrollChildRect()
        
        -- Auto-scroll to bottom with a small delay to ensure proper rendering
        C_Timer.After(0.01, function()
            if scrollFrame then
                local maxScroll = math.max(0, self.outputFrame:GetHeight() - scrollFrame:GetHeight())
                scrollFrame:SetVerticalScroll(maxScroll)
            end
        end)
    end
end

-- Execute a command
function TestTerminalGUI:ExecuteCommand(command)
    if isRunning then
        self:AddOutput(COLORS.error .. "Test already running..." .. COLORS.reset)
        return
    end
    
    -- Auto-clear output if enabled
    if autoClearEnabled then
        outputText = ""
        if self.outputEditBox then
            self.outputEditBox:SetText("")
        end
    end
    
    self:AddOutput(COLORS.info .. "> " .. command .. COLORS.reset)
    
    -- Run test command
    isRunning = true
    self:AddOutput(COLORS.warning .. "Running test..." .. COLORS.reset)
    
    -- Execute the command safely
    local success, result = pcall(function()
        -- Hook print function to capture output
        local originalPrint = print
        local capturedOutput = {}
        
        print = function(...)
            local args = {...}
            local output = ""
            for i, arg in ipairs(args) do
                if i > 1 then output = output .. "\t" end
                output = output .. tostring(arg)
            end
            table.insert(capturedOutput, output)
        end
        
        -- Execute the command
        if command == "runAllProfiles" then
            if _G.AutoRollTestRunner and _G.AutoRollTestRunner.runAllProfiles then
                AutoRollTestRunner:runAllProfiles(false) -- Use concise mode
            else
                self:AddOutput(COLORS.error .. "Test runner not available" .. COLORS.reset)
                self:AddOutput(COLORS.info .. "Please use /reload to load test files, then reopen terminal" .. COLORS.reset)
            end
        else
            self:AddOutput(COLORS.error .. "Unknown command: " .. command .. COLORS.reset)
        end
        
        -- Restore print function
        print = originalPrint
        
        -- Add captured output to terminal
        for _, output in ipairs(capturedOutput) do
            -- Color code the output
            local coloredOutput = output
            if output:find("✓ PASS") then
                coloredOutput = COLORS.success .. output .. COLORS.reset
            elseif output:find("✗ FAIL") then
                coloredOutput = COLORS.error .. output .. COLORS.reset
            elseif output:find("===") then
                coloredOutput = COLORS.header .. output .. COLORS.reset
            elseif output:find("Rule Script:") or output:find("scenarios") then
                coloredOutput = COLORS.info .. output .. COLORS.reset
            end
            self:AddOutput(coloredOutput)
        end
    end)
    
    if not success then
        self:AddOutput(COLORS.error .. "Error: " .. tostring(result) .. COLORS.reset)
    end
    
    isRunning = false
    self:AddOutput(COLORS.info .. "Command completed." .. COLORS.reset)
    self:AddOutput("")
end

-- Show the terminal
function TestTerminalGUI:Show()
    self:Initialize()
end

-- Hide the terminal
function TestTerminalGUI:Hide()
    if terminalFrame then
        terminalFrame:Hide()
    end
end

-- Toggle terminal visibility
function TestTerminalGUI:Toggle()
    if terminalFrame and terminalFrame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Export the GUI
_G.AutoRollTestTerminal = TestTerminalGUI

-- Add slash command for easy access
SLASH_ARTEST1 = '/artest'
SLASH_ARTEST2 = '/autorolltest'
SlashCmdList["ARTEST"] = function(msg)
    TestTerminalGUI:Toggle()
end 