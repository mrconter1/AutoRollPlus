-- Configuration GUI
-- Browse rollScripts by class+spec and view current configuration

local ConfigGUI = {}

-- GUI state
local configFrame = nil
local selectedClass = nil
local selectedSpec = nil
local classButtons = {}
local specButtons = {}
local ruleDisplay = nil
local currentPlayerLabel = nil

-- Colors
local COLORS = {
    normal = "|cFFFFFFFF",
    current = "|cFF00FF00",
    selected = "|cFFFFD700",
    class = "|cFFFF6600",
    spec = "|cFF00CCFF",
    script = "|cFFCCCCCC",
    header = "|cFFFFD700",
    reset = "|r"
}

-- Initialize the configuration GUI
function ConfigGUI:Initialize()
    if configFrame then
        configFrame:Show()
        self:UpdateCurrentPlayer()
        return
    end
    
    -- Create main frame
    configFrame = CreateFrame("Frame", "AutoRollConfigGUI", UIParent, "BackdropTemplate")
    configFrame:SetSize(1000, 700)
    configFrame:SetPoint("CENTER", UIParent, "CENTER")
    configFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    configFrame:SetBackdropColor(0, 0, 0, 0.9)
    configFrame:EnableMouse(true)
    configFrame:SetMovable(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    
    -- Title bar
    local titleBar = CreateFrame("Frame", nil, configFrame, "BackdropTemplate")
    titleBar:SetSize(984, 30)
    titleBar:SetPoint("TOP", configFrame, "TOP", 0, -8)
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
    titleText:SetText(COLORS.header .. "AutoRoll Configuration" .. COLORS.reset)
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -5, 0)
    closeButton:SetScript("OnClick", function() configFrame:Hide() end)
    
    -- Current player display
    currentPlayerLabel = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentPlayerLabel:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    
    -- Left panel for class/spec tree
    local leftPanel = CreateFrame("Frame", nil, configFrame, "BackdropTemplate")
    leftPanel:SetSize(300, 620)
    leftPanel:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 10, -10)
    leftPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    leftPanel:SetBackdropColor(0.05, 0.05, 0.05, 1)
    
    -- Left panel title
    local leftTitle = leftPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    leftTitle:SetPoint("TOP", leftPanel, "TOP", 0, -10)
    leftTitle:SetText(COLORS.header .. "Classes & Specs" .. COLORS.reset)
    
    -- Scroll frame for class/spec tree
    local treeScrollFrame = CreateFrame("ScrollFrame", "ConfigTreeScrollFrame", leftPanel, "UIPanelScrollFrameTemplate")
    treeScrollFrame:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 10, -35)
    treeScrollFrame:SetPoint("BOTTOMRIGHT", leftPanel, "BOTTOMRIGHT", -35, 10)
    
    local treeContent = CreateFrame("Frame", nil, treeScrollFrame)
    treeContent:SetSize(260, 1)
    treeScrollFrame:SetScrollChild(treeContent)
    
    -- Right panel for rule display
    local rightPanel = CreateFrame("Frame", nil, configFrame, "BackdropTemplate")
    rightPanel:SetSize(650, 620)
    rightPanel:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", -10, -10)
    rightPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    rightPanel:SetBackdropColor(0.05, 0.05, 0.05, 1)
    
    -- Right panel title
    local rightTitle = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    rightTitle:SetPoint("TOP", rightPanel, "TOP", 0, -10)
    rightTitle:SetText(COLORS.header .. "Rule Script" .. COLORS.reset)
    
    -- Rule display scroll frame
    local ruleScrollFrame = CreateFrame("ScrollFrame", "ConfigRuleScrollFrame", rightPanel, "UIPanelScrollFrameTemplate")
    ruleScrollFrame:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 10, -35)
    ruleScrollFrame:SetPoint("BOTTOMRIGHT", rightPanel, "BOTTOMRIGHT", -35, 10)
    
    local ruleContent = CreateFrame("Frame", nil, ruleScrollFrame)
    ruleContent:SetSize(600, 1)
    ruleScrollFrame:SetScrollChild(ruleContent)
    
    -- Rule display EditBox (for selectable text)
    ruleDisplay = CreateFrame("EditBox", nil, ruleContent)
    ruleDisplay:SetPoint("TOPLEFT", ruleContent, "TOPLEFT", 5, -5)
    ruleDisplay:SetPoint("TOPRIGHT", ruleContent, "TOPRIGHT", -5, -5)
    ruleDisplay:SetMultiLine(true)
    ruleDisplay:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    ruleDisplay:SetText("")
    ruleDisplay:SetAutoFocus(false)
    ruleDisplay:EnableMouse(true)
    ruleDisplay:SetScript("OnEditFocusLost", function() ruleDisplay:ClearFocus() end)
    ruleDisplay:SetScript("OnEnterPressed", function() ruleDisplay:ClearFocus() end)
    ruleDisplay:SetScript("OnEscapePressed", function() ruleDisplay:ClearFocus() end)
    
    -- Store references
    self.configFrame = configFrame
    self.treeContent = treeContent
    self.treeScrollFrame = treeScrollFrame
    self.ruleContent = ruleContent
    self.ruleScrollFrame = ruleScrollFrame
    
    -- Build the class/spec tree
    self:BuildClassTree()
    
    -- Update current player info
    self:UpdateCurrentPlayer()
    
    -- Show welcome message
    self:ShowWelcomeMessage()
    
    configFrame:Show()
end

-- Build the class/spec tree
function ConfigGUI:BuildClassTree()
    local yOffset = -10
    
    -- Clear existing buttons
    for _, button in pairs(classButtons) do
        button:Hide()
    end
    for _, button in pairs(specButtons) do
        button:Hide()
    end
    classButtons = {}
    specButtons = {}
    
    -- Get current player info for highlighting
    local _, currentClass = UnitClass("player")
    local currentSpec = self:GetCurrentSpec()
    
    -- Build tree for each class
    for className, specs in pairs(AutoRollMappings.classSpecs) do
        -- Create class button
        local classButton = CreateFrame("Button", nil, self.treeContent, "GameMenuButtonTemplate")
        classButton:SetSize(240, 25)
        classButton:SetPoint("TOPLEFT", self.treeContent, "TOPLEFT", 10, yOffset)
        
        -- Highlight current class
        local classColor = (className == currentClass) and COLORS.current or COLORS.class
        classButton:SetText(classColor .. className .. COLORS.reset)
        
        classButton:SetScript("OnClick", function()
            self:SelectClass(className)
        end)
        
        table.insert(classButtons, classButton)
        yOffset = yOffset - 30
        
        -- Create spec buttons for this class
        for specIndex, specName in ipairs(specs) do
            local specButton = CreateFrame("Button", nil, self.treeContent, "GameMenuButtonTemplate")
            specButton:SetSize(220, 20)
            specButton:SetPoint("TOPLEFT", self.treeContent, "TOPLEFT", 30, yOffset)
            
            -- Highlight current spec
            local specColor = (className == currentClass and specName == currentSpec) and COLORS.current or COLORS.spec
            specButton:SetText(specColor .. "  " .. specName .. COLORS.reset)
            
            specButton:SetScript("OnClick", function()
                self:SelectSpec(className, specName)
            end)
            
            table.insert(specButtons, specButton)
            yOffset = yOffset - 25
        end
        
        yOffset = yOffset - 5 -- Extra space between classes
    end
    
    -- Update tree content height
    self.treeContent:SetHeight(math.abs(yOffset) + 20)
    self.treeScrollFrame:UpdateScrollChildRect()
end

-- Select a class (show all specs)
function ConfigGUI:SelectClass(className)
    selectedClass = className
    selectedSpec = nil
    
    -- Update display
    self:UpdateRuleDisplay()
end

-- Select a specific spec
function ConfigGUI:SelectSpec(className, specName)
    selectedClass = className
    selectedSpec = specName
    
    -- Update display
    self:UpdateRuleDisplay()
end

-- Update the rule display
function ConfigGUI:UpdateRuleDisplay()
    if not selectedClass or not selectedSpec then
        self:ShowWelcomeMessage()
        return
    end
    
    -- Get profile key
    local profileKey = self:GetProfileKey(selectedClass, selectedSpec)
    
    -- Get rule script
    local ruleScript = AutoRollProfiles[profileKey]
    
    if ruleScript then
        -- Format the rule script for display
        local displayText = COLORS.header .. "Profile: " .. COLORS.class .. selectedClass .. COLORS.normal .. " > " .. COLORS.spec .. selectedSpec .. COLORS.reset .. "\n"
        displayText = displayText .. COLORS.header .. "Profile Key: " .. COLORS.normal .. profileKey .. COLORS.reset .. "\n\n"
        displayText = displayText .. COLORS.header .. "Rule Script:" .. COLORS.reset .. "\n"
        displayText = displayText .. COLORS.script .. ruleScript .. COLORS.reset
        
        self:SetRuleText(displayText)
    else
        local displayText = COLORS.header .. "Profile: " .. COLORS.class .. selectedClass .. COLORS.normal .. " > " .. COLORS.spec .. selectedSpec .. COLORS.reset .. "\n"
        displayText = displayText .. COLORS.header .. "Profile Key: " .. COLORS.normal .. profileKey .. COLORS.reset .. "\n\n"
        displayText = displayText .. "|cFFFF0000No rule script found for this profile." .. COLORS.reset
        
        self:SetRuleText(displayText)
    end
end

-- Set rule text and update display
function ConfigGUI:SetRuleText(text)
    ruleDisplay:SetText(text)
    
    -- Calculate text height
    local lineCount = 1
    for _ in text:gmatch("\n") do
        lineCount = lineCount + 1
    end
    local lineHeight = 14
    local textHeight = lineCount * lineHeight
    
    -- Update heights
    ruleDisplay:SetHeight(textHeight)
    self.ruleContent:SetHeight(math.max(textHeight + 20, self.ruleScrollFrame:GetHeight()))
    self.ruleScrollFrame:UpdateScrollChildRect()
end

-- Show welcome message
function ConfigGUI:ShowWelcomeMessage()
    local welcomeText = COLORS.header .. "AutoRoll Configuration Browser" .. COLORS.reset .. "\n\n"
    welcomeText = welcomeText .. "Select a class and spec from the left panel to view their rule scripts.\n\n"
    welcomeText = welcomeText .. COLORS.current .. "Green entries" .. COLORS.reset .. " indicate your current class/spec.\n\n"
    welcomeText = welcomeText .. "Rule scripts define how the addon automatically rolls on loot:\n"
    welcomeText = welcomeText .. "• " .. COLORS.spec .. "item.manualRoll()" .. COLORS.reset .. " - Requires manual decision\n"
    welcomeText = welcomeText .. "• " .. COLORS.spec .. "item.rollGreed()" .. COLORS.reset .. " - Automatically greeds\n"
    welcomeText = welcomeText .. "• " .. COLORS.spec .. "item.rollNeed()" .. COLORS.reset .. " - Automatically needs\n"
    welcomeText = welcomeText .. "• " .. COLORS.spec .. "item.rollPass()" .. COLORS.reset .. " - Automatically passes\n\n"
    welcomeText = welcomeText .. "Rules are evaluated in order until one matches."
    
    self:SetRuleText(welcomeText)
end

-- Get profile key for class/spec combination
function ConfigGUI:GetProfileKey(className, specName)
    local profileNameMap = AutoRollMappings.profileNameMap
    if profileNameMap and profileNameMap[className] and profileNameMap[className][specName] then
        return profileNameMap[className][specName]
    end
    
    -- Fallback to old format
    return string.lower(className .. "_" .. specName):gsub("%s+", "")
end

-- Get current player spec
function ConfigGUI:GetCurrentSpec()
    local specName = nil
    if GetPrimaryTalentTree then
        local _, classKey = UnitClass("player")
        local specIndex = GetPrimaryTalentTree()
        local classSpecs = AutoRollMappings.classSpecs
        local specs = classSpecs[classKey]
        if specs and specIndex and specs[specIndex] then
            specName = specs[specIndex]
        end
    elseif GetSpecialization and GetSpecializationInfo then
        local specIndex = GetSpecialization()
        if specIndex then
            local _, sName = GetSpecializationInfo(specIndex)
            specName = sName
        end
    end
    return specName
end

-- Update current player display
function ConfigGUI:UpdateCurrentPlayer()
    local _, currentClass = UnitClass("player")
    local currentSpec = self:GetCurrentSpec()
    
    if currentClass and currentSpec then
        local profileKey = self:GetProfileKey(currentClass, currentSpec)
        currentPlayerLabel:SetText(COLORS.current .. "Current: " .. currentClass .. " > " .. currentSpec .. " (" .. profileKey .. ")" .. COLORS.reset)
    else
        currentPlayerLabel:SetText(COLORS.current .. "Current: Unknown" .. COLORS.reset)
    end
end

-- Global access
_G.AutoRollConfigGUI = ConfigGUI 