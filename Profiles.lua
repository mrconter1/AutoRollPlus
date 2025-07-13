-- AutoRoll Profile Rules  
-- Maps profile names to shared rule scripts

AutoRollProfiles = {
    -- Hunter profiles (all specs use agility + manual rolling)
    hunter_beastmastery = AutoRollRuleScripts.hunter_agility,
    hunter_marksmanship = AutoRollRuleScripts.hunter_agility,
    hunter_survival = AutoRollRuleScripts.hunter_agility,

    -- Priest profiles (all specs use intellect + manual rolling + pass)
    priest_holy = AutoRollRuleScripts.priest_intellect,
    priest_discipline = AutoRollRuleScripts.priest_intellect,
    priest_shadow = AutoRollRuleScripts.priest_intellect,

    -- Warrior profiles use strength + need rolling
    warrior_arms = AutoRollRuleScripts.warrior_strength,
    warrior_fury = AutoRollRuleScripts.warrior_strength,
    warrior_protection = AutoRollRuleScripts.warrior_tank_strength,

    -- Druid profiles 
    druid_feral = AutoRollRuleScripts.leather_agility,          -- Agility (both cat/bear)
    druid_balance = AutoRollRuleScripts.leather_intellect,      -- Intellect (caster DPS)
    druid_restoration = AutoRollRuleScripts.leather_intellect,  -- Intellect (healer)

    -- Monk profiles
    monk_brewmaster = AutoRollRuleScripts.leather_agility,      -- Agility (tank)
    monk_windwalker = AutoRollRuleScripts.leather_agility,      -- Agility (DPS)
    monk_mistweaver = AutoRollRuleScripts.leather_intellect     -- Intellect (healer)
} 