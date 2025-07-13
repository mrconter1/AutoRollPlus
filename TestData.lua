-- Test data for AutoRoll rule evaluation
-- Organized by character profiles with complete rule scripts and multiple scenarios

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

AutoRollTestProfiles = {
    hunter = {
        ruleScript = {
            "IF item.type == 'leather' AND user.level < 50 AND item.agility.isUpgrade() THEN manual",
            "IF item.type == 'mail' AND user.level >= 50 AND item.agility.isUpgrade() THEN manual",
            "IF (item.type == 'bow' OR item.type == 'gun' OR item.type == 'crossbow') AND item.agility.isUpgrade() THEN manual",
            "ELSE greed"
        },
        scenarios = {
            {
                name = "leather upgrade at low level",
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
                name = "mail upgrade at high level",
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
                name = "bow upgrade",
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
            }
        }
    },
    
    priest_holy = {
        ruleScript = {
            "IF item.type == 'cloth' AND item.intellect.isUpgrade() THEN manual",
            "IF item.type == 'staff' AND item.intellect.isUpgrade() THEN manual",
            "IF item.type == 'trinket' AND item.intellect.isUpgrade() THEN manual",
            "ELSE pass"
        },
        scenarios = {
            {
                name = "cloth intellect upgrade",
                player = {
                    level = 50,
                    class = "PRIEST",
                    spec = "Holy"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Cloth",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 18,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 12 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "staff upgrade",
                player = {
                    level = 55,
                    class = "PRIEST",
                    spec = "Holy"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Staff",
                    itemEquipLoc = "INVTYPE_2HWEAPON",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 22,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_2HWEAPON"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 16 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "trinket upgrade",
                player = {
                    level = 60,
                    class = "PRIEST",
                    spec = "Holy"
                },
                item = {
                    itemRarity = "Epic",
                    itemSubType = "Miscellaneous",
                    itemEquipLoc = "INVTYPE_TRINKET",
                    quality = 4,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 20,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_TRINKET"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 15 } }
                }),
                expectedResult = "MANUAL"
            }
        }
    }
}
 