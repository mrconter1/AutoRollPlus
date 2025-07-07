AutoRollUtils = {
    ROLL = {
        UNSET = -1,
        PASS = 0,
        NEED = 1,
        GREED = 2,
        EXEMPT = 3
    },
    -- use ITEM_QUALITY_COLORS[integer] for colors {r,g,b,hex}
    ItemRarity = {
        POOR = 0,
        COMMON = 1,
        UNCOMMON = 2,
        RARE = 3,
        EPIC = 4,
        LEGENDARY = 5
    }
}

AutoRollUtils.STAT_KEYS = {
    intellect = "ITEM_MOD_INTELLECT_SHORT",
    -- Add more stat mappings as needed
}

function AutoRollUtils:modulus(a,b)
    return a - math.floor(a/b)*b
end

function AutoRollUtils:deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[AutoRollUtils:deepcopy(orig_key)] = AutoRollUtils:deepcopy(orig_value)
        end
        setmetatable(copy, AutoRollUtils:deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function AutoRollUtils:getItemId(str)
    if str then
        local tmp = string.match(str, "item:(%d*)")
        if tmp then
            return tonumber(string.match(tmp, "(%d*)"))
        end
        return nil
    end
end

function AutoRollUtils:getRuleValue(str)
    if str then
        if str:lower() == "pass" then return AutoRollUtils.ROLL.PASS end
        if str:lower() == "need" then return AutoRollUtils.ROLL.NEED end
        if str:lower() == "greed" then return AutoRollUtils.ROLL.GREED end
        if str:lower() == "exempt" then return AutoRollUtils.ROLL.EXEMPT end
        if str:lower() == "unset" then return AutoRollUtils.ROLL.UNSET end
    end

    return AutoRollUtils.ROLL.UNSET
end

function AutoRollUtils:getNextRule(rule)
    if rule then
        if AutoRollUtils.ROLL.UNSET then return AutoRollUtils.ROLL.GREED end
        if AutoRollUtils.ROLL.GREED then return AutoRollUtils.ROLL.NEED end
        if AutoRollUtils.ROLL.NEED then return AutoRollUtils.ROLL.PASS end
        if AutoRollUtils.ROLL.PASS then return AutoRollUtils.ROLL.UNSET end
    end

    return AutoRollUtils.ROLL.UNSET
end

function AutoRollUtils:getRuleString(num)
    if num == AutoRollUtils.ROLL.PASS then return "pass" end
    if num == AutoRollUtils.ROLL.NEED then return "need" end
    if num == AutoRollUtils.ROLL.GREED then return "greed" end
    if num == AutoRollUtils.ROLL.EXEMPT then return "exempt" end
    if num == AutoRollUtils.ROLL.UNSET then return "unset" end

    return "unset"
end

function AutoRollUtils:rollID2itemID(rollId)
    local ItemLink = GetLootRollItemLink(rollId)
    local itemString = gsub(ItemLink, "\124", "\124\124")
    local itemId = tonumber(AutoRollUtils:getItemId(itemString))
    return itemId
end

function AutoRollUtils:getRarityStringFromInteger(num)
    if num == AutoRollUtils.ItemRarity.POOR then return "poor" end
    if num == AutoRollUtils.ItemRarity.COMMON then return "common" end
    if num == AutoRollUtils.ItemRarity.UNCOMMON then return "uncommon" end
    if num == AutoRollUtils.ItemRarity.RARE then return "rare" end
    if num == AutoRollUtils.ItemRarity.EPIC then return "epic" end
    if num == AutoRollUtils.ItemRarity.LEGENDARY then return "legendary" end

    return nil
end

function AutoRollUtils:getRarityIntegerFromString(str)
    if str then
        if str:lower() == "poor" then return AutoRollUtils.ItemRarity.POOR end
        if str:lower() == "common" then return AutoRollUtils.ItemRarity.COMMON end
        if str:lower() == "uncommon" then return AutoRollUtils.ItemRarity.UNCOMMON end
        if str:lower() == "rare" then return AutoRollUtils.ItemRarity.RARE end
        if str:lower() == "epic" then return AutoRollUtils.ItemRarity.EPIC end
        if str:lower() == "legendary" then return AutoRollUtils.ItemRarity.LEGENDARY end
    end

    return -1
end

function AutoRollUtils:IsItemStatUpgrade(itemLink, equipLoc, statKey)
    local function GetItemStatValue(itemLink, statKey)
        if not itemLink then return 0 end
        local stats = GetItemStats(itemLink)
        if stats and stats[statKey] then
            return stats[statKey]
        end
        return 0
    end
    local itemStat = GetItemStatValue(itemLink, statKey)
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
