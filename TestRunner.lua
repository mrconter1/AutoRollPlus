-- AutoRoll Test Runner
-- Loads test data and executes rule evaluation tests

-- Dependencies loaded via TOC file

local TestRunner = {}

-- Mock WoW API functions
local function setupTestMocks(testCase)
    -- Store original functions
    local originalUnitLevel = _G.UnitLevel
    local originalUnitClass = _G.UnitClass
    local originalGetItemStats = _G.GetItemStats
    local originalGetInventoryItemLink = _G.GetInventoryItemLink
    local originalGetContainerNumSlots = _G.GetContainerNumSlots
    local originalGetContainerItemLink = _G.GetContainerItemLink
    local originalGetItemInfo = _G.GetItemInfo
    
    -- Mock UnitLevel
    _G.UnitLevel = function(unit)
        if unit == "player" then
            return testCase.player.level
        end
        return originalUnitLevel and originalUnitLevel(unit)
    end
    
    -- Mock UnitClass  
    _G.UnitClass = function(unit)
        if unit == "player" then
            return testCase.player.class, testCase.player.class:upper()
        end
        return originalUnitClass and originalUnitClass(unit)
    end
    
    -- Mock GetItemStats
    _G.GetItemStats = function(itemLink)
        if itemLink == "test_item_link" then
            return testCase.item.stats
        end

        if itemLink and itemLink:match("bag_item_") then
            local bagID_s, slotID_s = itemLink:match("bag_item_(%d+)_(%d+)")
            local bagID, slotID = tonumber(bagID_s), tonumber(slotID_s)
            if testCase.bagItems and testCase.bagItems[slotID] then
                return testCase.bagItems[slotID].stats
            end
        end

        if itemLink and itemLink:match("equipped_item_") then
            -- Extract slot ID from fake equipped item link
            local slotID = tonumber(itemLink:match("equipped_item_(%d+)"))
            if slotID and testCase.equippedItems[slotID] then
                return testCase.equippedItems[slotID].stats
            end
        end
        return originalGetItemStats and originalGetItemStats(itemLink)
    end
    
    -- Mock GetInventoryItemLink
    _G.GetInventoryItemLink = function(unit, slotID)
        if unit == "player" and testCase.equippedItems[slotID] then
            return "equipped_item_" .. slotID
        end
        return originalGetInventoryItemLink and originalGetInventoryItemLink(unit, slotID)
    end
    
    -- Mock bag functions
    local bagItems = testCase.bagItems or {}
    _G.GetContainerNumSlots = function(bagID)
        if bagID == 0 then
            return #bagItems
        end
        return 0
    end
    
    _G.GetContainerItemLink = function(bagID, slotID)
        if bagID == 0 and slotID <= #bagItems then
            -- Generate a unique, parsable link for the bag item
            return "bag_item_" .. bagID .. "_" .. slotID
        end
        return nil
    end
    
    -- Mock GetItemInfo to extract equipLoc from our fake item links
    _G.GetItemInfo = function(itemLink)
        if itemLink and itemLink:match("bag_item_") then
            local bagID_s, slotID_s = itemLink:match("bag_item_(%d+)_(%d+)")
            local bagID, slotID = tonumber(bagID_s), tonumber(slotID_s)
            if testCase.bagItems and testCase.bagItems[slotID] then
                local itemData = testCase.bagItems[slotID]
                return nil, nil, nil, nil, nil, nil, itemData.itemSubType, itemData.itemEquipLoc
            end
        end
        if originalGetItemInfo then
            return originalGetItemInfo(itemLink)
        end
        return nil
    end

    -- Return cleanup function
    return function()
        _G.UnitLevel = originalUnitLevel
        _G.UnitClass = originalUnitClass
        _G.GetItemStats = originalGetItemStats
        _G.GetInventoryItemLink = originalGetInventoryItemLink
        _G.GetContainerNumSlots = originalGetContainerNumSlots
        _G.GetContainerItemLink = originalGetContainerItemLink
        _G.GetItemInfo = originalGetItemInfo
    end
end

-- Run a single test case
function TestRunner:runSingleTest(testCase)
    local cleanup = setupTestMocks(testCase)
    
    local success, result = pcall(function()
        -- Create context like EvaluateActiveRolls does
        local context = {
            itemLink = "test_item_link",
            itemSubType = testCase.item.itemSubType,
            itemEquipLoc = testCase.item.itemEquipLoc,
            canNeed = true,
            canGreed = true
        }
        
        -- Use the rule parser to evaluate the rule strings
        local action = AutoRoll.RuleParser:evaluateRuleStrings(testCase.rules, context)
        
        return action
    end)
    
    cleanup()
    
    if not success then
        return false, "ERROR: " .. tostring(result)
    end
    
    return true, result
end

-- Run tests for a specific profile (concise mode)
function TestRunner:runProfileTests(profileName, verbose)
    local profile = AutoRollTestProfiles[profileName]
    if not profile then
        print("Profile not found: " .. profileName)
        return
    end
    
    local totalTests = 0
    local passedTests = 0
    local failedTests = {}
    
    if verbose then
        print("=== Testing Profile: " .. profileName .. " ===")
        print("Rule Script:")
        for i, rule in ipairs(profile.ruleScript) do
            print("  " .. i .. ". " .. rule)
        end
        print()
        print("Running " .. #profile.scenarios .. " scenarios...")
        print()
    end
    
    for i, scenario in ipairs(profile.scenarios) do
        totalTests = totalTests + 1
        
        local testCase = {
            name = profileName .. " - " .. scenario.name,
            rules = profile.ruleScript,
            player = scenario.player,
            item = scenario.item,
            equippedItems = scenario.equippedItems,
            expectedResult = scenario.expectedResult
        }
        
        local success, actualResult = self:runSingleTest(testCase)
        
        if success and actualResult == testCase.expectedResult then
            passedTests = passedTests + 1
            if verbose then
                print("[PASS] " .. scenario.name)
            end
        else
            local failureReason
            if not success then
                failureReason = actualResult -- Error message
            else
                failureReason = "Expected '" .. tostring(testCase.expectedResult) .. "' but got '" .. tostring(actualResult) .. "'"
            end
            
            table.insert(failedTests, {
                name = scenario.name,
                reason = failureReason,
                rules = profile.ruleScript,
                player = scenario.player,
                item = scenario.item
            })
            
            if verbose then
                print("[FAIL] " .. scenario.name)
                print("  " .. failureReason)
            end
        end
    end
    
    -- .NET style summary line
    local statusIcon = (totalTests == passedTests) and "[OK]" or "[FAIL]"
    print(profileName .. ": " .. totalTests .. " tests, " .. passedTests .. " passed, " .. (totalTests - passedTests) .. " failed " .. statusIcon)
    
    -- Show details only if verbose or if there are failures
    if verbose or #failedTests > 0 then
        if verbose then
            print()
            print("=== Profile Results ===")
            print("Total tests: " .. totalTests)
            print("Passed: " .. passedTests)
            print("Failed: " .. (totalTests - passedTests))
        end
        
        if #failedTests > 0 then
            print()
            print("=== Failed Test Details for " .. profileName .. " ===")
            for _, failure in ipairs(failedTests) do
                print("  [FAIL] " .. failure.name .. ": " .. failure.reason)
            end
        end
    end
    
    return passedTests, totalTests - passedTests
end

-- List all available profiles
function TestRunner:listProfiles()
    print("=== Available Test Profiles ===")
    for profileName, profile in pairs(AutoRollTestProfiles) do
        print(profileName .. " (" .. #profile.scenarios .. " scenarios)")
        print("  Rule Script:")
        for i, rule in ipairs(profile.ruleScript) do
            print("    " .. i .. ". " .. rule)
        end
        print()
    end
end

-- Run all profiles with organization (concise mode)
function TestRunner:runAllProfiles(verbose)
    local totalTests = 0
    local totalPassed = 0
    local totalFailed = 0
    
    if verbose then
        print("=== AutoRollPlus Test Runner - Profile Mode ===")
        print()
    else
        print("Running tests...")
        print()
    end
    
    for profileName, profile in pairs(AutoRollTestProfiles) do
        local passed, failed = self:runProfileTests(profileName, verbose)
        totalTests = totalTests + #profile.scenarios
        totalPassed = totalPassed + passed
        totalFailed = totalFailed + failed
        if verbose then
            print()
        end
    end
    
    if not verbose then
        print()
    end
    
    local overallStatus = (totalFailed == 0) and "[OK]" or "[FAIL]"
    print("Test run finished: " .. totalTests .. " tests, " .. totalPassed .. " passed, " .. totalFailed .. " failed " .. overallStatus)
    
    return totalPassed, totalFailed
end

-- Run a specific scenario by name within a profile
function TestRunner:runScenario(profileName, scenarioName)
    local profile = AutoRollTestProfiles[profileName]
    if not profile then
        print("Profile not found: " .. profileName)
        return
    end
    
    for i, scenario in ipairs(profile.scenarios) do
        if scenario.name == scenarioName then
            print("Running scenario: " .. profileName .. " - " .. scenarioName)
            
            local testCase = {
                name = profileName .. " - " .. scenario.name,
                rules = profile.ruleScript,
                player = scenario.player,
                item = scenario.item,
                equippedItems = scenario.equippedItems,
                expectedResult = scenario.expectedResult
            }
            
            local success, result = self:runSingleTest(testCase)
            
            if success then
                print("Result: " .. tostring(result))
                print("Expected: " .. tostring(testCase.expectedResult))
                print("Status: " .. (result == testCase.expectedResult and "PASS" or "FAIL"))
            else
                print("ERROR: " .. tostring(result))
            end
            return
        end
    end
    
    print("Scenario not found: " .. scenarioName .. " in profile " .. profileName)
end

-- Export the test runner
_G.AutoRollTestRunner = TestRunner

-- Usage examples:
-- TestRunner:listProfiles()                           -- List all available profiles
-- TestRunner:runAllProfiles()                         -- Run all profiles (concise mode)
-- TestRunner:runAllProfiles(true)                     -- Run all profiles (verbose mode)
-- TestRunner:runProfileTests("hunter")                -- Run hunter profile (concise mode)
-- TestRunner:runProfileTests("hunter", true)          -- Run hunter profile (verbose mode)
-- TestRunner:runScenario("hunter", "bow upgrade")     -- Run specific scenario in profile 