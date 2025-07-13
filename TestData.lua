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
        ruleScript = [[
            IF item.type == 'leather' 
               AND user.level < 50 
               AND item.agility.isUpgrade() 
            THEN item.manualRoll()

            IF item.type == 'mail' 
               AND user.level >= 50 
               AND item.agility.isUpgrade() 
            THEN item.manualRoll()

            IF (item.type == 'bow' OR 
                item.type == 'gun' OR 
                item.type == 'crossbow' OR 
                item.type == 'ring' OR 
                item.type == 'trinket' OR 
                item.type == 'necklace' OR 
                item.type == 'cloak') 
               AND item.agility.isUpgrade() 
            THEN item.manualRoll()

            item.rollGreed()
        ]],
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
            },
            {
                name = "non-upgrade item fallback to greed",
                player = {
                    level = 45,
                    class = "HUNTER",
                    spec = "Beast Mastery"
                },
                item = {
                    itemRarity = "Common",
                    itemSubType = "Leather",
                    itemEquipLoc = "INVTYPE_HAND",
                    quality = 1,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 8,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_HAND"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 12 } }
                }),
                expectedResult = "GREED"
            },
            {
                name = "ring upgrade",
                player = {
                    level = 55,
                    class = "HUNTER",
                    spec = "Survival"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Miscellaneous",
                    itemEquipLoc = "INVTYPE_FINGER",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 18,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_FINGER"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 14 } }
                }),
                expectedResult = "MANUAL"
            }
        }
    },
    
    priest_holy = {
        ruleScript = [[
            IF item.type == 'cloth' 
               AND item.intellect.isUpgrade() 
            THEN item.manualRoll()

            IF item.type == 'staff' 
               AND item.intellect.isUpgrade() 
            THEN item.manualRoll()

            IF item.type == 'trinket' 
               AND item.intellect.isUpgrade() 
            THEN item.manualRoll()

            item.rollPass()
        ]],
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
            },
            {
                name = "non-upgrade item fallback to pass",
                player = {
                    level = 50,
                    class = "PRIEST",
                    spec = "Holy"
                },
                item = {
                    itemRarity = "Common",
                    itemSubType = "Cloth",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 1,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 10,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 15 } }
                }),
                expectedResult = "PASS"
            },
            {
                name = "plate armor non-match",
                player = {
                    level = 55,
                    class = "PRIEST",
                    spec = "Holy"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Plate",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 25,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 15 } }
                }),
                expectedResult = "PASS"
            }
        }
    },
    
    dps_warrior = {
        ruleScript = [[
            IF item.type == 'mail' 
               AND user.level < 40 
               AND item.strength.isUpgrade() 
            THEN item.rollNeed()

            IF item.type == 'plate' 
               AND user.level >= 40 
               AND item.strength.isUpgrade() 
            THEN item.rollNeed()

            IF (item.type == 'one-handed sword' OR 
                item.type == 'two-handed sword' OR 
                item.type == 'one-handed axe' OR 
                item.type == 'two-handed axe' OR 
                item.type == 'one-handed mace' OR 
                item.type == 'two-handed mace' OR 
                item.type == 'polearm' OR 
                item.type == 'dagger' OR 
                item.type == 'fist weapon') 
               AND item.strength.isUpgrade() 
            THEN item.rollNeed()

            IF (item.type == 'ring' OR 
                item.type == 'trinket' OR 
                item.type == 'necklace' OR 
                item.type == 'cloak') 
               AND item.strength.isUpgrade() 
            THEN item.rollNeed()

            item.rollGreed()
        ]],
        scenarios = {
            {
                name = "mail upgrade at low level",
                player = {
                    level = 35,
                    class = "WARRIOR",
                    spec = "Arms"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Mail",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 16,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_STRENGTH_SHORT"] = 12 } }
                }),
                expectedResult = "NEED"
            },
            {
                name = "plate upgrade at high level",
                player = {
                    level = 45,
                    class = "WARRIOR",
                    spec = "Arms"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Plate",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 20,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_STRENGTH_SHORT"] = 16 } }
                }),
                expectedResult = "NEED"
            },
            {
                name = "two-handed sword upgrade",
                player = {
                    level = 50,
                    class = "WARRIOR",
                    spec = "Arms"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Two-Handed Sword",
                    itemEquipLoc = "INVTYPE_2HWEAPON",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 22,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_2HWEAPON"] = { stats = { ["ITEM_MOD_STRENGTH_SHORT"] = 18 } }
                }),
                expectedResult = "NEED"
            },
            {
                name = "ring upgrade",
                player = {
                    level = 55,
                    class = "WARRIOR",
                    spec = "Fury"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Miscellaneous",
                    itemEquipLoc = "INVTYPE_FINGER",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 14,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_FINGER"] = { stats = { ["ITEM_MOD_STRENGTH_SHORT"] = 10 } }
                }),
                expectedResult = "NEED"
            },
            {
                name = "non-upgrade fallback to greed",
                player = {
                    level = 45,
                    class = "WARRIOR",
                    spec = "Arms"
                },
                item = {
                    itemRarity = "Common",
                    itemSubType = "Plate",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 1,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 12,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_STRENGTH_SHORT"] = 18 } }
                }),
                expectedResult = "GREED"
            }
        }
    },
    
    tank_warrior = {
        ruleScript = [[
            IF item.type == 'mail' 
               AND user.level < 40 
               AND item.strength.isUpgrade() 
            THEN item.rollNeed()

            IF item.type == 'plate' 
               AND user.level >= 40 
               AND item.strength.isUpgrade() 
            THEN item.rollNeed()

            IF (item.type == 'one-handed sword' OR 
                item.type == 'two-handed sword' OR 
                item.type == 'one-handed axe' OR 
                item.type == 'two-handed axe' OR 
                item.type == 'one-handed mace' OR 
                item.type == 'two-handed mace' OR 
                item.type == 'polearm' OR 
                item.type == 'dagger' OR 
                item.type == 'fist weapon') 
               AND item.strength.isUpgrade() 
            THEN item.rollNeed()

            IF item.type == 'shield' 
               AND item.strength.isUpgrade() 
            THEN item.rollNeed()

            IF (item.type == 'ring' OR 
                item.type == 'trinket' OR 
                item.type == 'necklace' OR 
                item.type == 'cloak') 
               AND item.strength.isUpgrade() 
            THEN item.rollNeed()

            item.rollGreed()
        ]],
        scenarios = {
            {
                name = "mail upgrade at low level",
                player = {
                    level = 35,
                    class = "WARRIOR",
                    spec = "Protection"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Mail",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 16,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_STRENGTH_SHORT"] = 12 } }
                }),
                expectedResult = "NEED"
            },
            {
                name = "plate upgrade at high level",
                player = {
                    level = 45,
                    class = "WARRIOR",
                    spec = "Protection"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Plate",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 20,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_STRENGTH_SHORT"] = 16 } }
                }),
                expectedResult = "NEED"
            },
            {
                name = "shield upgrade",
                player = {
                    level = 50,
                    class = "WARRIOR",
                    spec = "Protection"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Shield",
                    itemEquipLoc = "INVTYPE_SHIELD",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 18,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_SHIELD"] = { stats = { ["ITEM_MOD_STRENGTH_SHORT"] = 14 } }
                }),
                expectedResult = "NEED"
            },
            {
                name = "one-handed mace upgrade",
                player = {
                    level = 55,
                    class = "WARRIOR",
                    spec = "Protection"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "One-Handed Mace",
                    itemEquipLoc = "INVTYPE_WEAPON",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 20,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_WEAPON"] = { stats = { ["ITEM_MOD_STRENGTH_SHORT"] = 16 } }
                }),
                expectedResult = "NEED"
            },
            {
                name = "non-upgrade fallback to greed",
                player = {
                    level = 45,
                    class = "WARRIOR",
                    spec = "Protection"
                },
                item = {
                    itemRarity = "Common",
                    itemSubType = "Shield",
                    itemEquipLoc = "INVTYPE_SHIELD",
                    quality = 1,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 10,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_SHIELD"] = { stats = { ["ITEM_MOD_STRENGTH_SHORT"] = 16 } }
                }),
                expectedResult = "GREED"
            }
        }
    }
}
 