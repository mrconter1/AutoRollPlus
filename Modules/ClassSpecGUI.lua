-- AutoRoll Class/Spec Selection GUI
AutoRollClassSpecGUI = {}

-- Class data for Classic WoW
local CLASSES = {
    ["WARRIOR"] = { name = "Warrior", specs = {"Arms", "Fury", "Protection"} },
    ["PALADIN"] = { name = "Paladin", specs = {"Holy", "Protection", "Retribution"} },
    ["HUNTER"] = { name = "Hunter", specs = {"Beast Mastery", "Marksmanship", "Survival"} },
    ["ROGUE"] = { name = "Rogue", specs = {"Assassination", "Combat", "Subtlety"} },
    ["PRIEST"] = { name = "Priest", specs = {"Discipline", "Holy", "Shadow"} },
    ["SHAMAN"] = { name = "Shaman", specs = {"Elemental", "Enhancement", "Restoration"} },
    ["MAGE"] = { name = "Mage", specs = {"Arcane", "Fire", "Frost"} },
    ["WARLOCK"] = { name = "Warlock", specs = {"Affliction", "Demonology", "Destruction"} },
    ["DRUID"] = { name = "Druid", specs = {"Balance", "Feral", "Restoration"} }
}

-- GUI Frame
local frame = nil
local classDropdown = nil
local specDropdown = nil
local selectedClass = nil
local selectedSpec = nil

-- Create the main frame
function AutoRollClassSpecGUI:CreateFrame()
    if frame then
        return frame
    end

    -- Main frame (very simple for Classic WoW)
    frame = CreateFrame("Frame", "AutoRollClassSpecFrame", UIParent)
    frame:SetSize(400, 300)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    -- Simple background texture
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(0, 0, 0, 0.8)
    
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -20)
    title:SetText("AutoRoll - Class & Spec Selection")
    title:SetTextColor(1, 1, 1)

    -- Class label
    local classLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 30, -60)
    classLabel:SetText("Class:")
    classLabel:SetTextColor(1, 1, 1)

    -- Class dropdown
    classDropdown = CreateFrame("Frame", "AutoRollClassDropdown", frame, "UIDropDownMenuTemplate")
    classDropdown:SetPoint("TOPLEFT", classLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(classDropdown, 150)
    UIDropDownMenu_SetText(classDropdown, "Select Class")
    UIDropDownMenu_Initialize(classDropdown, function()
        AutoRollClassSpecGUI:InitializeClassDropdown()
    end)

    -- Spec label
    local specLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    specLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 30, -130)
    specLabel:SetText("Specialization:")
    specLabel:SetTextColor(1, 1, 1)

    -- Spec dropdown
    specDropdown = CreateFrame("Frame", "AutoRollSpecDropdown", frame, "UIDropDownMenuTemplate")
    specDropdown:SetPoint("TOPLEFT", specLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(specDropdown, 150)
    UIDropDownMenu_SetText(specDropdown, "Select Spec")
    UIDropDownMenu_Initialize(specDropdown, function()
        AutoRollClassSpecGUI:InitializeSpecDropdown()
    end)

    -- OK Button
    local okButton = CreateFrame("Button", "AutoRollOKButton", frame, "GameMenuButtonTemplate")
    okButton:SetSize(100, 30)
    okButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 20)
    okButton:SetText("OK")
    okButton:SetScript("OnClick", function()
        AutoRollClassSpecGUI:OnOKClicked()
    end)

    -- Cancel Button
    local cancelButton = CreateFrame("Button", "AutoRollCancelButton", frame, "GameMenuButtonTemplate")
    cancelButton:SetSize(100, 30)
    cancelButton:SetPoint("BOTTOMRIGHT", okButton, "BOTTOMLEFT", -10, 0)
    cancelButton:SetText("Cancel")
    cancelButton:SetScript("OnClick", function()
        AutoRollClassSpecGUI:OnCancelClicked()
    end)

    -- Simple close button
    local closeButton = CreateFrame("Button", "AutoRollCloseButton", frame)
    closeButton:SetSize(20, 20)
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeButton:SetText("X")
    closeButton:SetNormalFontObject("GameFontNormalSmall")
    closeButton:SetScript("OnClick", function()
        AutoRollClassSpecGUI:Hide()
    end)

    -- Status text
    local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("TOP", frame, "TOP", 0, -220)
    statusText:SetText("Select your class and specialization")
    statusText:SetTextColor(0.8, 0.8, 0.8)
    frame.statusText = statusText

    frame:Hide()
    return frame
end

-- Initialize class dropdown
function AutoRollClassSpecGUI:InitializeClassDropdown()
    local info = UIDropDownMenu_CreateInfo()
    
    for classKey, classData in pairs(CLASSES) do
        info.text = classData.name
        info.value = classKey
        info.func = function()
            AutoRollClassSpecGUI:OnClassSelected(classKey, classData.name)
        end
        UIDropDownMenu_AddButton(info)
    end
end

-- Initialize spec dropdown
function AutoRollClassSpecGUI:InitializeSpecDropdown()
    if not selectedClass then
        return
    end

    local info = UIDropDownMenu_CreateInfo()
    local classData = CLASSES[selectedClass]
    
    if classData then
        for _, specName in ipairs(classData.specs) do
            info.text = specName
            info.value = specName
            info.func = function()
                AutoRollClassSpecGUI:OnSpecSelected(specName)
            end
            UIDropDownMenu_AddButton(info)
        end
    end
end

-- Class selection handler
function AutoRollClassSpecGUI:OnClassSelected(classKey, className)
    selectedClass = classKey
    UIDropDownMenu_SetText(classDropdown, className)
    
    -- Reset spec selection
    selectedSpec = nil
    UIDropDownMenu_SetText(specDropdown, "Select Spec")
    
    -- Update status
    frame.statusText:SetText("Class: " .. className .. " - Now select specialization")
    frame.statusText:SetTextColor(1, 1, 0)
    
    print("AutoRoll: Selected class - " .. className)
end

-- Spec selection handler
function AutoRollClassSpecGUI:OnSpecSelected(specName)
    selectedSpec = specName
    UIDropDownMenu_SetText(specDropdown, specName)
    
    -- Update status
    local className = CLASSES[selectedClass].name
    frame.statusText:SetText("Selected: " .. className .. " - " .. specName)
    frame.statusText:SetTextColor(0, 1, 0)
    
    print("AutoRoll: Selected spec - " .. specName)
end

-- OK button handler
function AutoRollClassSpecGUI:OnOKClicked()
    if selectedClass and selectedSpec then
        local className = CLASSES[selectedClass].name
        print("AutoRoll: Confirmed selection - " .. className .. " (" .. selectedSpec .. ")")
        -- TODO: This is where we'll connect to the actual functionality later
        AutoRollClassSpecGUI:Hide()
    else
        print("AutoRoll: Please select both class and specialization")
    end
end

-- Cancel button handler
function AutoRollClassSpecGUI:OnCancelClicked()
    print("AutoRoll: Selection cancelled")
    AutoRollClassSpecGUI:Hide()
end

-- Show the GUI
function AutoRollClassSpecGUI:Show()
    if not frame then
        self:CreateFrame()
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