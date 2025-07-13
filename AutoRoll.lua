-- NAMESPACE / CLASS: AutoRoll
-- OPTIONS: AutoRollPlus_PCDB

AutoRoll = CreateFrame("Frame")

AutoRoll.COIN_IDS = {
    19698, -- Zulian Coin
    19699, -- Razzashi Coin
    19700, -- Hakkari Coin
    19701, -- Gurubashi Coin
    19702, -- Vilebranch Coin
    19703, -- Witherbark Coin
    19704, -- Sandfury Coin
    19705, -- Skullsplitter Coin
    19706, -- Bloodscalp Coin
}

AutoRoll.BIJOUS_IDS = {
    19707, -- Red Hakkari Bijou
    19708, -- Blue Hakkari Bijou
    19709, -- Yellow Hakkari Bijou
    19710, -- Orange Hakkari Bijou
    19711, -- Green Hakkari Bijou
    19712, -- Purple Hakkari Bijou
    19713, -- Bronze Hakkari Bijou
    19714, -- Silver Hakkari Bijou
    19715, -- Gold Hakkari Bijou
}

AutoRoll.SCARAB_IDS = {
  20858,
  20859,
  20860,
  20861,
  20862,
  20863,
  20864,
  20865,
}

AutoRoll.IDOL_IDS = {
  20866,
  20867,
  20868,
  20869,
  20870,
  20871,
  20872,
  20873,
  20874,
  20875,
  20876,
  20877,
  20878,
  20879,
  20881,
  20882,
}

AutoRoll.ItemSubTypes = {
    -- ARMOR
    "Cloth",
    "Leather",
    "Mail",
    "Plate",
    "Shields",
    "Librams",
    "Idols",
    "Totems",
    "Sigils",

    -- WEAPONS
    "One-Handed Axes",
    "Two-Handed Axes",
    "Bows",
    "Guns",
    "One-Handed Maces",
    "Two-Handed Maces",
    "Polearms",
    "One-Handed Swords",
    "Two-Handed Swords",
    "Staves",
    "Fist Weapons",
    "Daggers",
    "Thrown",
    "Spears",
    "Crossbows",
    "Wands",
    "Fishing Poles",

    -- TRADE GOODS
    "Trade Goods"
}

AutoRoll.ItemRarities = {
    "Poor",
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary"
}

AutoRoll.FilterStrings = {
    "Bijou",
    "Coin",
}

AutoRoll.FilterEndStrings = {
    "Scarab$",
    "Idol$",
}

-- Make defaults globally accessible for GUI suggested rules
AutoRollDefaults = {
    -- defaultAction = "GREED", -- Removed default auto-greed fallback
    ["rules"] = {},
    ["profiles"] = {
        priest_discipline = {
            { item = "CLOTH",    stat = "INTELLECT", upgrade = true, action = "MANUAL" },
            { item = "STAVES",   stat = "INTELLECT", upgrade = true, action = "MANUAL" },
            { item = "RING",     stat = "INTELLECT", upgrade = true, action = "MANUAL" },
            { item = "TRINKET",  stat = "INTELLECT", upgrade = true, action = "MANUAL" },
            { item = "NECKLACE", stat = "INTELLECT", upgrade = true, action = "MANUAL" },
            { item = "CLOAK",    stat = "INTELLECT", upgrade = true, action = "MANUAL" }
        },
    },
    ["printRolls"] = false,
    ["enabled"] = true,
    ["filterRolls"] = true,
    ["debug"] = false,
}

do -- Private Scope

    local ADDON_NAME = "AutoRollPlus"

    local defaults = AutoRollDefaults

    --==============================
    -- Dynamic Upgrade Rule Helpers
    --==============================

    -- Map simple stat names to GetItemStats keys
    local STAT_KEYS = {
        intellect = "ITEM_MOD_INTELLECT_SHORT",
    }

    -- Map equip locations to inventory slot IDs
    local equipSlotMap = {
        ["INVTYPE_HEAD"]            = { 1 },
        ["INVTYPE_NECK"]            = { 2 },
        ["INVTYPE_SHOULDER"]        = { 3 },
        ["INVTYPE_CLOAK"]           = { 15 },
        ["INVTYPE_CHEST"]           = { 5 },
        ["INVTYPE_ROBE"]            = { 5 },
        ["INVTYPE_WRIST"]           = { 9 },
        ["INVTYPE_HAND"]            = { 10 },
        ["INVTYPE_WAIST"]           = { 6 },
        ["INVTYPE_LEGS"]            = { 7 },
        ["INVTYPE_FEET"]            = { 8 },
        ["INVTYPE_FINGER"]          = { 11, 12 },
        ["INVTYPE_TRINKET"]         = { 13, 14 },
        ["INVTYPE_WEAPON"]          = { 16, 17 },
        ["INVTYPE_2HWEAPON"]        = { 16 },
        ["INVTYPE_WEAPONMAINHAND"]  = { 16 },
        ["INVTYPE_WEAPONOFFHAND"]   = { 17 },
        ["INVTYPE_HOLDABLE"]        = { 17 },
        ["INVTYPE_SHIELD"]          = { 17 },
        ["INVTYPE_RANGED"]          = { 18 },
        ["INVTYPE_RANGEDRIGHT"]     = { 18 },
    }

    -- Return the value of a given stat on an item link
    local function GetItemStatValue(itemLink, statKey)
        if not itemLink then return 0 end
        local stats = GetItemStats(itemLink)
        if stats and stats[statKey] then
            return stats[statKey]
        end
        return 0
    end

    -- Determine if "itemLink" provides strictly more of "statKey" than currently equipped items
    local function IsItemStatUpgrade(itemLink, equipLoc, statKey)
        local itemStat = GetItemStatValue(itemLink, statKey)
        local slots = equipSlotMap[equipLoc]
        if not slots then return false end

        local bestEquipped = 0
        for _,slotID in ipairs(slots) do
            local equippedLink = GetInventoryItemLink("player", slotID)
            local equippedStat = GetItemStatValue(equippedLink, statKey)
            if equippedStat > bestEquipped then
                bestEquipped = equippedStat
            end
        end

        return itemStat > bestEquipped
    end

    -- REGISTER EVENTS
    AutoRoll:RegisterEvent("ADDON_LOADED")
    AutoRoll:RegisterEvent("START_LOOT_ROLL")
    AutoRoll:RegisterEvent("CONFIRM_LOOT_ROLL")
    AutoRoll:RegisterEvent("PLAYER_ENTERING_WORLD")

    AutoRoll:SetScript("OnEvent", function(self, event, arg1, ...)
        AutoRoll:onEvent(self, event, arg1, ...)
    end)

    -- REGISTER ROLL FILTER
    function rollFiler(_, _, message)
        if AutoRoll_PCDB["filterRolls"] and not string.match(message, "won:") then
            for _, str in pairs(AutoRoll.FilterStrings) do
                if string.match(message, str) then return true end
            end
            for _, str in pairs(AutoRoll.FilterEndStrings) do
                if string.match(message, str) then return true end
            end
        end
        return false
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", rollFiler)

    -- INITIALIZATION
    function Init()
        LoadOptions()
        -- (Auto-seed logic removed from here)
    end

    function LoadOptions()
        AutoRoll_PCDB = AutoRoll_PCDB or AutoRollUtils:deepcopy(defaults)
        for key,value in pairs(defaults) do
            if (AutoRoll_PCDB[key] == nil) then
                AutoRoll_PCDB[key] = value
            end
        end
        -- Convert legacy table rules to array format for all profiles and global rules
        if AutoRollPlus_PCDB and AutoRollPlus_PCDB["profiles"] then
            for profileKey, rules in pairs(AutoRollPlus_PCDB["profiles"]) do
                if type(rules) ~= "table" or type(rules[1]) ~= "table" then
                    local newRules = {}
                    if type(rules) == "table" then
                        for k, v in pairs(rules) do
                            if type(k) == "string" and type(v) == "number" then
                                local action = AutoRollUtils and AutoRollUtils.getRuleString and AutoRollUtils:getRuleString(v)
                                if action then
                                    table.insert(newRules, { item = k:upper(), action = action:upper() })
                                end
                            end
                        end
                    end
                    AutoRollPlus_PCDB["profiles"][profileKey] = newRules
                end
            end
        end
        if AutoRollPlus_PCDB and AutoRollPlus_PCDB["rules"] then
            local rules = AutoRollPlus_PCDB["rules"]
            if type(rules) ~= "table" or type(rules[1]) ~= "table" then
                local newRules = {}
                if type(rules) == "table" then
                    for k, v in pairs(rules) do
                        if type(k) == "string" and type(v) == "number" then
                            local action = AutoRollUtils and AutoRollUtils.getRuleString and AutoRollUtils:getRuleString(v)
                            if action then
                                table.insert(newRules, { item = k:upper(), action = action:upper() })
                            end
                        end
                    end
                end
                AutoRollPlus_PCDB["rules"] = newRules
            end
        end
    end

    function AutoRoll:onEvent(self, event, ...)
        if event == "ADDON_LOADED" then
            if select(1, ...) == ADDON_NAME then
                if not AutoRollPlus_PCDB then
                    AutoRollPlus_PCDB = {}
                end
                LoadOptions()
                -- Automatically apply hunter rules on each load
                local _, classKey = UnitClass("player")
                if classKey == "HUNTER" then
                    local profileKey = AutoRoll.GetCurrentProfileKey and AutoRoll.GetCurrentProfileKey()
                    if profileKey then
                        -- Always ensure hunter has the correct rules
                        local hunterRules = {
                            -- MANUAL rules
                            { item = "LEATHER", action = "MANUAL" },
                            { item = "GUNS", action = "MANUAL" },
                            { item = "BOWS", action = "MANUAL" },
                            -- GREED rules
                            { item = "ONE-HANDED SWORDS", action = "GREED" },
                            { item = "TWO-HANDED SWORDS", action = "GREED" },
                            { item = "ONE-HANDED MACES", action = "GREED" },
                            { item = "TWO-HANDED MACES", action = "GREED" },
                            { item = "ONE-HANDED AXES", action = "GREED" },
                            { item = "TWO-HANDED AXES", action = "GREED" },
                            { item = "DAGGERS", action = "GREED" },
                            { item = "POLEARMS", action = "GREED" },
                            { item = "STAVES", action = "GREED" },
                            { item = "FIST WEAPONS", action = "GREED" },
                            { item = "WANDS", action = "GREED" },
                            { item = "THROWN", action = "GREED" },
                            { item = "SPEARS", action = "GREED" },
                            { item = "CROSSBOWS", action = "GREED" },
                            { item = "PLATE", action = "GREED" },
                            { item = "MAIL", action = "GREED" },
                            { item = "CLOTH", action = "GREED" },
                            { item = "SHIELDS", action = "GREED" },
                            { item = "LIBRAMS", action = "GREED" },
                            { item = "IDOLS", action = "GREED" },
                            { item = "TOTEMS", action = "GREED" },
                            { item = "SIGILS", action = "GREED" },
                            { item = "TRADE GOODS", action = "GREED" },
                            { item = "MISCELLANEOUS", action = "GREED" },
                            { item = "RINGS", action = "GREED" },
                            { item = "TRINKETS", action = "GREED" },
                            { item = "NECKLACES", action = "GREED" },
                            { item = "CLOAKS", action = "GREED" },
                        }
                        
                        AutoRollPlus_PCDB["profiles"] = AutoRollPlus_PCDB["profiles"] or {}
                        AutoRollPlus_PCDB["profiles"][profileKey] = hunterRules
                        print("AutoRoll: Hunter rules applied.")
                    end
                end
                PrintHelp()
            end
            return
        end
        -- For all other events, do nothing if AutoRollPlus_PCDB is not initialized
        if not AutoRollPlus_PCDB then return end

        if AutoRoll_PCDB["enabled"] then
            if event == "START_LOOT_ROLL" then
                EvaluateActiveRolls()
            end

            if event == "PLAYER_ENTERING_WORLD" then
                EvaluateActiveRolls()
            end

            if event == "CONFIRM_LOOT_ROLL" then
                local rollId = select(1, ...)
                local roll = select(2, ...)

                ConfirmLootRoll(rollId, roll)
            end
        end
    end

    function PrintHelp()
        local colorHex = "2979ff"
        print("|cff"..colorHex.."AutoRoll loaded")
        print("-- Use the following commands: ")
        print("--       /ar NEED [item-link]")
        print("--       /ar GREED [item-link]")
        print("--       /ar PASS [item-link]")
        print("--       /ar IGNORE [item-link]")
    end

    function SaveRule(key, rule)
        -- Always use array-of-objects format for rules
        local profileKey = AutoRoll.GetCurrentProfileKey and AutoRoll.GetCurrentProfileKey()
        local rules
        if profileKey then
            AutoRollPlus_PCDB["profiles"] = AutoRollPlus_PCDB["profiles"] or {}
            AutoRollPlus_PCDB["profiles"][profileKey] = AutoRollPlus_PCDB["profiles"][profileKey] or {}
            rules = AutoRollPlus_PCDB["profiles"][profileKey]
        else
            AutoRollPlus_PCDB["rules"] = AutoRollPlus_PCDB["rules"] or {}
            rules = AutoRollPlus_PCDB["rules"]
        end
        if type(rules) ~= "table" or type(rules[1]) ~= "table" then
            rules = {}
            if profileKey then
                AutoRollPlus_PCDB["profiles"][profileKey] = rules
            else
                AutoRollPlus_PCDB["rules"] = rules
            end
        end
        -- Remove rule if rule == nil
        if rule == nil then
            for i = #rules, 1, -1 do
                if rules[i].item and rules[i].item:lower() == key:lower() then
                    table.remove(rules, i)
                end
            end
            print("Removed rule for "..key)
        else
            -- Add or update rule
            local found = false
            local actionString = rule:upper()
            for i, r in ipairs(rules) do
                if r.item and r.item:lower() == key:lower() then
                    r.action = actionString
                    found = true
                    print("Updated "..rule:upper().." on "..key)
                    break
                end
            end
            if not found then
                table.insert(rules, { item = key:upper(), action = actionString })
                print("Remembered "..rule:upper().." on "..key)
            end
        end
        if profileKey then
            AutoRollPlus_PCDB["profiles"][profileKey] = rules
        else
            AutoRollPlus_PCDB["rules"] = rules
        end
    end

    function EvaluateActiveRolls()
        -- Only use array-of-objects format for rules
        local rules = AutoRoll.GetActiveRules and AutoRoll.GetActiveRules() or {}
        if type(rules) ~= "table" or type(rules[1]) ~= "table" then return end
        for index,RollID in ipairs(GetActiveLootRollIDs()) do
            local itemId = AutoRollUtils:rollID2itemID(RollID)
            local _, _, _, quality, bindOnPickUp, canNeed, canGreed, _ = GetLootRollItemInfo(RollID)
            local itemName, itemLink, itemRarity, _, _, _, itemSubType, _, itemEquipLoc = GetItemInfo(itemId)
            local handled = false
            local playerLevel = UnitLevel("player")
            for _, rule in ipairs(rules) do
                local match = true
                if rule.item and rule.item:upper() ~= (itemSubType and itemSubType:upper()) then
                    match = false
                end
                if match and rule.stat and rule.upgrade then
                    local statKey = STAT_KEYS[rule.stat:lower()]
                    if not statKey or not IsItemStatUpgrade(itemLink, itemEquipLoc, statKey) then
                        match = false
                    end
                end
                if match and rule.levelMin and playerLevel < rule.levelMin then
                    match = false
                end
                if match and rule.levelMax and playerLevel > rule.levelMax then
                    match = false
                end
                if match then
                    if rule.action == "MANUAL" then
                        if AutoRoll_PCDB["printRolls"] then
                            print("AutoRoll: MANUAL required for "..(itemLink or "item:"..itemId))
                        end
                        handled = true
                        break
                    elseif rule.action == "NEED" and canNeed then
                        if AutoRoll_PCDB["printRolls"] then
                            print("AutoRoll: NEED on "..(itemLink or "item:"..itemId))
                        end
                        RollOnLoot(RollID, AutoRollUtils.ROLL.NEED)
                        handled = true
                        break
                    elseif rule.action == "GREED" and canGreed then
                        if AutoRoll_PCDB["printRolls"] then
                            print("AutoRoll: GREED on "..(itemLink or "item:"..itemId))
                        end
                        RollOnLoot(RollID, AutoRollUtils.ROLL.GREED)
                        handled = true
                        break
                    elseif rule.action == "PASS" then
                        if AutoRoll_PCDB["printRolls"] then
                            print("AutoRoll: PASS on "..(itemLink or "item:"..itemId))
                        end
                        RollOnLoot(RollID, AutoRollUtils.ROLL.PASS)
                        handled = true
                        break
                    end
                end
            end
        end
    end

    function CheckItemType(cmd, rule)
        return SaveIfFound(cmd, rule, "cloth")
        or SaveIfFound(cmd, rule, "leather")
        or SaveIfFound(cmd, rule, "mail")
        or SaveIfFound(cmd, rule, "plate")
        or SaveIfFound(cmd, rule, "shields")
        or SaveIfFound(cmd, rule, "trade goods")
        or SaveIfFound(cmd, rule, "miscellaneous")
    end

    function CheckItemRarity(cmd, rule)
        return SaveIfFound(cmd, rule, "poor")
        or SaveIfFound(cmd, rule, "uncommon")
        or SaveIfFound(cmd, rule, "common")
        or SaveIfFound(cmd, rule, "rare")
        or SaveIfFound(cmd, rule, "epic")
        or SaveIfFound(cmd, rule, "legendary")
    end

    function SaveIfFound(cmd, rule, keyword)
        if string.match(cmd, keyword) then
            AutoRoll.SaveRule(keyword, rule)
            return true
        end
        return false
    end

    function CheckRuleCombinations(cmd, rule)
        for _,itemRarity in ipairs(AutoRoll.ItemRarities) do
            for _,itemType in ipairs(AutoRoll.ItemSubTypes) do
                if CheckRuleCombination(cmd, rule, itemRarity, itemType) then
                    return true
                end
            end
        end
        return false
    end

    function CheckRuleCombination(cmd, rule, itemRarity, itemType)
        local keyword = itemRarity:lower().."%+"..itemType:lower()
        return SaveIfFound(cmd, rule, keyword)
    end

    -- Expose Functions
    AutoRoll.SaveRule = SaveRule
    AutoRoll.CheckItemType = CheckItemType
    AutoRoll.CheckItemRarity = CheckItemRarity
    AutoRoll.CheckRuleCombinations = CheckRuleCombinations

    -- Helper to get the current profile key
    function AutoRoll.GetCurrentProfileKey()
        local _, classKey = UnitClass("player")
        local specName = nil
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
        if classKey and specName then
            return string.lower(classKey .. "_" .. specName):gsub("%s+", "")
        end
        return nil
    end

    -- Helper to get rules for current profile (or global fallback)
    function AutoRoll.GetActiveRules()
        if not AutoRollPlus_PCDB then return {} end
        local key = AutoRoll.GetCurrentProfileKey()
        if key and AutoRollPlus_PCDB["profiles"] and AutoRollPlus_PCDB["profiles"][key] then
            return AutoRollPlus_PCDB["profiles"][key]
        end
        return AutoRollPlus_PCDB["rules"]
    end

end

return AutoRoll
