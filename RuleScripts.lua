-- AutoRoll Rule Scripts
-- Base rule scripts that can be shared between multiple profiles

AutoRollRuleScripts = {
    -- Hunter agility rules (manual roll for all upgrades)
    hunter_agility = [[
        IF item.type == 'leather' 
           AND player.level < 50 
           AND item.agility.isUpgrade() 
        THEN item.manualRoll()

        IF item.type == 'mail' 
           AND player.level >= 50 
           AND item.agility.isUpgrade() 
        THEN item.manualRoll()

        IF (item.type == 'bows' OR
            item.type == 'crossbows' OR
            item.type == 'guns')
        THEN item.manualRoll()

        IF item.type == 'ring' OR 
           item.type == 'trinket'
        THEN item.manualRoll()

        IF (item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.agility.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Priest intellect rules (manual roll for all upgrades)
    priest_intellect = [[
        IF item.type == 'cloth' 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF item.type == 'trinket' 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Warrior strength rules (manual roll for all upgrades)
    warrior_strength = [[
        IF item.type == 'mail' 
           AND player.level < 40 
           AND item.strength.isUpgrade() 
        THEN item.manualRoll()

        IF item.type == 'plate' 
           AND player.level >= 40 
           AND item.strength.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.strength.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Warrior tank strength rules (includes shields)
    warrior_tank_strength = [[
        IF item.type == 'mail' 
           AND player.level < 40 
           AND item.strength.isUpgrade() 
        THEN item.manualRoll()

        IF item.type == 'plate' 
           AND player.level >= 40 
           AND item.strength.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.strength.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Monk/Druid agility rules (manual roll for all upgrades)
    leather_agility = [[
        IF item.type == 'leather' 
           AND item.agility.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.agility.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Druid/Monk intellect rules (manual roll for all upgrades) 
    leather_intellect = [[
        IF item.type == 'leather' 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Rogue agility rules (manual roll for all upgrades)
    rogue_agility = [[
        IF item.type == 'leather' 
           AND item.agility.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.agility.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Warlock intellect rules (manual roll for all upgrades)
    warlock_intellect = [[
        IF item.type == 'cloth' 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Death Knight strength rules (manual roll for all upgrades)
    death_knight_strength = [[
        IF item.type == 'plate' 
           AND item.strength.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.strength.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Paladin Holy rules (intellect, mail->plate progression)
    paladin_holy = [[
        IF item.type == 'mail' 
           AND player.level < 40 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        IF item.type == 'plate' 
           AND player.level >= 40 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Paladin Ret/Prot rules (strength, mail->plate progression)
    paladin_strength = [[
        IF item.type == 'mail' 
           AND player.level < 40 
           AND item.strength.isUpgrade() 
        THEN item.manualRoll()

        IF item.type == 'plate' 
           AND player.level >= 40 
           AND item.strength.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.strength.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Shaman Enhancement rules (agility, leather->mail progression)
    shaman_agility = [[
        IF item.type == 'leather' 
           AND player.level < 40 
           AND item.agility.isUpgrade() 
        THEN item.manualRoll()

        IF item.type == 'mail' 
           AND player.level >= 40 
           AND item.agility.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.agility.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Shaman Elemental/Resto rules (intellect, leather->mail progression)
    shaman_intellect = [[
        IF item.type == 'leather' 
           AND player.level < 40 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        IF item.type == 'mail' 
           AND player.level >= 40 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]],

    -- Mage rules (intellect, cloth only)
    mage_intellect = [[
        IF item.type == 'cloth' 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        IF item.isUsableWeapon() 
        THEN item.manualRoll()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.intellect.isUpgrade() 
        THEN item.manualRoll()

        item.rollGreed()
    ]]
}

-- Global access
_G.AutoRollRuleScripts = AutoRollRuleScripts 