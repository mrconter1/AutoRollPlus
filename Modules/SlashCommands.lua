-- COMMANDS
SLASH_AR1 = '/ar';
SLASH_AR2 = '/autoroll';

local STAT_KEYS = AutoRollUtils.STAT_KEYS

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
        -- Item Link Rules
        if itemIdString then
            AutoRoll.SaveRule(itemIdString, rule)
            return
        end

        -- Remove alias support for multi-type weapons (maces, swords, axes)
        -- Users must now specify the full subtype, e.g., 'one-handed maces' or 'two-handed maces'

        -- Multi-word item type support: join all words after the rule
        local itemType = string.match(cmd, "^"..rule.."%s+(.+)$")
        if itemType then
            AutoRoll.SaveRule(itemType:lower(), rule)
            print("AutoRoll - "..rule:upper().." on "..itemType)
            return
        end

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
            local itemId = AutoRollUtils:getItemId(itemLink)
            if itemId then
                local itemName, _, itemRarity, _, _, _, itemSubType, _, itemEquipLoc = GetItemInfo(itemId)
                print("AutoRoll Test - Item: "..(itemLink or "Unknown"))
                print("-- Item Type: "..(itemSubType or "Unknown"))
                print("-- Equip Location: "..(itemEquipLoc or "Unknown"))
                -- Use the same logic as EvaluateActiveRolls
                local rules = AutoRoll.GetActiveRules and AutoRoll.GetActiveRules() or {}
                local isArrayProfile = type(rules) == "table" and #rules > 0 and type(rules[1]) == "table"
                local handled = false
                if isArrayProfile then
                    for _, rule in ipairs(rules) do
                        local match = true
                        if rule.item and rule.item:upper() ~= (itemSubType and itemSubType:upper()) then
                            match = false
                        end
                        if match and rule.stat and rule.upgrade then
                            local statKey = STAT_KEYS[rule.stat:lower()]
                            if not statKey or not AutoRollUtils:IsItemStatUpgrade(itemLink, itemEquipLoc, statKey) then
                                match = false
                            end
                        end
                        if match then
                            print(string.format("Would take action: %s (matched rule: %s)", rule.action, (rule.item and (rule.item .. (rule.stat and ", "..rule.stat or "")) or "")))
                            handled = true
                            break
                        end
                    end
                    if not handled and AutoRollDefaults and AutoRollDefaults.defaultAction then
                        print(string.format("No rule matched. Would take default action: %s", AutoRollDefaults.defaultAction:upper()))
                    end
                else
                    -- Legacy logic (table-based rules)
                    local exemptKey = itemSubType and itemSubType:lower() or ""
                    local isExempt = rules[exemptKey] == AutoRollUtils.ROLL.EXEMPT
                    print("-- MANUAL Rule: "..(isExempt and "YES" or "NO"))
                    if isExempt then
                        print("-- RESULT: MANUAL - Would show manual roll window")
                        return
                    end
                    local dynamicRuleKey = "dynamic_pass_ifnotupgrade_intellect_"..(itemSubType and itemSubType:lower() or "")
                    local hasRule = rules[dynamicRuleKey]
                    print("-- Dynamic Rule Active: "..(hasRule and "YES" or "NO"))
                    if hasRule then
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

        -- Use the same logic as AutoRoll.GetActiveRules to get the correct rules table
        local rules = nil
        if AutoRoll.GetActiveRules then
            rules = AutoRoll.GetActiveRules()
        else
            -- fallback for legacy
            local profileKey = AutoRoll.GetCurrentProfileKey and AutoRoll.GetCurrentProfileKey()
            if profileKey and AutoRollPlus_PCDB and AutoRollPlus_PCDB["profiles"] and AutoRollPlus_PCDB["profiles"][profileKey] then
                rules = AutoRollPlus_PCDB["profiles"][profileKey]
            elseif AutoRollPlus_PCDB then
                rules = AutoRollPlus_PCDB["rules"]
            else
                rules = AutoRoll_PCDB["rules"]
            end
        end

        -- Detect new array-of-objects format
        if type(rules) == "table" and #rules > 0 and type(rules[1]) == "table" then
            local count = 0
            for _, rule in ipairs(rules) do
                if rule.item and rule.stat and rule.upgrade and rule.action then
                    print(string.format("%s if %s and item is an %s upgrade", rule.action, rule.item, rule.stat))
                    count = count + 1
                elseif rule.item and rule.action then
                    print(string.format("%s on %s", rule.action, rule.item))
                    count = count + 1
                end
            end
            -- Print default action as fallback
            if AutoRollDefaults and AutoRollDefaults.defaultAction then
                print(string.format("Otherwise, auto-%s", AutoRollDefaults.defaultAction:upper()))
            end
            if count == 0 then
                print("-- You haven't added any rules yet.")
            end
            return
        end

        -- Legacy table rules (numeric and string keys)
        if rules then
            local count = 0
            for itemId,ruleNum in pairs(rules) do
                local rule = AutoRollUtils and AutoRollUtils.getRuleString and AutoRollUtils:getRuleString(ruleNum) or tostring(ruleNum)
                if tonumber(itemId) then
                    local _, itemLink = GetItemInfo(itemId)
                    if rule then
                        print(rule:upper().." on "..(itemLink or "item:"..itemId))
                    end
                else
                    if rule then
                        print(rule:upper().." on "..tostring(itemId))
                    end
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

    if cmd == "apply hunter" then
        local greedTypes = {
            "one-handed swords", "two-handed swords", "one-handed maces", "two-handed maces", "one-handed axes", "two-handed axes", "daggers", "polearms", "staves", "fist weapons", "wands", "thrown", "spears",
            "plate", "cloth", "shields", "librams", "idols", "totems", "sigils", "trade goods", "miscellaneous",
            "rings", "trinkets", "necklaces", "cloaks"
        }
        for _, t in ipairs(greedTypes) do
            AutoRoll.SaveRule(t, "greed")
        end
        print("AutoRoll: Applied GREED rules for all standard hunter non-NEED types.")
        return
    end

    if cmd == "clearall" then
        local profileKey = AutoRoll.GetCurrentProfileKey and AutoRoll.GetCurrentProfileKey()
        if profileKey and AutoRollPlus_PCDB and AutoRollPlus_PCDB["profiles"] and AutoRollPlus_PCDB["profiles"][profileKey] then
            AutoRollPlus_PCDB["profiles"][profileKey] = {}
            print("AutoRoll: Cleared all rules for profile: " .. profileKey)
        elseif AutoRollPlus_PCDB and AutoRollPlus_PCDB["rules"] then
            AutoRollPlus_PCDB["rules"] = {}
            print("AutoRoll: Cleared all global rules.")
        else
            print("AutoRoll: No rules to clear.")
        end
        return
    end

    if cmd == "classspec" then
        -- Print the player's class and spec
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
        local _, localizedClass = UnitClass("player")
        print("AutoRoll: Your class is " .. (localizedClass or classKey or "Unknown"))
        print("AutoRoll: Your spec is " .. (specName or "Unknown"))
        return
    end

    if cmd == "level" then
        local level = UnitLevel("player")
        print("AutoRoll: Your level is " .. tostring(level))
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
