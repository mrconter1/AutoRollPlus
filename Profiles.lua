-- AutoRoll Profile Rules  
-- Maps profile names to shared rule scripts

AutoRollProfiles = {
    -- Hunter profiles (all specs use agility + manual rolling)
    hunter_beastmastery = AutoRollRuleScripts.hunter_agility,
    hunter_marksmanship = AutoRollRuleScripts.hunter_agility,
    hunter_survival = AutoRollRuleScripts.hunter_agility,

    -- Priest profiles (all specs use intellect + manual rolling + greed)
    priest_holy = AutoRollRuleScripts.priest_intellect,
    priest_discipline = AutoRollRuleScripts.priest_intellect,
    priest_shadow = AutoRollRuleScripts.priest_intellect,

    -- Warrior profiles use strength + need rolling
    warrior_arms = AutoRollRuleScripts.warrior_strength,
    warrior_fury = AutoRollRuleScripts.warrior_strength,
    warrior_protection = AutoRollRuleScripts.warrior_tank_strength,

    -- Rogue profiles (all specs use agility + need rolling)
    rogue_assassination = AutoRollRuleScripts.rogue_agility,
    rogue_combat = AutoRollRuleScripts.rogue_agility,
    rogue_subtlety = AutoRollRuleScripts.rogue_agility,

    -- Druid profiles 
    druid_feral = AutoRollRuleScripts.leather_agility,          -- Agility (both cat/bear)
    druid_balance = AutoRollRuleScripts.leather_intellect,      -- Intellect (caster DPS)
    druid_restoration = AutoRollRuleScripts.leather_intellect,  -- Intellect (healer)

    -- Monk profiles
    monk_brewmaster = AutoRollRuleScripts.leather_agility,      -- Agility (tank)
    monk_windwalker = AutoRollRuleScripts.leather_agility,      -- Agility (DPS)
    monk_mistweaver = AutoRollRuleScripts.leather_intellect,    -- Intellect (healer)

    -- Warlock profiles (all specs use intellect + manual rolling)
    warlock_affliction = AutoRollRuleScripts.warlock_intellect,
    warlock_demonology = AutoRollRuleScripts.warlock_intellect,
    warlock_destruction = AutoRollRuleScripts.warlock_intellect,

    -- Death Knight profiles (all specs use strength + manual rolling)
    death_knight_blood = AutoRollRuleScripts.death_knight_strength,
    death_knight_frost = AutoRollRuleScripts.death_knight_strength,
    death_knight_unholy = AutoRollRuleScripts.death_knight_strength
} 