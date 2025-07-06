-- AutoRoll Class/Spec Selection GUI
AutoRollClassSpecGUI = {}

-- Class data for Classic WoW with icons (including Death Knight)
local CLASSES = {
    ["WARRIOR"] = { name = "Warrior", specs = {"Arms", "Fury", "Protection"}, icon = "Interface\\Icons\\ClassIcon_Warrior" },
    ["PALADIN"] = { name = "Paladin", specs = {"Holy", "Protection", "Retribution"}, icon = "Interface\\Icons\\ClassIcon_Paladin" },
    ["HUNTER"] = { name = "Hunter", specs = {"Beast Mastery", "Marksmanship", "Survival"}, icon = "Interface\\Icons\\ClassIcon_Hunter" },
    ["ROGUE"] = { name = "Rogue", specs = {"Assassination", "Combat", "Subtlety"}, icon = "Interface\\Icons\\ClassIcon_Rogue" },
    ["PRIEST"] = { name = "Priest", specs = {"Discipline", "Holy", "Shadow"}, icon = "Interface\\Icons\\ClassIcon_Priest" },
    ["DEATHKNIGHT"] = { name = "Death Knight", specs = {"Blood", "Frost", "Unholy"}, icon = "Interface\\Icons\\ClassIcon_DeathKnight" },
    ["SHAMAN"] = { name = "Shaman", specs = {"Elemental", "Enhancement", "Restoration"}, icon = "Interface\\Icons\\ClassIcon_Shaman" },
    ["MAGE"] = { name = "Mage", specs = {"Arcane", "Fire", "Frost"}, icon = "Interface\\Icons\\ClassIcon_Mage" },
    ["WARLOCK"] = { name = "Warlock", specs = {"Affliction", "Demonology", "Destruction"}, icon = "Interface\\Icons\\ClassIcon_Warlock" },
    ["DRUID"] = { name = "Druid", specs = {"Balance", "Feral", "Restoration"}, icon = "Interface\\Icons\\ClassIcon_Druid" }
}

-- GUI Frame
local frame = nil
local classButtons = {}
local specButtons = {}
local selectedClass = nil
local selectedSpec = nil
local specFrame = nil

-- Create the main frame
function AutoRollClassSpecGUI:CreateFrame()
    if frame then
        return frame
    end

    -- Main frame with bigger dimensions
    frame = CreateFrame("Frame", "AutoRollClassSpecFrame", UIParent)
    frame:SetSize(600, 480)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    -- Background using a nicer texture
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    bg:SetVertexColor(0.1, 0.1, 0.2, 0.95)
    
    -- Border frame
    local border = frame:CreateTexture(nil, "BORDER")
    border:SetAllPoints()
    border:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    border:SetVertexColor(0.3, 0.3, 0.5, 1)
    
    -- Top accent bar
    local topBar = frame:CreateTexture(nil, "ARTWORK")
    topBar:SetSize(600, 3)
    topBar:SetPoint("TOP", frame, "TOP", 0, 0)
    topBar:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    topBar:SetVertexColor(0.2, 0.6, 1, 1)
    
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    -- Title with better styling
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -25)
    title:SetText("AutoRoll Configuration")
    title:SetTextColor(1, 1, 1)
    title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    
    -- Subtitle
    local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -8)
    subtitle:SetText("Select your class and specialization")
    subtitle:SetTextColor(0.8, 0.8, 0.9)

    -- Class section with proper containment
    local classSection = CreateFrame("Frame", nil, frame)
    classSection:SetSize(560, 160)
    classSection:SetPoint("TOP", subtitle, "BOTTOM", 0, -15)
    
    -- Class section background
    local classBg = classSection:CreateTexture(nil, "BACKGROUND")
    classBg:SetAllPoints()
    classBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    classBg:SetVertexColor(0.05, 0.05, 0.1, 0.8)
    
    -- Class section border
    local classBorder = classSection:CreateTexture(nil, "BORDER")
    classBorder:SetAllPoints()
    classBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    classBorder:SetVertexColor(0.2, 0.2, 0.3, 0.6)
    
    -- Class label
    local classLabel = classSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classLabel:SetPoint("TOP", classSection, "TOP", 0, -12)
    classLabel:SetText("Choose Your Class")
    classLabel:SetTextColor(0.9, 0.9, 1)
    classLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    -- Create class icons
    AutoRollClassSpecGUI:CreateClassIcons(classSection)

    -- Spec section (initially hidden) with proper containment
    specFrame = CreateFrame("Frame", nil, frame)
    specFrame:SetSize(560, 100)
    specFrame:SetPoint("TOP", classSection, "BOTTOM", 0, -15)
    specFrame:Hide()
    
    -- Spec section background
    local specBg = specFrame:CreateTexture(nil, "BACKGROUND")
    specBg:SetAllPoints()
    specBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    specBg:SetVertexColor(0.05, 0.1, 0.05, 0.8)
    
    -- Spec section border
    local specBorder = specFrame:CreateTexture(nil, "BORDER")
    specBorder:SetAllPoints()
    specBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    specBorder:SetVertexColor(0.2, 0.3, 0.2, 0.6)
    
    -- Spec label
    local specLabel = specFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    specLabel:SetPoint("TOP", specFrame, "TOP", 0, -12)
    specLabel:SetText("Choose Your Specialization")
    specLabel:SetTextColor(0.9, 1, 0.9)
    specLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    specFrame.label = specLabel

    -- Status text with proper positioning
    local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("TOP", specFrame, "BOTTOM", 0, -15)
    statusText:SetText("Ready to configure")
    statusText:SetTextColor(0.7, 0.8, 0.9)
    statusText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    frame.statusText = statusText

    -- Button section with proper alignment
    local buttonSection = CreateFrame("Frame", nil, frame)
    buttonSection:SetSize(560, 50)
    buttonSection:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)

    -- Cancel Button (left side)
    local cancelButton = CreateFrame("Button", "AutoRollCancelButton", buttonSection, "GameMenuButtonTemplate")
    cancelButton:SetSize(120, 35)
    cancelButton:SetPoint("BOTTOMLEFT", buttonSection, "BOTTOMLEFT", 20, 0)
    cancelButton:SetText("Cancel")
    cancelButton:SetNormalFontObject("GameFontNormalLarge")
    cancelButton:SetScript("OnClick", function()
        AutoRollClassSpecGUI:OnCancelClicked()
    end)

    -- OK Button (right side)
    local okButton = CreateFrame("Button", "AutoRollOKButton", buttonSection, "GameMenuButtonTemplate")
    okButton:SetSize(120, 35)
    okButton:SetPoint("BOTTOMRIGHT", buttonSection, "BOTTOMRIGHT", -20, 0)
    okButton:SetText("Confirm")
    okButton:SetNormalFontObject("GameFontNormalLarge")
    okButton:SetScript("OnClick", function()
        AutoRollClassSpecGUI:OnOKClicked()
    end)

    -- Fixed close button with proper positioning
    local closeButton = CreateFrame("Button", "AutoRollCloseButton", frame)
    closeButton:SetSize(25, 25)
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
    
    -- Close button background
    local closeBg = closeButton:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints()
    closeBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    closeBg:SetVertexColor(0.8, 0.2, 0.2, 0.9)
    
    -- Close button border
    local closeBorder = closeButton:CreateTexture(nil, "BORDER")
    closeBorder:SetAllPoints()
    closeBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    closeBorder:SetVertexColor(0.6, 0.1, 0.1, 1)
    
    -- Close button text
    local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeText:SetPoint("CENTER", closeButton, "CENTER", 0, 0)
    closeText:SetText("X")
    closeText:SetTextColor(1, 1, 1)
    closeText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    
    closeButton:SetScript("OnClick", function()
        AutoRollClassSpecGUI:Hide()
    end)
    
    -- Hover effects for close button
    closeButton:SetScript("OnEnter", function()
        closeBg:SetVertexColor(1, 0.3, 0.3, 1)
        closeBorder:SetVertexColor(1, 0.2, 0.2, 1)
    end)
    closeButton:SetScript("OnLeave", function()
        closeBg:SetVertexColor(0.8, 0.2, 0.2, 0.9)
        closeBorder:SetVertexColor(0.6, 0.1, 0.1, 1)
    end)

    frame:Hide()
    return frame
end

-- Create class icons with proper border highlighting
function AutoRollClassSpecGUI:CreateClassIcons(parent)
    local iconSize = 52
    local spacing = 58
    local iconsPerRow = 5
    local totalIcons = 10  -- Now we have 10 classes
    local totalRows = 2   -- 10 icons = 2 rows (5 + 5)
    
    -- Calculate proper centering for both rows (5 icons each)
    local rowWidth = (iconsPerRow * iconSize) + ((iconsPerRow - 1) * (spacing - iconSize))
    local startX = -rowWidth / 2
    
    local startY = -40
    local rowHeight = 65
    
    local iconIndex = 0
    local classOrder = {"WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "DRUID"}
    
    for _, classKey in ipairs(classOrder) do
        local classData = CLASSES[classKey]
        if classData then
            local row = math.floor(iconIndex / iconsPerRow)
            local col = iconIndex % iconsPerRow
            
            local button = CreateFrame("Button", nil, parent)
            button:SetSize(iconSize, iconSize)
            button:SetPoint("TOP", parent, "TOP", startX + (col * spacing), startY - (row * rowHeight))
            
            -- Icon texture
            local icon = button:CreateTexture(nil, "ARTWORK")
            icon:SetSize(iconSize - 4, iconSize - 4)  -- Slightly smaller to show border
            icon:SetPoint("CENTER", button, "CENTER")
            icon:SetTexture(classData.icon)
            button.icon = icon
            
            -- Normal border (always visible)
            local normalBorder = button:CreateTexture(nil, "BACKGROUND")
            normalBorder:SetAllPoints()
            normalBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
            normalBorder:SetVertexColor(0.3, 0.3, 0.4, 0.7)
            button.normalBorder = normalBorder
            
            -- Hover border
            local hoverBorder = button:CreateTexture(nil, "BORDER")
            hoverBorder:SetAllPoints()
            hoverBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
            hoverBorder:SetVertexColor(0.6, 0.6, 0.8, 0.9)
            hoverBorder:Hide()
            button.hoverBorder = hoverBorder
            
            -- Selected border (bright and prominent)
            local selectedBorder = button:CreateTexture(nil, "OVERLAY")
            selectedBorder:SetAllPoints()
            selectedBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
            selectedBorder:SetVertexColor(1, 0.8, 0.2, 1)
            selectedBorder:Hide()
            button.selectedBorder = selectedBorder
            
            -- Class name tooltip
            button:SetScript("OnEnter", function()
                GameTooltip:SetOwner(button, "ANCHOR_TOP")
                GameTooltip:SetText(classData.name, 1, 1, 1)
                GameTooltip:Show()
                if not button.selected then
                    hoverBorder:Show()
                end
            end)
            
            button:SetScript("OnLeave", function()
                GameTooltip:Hide()
                if not button.selected then
                    hoverBorder:Hide()
                end
            end)
            
            -- Click handler
            button:SetScript("OnClick", function()
                AutoRollClassSpecGUI:OnClassSelected(classKey, classData.name, button)
            end)
            
            button.classKey = classKey
            button.className = classData.name
            button.selected = false
            classButtons[classKey] = button
            
            iconIndex = iconIndex + 1
        end
    end
end

-- Create spec buttons with proper centering
function AutoRollClassSpecGUI:CreateSpecButtons(classKey)
    -- Clear existing spec buttons
    for _, button in pairs(specButtons) do
        button:Hide()
        button:SetParent(nil)
    end
    specButtons = {}
    
    local classData = CLASSES[classKey]
    if not classData then return end
    
    local buttonWidth = 140
    local buttonHeight = 35
    local spacing = 20
    local numSpecs = #classData.specs
    
    -- Calculate total width and center position properly
    local totalWidth = (numSpecs * buttonWidth) + ((numSpecs - 1) * spacing)
    local startX = -totalWidth / 2 + (buttonWidth / 2)  -- Center first button
    
    for i, specName in ipairs(classData.specs) do
        local button = CreateFrame("Button", nil, specFrame, "GameMenuButtonTemplate")
        button:SetSize(buttonWidth, buttonHeight)
        button:SetPoint("TOP", specFrame, "TOP", startX + ((i - 1) * (buttonWidth + spacing)), -50)
        button:SetText(specName)
        button:SetNormalFontObject("GameFontNormal")
        
        -- Click handler
        button:SetScript("OnClick", function()
            AutoRollClassSpecGUI:OnSpecSelected(specName, button)
        end)
        
        button.specName = specName
        button.selected = false
        specButtons[specName] = button
    end
end

-- Class selection handler with border highlighting
function AutoRollClassSpecGUI:OnClassSelected(classKey, className, button)
    -- Reset previous selection
    if selectedClass and classButtons[selectedClass] then
        classButtons[selectedClass].selectedBorder:Hide()
        classButtons[selectedClass].hoverBorder:Hide()
        classButtons[selectedClass].selected = false
    end
    
    selectedClass = classKey
    selectedSpec = nil
    
    -- Highlight selected class with border
    button.selectedBorder:Show()
    button.hoverBorder:Hide()  -- Hide hover border when selected
    button.selected = true
    
    -- Update status
    frame.statusText:SetText("Class selected: " .. className)
    frame.statusText:SetTextColor(1, 0.8, 0.2)
    
    -- Show spec section and create spec buttons
    specFrame:Show()
    AutoRollClassSpecGUI:CreateSpecButtons(classKey)
    
    print("AutoRoll: Selected class - " .. className)
end

-- Spec selection handler
function AutoRollClassSpecGUI:OnSpecSelected(specName, button)
    -- Reset previous selection
    for _, btn in pairs(specButtons) do
        btn:SetNormalFontObject("GameFontNormal")
        btn.selected = false
    end
    
    selectedSpec = specName
    
    -- Highlight selected spec
    button:SetNormalFontObject("GameFontNormalLarge")
    button.selected = true
    
    -- Update status
    local className = CLASSES[selectedClass].name
    frame.statusText:SetText("Ready: " .. className .. " - " .. specName)
    frame.statusText:SetTextColor(0.2, 1, 0.4)
    
    print("AutoRoll: Selected spec - " .. specName)
end

-- OK button handler
function AutoRollClassSpecGUI:OnOKClicked()
    if selectedClass and selectedSpec then
        local className = CLASSES[selectedClass].name
        print("AutoRoll: Configuration saved - " .. className .. " (" .. selectedSpec .. ")")
        frame.statusText:SetText("Configuration saved!")
        frame.statusText:SetTextColor(0.2, 1, 0.2)
        -- TODO: This is where we'll connect to the actual functionality later
        AutoRollClassSpecGUI:Hide()
    else
        print("AutoRoll: Please select both class and specialization")
        frame.statusText:SetText("Please complete your selection")
        frame.statusText:SetTextColor(1, 0.4, 0.4)
    end
end

-- Cancel button handler
function AutoRollClassSpecGUI:OnCancelClicked()
    print("AutoRoll: Configuration cancelled")
    AutoRollClassSpecGUI:Hide()
end

-- Show the GUI
function AutoRollClassSpecGUI:Show()
    if not frame then
        self:CreateFrame()
    end
    -- Reset selections when showing
    selectedClass = nil
    selectedSpec = nil
    if specFrame then
        specFrame:Hide()
    end
    for _, button in pairs(classButtons) do
        button.selectedBorder:Hide()
        button.selected = false
    end
    frame.statusText:SetText("Ready to configure")
    frame.statusText:SetTextColor(0.7, 0.8, 0.9)
    frame:Show()
end

-- Hide the GUI
function AutoRollClassSpecGUI:Hide()
    if frame then
        frame:Hide()
    end
end

-- Toggle the GUI
function AutoRollClassSpecGUI:Toggle()
    if frame and frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Get current selection
function AutoRollClassSpecGUI:GetSelection()
    return selectedClass, selectedSpec
end 