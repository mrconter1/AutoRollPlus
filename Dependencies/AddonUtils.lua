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

function AutoRollUtils:rollID2itemID(rollId)
    local ItemLink = GetLootRollItemLink(rollId)
    local itemString = gsub(ItemLink, "\124", "\124\124")
    local itemId = tonumber(AutoRollUtils:getItemId(itemString))
    return itemId
end

function AutoRollUtils:IsItemStatUpgrade(itemLink, equipLoc, statKey)
    -- This function checks if an item is a stat upgrade
    -- Implementation details for upgrade detection
    if not itemLink or not equipLoc or not statKey then
        return false
    end
    -- Add upgrade detection logic here if needed
    -- For now, return false as this is handled by the local function in AutoRoll.lua
    return false
end
