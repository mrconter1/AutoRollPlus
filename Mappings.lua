-- AutoRollPlus Mappings
-- Consolidated mappings used across multiple files

local AutoRollMappings = {}

-- Map simple stat names to GetItemStats keys
AutoRollMappings.STAT_KEYS = {
    intellect = "ITEM_MOD_INTELLECT_SHORT",
    agility = "ITEM_MOD_AGILITY_SHORT",
    strength = "ITEM_MOD_STRENGTH_SHORT",
    armor = "ITEM_MOD_ARMOR_SHORT",
}

-- Map equip locations to inventory slot IDs (array format for multiple slots)
AutoRollMappings.equipSlotMap = {
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

-- Class specializations mapping
AutoRollMappings.classSpecs = {
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

-- Profile name mapping for specs that need more granular profiles
AutoRollMappings.profileNameMap = {
    DRUID = {
        ["Balance"] = "druid_balance",
        ["Feral"] = "druid_feral",
        ["Restoration"] = "druid_restoration"
    },
    WARRIOR = {
        ["Arms"] = "warrior_arms",
        ["Fury"] = "warrior_fury",
        ["Protection"] = "warrior_protection"
    },
    PRIEST = {
        ["Holy"] = "priest_holy",
        ["Discipline"] = "priest_discipline",
        ["Shadow"] = "priest_shadow"
    },
    HUNTER = {
        ["Beast Mastery"] = "hunter_beastmastery",
        ["Marksmanship"] = "hunter_marksmanship",
        ["Survival"] = "hunter_survival"
    },
    ROGUE = {
        ["Assassination"] = "rogue_assassination",
        ["Combat"] = "rogue_combat",
        ["Subtlety"] = "rogue_subtlety"
    },
    MONK = {
        ["Brewmaster"] = "monk_brewmaster",
        ["Windwalker"] = "monk_windwalker",
        ["Mistweaver"] = "monk_mistweaver"
    },
    WARLOCK = {
        ["Affliction"] = "warlock_affliction",
        ["Demonology"] = "warlock_demonology",
        ["Destruction"] = "warlock_destruction"
    },
    DEATHKNIGHT = {
        ["Blood"] = "death_knight_blood",
        ["Frost"] = "death_knight_frost",
        ["Unholy"] = "death_knight_unholy"
    },
    PALADIN = {
        ["Holy"] = "paladin_holy",
        ["Protection"] = "paladin_protection",
        ["Retribution"] = "paladin_retribution"
    },
    SHAMAN = {
        ["Enhancement"] = "shaman_enhancement",
        ["Elemental"] = "shaman_elemental",
        ["Restoration"] = "shaman_restoration"
    },
    MAGE = {
        ["Arcane"] = "mage_arcane",
        ["Fire"] = "mage_fire",
        ["Frost"] = "mage_frost"
    }
}

-- Helper function to get single slot ID (for TestData compatibility)
function AutoRollMappings:getSlotID(invType)
    local slots = self.equipSlotMap[invType]
    return slots and slots[1] or nil
end

-- Global access
_G.AutoRollMappings = AutoRollMappings 