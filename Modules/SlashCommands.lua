-- COMMANDS
SLASH_AR1 = '/ar';
SLASH_AR2 = '/autoroll';

local STAT_KEYS = AutoRollMappings.STAT_KEYS

SlashCmdList["AR"] = function(msg)
    local cmd = msg:lower()

    local rule = string.match(cmd, "^(%S*)")
    local itemIdString = AutoRollUtils:getItemId(cmd)

    if (rule == "enable") then
        AutoRoll_PCDB["enabled"] = true
        print("AutoRoll Enabled.")
        return
    end

    if (rule == "disable") then
        AutoRoll_PCDB["enabled"] = false
        print("AutoRoll Disabled.")
        return
    end



    if string.match(cmd, "^test%s+") then
        local itemLink = string.match(cmd, "^test%s+(.+)")
        if itemLink then
            local itemId = AutoRollUtils:getItemId(itemLink)
            if itemId then
                local itemName, _, itemRarity, _, _, _, itemSubType, _, itemEquipLoc = GetItemInfo(itemId)
                print("AutoRoll Test - Item: "..(itemLink or "Unknown"))
                print("-- Item Type: "..(itemSubType or "Unknown"))
                print("-- Equip Location: "..(itemEquipLoc or "Unknown"))
                print("-- Player Level: "..UnitLevel("player"))
                
                -- Check for rule strings first
                local profileKey = AutoRoll.GetCurrentProfileKey and AutoRoll.GetCurrentProfileKey()
                local ruleStrings = nil
                if profileKey then
                    local profile = AutoRollPlus_PCDB["profiles"] and AutoRollPlus_PCDB["profiles"][profileKey]
                    if profile and profile.ruleStrings then
                        ruleStrings = profile.ruleStrings
                    end
                end
                
                if ruleStrings then
                    print("-- Testing rule strings:")
                    local context = {
                        itemLink = itemLink,
                        itemSubType = itemSubType,
                        itemEquipLoc = itemEquipLoc,
                        canNeed = true,
                        canGreed = true
                    }
                    
                    -- Enable debug temporarily for this test
                    -- Call the parser from AutoRoll.lua
                    local action = AutoRoll.RuleParser and AutoRoll.RuleParser:evaluateRuleStrings(ruleStrings, context)
                    
                    if action then
                        print("-- RESULT: "..action)
                    else
                        print("-- RESULT: No matching rule")
                    end
                else
                    print("-- No rule strings found for current profile")
                    print("-- Rule strings are automatically applied based on class/spec")
                end
                return
            else
                print("AutoRoll Test - ERROR: Invalid item link")
            end
        else
            print("AutoRoll Test - Usage: /ar test [item-link]")
            print("-- Shift-click an item to get its link, then paste after 'test'")
        end
        return
    end





    if cmd == "rules" then
        print("AutoRoll - Rules")

        -- Check for rule strings
        local profileKey = AutoRoll.GetCurrentProfileKey and AutoRoll.GetCurrentProfileKey()
        local ruleStrings = nil
        if profileKey then
            local profile = AutoRollPlus_PCDB["profiles"] and AutoRollPlus_PCDB["profiles"][profileKey]
            if profile and profile.ruleStrings then
                ruleStrings = profile.ruleStrings
            end
        end
        
        if ruleStrings then
            print("-- Current Rule Strings:")
            for i, ruleString in ipairs(ruleStrings) do
                print("   "..i..". "..ruleString)
            end
        else
            print("-- No rule strings found for current profile: " .. (profileKey or "unknown"))
            print("-- Rule strings are automatically applied based on your class/spec")
        end
        return
    end

    if cmd == "clearall" then
        print("AutoRoll: Rule strings are centrally managed in Profiles.lua")
        print("-- Individual rules cannot be cleared - profiles are automatically applied based on class/spec")
        print("-- To disable AutoRoll entirely, use: /ar disable")
        return
    end

    if cmd == "test" then
        -- Run the test runner (files loaded via TOC)
        if AutoRollTestRunner then
            AutoRollTestRunner:runAllTests()
        else
            print("AutoRoll: Test runner not available")
        end
        return
    end

    if cmd == "config" then
        -- Open the configuration GUI
        if AutoRollConfigGUI then
            AutoRollConfigGUI:Initialize()
        else
            print("AutoRoll: Configuration GUI not available")
        end
        return
    end



    -- No rules matched, print help
    print("AutoRoll - Commands")
    print("-- View current rules:")
    print("--       /ar rules")
    print("-- Control addon:")
    print("--       /ar enable")
    print("--       /ar disable")

    print("-- Testing:")
    print("--       /ar test [item-link]")
    print("--       /ar test         (run unit tests)")
    print("-- Configuration:")
    print("--       /ar config       (open configuration GUI)")
    print("-- Note: Rules are automatically applied based on your class/spec")
    print("-- Edit rules in Profiles.lua or use /artest for testing interface")

end
