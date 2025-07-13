-- Test data for AutoRoll rule evaluation
-- Each test case contains: name, rules, player, item, equippedItems, expectedResult

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
        equippedItems = {
            [10] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 10 } }
        },
        expectedResult = "manual"
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
        equippedItems = {
            [5] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 15 } }
        },
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
        equippedItems = {
            [18] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 20 } }
        },
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
        equippedItems = {
            [10] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 15 } }
        },
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
        equippedItems = {},
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
        equippedItems = {
            [11] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 12 } },
            [12] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 14 } }
        },
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
        equippedItems = {
            [13] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 15 } },
            [14] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 18 } }
        },
        expectedResult = "NEED"
    }
} 