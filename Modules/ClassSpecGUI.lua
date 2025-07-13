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
    frame:SetSize(900, 600)
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
    topBar:SetSize(700, 3)
    topBar:SetPoint("TOP", frame, "TOP", 0, 0)
    topBar:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    topBar:SetVertexColor(0.2, 0.6, 1, 1)
    
    frame:EnableMouse(true)
    -- Dragging disabled to improve text selection
    -- frame:SetMovable(true)
    -- frame:RegisterForDrag("LeftButton")
    -- frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    -- frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -25)
    title:SetText("AutoRoll Configuration")
    title:SetTextColor(1, 1, 1)
    title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    
    -- Message label (will be set in Show)
    frame.detectedLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.detectedLabel:SetPoint("TOP", title, "BOTTOM", 0, -30)
    frame.detectedLabel:SetTextColor(0.9, 0.9, 1)
    frame.detectedLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")

    -- Status text with proper positioning
    local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("TOP", frame.detectedLabel, "BOTTOM", 0, -20)
    statusText:SetText("Ready to configure")
    statusText:SetTextColor(0.7, 0.8, 0.9)
    statusText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    frame.statusText = statusText

    -- ScrollFrame for rules
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -120)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 70)
    frame.rulesScrollFrame = scrollFrame

    local rulesContent = CreateFrame("Frame", nil, scrollFrame)
    rulesContent:SetSize(1, 1) -- Will be resized dynamically
    scrollFrame:SetScrollChild(rulesContent)
    frame.rulesContent = rulesContent

    -- Button section with proper alignment
    local buttonSection = CreateFrame("Frame", nil, frame)
    buttonSection:SetSize(660, 50)
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

-- Utility to detect class and spec
local function DetectPlayerClassAndSpec()
    local _, classKey = UnitClass("player")
    local specName = nil
    -- MoP: Use GetPrimaryTalentTree if available
    if GetPrimaryTalentTree then
        local specIndex = GetPrimaryTalentTree()
        local classSpecs = {
            WARRIOR = {"Arms", "Fury", "Protection"},
            PALADIN = {"Holy", "Protection", "Retribution"},
            HUNTER = {"Beast Mastery", "Marksmanship", "Survival"},
            ROGUE = {"Assassination", "Combat", "Subtlety"},
            PRIEST = {"Discipline", "Holy", "Shadow"},
            DEATHKNIGHT = {"Blood", "Frost", "Unholy"},
            SHAMAN = {"Elemental", "Enhancement", "Restoration"},
            MAGE = {"Arcane", "Fire", "Frost"},
            WARLOCK = {"Affliction", "Demonology", "Destruction"},
            DRUID = {"Balance", "Feral", "Restoration"},
            MONK = {"Brewmaster", "Mistweaver", "Windwalker"},
        }
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
    return classKey, specName
end

-- Patch: Disable all class and spec buttons except the detected ones
function AutoRollClassSpecGUI:CreateClassIcons(parent, detectedClass)
    local iconSize = 52
    local spacing = 58
    local iconsPerRow = 5
    local totalIcons = 10
    local totalRows = 2
    local rowWidth = (iconsPerRow * iconSize) + ((iconsPerRow - 1) * (spacing - iconSize))
    local startX = -rowWidth / 2 + (iconSize / 2)
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
            button:SetSize(iconSize + 8, iconSize + 8)
            button:SetPoint("TOP", parent, "TOP", startX + (col * spacing), startY - (row * rowHeight))
            
            -- Background glow for selection (initially hidden)
            local selectionGlow = button:CreateTexture(nil, "BACKGROUND")
            selectionGlow:SetSize(iconSize + 12, iconSize + 12)
            selectionGlow:SetPoint("CENTER", button, "CENTER")
            selectionGlow:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
            selectionGlow:SetVertexColor(1, 0.8, 0.2, 0.8)
            selectionGlow:Hide()
            button.selectionGlow = selectionGlow
            
            -- Hover glow (initially hidden)
            local hoverGlow = button:CreateTexture(nil, "BACKGROUND")
            hoverGlow:SetSize(iconSize + 8, iconSize + 8)
            hoverGlow:SetPoint("CENTER", button, "CENTER")
            hoverGlow:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
            hoverGlow:SetVertexColor(0.6, 0.6, 0.9, 0.6)
            hoverGlow:Hide()
            button.hoverGlow = hoverGlow
            
            -- Icon texture
            local icon = button:CreateTexture(nil, "ARTWORK")
            icon:SetSize(iconSize - 2, iconSize - 2)  -- Slightly smaller to show border
            icon:SetPoint("CENTER", button, "CENTER")
            icon:SetTexture(classData.icon)
            button.icon = icon
            
            -- Normal border (always visible, subtle)
            local normalBorder = button:CreateTexture(nil, "BORDER")
            normalBorder:SetSize(iconSize + 2, iconSize + 2)
            normalBorder:SetPoint("CENTER", button, "CENTER")
            normalBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
            normalBorder:SetVertexColor(0.4, 0.4, 0.5, 0.8)
            button.normalBorder = normalBorder
            
            -- Hover border (more prominent)
            local hoverBorder = button:CreateTexture(nil, "BORDER")
            hoverBorder:SetSize(iconSize + 4, iconSize + 4)
            hoverBorder:SetPoint("CENTER", button, "CENTER")
            hoverBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
            hoverBorder:SetVertexColor(0.7, 0.7, 1, 1)
            hoverBorder:Hide()
            button.hoverBorder = hoverBorder
            
            -- Selected border (very prominent with multiple layers)
            local selectedBorder1 = button:CreateTexture(nil, "OVERLAY")
            selectedBorder1:SetSize(iconSize + 6, iconSize + 6)
            selectedBorder1:SetPoint("CENTER", button, "CENTER")
            selectedBorder1:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
            selectedBorder1:SetVertexColor(1, 0.8, 0.2, 1)
            selectedBorder1:Hide()
            button.selectedBorder1 = selectedBorder1
            
            -- Second selected border layer for more prominence
            local selectedBorder2 = button:CreateTexture(nil, "OVERLAY")
            selectedBorder2:SetSize(iconSize + 8, iconSize + 8)
            selectedBorder2:SetPoint("CENTER", button, "CENTER")
            selectedBorder2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
            selectedBorder2:SetVertexColor(1, 0.9, 0.4, 0.7)
            selectedBorder2:Hide()
            button.selectedBorder2 = selectedBorder2
            
            -- Class name tooltip
            button:SetScript("OnEnter", function()
                GameTooltip:SetOwner(button, "ANCHOR_TOP")
                GameTooltip:SetText(classData.name, 1, 1, 1)
                GameTooltip:Show()
                if not button.selected then
                    hoverBorder:Show()
                    hoverGlow:Show()
                end
            end)
            
            button:SetScript("OnLeave", function()
                GameTooltip:Hide()
                if not button.selected then
                    hoverBorder:Hide()
                    hoverGlow:Hide()
                end
            end)
            
            -- Remove click handler
            button:SetScript("OnClick", nil)
            button:Disable()
            if classKey == detectedClass then
                button:Enable()
            end
            button.classKey = classKey
            button.className = classData.name
            button.selected = false
            classButtons[classKey] = button
            iconIndex = iconIndex + 1
        end
    end
end

function AutoRollClassSpecGUI:CreateSpecButtons(classKey, detectedSpec)
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
    local totalWidth = (numSpecs * buttonWidth) + ((numSpecs - 1) * spacing)
    local startX = -totalWidth / 2 + (buttonWidth / 2)
    for i, specName in ipairs(classData.specs) do
        local button = CreateFrame("Button", nil, specFrame, "GameMenuButtonTemplate")
        button:SetSize(buttonWidth, buttonHeight)
        button:SetPoint("TOP", specFrame, "TOP", startX + ((i - 1) * (buttonWidth + spacing)), -50)
        button:SetText(specName)
        button:SetNormalFontObject("GameFontNormal")
        -- Remove click handler
        button:SetScript("OnClick", nil)
        button:Disable()
        if specName == detectedSpec then
            button:Enable()
        end
        button.specName = specName
        button.selected = false
        specButtons[specName] = button
    end
end

-- Class selection handler with enhanced border highlighting
function AutoRollClassSpecGUI:OnClassSelected(classKey, className, button)
    -- Reset previous selection
    if selectedClass and classButtons[selectedClass] then
        local prevButton = classButtons[selectedClass]
        prevButton.selectedBorder1:Hide()
        prevButton.selectedBorder2:Hide()
        prevButton.selectionGlow:Hide()
        prevButton.hoverBorder:Hide()
        prevButton.hoverGlow:Hide()
        prevButton.selected = false
    end
    
    selectedClass = classKey
    selectedSpec = nil
    
    -- Highlight selected class with enhanced borders and glow
    button.selectedBorder1:Show()
    button.selectedBorder2:Show()
    button.selectionGlow:Show()
    button.hoverBorder:Hide()  -- Hide hover border when selected
    button.hoverGlow:Hide()    -- Hide hover glow when selected
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
    -- Detect class and spec
    local detectedClass, detectedSpec = DetectPlayerClassAndSpec()
    selectedClass = detectedClass
    selectedSpec = detectedSpec
    -- Set the detected label
    local className = detectedClass and CLASSES[detectedClass] and CLASSES[detectedClass].name or (detectedClass or "Unknown")
    local specName = detectedSpec or "Unknown"
    frame.detectedLabel:SetText("Detected your class/spec: |cffffd200"..className.."|r - |cff00ffba"..specName.."|r.\nAutoRollPlus will use the profile for this character.")
    frame.statusText:SetText("")
    frame.statusText:SetTextColor(0.7, 0.8, 0.9)

    -- Hide all extra UI elements
    if frame.profileKeyLabel then frame.profileKeyLabel:Hide() end
    if frame.suggestedHeader then frame.suggestedHeader:Hide() end
    if frame.suggestedLines then for _, line in ipairs(frame.suggestedLines) do line:Hide() end end
    if frame.rulesSeparator then frame.rulesSeparator:Hide() end
    if frame.rulesHeader then frame.rulesHeader:Hide() end
    if frame.reviewNote then frame.reviewNote:Hide() end
    if frame.rulesBg then frame.rulesBg:Hide() end
    if frame.rulesBorder then frame.rulesBorder:Hide() end

    -- Show only the rules for this profile as a scrollable list
    local rulesContent = frame.rulesContent
    for _, child in ipairs({rulesContent:GetChildren()}) do child:Hide() end
    local profileKey = AutoRoll.GetCurrentProfileKey and AutoRoll.GetCurrentProfileKey() or "(unknown)"
    local rulesList = {}
    if profileKey == "priest_discipline" then
        local profile = AutoRollDefaults and AutoRollDefaults.profiles and AutoRollDefaults.profiles["priest_discipline"] or {}
        for _, rule in ipairs(profile) do
            if type(rule) == "table" and rule.item and rule.stat and rule.upgrade and rule.action then
                table.insert(rulesList, string.format("%s if %s and item is an %s upgrade", rule.action, rule.item, rule.stat))
            end
        end
        -- Add the default action as the last line
        if AutoRollDefaults and AutoRollDefaults.defaultAction then
            table.insert(rulesList, string.format("Otherwise, auto-%s", AutoRollDefaults.defaultAction:upper()))
        end
    else
        local rules = AutoRoll.GetActiveRules and AutoRoll.GetActiveRules() or {}
        if type(rules) == "table" and type(rules[1]) == "table" then
            -- New array-of-objects format
            for _, rule in ipairs(rules) do
                if rule.item and rule.stat and rule.upgrade and rule.action then
                    table.insert(rulesList, string.format("%s if %s and item is an %s upgrade", rule.action, rule.item, rule.stat))
                elseif rule.item and rule.action then
                    table.insert(rulesList, string.format("%s on %s", rule.action, rule.item))
                end
            end
            -- Print default action as fallback
            if AutoRollDefaults and AutoRollDefaults.defaultAction then
                table.insert(rulesList, string.format("Otherwise, auto-%s", AutoRollDefaults.defaultAction:upper()))
            end
        else
            -- Legacy format handling (table-based rules)
            for k, v in pairs(rules) do
                if k:find("dynamic_pass_ifnotupgrade_intellect_cloth") and v then
                    table.insert(rulesList, "PASS if not upgrade (cloth, intellect)")
                elseif k == "staves" and v == AutoRollUtils.ROLL.NEED then
                    table.insert(rulesList, "NEED staves")
                elseif type(v) == "number" then
                    local ruleStr = AutoRollUtils:getRuleString(v)
                    table.insert(rulesList, (ruleStr:upper() or "?") .. " on " .. k)
                elseif type(v) == "boolean" and v then
                    table.insert(rulesList, k)
                end
            end
        end
    end
    -- Remove old rule lines
    if frame.ruleLines then for _, line in ipairs(frame.ruleLines) do line:Hide() end end
    frame.ruleLines = {}
    if frame.ruleRowFrames then for _, row in ipairs(frame.ruleRowFrames) do row:Hide() end end
    frame.ruleRowFrames = {}
    -- Render rules as a table with four columns: Item Type, Greed, Need, Manual
    local yOffset = 0
    local lastRow = nil
    local rowHeight = 24
    local tableWidth = frame:GetWidth() - 60
    local col1Width = math.floor(tableWidth * 0.55)
    local col2Width = math.floor(tableWidth * 0.15)
    local col3Width = math.floor(tableWidth * 0.15)
    local col4Width = math.floor(tableWidth * 0.15)
    -- Header row
    if not frame.rulesHeaderRow then
        local header = CreateFrame("Frame", nil, rulesContent)
        header:SetHeight(rowHeight+2)
        header:SetWidth(tableWidth)
        local bg = header:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.18, 0.22, 0.32, 1)
        local border = header:CreateTexture(nil, "BORDER")
        border:SetAllPoints()
        border:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
        border:SetVertexColor(0.35, 0.45, 0.65, 0.9)
        local col1 = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        col1:SetText("Item Type")
        col1:SetTextColor(1, 1, 1)
        col1:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        col1:SetPoint("LEFT", header, "LEFT", 16, 0)
        col1:SetWidth(col1Width)
        col1:SetJustifyH("LEFT")
        local col2 = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        col2:SetText("Greed")
        col2:SetTextColor(0.2, 1, 0.2)
        col2:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        col2:SetPoint("LEFT", header, "LEFT", col1Width + 8, 0)
        col2:SetWidth(col2Width)
        col2:SetJustifyH("CENTER")
        local col3 = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        col3:SetText("Need")
        col3:SetTextColor(0.2, 0.6, 1)
        col3:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        col3:SetPoint("LEFT", header, "LEFT", col1Width + col2Width + 16, 0)
        col3:SetWidth(col3Width)
        col3:SetJustifyH("CENTER")
        local col4 = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        col4:SetText("Manual")
        col4:SetTextColor(1, 0.85, 0.2)
        col4:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        col4:SetPoint("LEFT", header, "LEFT", col1Width + col2Width + col3Width + 24, 0)
        col4:SetWidth(col4Width)
        col4:SetJustifyH("CENTER")
        -- Add a thin line below the header
        local sep = header:CreateTexture(nil, "ARTWORK")
        sep:SetColorTexture(0.3, 0.35, 0.45, 0.85)
        sep:SetHeight(1)
        sep:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 2, 0)
        sep:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -2, 0)
        frame.rulesHeaderRow = header
    end
    frame.rulesHeaderRow:SetWidth(tableWidth)
    frame.rulesHeaderRow:SetPoint("TOPLEFT", rulesContent, "TOPLEFT", 0, 0)
    frame.rulesHeaderRow:Show()
    lastRow = frame.rulesHeaderRow
    -- Render each rule as a table row
    local rowIdx = 1
    for _, rule in ipairs(rulesList) do
        local itemType, action = nil, nil
        if rule:find(" on ") then
            action, itemType = rule:match("^(%w+) on (.+)$")
        elseif rule:find(" if ") then
            action, itemType = rule:match("^(%w+) if (.+)$")
        end
        if itemType and action then
            local row = frame.ruleRowFrames and frame.ruleRowFrames[rowIdx] or nil
            if not row then
                row = CreateFrame("Frame", nil, rulesContent)
                row:SetHeight(rowHeight)
                row:SetWidth(tableWidth)
                -- Alternating row color
                local bg = row:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints()
                if rowIdx % 2 == 0 then
                    bg:SetColorTexture(0.15, 0.18, 0.26, 0.93)
                else
                    bg:SetColorTexture(0.11, 0.13, 0.19, 0.93)
                end
                row.bg = bg
                -- Thin line at bottom of each row
                local sep = row:CreateTexture(nil, "ARTWORK")
                sep:SetColorTexture(0.22, 0.25, 0.32, 0.7)
                sep:SetHeight(1)
                sep:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 2, 0)
                sep:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -2, 0)
                row.sep = sep
                -- Item Type text
                local col1 = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                col1:SetTextColor(0.95, 0.98, 1)
                col1:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                col1:SetJustifyH("LEFT")
                col1:SetPoint("LEFT", row, "LEFT", 16, 0)
                col1:SetWidth(col1Width)
                row.col1 = col1
                -- Greed icon
                local greedIcon = row:CreateTexture(nil, "ARTWORK")
                greedIcon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                greedIcon:SetSize(16, 16)
                greedIcon:SetPoint("CENTER", row, "LEFT", col1Width + col2Width/2 + 8, 0)
                greedIcon:Hide()
                row.greedIcon = greedIcon
                -- Need icon
                local needIcon = row:CreateTexture(nil, "ARTWORK")
                needIcon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                needIcon:SetSize(16, 16)
                needIcon:SetPoint("CENTER", row, "LEFT", col1Width + col2Width + col3Width/2 + 16, 0)
                needIcon:Hide()
                row.needIcon = needIcon
                -- Manual icon
                local manualIcon = row:CreateTexture(nil, "ARTWORK")
                manualIcon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                manualIcon:SetSize(16, 16)
                manualIcon:SetPoint("CENTER", row, "LEFT", col1Width + col2Width + col3Width + col4Width/2 + 24, 0)
                manualIcon:Hide()
                row.manualIcon = manualIcon
                frame.ruleRowFrames = frame.ruleRowFrames or {}
                table.insert(frame.ruleRowFrames, row)
            end
            row:SetWidth(tableWidth)
            row.col1:SetText(itemType)
            row.greedIcon:Hide()
            row.needIcon:Hide()
            row.manualIcon:Hide()
            if action:upper() == "GREED" or action:upper() == "ROLLGREED" then
                row.greedIcon:SetVertexColor(0.2, 1, 0.2, 1)
                row.greedIcon:Show()
            elseif action:upper() == "NEED" or action:upper() == "ROLLNEED" then
                row.needIcon:SetVertexColor(0.2, 0.6, 1, 1)
                row.needIcon:Show()
            elseif action:upper() == "MANUAL" or action:upper() == "MANUALROLL" then
                row.manualIcon:SetVertexColor(1, 0.85, 0.2, 1)
                row.manualIcon:Show()
            end
            row:ClearAllPoints()
            if rowIdx == 1 then
                row:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT", 0, yOffset)
            else
                row:SetPoint("TOPLEFT", frame.ruleRowFrames[rowIdx-1], "BOTTOMLEFT", 0, yOffset)
            end
            row:Show()
            lastRow = row
            rowIdx = rowIdx + 1
        end
    end
    -- Hide any extra row frames
    if frame.ruleRowFrames then
        for i = rowIdx, #frame.ruleRowFrames do
            frame.ruleRowFrames[i]:Hide()
        end
    end
    -- Resize content frame to fit all rows
    if lastRow then
        local _, _, _, _, y = lastRow:GetPoint()
        rulesContent:SetHeight(math.abs(y) + (rowIdx * rowHeight) + 10)
    else
        rulesContent:SetHeight(40)
    end
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