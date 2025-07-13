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

-- Run all tests
function TestRunner:runAllTests()
    local totalTests = 0
    local passedTests = 0
    local failedTests = {}
    
    print("=== AutoRoll Test Runner ===")
    print("Running " .. #AutoRollTestData .. " test cases...")
    print()
    
    for i, testCase in ipairs(AutoRollTestData) do
        totalTests = totalTests + 1
        
        local success, actualResult = self:runSingleTest(testCase)
        
        if success and actualResult == testCase.expectedResult then
            passedTests = passedTests + 1
            print("✓ PASS: " .. testCase.name)
        else
            local failureReason
            if not success then
                failureReason = actualResult -- Error message
            else
                failureReason = "Expected '" .. tostring(testCase.expectedResult) .. "' but got '" .. tostring(actualResult) .. "'"
            end
            
            table.insert(failedTests, {
                name = testCase.name,
                reason = failureReason,
                rules = testCase.rules,
                player = testCase.player,
                item = testCase.item
            })
            
            print("✗ FAIL: " .. testCase.name)
            print("  " .. failureReason)
        end
    end
    
    print()
    print("=== Test Results ===")
    print("Total tests: " .. totalTests)
    print("Passed: " .. passedTests)
    print("Failed: " .. (totalTests - passedTests))
    
    if #failedTests > 0 then
        print()
        print("=== Failed Test Details ===")
        for _, failure in ipairs(failedTests) do
            print("Test: " .. failure.name)
            print("Reason: " .. failure.reason)
            print("Rules: ")
            for j, rule in ipairs(failure.rules) do
                print("  " .. j .. ". " .. rule)
            end
            print("Player: Level " .. failure.player.level .. " " .. failure.player.class)
            print("Item: " .. (failure.item.itemSubType or "Unknown") .. " at " .. (failure.item.itemEquipLoc or "Unknown"))
            print()
        end
    end
    
    return passedTests, totalTests - passedTests
end

-- Run a specific test by name
function TestRunner:runTestByName(testName)
    for i, testCase in ipairs(AutoRollTestData) do
        if testCase.name == testName then
            print("Running test: " .. testName)
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
    
    print("Test not found: " .. testName)
end

-- Export the test runner
_G.AutoRollTestRunner = TestRunner

-- Auto-run tests if executed directly
if not _G.AutoRollTestRunner_ManualMode then
    TestRunner:runAllTests()
end 