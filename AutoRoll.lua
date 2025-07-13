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

-- Simple defaults
local defaults = {
}

do -- Private Scope

    local ADDON_NAME = "AutoRollPlus"

    --==============================
    -- Dynamic Upgrade Rule Helpers
    --==============================

    -- Use centralized mappings
    local STAT_KEYS = AutoRollMappings.STAT_KEYS
    local equipSlotMap = AutoRollMappings.equipSlotMap

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
        if not string.match(message, "won:") then
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
        -- Initialize profiles if not exists
        if not AutoRollPlus_PCDB then
            AutoRollPlus_PCDB = {}
        end
        if not AutoRollPlus_PCDB["profiles"] then
            AutoRollPlus_PCDB["profiles"] = {}
        end
    end

    function AutoRoll:onEvent(self, event, ...)
        if event == "ADDON_LOADED" then
            if select(1, ...) == ADDON_NAME then
                            if not AutoRollPlus_PCDB then
                AutoRollPlus_PCDB = {}
            end
            LoadOptions()
            -- Automatically apply profile rules on each load
            local profileKey = AutoRoll.GetCurrentProfileKey and AutoRoll.GetCurrentProfileKey()
            if profileKey then
                -- Check if we have a centralized profile for this key
                local profileRules = AutoRollProfiles[profileKey]
                
                if profileRules then
                    AutoRollPlus_PCDB["profiles"] = AutoRollPlus_PCDB["profiles"] or {}
                    AutoRollPlus_PCDB["profiles"][profileKey] = { ruleStrings = profileRules }
                    print("AutoRollPlus: Profile rules applied for " .. profileKey)
                end
            end
            
            -- Check if test dialog should be opened after reload
            if AutoRollPlus_PCDB.openTestDialogOnLoad then
                -- Reset the flag
                AutoRollPlus_PCDB.openTestDialogOnLoad = false
                
                -- Open test dialog with a small delay to ensure everything is loaded
                C_Timer.After(0.5, function()
                    if AutoRollTestTerminal and AutoRollTestTerminal.Initialize then
                        AutoRollTestTerminal:Initialize()
                    end
                end)
            end
            
            PrintHelp()
            end
            return
        end
        -- For all other events, do nothing if AutoRollPlus_PCDB is not initialized
        if not AutoRollPlus_PCDB then return end

        if event == "START_LOOT_ROLL" then
            EvaluateActiveRolls()
        elseif event == "PLAYER_ENTERING_WORLD" then
            EvaluateActiveRolls()
        elseif event == "CONFIRM_LOOT_ROLL" then
            local rollId = select(1, ...)
            local roll = select(2, ...)
            ConfirmLootRoll(rollId, roll)
        end
    end

    function PrintHelp()
        local colorHex = "2979ff"
        print("|cff"..colorHex.."AutoRollPlus loaded")
        print("-- Use /arp for available commands")
    end



    --==============================
    -- Rule Parser and Evaluator
    --==============================

    local RuleParser = {}
    
    -- Make RuleParser globally accessible for testing
    AutoRoll.RuleParser = RuleParser

    -- Tokenizer
    function RuleParser:tokenize(ruleString)
        local tokens = {}
        local i = 1
        local len = #ruleString
        
        while i <= len do
            local char = ruleString:sub(i, i)
            
            -- Skip whitespace
            if char:match("%s") then
                i = i + 1
            -- Handle operators and punctuation
            elseif char == "(" then
                table.insert(tokens, {type = "LPAREN", value = "("})
                i = i + 1
            elseif char == ")" then
                table.insert(tokens, {type = "RPAREN", value = ")"})
                i = i + 1
            elseif char == "." then
                table.insert(tokens, {type = "DOT", value = "."})
                i = i + 1
            elseif char == "<" then
                if i + 1 <= len and ruleString:sub(i + 1, i + 1) == "=" then
                    table.insert(tokens, {type = "OPERATOR", value = "<="})
                    i = i + 2
                else
                    table.insert(tokens, {type = "OPERATOR", value = "<"})
                    i = i + 1
                end
            elseif char == ">" then
                if i + 1 <= len and ruleString:sub(i + 1, i + 1) == "=" then
                    table.insert(tokens, {type = "OPERATOR", value = ">="})
                    i = i + 2
                else
                    table.insert(tokens, {type = "OPERATOR", value = ">"})
                    i = i + 1
                end
            elseif char == "=" then
                if i + 1 <= len and ruleString:sub(i + 1, i + 1) == "=" then
                    table.insert(tokens, {type = "OPERATOR", value = "=="})
                    i = i + 2
                else
                    table.insert(tokens, {type = "OPERATOR", value = "="})
                    i = i + 1
                end
            -- Handle numbers
            elseif char:match("%d") then
                local num = ""
                while i <= len and ruleString:sub(i, i):match("%d") do
                    num = num .. ruleString:sub(i, i)
                    i = i + 1
                end
                table.insert(tokens, {type = "NUMBER", value = tonumber(num)})
            -- Handle string literals
            elseif char == "'" or char == '"' then
                local quote = char
                local str = ""
                i = i + 1 -- Skip opening quote
                while i <= len and ruleString:sub(i, i) ~= quote do
                    str = str .. ruleString:sub(i, i)
                    i = i + 1
                end
                if i <= len then
                    i = i + 1 -- Skip closing quote
                end
                table.insert(tokens, {type = "STRING", value = str})
            -- Handle identifiers and keywords
            elseif char:match("%a") then
                local word = ""
                while i <= len and ruleString:sub(i, i):match("[%w_]") do
                    word = word .. ruleString:sub(i, i)
                    i = i + 1
                end
                
                local upperWord = word:upper()
                if upperWord == "IF" then
                    table.insert(tokens, {type = "IF", value = word})
                elseif upperWord == "THEN" then
                    table.insert(tokens, {type = "THEN", value = word})
                elseif upperWord == "ELSE" then
                    table.insert(tokens, {type = "ELSE", value = word})
                elseif upperWord == "AND" then
                    table.insert(tokens, {type = "AND", value = word})
                elseif upperWord == "OR" then
                    table.insert(tokens, {type = "OR", value = word})
                else
                    table.insert(tokens, {type = "IDENTIFIER", value = word})
                end
            else
                -- Unknown character, skip
                i = i + 1
            end
        end
        
        return tokens
    end

    -- Parser
    function RuleParser:parse(tokens)
        local pos = 1
        
        local function peek()
            return tokens[pos]
        end
        
        local function consume(expectedType)
            local token = tokens[pos]
            if token and (not expectedType or token.type == expectedType) then
                pos = pos + 1
                return token
            end
            return nil
        end
        
        -- Forward declarations
        local parseExpression, parseOrExpression, parseAndExpression, parseComparisonExpression, parsePrimaryExpression
        
        parseExpression = function()
            return parseOrExpression()
        end
        
        parseOrExpression = function()
            local left = parseAndExpression()
            
            while peek() and peek().type == "OR" do
                consume("OR")
                local right = parseAndExpression()
                left = {type = "OR", left = left, right = right}
            end
            
            return left
        end
        
        parseAndExpression = function()
            local left = parseComparisonExpression()
            
            while peek() and peek().type == "AND" do
                consume("AND")
                local right = parseComparisonExpression()
                left = {type = "AND", left = left, right = right}
            end
            
            return left
        end
        
        parseComparisonExpression = function()
            local left = parsePrimaryExpression()
            
            local token = peek()
            if token and token.type == "OPERATOR" then
                local op = consume("OPERATOR")
                local right = parsePrimaryExpression()
                return {type = "COMPARISON", operator = op.value, left = left, right = right}
            end
            
            return left
        end
        
        parsePrimaryExpression = function()
            local token = peek()
            
            if token and token.type == "LPAREN" then
                consume("LPAREN")
                local expr = parseExpression()
                consume("RPAREN")
                return expr
            elseif token and token.type == "IDENTIFIER" then
                local identifier = consume("IDENTIFIER")
                local result = {type = "IDENTIFIER", value = identifier.value}
                
                -- Handle dot notation (player.level, item.agility.isUpgrade())
                while peek() and peek().type == "DOT" do
                    consume("DOT")
                    local member = consume("IDENTIFIER")
                    if member then
                        result = {type = "MEMBER", object = result, member = member.value}
                        
                        -- Handle method calls
                        if peek() and peek().type == "LPAREN" then
                            consume("LPAREN")
                            consume("RPAREN")
                            result = {type = "METHOD_CALL", object = result}
                        end
                    end
                end
                
                return result
            elseif token and token.type == "NUMBER" then
                local num = consume("NUMBER")
                return {type = "NUMBER", value = num.value}
            elseif token and token.type == "STRING" then
                local str = consume("STRING")
                return {type = "STRING", value = str.value}
            end
            
            return nil
        end
        
        local function parseRule()
            local token = peek()
            
            if token and token.type == "IF" then
                consume("IF")
                local condition = parseExpression()
                consume("THEN")
                
                -- Check if the action is a method call (like item.rollNeed())
                local nextToken = peek()
                if nextToken and nextToken.type == "IDENTIFIER" and nextToken.value == "item" then
                    local methodCall = parsePrimaryExpression()
                    if methodCall and methodCall.type == "METHOD_CALL" then
                        return {
                            type = "IF_RULE",
                            condition = condition,
                            methodCall = methodCall
                        }
                    end
                else
                    -- Handle simple identifier actions (for backward compatibility)
                    local action = consume("IDENTIFIER")
                    return {
                        type = "IF_RULE",
                        condition = condition,
                        action = action and action.value
                    }
                end
            elseif token and token.type == "ELSE" then
                consume("ELSE")
                local action = consume("IDENTIFIER")
                
                return {
                    type = "ELSE_RULE",
                    action = action and action.value
                }
            elseif token and token.type == "IDENTIFIER" and token.value == "item" then
                -- Handle item.action() calls
                local methodCall = parsePrimaryExpression()
                if methodCall and methodCall.type == "METHOD_CALL" then
                    return {
                        type = "METHOD_RULE",
                        methodCall = methodCall
                    }
                end
            end
            
            return nil
        end
        
        return parseRule()
    end

    -- Evaluator
    function RuleParser:evaluate(ast, context)
        if not ast then return nil end
        
        if ast.type == "IF_RULE" then
            if self:evaluateCondition(ast.condition, context) then
                -- Handle method call actions (like item.rollNeed())
                if ast.methodCall then
                    return self:evaluateMethodRule(ast.methodCall, context)
                else
                    -- Handle simple identifier actions (for backward compatibility)
                    return ast.action
                end
            end
            return nil
        elseif ast.type == "ELSE_RULE" then
            return ast.action
        elseif ast.type == "METHOD_RULE" then
            return self:evaluateMethodRule(ast.methodCall, context)
        end
        
        return nil
    end
    
    function RuleParser:evaluateCondition(condition, context)
        if not condition then return false end
        
        if condition.type == "AND" then
            return self:evaluateCondition(condition.left, context) and 
                   self:evaluateCondition(condition.right, context)
        elseif condition.type == "OR" then
            return self:evaluateCondition(condition.left, context) or 
                   self:evaluateCondition(condition.right, context)
        elseif condition.type == "COMPARISON" then
            local left = self:evaluateValue(condition.left, context)
            local right = self:evaluateValue(condition.right, context)
            
            if condition.operator == "<" then
                return left < right
            elseif condition.operator == "<=" then
                return left <= right
            elseif condition.operator == ">" then
                return left > right
            elseif condition.operator == ">=" then
                return left >= right
            elseif condition.operator == "==" then
                return left == right
            end
        elseif condition.type == "IDENTIFIER" then
            -- Item type checks (leather, mail, bow, etc.)
            local itemType = condition.value:lower()
            return self:checkItemType(itemType, context)
        elseif condition.type == "METHOD_CALL" then
            return self:evaluateMethodCall(condition, context)
        end
        
        return false
    end
    
    function RuleParser:evaluateValue(value, context)
        if not value then return nil end
        
        if value.type == "NUMBER" then
            return value.value
        elseif value.type == "STRING" then
            return value.value
        elseif value.type == "MEMBER" then
            if value.object.type == "IDENTIFIER" and value.object.value == "player" then
                if value.member == "level" then
                    return UnitLevel("player")
                elseif value.member == "class" then
                    local _, classKey = UnitClass("player")
                    return classKey
                end
            elseif value.object.type == "IDENTIFIER" and value.object.value == "item" then
                if value.member == "type" then
                    -- Handle special cases where type is determined by equipment location
                    local equipLoc = context.itemEquipLoc
                    local subType = context.itemSubType and context.itemSubType:lower()
                    
                    if equipLoc == "INVTYPE_FINGER" then
                        return "ring"
                    elseif equipLoc == "INVTYPE_TRINKET" then
                        return "trinket"
                    elseif equipLoc == "INVTYPE_NECK" then
                        return "necklace"
                    elseif equipLoc == "INVTYPE_CLOAK" then
                        return "cloak"
                    elseif equipLoc == "INVTYPE_HOLDABLE" then
                        return "off-hand"
                    else
                        return subType
                    end
                end
            end
        end
        
        return nil
    end
    
    function RuleParser:evaluateMethodCall(methodCall, context)
        -- Handle item.stat.isUpgrade() structure
        if methodCall.object.type == "MEMBER" and 
           methodCall.object.member == "isUpgrade" then
            
            -- Check if this is item.stat.isUpgrade()
            if methodCall.object.object.type == "MEMBER" and
               methodCall.object.object.object.type == "IDENTIFIER" and
               methodCall.object.object.object.value == "item" then
                
                local statName = methodCall.object.object.member
                local statKey = STAT_KEYS[statName:lower()]
                if statKey and context.itemLink and context.itemEquipLoc then
                    return IsItemStatUpgrade(context.itemLink, context.itemEquipLoc, statKey)
                end
            end
        end
        
        return false
    end
    
    function RuleParser:evaluateMethodRule(methodCall, context)
        -- Handle item.action() calls
        if methodCall.object.type == "MEMBER" and 
           methodCall.object.object.type == "IDENTIFIER" and 
           methodCall.object.object.value == "item" then
            -- This is a direct action call like item.rollGreed(), item.rollPass(), etc.
            local methodName = methodCall.object.member
            
            -- Map method names to expected action names
            if methodName == "rollNeed" then
                return "NEED"
            elseif methodName == "rollGreed" then
                return "GREED"
            elseif methodName == "rollPass" then
                return "PASS"
            elseif methodName == "manualRoll" then
                return "MANUAL"
            end
            
            -- Fallback to original behavior for backward compatibility
            return methodName
        end
        
        return nil
    end
    
    function RuleParser:checkItemType(itemType, context)
        if not context.itemSubType and not context.itemEquipLoc then return false end
        
        local subType = context.itemSubType and context.itemSubType:lower()
        local equipLoc = context.itemEquipLoc
        
        -- Armor types
        if itemType == "leather" then
            return subType == "leather"
        elseif itemType == "mail" then
            return subType == "mail"
        elseif itemType == "cloth" then
            return subType == "cloth"
        elseif itemType == "plate" then
            return subType == "plate"
        -- Weapons
        elseif itemType == "bow" then
            return subType == "bow"
        elseif itemType == "gun" then
            return subType == "gun"
        elseif itemType == "crossbow" then
            return subType == "crossbow"
        elseif itemType == "staff" then
            return subType == "staff"
        elseif itemType == "one-handed sword" then
            return subType == "one-handed sword"
        elseif itemType == "two-handed sword" then
            return subType == "two-handed sword"
        elseif itemType == "one-handed axe" then
            return subType == "one-handed axe"
        elseif itemType == "two-handed axe" then
            return subType == "two-handed axe"
        elseif itemType == "one-handed mace" then
            return subType == "one-handed mace"
        elseif itemType == "two-handed mace" then
            return subType == "two-handed mace"
        elseif itemType == "polearm" then
            return subType == "polearm"
        elseif itemType == "dagger" then
            return subType == "dagger"
        elseif itemType == "fist weapon" then
            return subType == "fist weapon"
        elseif itemType == "shield" then
            return subType == "shield"
        elseif itemType == "wand" then
            return subType == "wand"
        elseif itemType == "thrown" then
            return subType == "thrown"
        -- Accessories
        elseif itemType == "ring" then
            return equipLoc == "INVTYPE_FINGER"
        elseif itemType == "trinket" then
            return equipLoc == "INVTYPE_TRINKET"
        elseif itemType == "necklace" then
            return equipLoc == "INVTYPE_NECK"
        elseif itemType == "cloak" then
            return equipLoc == "INVTYPE_CLOAK"
        end
        
        return false
    end

    -- Main function to evaluate rule strings
    function RuleParser:evaluateRuleStrings(ruleStrings, context)
        if not ruleStrings then return nil end
        
        -- Convert multi-line string to array if needed
        local rules = ruleStrings
        if type(ruleStrings) == "string" then
            rules = {}
            local currentRule = ""
            
            for line in ruleStrings:gmatch("[^\r\n]+") do
                line = line:match("^%s*(.-)%s*$") -- trim whitespace
                if line ~= "" then
                    if currentRule == "" then
                        currentRule = line
                    else
                        currentRule = currentRule .. " " .. line
                    end
                    
                    -- Check if this completes a rule (ends with THEN action, is an ELSE, or is item.action())
                    if line:match("THEN%s+%w+$") or line:match("THEN%s+item%.%w+%(%)%s*$") or line:match("^ELSE%s+%w+$") or line:match("^%s*item%.%w+%(%)%s*$") then
                        table.insert(rules, currentRule)
                        currentRule = ""
                    end
                end
            end
            
            -- Add any remaining rule
            if currentRule ~= "" then
                table.insert(rules, currentRule)
            end
        end
        
        for i, ruleString in ipairs(rules) do
            local tokens = self:tokenize(ruleString)
            local ast = self:parse(tokens)
            local result = self:evaluate(ast, context)
            
            if result then
                return result:upper()
            end
        end
        
        return nil
    end

    function EvaluateActiveRolls()
        for index,RollID in ipairs(GetActiveLootRollIDs()) do
            local itemId = AutoRollUtils:rollID2itemID(RollID)
            local _, _, _, quality, bindOnPickUp, canNeed, canGreed, _ = GetLootRollItemInfo(RollID)
            local itemName, itemLink, itemRarity, _, _, _, itemSubType, _, itemEquipLoc = GetItemInfo(itemId)
            local handled = false
            
            -- Create context for rule evaluation
            local context = {
                itemLink = itemLink,
                itemSubType = itemSubType,
                itemEquipLoc = itemEquipLoc,
                canNeed = canNeed,
                canGreed = canGreed
            }
            
            -- First try rule strings if they exist
            local profileKey = AutoRoll.GetCurrentProfileKey and AutoRoll.GetCurrentProfileKey()
            local ruleStrings = nil
            if profileKey then
                local profile = AutoRollPlus_PCDB["profiles"] and AutoRollPlus_PCDB["profiles"][profileKey]
                if profile and profile.ruleStrings then
                    ruleStrings = profile.ruleStrings
                end
            end
            
            if ruleStrings then
                local action = RuleParser:evaluateRuleStrings(ruleStrings, context)

                if action then
                    if action == "MANUAL" or action == "manualRoll" or action == "MANUALROLL" then
                        handled = true
                    elseif (action == "NEED" or action == "rollNeed" or action == "ROLLNEED") and canNeed then
                        RollOnLoot(RollID, AutoRollUtils.ROLL.NEED)
                        handled = true
                    elseif (action == "GREED" or action == "rollGreed" or action == "ROLLGREED") and canGreed then
                        RollOnLoot(RollID, AutoRollUtils.ROLL.GREED)
                        handled = true
                    elseif action == "PASS" or action == "rollPass" or action == "ROLLPASS" then
                        RollOnLoot(RollID, AutoRollUtils.ROLL.PASS)
                        handled = true
                    end
                end
            end

        end
    end



    -- Helper to get the current profile key
    function AutoRoll.GetCurrentProfileKey()
        local _, classKey = UnitClass("player")
        local specName = nil
        if GetPrimaryTalentTree then
            local specIndex = GetPrimaryTalentTree()
            local classSpecs = AutoRollMappings.classSpecs
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
            -- Use profile name mapping if available
            local profileNameMap = AutoRollMappings.profileNameMap
            if profileNameMap and profileNameMap[classKey] and profileNameMap[classKey][specName] then
                return profileNameMap[classKey][specName]
            end
            
            -- Fallback to old format for unmapped classes
            return string.lower(classKey .. "_" .. specName):gsub("%s+", "")
        end
        return nil
    end

end

return AutoRoll
