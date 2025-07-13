-- AutoRoll Profile Rules
-- Centralized rule scripts for all class/spec profiles

AutoRollProfiles = {
    hunter = [[
        IF item.type == 'leather' 
           AND player.level < 50 
           AND item.agility.isUpgrade() 
        THEN item.manualRoll()

        IF item.type == 'mail' 
           AND player.level >= 50 
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

    priest_holy = [[
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

    warrior_dps = [[
        IF item.type == 'mail' 
           AND player.level < 40 
           AND item.strength.isUpgrade() 
        THEN item.rollNeed()

        IF item.type == 'plate' 
           AND player.level >= 40 
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

    warrior_tank = [[
        IF item.type == 'mail' 
           AND player.level < 40 
           AND item.strength.isUpgrade() 
        THEN item.rollNeed()

        IF item.type == 'plate' 
           AND player.level >= 40 
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

    druid_feral = [[
        IF item.type == 'leather' 
           AND item.agility.isUpgrade() 
        THEN item.rollNeed()

        IF (item.type == 'staff' OR 
            item.type == 'one-handed mace' OR 
            item.type == 'two-handed mace' OR 
            item.type == 'dagger' OR 
            item.type == 'fist weapon' OR 
            item.type == 'polearm') 
           AND item.agility.isUpgrade() 
        THEN item.rollNeed()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.agility.isUpgrade() 
        THEN item.rollNeed()

        item.rollGreed()
    ]],

    druid_balance = [[
        IF item.type == 'leather' 
           AND item.intellect.isUpgrade() 
        THEN item.rollNeed()

        IF (item.type == 'staff' OR 
            item.type == 'one-handed mace' OR 
            item.type == 'two-handed mace' OR 
            item.type == 'dagger' OR 
            item.type == 'fist weapon' OR 
            item.type == 'polearm') 
           AND item.intellect.isUpgrade() 
        THEN item.rollNeed()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.intellect.isUpgrade() 
        THEN item.rollNeed()

        item.rollGreed()
    ]],

    druid_restoration = [[
        IF item.type == 'leather' 
           AND item.intellect.isUpgrade() 
        THEN item.rollNeed()

        IF (item.type == 'staff' OR 
            item.type == 'one-handed mace' OR 
            item.type == 'two-handed mace' OR 
            item.type == 'dagger' OR 
            item.type == 'fist weapon' OR 
            item.type == 'polearm') 
           AND item.intellect.isUpgrade() 
        THEN item.rollNeed()

        IF (item.type == 'ring' OR 
            item.type == 'trinket' OR 
            item.type == 'necklace' OR 
            item.type == 'cloak') 
           AND item.intellect.isUpgrade() 
        THEN item.rollNeed()

        item.rollGreed()
    ]]
} 