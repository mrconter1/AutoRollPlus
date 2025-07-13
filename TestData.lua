-- Test data for AutoRoll rule evaluation
-- Organized by character profiles with complete rule scripts and multiple scenarios

-- Helper function to convert INVTYPE constants to slot IDs
local function getSlotID(invType)
    return AutoRollMappings:getSlotID(invType)
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
    hunter_beastmastery = {
        ruleScript = AutoRollProfiles.hunter_beastmastery,
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
                    level = 55,
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
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 16 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "bow upgrade",
                player = {
                    level = 50,
                    class = "HUNTER",
                    spec = "Marksmanship"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Bow",
                    itemEquipLoc = "INVTYPE_RANGED",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 22,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_RANGED"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 18 } }
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
        ruleScript = AutoRollProfiles.priest_holy,
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
                name = "trinket intellect upgrade",
                player = {
                    level = 60,
                    class = "PRIEST",
                    spec = "Holy"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Miscellaneous",
                    itemEquipLoc = "INVTYPE_TRINKET",
                    quality = 3,
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
                name = "wrong stat item fallback to greed",
                player = {
                    level = 45,
                    class = "PRIEST",
                    spec = "Holy"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Cloth",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 20,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 15 } }
                }),
                expectedResult = "GREED"
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
                expectedResult = "GREED"
            }
        }
    },
    
    warrior_arms = {
        ruleScript = AutoRollProfiles.warrior_arms,
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
                expectedResult = "MANUAL"
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
                expectedResult = "MANUAL"
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
                expectedResult = "MANUAL"
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
                expectedResult = "MANUAL"
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
    
    warrior_protection = {
        ruleScript = AutoRollProfiles.warrior_protection,
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
                expectedResult = "MANUAL"
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
                expectedResult = "MANUAL"
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
                expectedResult = "MANUAL"
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
                expectedResult = "MANUAL"
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
    },

    rogue_assassination = {
        ruleScript = AutoRollProfiles.rogue_assassination,
        scenarios = {
            {
                name = "leather agility upgrade",
                player = {
                    level = 35,
                    class = "ROGUE",
                    spec = "Assassination"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Leather",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 18,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 14 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "dagger agility upgrade",
                player = {
                    level = 40,
                    class = "ROGUE",
                    spec = "Assassination"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Dagger",
                    itemEquipLoc = "INVTYPE_WEAPON",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 22,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_WEAPON"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 18 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "thrown weapon agility upgrade",
                player = {
                    level = 45,
                    class = "ROGUE",
                    spec = "Combat"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Thrown",
                    itemEquipLoc = "INVTYPE_RANGED",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 16,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_RANGED"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 12 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "mail armor - wrong type results in greed",
                player = {
                    level = 30,
                    class = "ROGUE",
                    spec = "Assassination"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Mail",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 20,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 15 } }
                }),
                expectedResult = "GREED"
            },
            {
                name = "bow weapon - wrong type results in greed",
                player = {
                    level = 50,
                    class = "ROGUE",
                    spec = "Subtlety"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Bow",
                    itemEquipLoc = "INVTYPE_RANGED",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 25,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_RANGED"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 18 } }
                }),
                expectedResult = "GREED"
            }
        }
    },

    druid_feral = {
        ruleScript = AutoRollProfiles.druid_feral,
        scenarios = {
            {
                name = "leather agility upgrade",
                player = {
                    level = 35,
                    class = "DRUID",
                    spec = "Feral"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Leather",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 18,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 12 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "feral weapon upgrade",
                player = {
                    level = 40,
                    class = "DRUID",
                    spec = "Feral"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Staff",
                    itemEquipLoc = "INVTYPE_2HWEAPON",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 25,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_2HWEAPON"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 15 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "ring upgrade (works for both cat and bear)",
                player = {
                    level = 45,
                    class = "DRUID",
                    spec = "Feral"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Miscellaneous",
                    itemEquipLoc = "INVTYPE_FINGER",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 14,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_FINGER"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 10 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "mail armor - wrong type results in greed",
                player = {
                    level = 25,
                    class = "DRUID",
                    spec = "Feral"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Mail",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 20,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 12 } }
                }),
                expectedResult = "GREED"
            },
            {
                name = "non-upgrade leather - results in greed",
                player = {
                    level = 40,
                    class = "DRUID",
                    spec = "Feral"
                },
                item = {
                    itemRarity = "Common",
                    itemSubType = "Leather",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 1,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 10,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 18 } }
                }),
                expectedResult = "GREED"
            }
        }
    },

    druid_balance = {
        ruleScript = AutoRollProfiles.druid_balance,
        scenarios = {
            {
                name = "leather intellect upgrade",
                player = {
                    level = 35,
                    class = "DRUID",
                    spec = "Balance"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Leather",
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
                name = "balance weapon upgrade",
                player = {
                    level = 40,
                    class = "DRUID",
                    spec = "Balance"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Staff",
                    itemEquipLoc = "INVTYPE_2HWEAPON",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 25,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_2HWEAPON"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 15 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "trinket intellect upgrade",
                player = {
                    level = 45,
                    class = "DRUID",
                    spec = "Balance"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Miscellaneous",
                    itemEquipLoc = "INVTYPE_TRINKET",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 16,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_TRINKET"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 12 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "plate armor - wrong type results in greed",
                player = {
                    level = 50,
                    class = "DRUID",
                    spec = "Balance"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Plate",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 30,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 20 } }
                }),
                expectedResult = "GREED"
            },
            {
                name = "agility leather - wrong stat results in greed",
                player = {
                    level = 35,
                    class = "DRUID",
                    spec = "Balance"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Leather",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 20,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 15 } }
                }),
                expectedResult = "GREED"
            }
        }
    },

    druid_restoration = {
        ruleScript = AutoRollProfiles.druid_restoration,
        scenarios = {
            {
                name = "leather intellect upgrade for healer",
                player = {
                    level = 35,
                    class = "DRUID",
                    spec = "Restoration"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Leather",
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
                name = "restoration staff upgrade",
                player = {
                    level = 40,
                    class = "DRUID",
                    spec = "Restoration"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Staff",
                    itemEquipLoc = "INVTYPE_2HWEAPON",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 28,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_2HWEAPON"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 22 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "healing trinket upgrade",
                player = {
                    level = 50,
                    class = "DRUID",
                    spec = "Restoration"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Miscellaneous",
                    itemEquipLoc = "INVTYPE_TRINKET",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 20,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_TRINKET"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 16 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "mail armor - wrong type results in greed",
                player = {
                    level = 30,
                    class = "DRUID",
                    spec = "Restoration"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Mail",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 25,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 15 } }
                }),
                expectedResult = "GREED"
            },
            {
                name = "strength leather - wrong stat results in greed",
                player = {
                    level = 45,
                    class = "DRUID",
                    spec = "Restoration"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Leather",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_STRENGTH_SHORT"] = 22,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 18 } }
                }),
                expectedResult = "GREED"
            }
        }
    },

    monk_brewmaster = {
        ruleScript = AutoRollProfiles.monk_brewmaster,
        scenarios = {
            {
                name = "leather agility upgrade for tank",
                player = {
                    level = 35,
                    class = "MONK",
                    spec = "Brewmaster"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Leather",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
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
                name = "fist weapon agility upgrade",
                player = {
                    level = 40,
                    class = "MONK",
                    spec = "Brewmaster"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Fist Weapon",
                    itemEquipLoc = "INVTYPE_WEAPON",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 25,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_WEAPON"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 18 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "trinket agility upgrade",
                player = {
                    level = 45,
                    class = "MONK",
                    spec = "Brewmaster"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Miscellaneous",
                    itemEquipLoc = "INVTYPE_TRINKET",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 16,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_TRINKET"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 12 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "mail armor - wrong type results in greed",
                player = {
                    level = 30,
                    class = "MONK",
                    spec = "Brewmaster"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Mail",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 22,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 16 } }
                }),
                expectedResult = "GREED"
            },
            {
                name = "intellect leather - wrong stat results in greed",
                player = {
                    level = 50,
                    class = "MONK",
                    spec = "Brewmaster"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Leather",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 24,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 18 } }
                }),
                expectedResult = "GREED"
            }
        }
    },

    monk_windwalker = {
        ruleScript = AutoRollProfiles.monk_windwalker,
        scenarios = {
            {
                name = "leather agility upgrade for dps",
                player = {
                    level = 35,
                    class = "MONK",
                    spec = "Windwalker"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Leather",
                    itemEquipLoc = "INVTYPE_LEGS",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 18,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_LEGS"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 14 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "staff agility upgrade",
                player = {
                    level = 40,
                    class = "MONK",
                    spec = "Windwalker"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Staff",
                    itemEquipLoc = "INVTYPE_2HWEAPON",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 28,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_2HWEAPON"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 22 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "one-handed sword agility upgrade",
                player = {
                    level = 50,
                    class = "MONK",
                    spec = "Windwalker"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "One-Handed Sword",
                    itemEquipLoc = "INVTYPE_WEAPON",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 22,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_WEAPON"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 18 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "plate armor - wrong type results in greed",
                player = {
                    level = 45,
                    class = "MONK",
                    spec = "Windwalker"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Plate",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 30,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 20 } }
                }),
                expectedResult = "GREED"
            },
            {
                name = "non-upgrade fist weapon - results in greed",
                player = {
                    level = 55,
                    class = "MONK",
                    spec = "Windwalker"
                },
                item = {
                    itemRarity = "Common",
                    itemSubType = "Fist Weapon",
                    itemEquipLoc = "INVTYPE_WEAPON",
                    quality = 1,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 15,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_WEAPON"] = { stats = { ["ITEM_MOD_AGILITY_SHORT"] = 25 } }
                }),
                expectedResult = "GREED"
            }
        }
    },

    monk_mistweaver = {
        ruleScript = AutoRollProfiles.monk_mistweaver,
        scenarios = {
            {
                name = "leather intellect upgrade for healer",
                player = {
                    level = 35,
                    class = "MONK",
                    spec = "Mistweaver"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Leather",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 20,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 15 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "staff intellect upgrade",
                player = {
                    level = 40,
                    class = "MONK",
                    spec = "Mistweaver"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Staff",
                    itemEquipLoc = "INVTYPE_2HWEAPON",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 30,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_2HWEAPON"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 24 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "healing trinket upgrade",
                player = {
                    level = 50,
                    class = "MONK",
                    spec = "Mistweaver"
                },
                item = {
                    itemRarity = "Rare",
                    itemSubType = "Miscellaneous",
                    itemEquipLoc = "INVTYPE_TRINKET",
                    quality = 3,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 22,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_TRINKET"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 18 } }
                }),
                expectedResult = "MANUAL"
            },
            {
                name = "mail armor - wrong type results in greed",
                player = {
                    level = 30,
                    class = "MONK",
                    spec = "Mistweaver"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Mail",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_INTELLECT_SHORT"] = 25,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 15 } }
                }),
                expectedResult = "GREED"
            },
            {
                name = "agility leather - wrong stat results in greed",
                player = {
                    level = 45,
                    class = "MONK",
                    spec = "Mistweaver"
                },
                item = {
                    itemRarity = "Uncommon",
                    itemSubType = "Leather",
                    itemEquipLoc = "INVTYPE_CHEST",
                    quality = 2,
                    stats = {
                        ["ITEM_MOD_AGILITY_SHORT"] = 26,
                    }
                },
                equippedItems = convertEquippedItems({
                    ["INVTYPE_CHEST"] = { stats = { ["ITEM_MOD_INTELLECT_SHORT"] = 18 } }
                }),
                expectedResult = "GREED"
            }
        }
    }
}
 