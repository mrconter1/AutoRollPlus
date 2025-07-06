-- COMMANDS
SLASH_AR1 = '/ar';
SLASH_AR2 = '/autoroll';

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

    if (rule == "need") or (rule == "greed") or (rule == "pass") or (rule == "exempt") then
        -- NEW FEATURE: "/ar exempt <item-type> [<item-type> ...]"
        -- Example: /ar exempt leather staves
        -- This will set EXEMPT rules so these items always show manual roll window
        if (rule == "exempt") then
            local itemTypeList = string.match(cmd, "^exempt%s+(.+)")
            if itemTypeList then
                for word in string.gmatch(itemTypeList, "%S+") do
                    AutoRoll.SaveRule(word:lower(), "exempt")
                end
                print("AutoRoll - EXEMPT (manual roll) for: " .. itemTypeList)
                return
            end
        end
        
        if (rule == "pass") then
            -- Special case: pass ifnotupgrade <item-type> <stat>
            local itemType, stat = string.match(cmd, "^pass%s+ifnotupgrade%s+(.-)%s+(%S+)$")
            if itemType and stat then
                local ruleKey = "dynamic_pass_ifnotupgrade_"..stat:lower().."_"..itemType:lower()
                AutoRoll_PCDB["rules"][ruleKey] = true
                print("AutoRoll - PASS on non-upgrade "..itemType.." ("..stat..") items enabled.")
                return
            end
        end

        -- Item Link Rules
        if itemIdString then
            AutoRoll.SaveRule(itemIdString, rule)
            return
        end

        -- Item Rarity + Item Type Rules
        if AutoRoll.CheckRuleCombinations(cmd, rule) then
            return
        end

        -- Item Type Rules
        if AutoRoll.CheckItemType(cmd, rule) then
            return
        end

        -- Item Rarity Rules
        if AutoRoll.CheckItemRarity(cmd, rule) then
            return
        end

        -- Zul'Gurub Coins
        if string.match(cmd, "coins") then
            for index,itemId in ipairs(AutoRoll.COIN_IDS) do
                AutoRoll.SaveRule(itemId, rule)
            end
            return
        end

        -- Zul'Gurub Bijous
        if string.match(cmd, "bijous") then
            for index,itemId in ipairs(AutoRoll.BIJOUS_IDS) do
                AutoRoll.SaveRule(itemId, rule)
            end
            return
        end

        -- Ahn'Qiraj Scarabs
        if string.match(cmd, "scarabs") then
            for index,itemId in ipairs(AutoRoll.SCARAB_IDS) do
                AutoRoll.SaveRule(itemId, rule)
            end
            return
        end

        -- Ahn'Qiraj Idols
        if string.match(cmd, "idols") then
            for index,itemId in ipairs(AutoRoll.IDOL_IDS) do
                AutoRoll.SaveRule(itemId, rule)
            end
            return
        end
    end

    if (rule == "reset") or (rule == "ignore") or (rule == "clear") or (rule == "remove") then
        -- Special case: clear ifnotupgrade <item-type> <stat>
        local itemType, stat = string.match(cmd, "^%w+%s+ifnotupgrade%s+(.-)%s+(%S+)$")
        if itemType and stat then
            local ruleKey = "dynamic_pass_ifnotupgrade_"..stat:lower().."_"..itemType:lower()
            AutoRoll_PCDB["rules"][ruleKey] = nil
            print("AutoRoll - Removed non-upgrade PASS rule for "..itemType.." ("..stat..")")
            return
        end

        if itemIdString then
            AutoRoll.SaveRule(itemIdString, nil)
            return
        end

        -- Zul'Gurub Coins
        if string.match(cmd, "coins") then
            for index,itemId in ipairs(AutoRoll.COIN_IDS) do
                AutoRoll.SaveRule(itemId, nil)
            end
            return
        end

        -- Zul'Gurub Bijous
        if string.match(cmd, "bijous") then
            for index,itemId in ipairs(AutoRoll.BIJOUS_IDS) do
                AutoRoll.SaveRule(itemId, nil)
            end
            return
        end

        -- Ahn'Qiraj Scarabs
        if string.match(cmd, "scarabs") then
            for index,itemId in ipairs(AutoRoll.SCARAB_IDS) do
                AutoRoll.SaveRule(itemId, nil)
            end
        end

        -- Ahn'Qiraj Idols
        if string.match(cmd, "idols") then
            for index,itemId in ipairs(AutoRoll.IDOL_IDS) do
                AutoRoll.SaveRule(itemId, nil)
            end
        end

        if string.match(cmd, "all rules") then
            local rules = AutoRoll_PCDB["rules"]

            for itemId,ruleNum in pairs(rules) do
                if itemId then
                    AutoRoll.SaveRule(itemId, nil)
                end
            end

            AutoRoll_PCDB["rules"] = {}
            return
        end
    end

    if cmd == "printing" then
        local willPrint = not AutoRoll_PCDB["printRolls"]

        if willPrint then
            print("AutoRoll - Printing ENABLED")
        else
            print("AutoRoll - Printing DISABLED")
        end

        AutoRoll_PCDB["printRolls"] = willPrint
        return
    end

    if cmd == "debug" then
        local willDebug = not AutoRoll_PCDB["debug"]

        if willDebug then
            print("AutoRoll - Debug ENABLED")
        else
            print("AutoRoll - Debug DISABLED")
        end

        AutoRoll_PCDB["debug"] = willDebug
        return
    end

    if string.match(cmd, "^test%s+") then
        local itemLink = string.match(cmd, "^test%s+(.+)")
        if itemLink then
            -- Test the upgrade logic without a real roll
            local itemId = AutoRollUtils:getItemId(itemLink)
            if itemId then
                local itemName, _, itemRarity, _, _, _, itemSubType, _, itemEquipLoc = GetItemInfo(itemId)
                
                print("AutoRoll Test - Item: "..(itemLink or "Unknown"))
                print("-- Item Type: "..(itemSubType or "Unknown"))
                print("-- Equip Location: "..(itemEquipLoc or "Unknown"))
                
                -- Check if item type is EXEMPT first
                local exemptKey = itemSubType and itemSubType:lower() or ""
                local isExempt = AutoRoll_PCDB["rules"][exemptKey] == AutoRollUtils.ROLL.EXEMPT
                
                print("-- EXEMPT Rule: "..(isExempt and "YES" or "NO"))
                
                if isExempt then
                    print("-- RESULT: EXEMPT - Would show manual roll window")
                    return
                end
                
                -- Check if we have a dynamic rule for this item type
                local dynamicRuleKey = "dynamic_pass_ifnotupgrade_intellect_"..(itemSubType and itemSubType:lower() or "")
                local hasRule = AutoRoll_PCDB["rules"][dynamicRuleKey]
                
                print("-- Dynamic Rule Active: "..(hasRule and "YES" or "NO"))
                
                if hasRule then
                    -- Simulate the upgrade check
                    local function GetItemStatValue(link, statKey)
                        if not link then return 0 end
                        local stats = GetItemStats(link)
                        return (stats and stats[statKey]) or 0
                    end
                    
                    local equipSlotMap = {
                        ["INVTYPE_HEAD"] = { 1 }, ["INVTYPE_NECK"] = { 2 }, ["INVTYPE_SHOULDER"] = { 3 },
                        ["INVTYPE_CLOAK"] = { 15 }, ["INVTYPE_CHEST"] = { 5 }, ["INVTYPE_ROBE"] = { 5 },
                        ["INVTYPE_WRIST"] = { 9 }, ["INVTYPE_HAND"] = { 10 }, ["INVTYPE_WAIST"] = { 6 },
                        ["INVTYPE_LEGS"] = { 7 }, ["INVTYPE_FEET"] = { 8 }, ["INVTYPE_FINGER"] = { 11, 12 },
                        ["INVTYPE_TRINKET"] = { 13, 14 }, ["INVTYPE_WEAPON"] = { 16, 17 },
                        ["INVTYPE_2HWEAPON"] = { 16 }, ["INVTYPE_WEAPONMAINHAND"] = { 16 },
                        ["INVTYPE_WEAPONOFFHAND"] = { 17 }, ["INVTYPE_HOLDABLE"] = { 17 },
                        ["INVTYPE_SHIELD"] = { 17 }, ["INVTYPE_RANGED"] = { 18 }, ["INVTYPE_RANGEDRIGHT"] = { 18 },
                    }
                    
                    local itemInt = GetItemStatValue(itemLink, "ITEM_MOD_INTELLECT_SHORT")
                    local slots = equipSlotMap[itemEquipLoc]
                    
                    print("-- Item Intellect: "..itemInt)
                    
                    if slots then
                        local bestEquipped = 0
                        for _,slotID in ipairs(slots) do
                            local equippedLink = GetInventoryItemLink("player", slotID)
                            local equippedInt = GetItemStatValue(equippedLink, "ITEM_MOD_INTELLECT_SHORT")
                            print("-- Slot "..slotID.." Intellect: "..equippedInt.." "..(equippedLink or "(empty)"))
                            if equippedInt > bestEquipped then
                                bestEquipped = equippedInt
                            end
                        end
                        
                        print("-- Best Equipped Intellect: "..bestEquipped)
                        
                        if itemInt > bestEquipped then
                            print("-- RESULT: UPGRADE - Would show roll window")
                        else
                            print("-- RESULT: NOT UPGRADE - Would auto-PASS")
                        end
                    else
                        print("-- ERROR: Unknown equip location, can't test")
                    end
                else
                    print("-- RESULT: No dynamic rule - normal rule processing")
                end
            else
                print("AutoRoll Test - ERROR: Invalid item link")
            end
        else
            print("AutoRoll Test - Usage: /ar test [item-link]")
            print("-- Shift-click an item to get its link, then paste after 'test'")
        end
        return
    end

    if cmd == "filter rolls" then
        local willFilter = not AutoRoll_PCDB["filterRolls"]

        if willFilter then
            print("AutoRoll - Filtering rolls ENABLED")
        else
            print("AutoRoll - Filtering rolls DISABLED")
        end

        AutoRoll_PCDB["filterRolls"] = willFilter
        return
    end

    if cmd == "config" or cmd == "gui" or cmd == "setup" then
        AutoRollClassSpecGUI:Show()
        return
    end

    if cmd == "rules" then
        print("AutoRoll - Rules")

        local rules = AutoRoll_PCDB["rules"]
        if rules then
            local count = 0

            for itemId,ruleNum in pairs(rules) do
                local _, itemLink = GetItemInfo(itemId)
                local rule = AutoRollUtils:getRuleString(ruleNum)

                if rule then
                    print(rule:upper().." on "..(itemLink or "item:"..itemId))
                end
                count = count + 1
            end

            if count == 0 then
                print("-- You haven't added any rules yet.")
            else
                return
            end
        end

    end

    if cmd == "detect" then
        -- Detect class
        local _, classKey, classID = UnitClass("player")
        print("AutoRoll: Detected class: " .. classKey)

        -- MoP: Use GetPrimaryTalentTree if available
        if GetPrimaryTalentTree then
            local specIndex = GetPrimaryTalentTree()
            local specName = nil
            -- Map specIndex to spec name for the player's class
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
            if specName then
                print("AutoRoll: Detected spec: " .. specName)
            else
                print("AutoRoll: Could not determine spec name (index: "..tostring(specIndex)..")")
            end
            return
        end

        -- Modern API fallback
        if GetSpecialization and GetSpecializationInfo then
            local specIndex = GetSpecialization()
            if specIndex then
                local specID, specName = GetSpecializationInfo(specIndex)
                if specName then
                    print("AutoRoll: Detected spec: " .. specName)
                else
                    print("AutoRoll: Could not determine spec name.")
                end
            else
                print("AutoRoll: No specialization selected.")
            end
            return
        end

        print("AutoRoll: Spec detection is not supported in this version of WoW.")
        return
    end

    -- No rules matched, print help
    print("AutoRoll - Commands")
    print("-- Adding custom rules:")
    print("--       /ar [need,greed,pass] [item-link]")
    print("--       /ar [need,greed,pass] [item-rarity]+[item-type] e.g. /ar need rare+wrands")
    print("-- Adding predefined rules:")
    print("--       /ar [need,greed,pass] [coins,bijous,scarabs,idols]")
    print("-- List current rules:")
    print("--       /ar rules")
    print("-- Removing rules:")
    print("--       /ar [clear,ignore,remove,reset] [item-link]")
    print("--       /ar [clear,ignore,remove,reset] all rules")
    print("-- Only show the winner of rolls in the chat (toggle):")
    print("--       /ar filter rolls")
    print("-- Know when AutoRoll automates rolls (toggle):")
    print("--       /ar printing")
    print("-- Enabling/Disabling the addon")
    print("--       /ar enable")
    print("--       /ar disable")
    print("-- Set items to always show manual roll:")
    print("--       /ar exempt <item-type> [<item-type> ...]")
    print("-- Pass non-upgrade items:")
    print("--       /ar pass ifnotupgrade <item-type> intellect")
    print("-- Clear that rule:")
    print("--       /ar clear ifnotupgrade <item-type> intellect")
    print("-- Test upgrade logic:")
    print("--       /ar test [item-link]")
    print("-- Open Class/Spec configuration GUI:")
    print("--       /ar config (or /ar gui or /ar setup)")

end
