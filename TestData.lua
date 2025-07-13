-- Test data for AutoRoll rule evaluation
-- Each test case contains: name, rules, player, item, equippedItems, expectedResult

-- Helper function to convert INVTYPE constants to slot IDs
local function getSlotID(invType)
    local equipSlotMap = {
        ["INVTYPE_HEAD"]            = 1,
        ["INVTYPE_NECK"]            = 2,
        ["INVTYPE_SHOULDER"]        = 3,
        ["INVTYPE_CLOAK"]           = 15,
        ["INVTYPE_CHEST"]           = 5,
        ["INVTYPE_ROBE"]            = 5,
        ["INVTYPE_WRIST"]           = 9,
        ["INVTYPE_HAND"]            = 10,
        ["INVTYPE_WAIST"]           = 6,
        ["INVTYPE_LEGS"]            = 7,
        ["INVTYPE_FEET"]            = 8,
        ["INVTYPE_FINGER"]          = 11,
        ["INVTYPE_FINGER_2"]        = 12,
        ["INVTYPE_TRINKET"]         = 13,
        ["INVTYPE_TRINKET_2"]       = 14,
        ["INVTYPE_WEAPON"]          = 16,
        ["INVTYPE_2HWEAPON"]        = 16,
        ["INVTYPE_WEAPONMAINHAND"]  = 16,
        ["INVTYPE_WEAPONOFFHAND"]   = 17,
        ["INVTYPE_HOLDABLE"]        = 17,
        ["INVTYPE_SHIELD"]          = 17,
        ["INVTYPE_RANGED"]          = 18,
        ["INVTYPE_RANGEDRIGHT"]     = 18,
    }
    return equipSlotMap[invType]
end

-- Helper function to convert equipped items from INVTYPE format to slot ID format
local function convertEquippedItems(equippedItems)
    local converted = {}
    for invType, itemData in pairs(equippedItems) do
        local slotID = getSlotID(invType)
        if slotID then
            converted[slotID] = itemData
        end
    end
    return converted
end

AutoRollTestData = {
    {
        name = "Hunter leather upgrade at low level",
        rules = {
            "IF leather AND user.level < 50 AND item.agility.isBetter() THEN manual",
            "IF mail AND user.level >= 50 AND item.agility.isBetter() THEN manual",
            "IF (bow OR gun OR crossbow) AND item.agility.isBetter() THEN manual",
            "ELSE greed"
        },
        player = {
            level = 45,
            class = "HUNTER",
            spec = "Beast Mastery"
        },
        item = {
            itemRarity = "Uncommon",
            itemSubType = "Leather",
            itemEquipLoc = "INVTYPE_HAND",
            quality = 2,
            stats = {
                ["ITEM_MOD_AGILITY_SHORT"] = 15,
            }
        },
        equippedItems = convertEquippedItems({
            ["INVTYPE_HAND"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 10 } }
        }),
        expectedResult = "MANUAL"
    },
    
    {
        name = "Hunter mail upgrade at high level",
        rules = {
            "IF leather AND user.level < 50 AND item.agility.isBetter() THEN manual",
            "IF mail AND user.level >= 50 AND item.agility.isBetter() THEN manual",
            "IF (bow OR gun OR crossbow) AND item.agility.isBetter() THEN manual",
            "ELSE greed"
        },
        player = {
            level = 52,
            class = "HUNTER",
            spec = "Beast Mastery"
        },
        item = {
            itemRarity = "Rare",
            itemSubType = "Mail",
            itemEquipLoc = "INVTYPE_CHEST",
            quality = 3,
            stats = {
                ["ITEM_MOD_AGILITY_SHORT"] = 20,
            }
        },
        equippedItems = convertEquippedItems({
            ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 15 } }
        }),
        expectedResult = "MANUAL"
    },
    
    {
        name = "Hunter bow upgrade",
        rules = {
            "IF leather AND user.level < 50 AND item.agility.isBetter() THEN manual",
            "IF mail AND user.level >= 50 AND item.agility.isBetter() THEN manual",
            "IF (bow OR gun OR crossbow) AND item.agility.isBetter() THEN manual",
            "ELSE greed"
        },
        player = {
            level = 60,
            class = "HUNTER",
            spec = "Marksmanship"
        },
        item = {
            itemRarity = "Epic",
            itemSubType = "Bow",
            itemEquipLoc = "INVTYPE_RANGED",
            quality = 4,
            stats = {
                ["ITEM_MOD_AGILITY_SHORT"] = 25,
            }
        },
        equippedItems = convertEquippedItems({
            ["INVTYPE_RANGED"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 20 } }
        }),
        expectedResult = "MANUAL"
    },
    
    {
        name = "Hunter leather at high level - no upgrade",
        rules = {
            "IF leather AND user.level < 50 AND item.agility.isBetter() THEN manual",
            "IF mail AND user.level >= 50 AND item.agility.isBetter() THEN manual",
            "IF (bow OR gun OR crossbow) AND item.agility.isBetter() THEN manual",
            "ELSE greed"
        },
        player = {
            level = 55,
            class = "HUNTER",
            spec = "Beast Mastery"
        },
        item = {
            itemRarity = "Uncommon",
            itemSubType = "Leather",
            itemEquipLoc = "INVTYPE_HAND",
            quality = 2,
            stats = {
                ["ITEM_MOD_AGILITY_SHORT"] = 12,
            }
        },
        equippedItems = convertEquippedItems({
            ["INVTYPE_HAND"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 15 } }
        }),
        expectedResult = "GREED"
    },
    
    {
        name = "Non-hunter class gets greed fallback",
        rules = {
            "IF leather AND user.level < 50 AND item.agility.isBetter() THEN manual",
            "IF mail AND user.level >= 50 AND item.agility.isBetter() THEN manual",
            "IF (bow OR gun OR crossbow) AND item.agility.isBetter() THEN manual",
            "ELSE greed"
        },
        player = {
            level = 60,
            class = "WARRIOR",
            spec = "Arms"
        },
        item = {
            itemRarity = "Rare",
            itemSubType = "Cloth",
            itemEquipLoc = "INVTYPE_CHEST",
            quality = 3,
            stats = {
                ["ITEM_MOD_INTELLECT_SHORT"] = 18,
            }
        },
        equippedItems = convertEquippedItems({}),
        expectedResult = "GREED"
    },
    
    {
        name = "Ring upgrade test",
        rules = {
            "IF ring AND item.agility.isBetter() THEN manual",
            "ELSE pass"
        },
        player = {
            level = 60,
            class = "HUNTER",
            spec = "Beast Mastery"
        },
        item = {
            itemRarity = "Epic",
            itemSubType = "Miscellaneous",
            itemEquipLoc = "INVTYPE_FINGER",
            quality = 4,
            stats = {
                ["ITEM_MOD_AGILITY_SHORT"] = 16,
            }
        },
        equippedItems = convertEquippedItems({
            ["INVTYPE_FINGER"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 12 } },
            ["INVTYPE_FINGER_2"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 14 } }
        }),
        expectedResult = "MANUAL"
    },
    
    {
        name = "Trinket upgrade test",
        rules = {
            "IF trinket AND item.agility.isBetter() THEN need",
            "ELSE pass"
        },
        player = {
            level = 60,
            class = "ROGUE",
            spec = "Combat"
        },
        item = {
            itemRarity = "Epic",
            itemSubType = "Miscellaneous",
            itemEquipLoc = "INVTYPE_TRINKET",
            quality = 4,
            stats = {
                ["ITEM_MOD_AGILITY_SHORT"] = 20,
            }
        },
        equippedItems = convertEquippedItems({
            ["INVTYPE_TRINKET"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 15 } },
            ["INVTYPE_TRINKET_2"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 18 } }
        }),
        expectedResult = "NEED"
    }
} 