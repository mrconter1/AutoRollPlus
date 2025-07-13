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
        elseif itemLink and itemLink:match("equipped_item_") then
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
    
    -- Return cleanup function
    return function()
        _G.UnitLevel = originalUnitLevel
        _G.UnitClass = originalUnitClass
        _G.GetItemStats = originalGetItemStats
        _G.GetInventoryItemLink = originalGetInventoryItemLink
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

-- Run tests for a specific profile
function TestRunner:runProfileTests(profileName)
    local profile = AutoRollTestProfiles[profileName]
    if not profile then
        print("Profile not found: " .. profileName)
        return
    end
    
    local totalTests = 0
    local passedTests = 0
    local failedTests = {}
    
    print("=== Testing Profile: " .. profileName .. " ===")
    print("Rule Script:")
    for i, rule in ipairs(profile.ruleScript) do
        print("  " .. i .. ". " .. rule)
    end
    print()
    print("Running " .. #profile.scenarios .. " scenarios...")
    print()
    
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
            print("✓ PASS: " .. scenario.name)
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
            
            print("✗ FAIL: " .. scenario.name)
            print("  " .. failureReason)
        end
    end
    
    print()
    print("=== Profile Results ===")
    print("Total tests: " .. totalTests)
    print("Passed: " .. passedTests)
    print("Failed: " .. (totalTests - passedTests))
    
    if #failedTests > 0 then
        print()
        print("=== Failed Test Details ===")
        for _, failure in ipairs(failedTests) do
            print("Test: " .. failure.name)
            print("Reason: " .. failure.reason)
            print()
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

-- Run all profiles with organization
function TestRunner:runAllProfiles()
    local totalTests = 0
    local totalPassed = 0
    local totalFailed = 0
    
    print("=== AutoRoll Test Runner - Profile Mode ===")
    print()
    
    for profileName, profile in pairs(AutoRollTestProfiles) do
        local passed, failed = self:runProfileTests(profileName)
        totalTests = totalTests + #profile.scenarios
        totalPassed = totalPassed + passed
        totalFailed = totalFailed + failed
        print()
    end
    
    print("=== Overall Results ===")
    print("Total tests: " .. totalTests)
    print("Passed: " .. totalPassed)
    print("Failed: " .. totalFailed)
    
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
-- TestRunner:runAllProfiles()                         -- Run all profiles with organization
-- TestRunner:runProfileTests("hunter")                -- Run only hunter profile tests
-- TestRunner:runProfileTests("priest_holy")           -- Run only priest_holy profile tests
-- TestRunner:runScenario("hunter", "bow upgrade")     -- Run specific scenario in profile 