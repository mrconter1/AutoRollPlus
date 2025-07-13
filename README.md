# 🎲 AutoRollPlus

Enhanced auto-rolling addon for World of Warcraft Classic that intelligently handles loot rolls based on your character's class and specialization.

## ⚡ Quick Start

1. Extract to `Interface/AddOns/AutoRollPlus`
2. `/reload` 
3. Restart WoW or `/reload`

## 🎮 Usage

### Available Commands
```
/arp test                    # Open test GUI
/arp test [item-link]        # Test how item would be handled
/arp profiles                # Open profiles GUI
```

## 🧠 How It Works

1. **Profile-Based**: Rules are automatically applied based on your character's class and specialization
2. **Rule Evaluation**: Each item is evaluated against your current profile's rule set
3. **Automatic Rolling**: Based on rule evaluation, the addon automatically rolls Need, Greed, or Pass
4. **Manual Override**: Items can be configured to always show manual roll dialog

## 🎯 Example

**Testing how an item would be handled:**
```
/arp test [Shift-click an item to get its link]
```

**Open test GUI:**
```
/arp test
```

**Open profiles GUI:**
```
/arp profiles
```

## 🙏 Credits

Based on [AutoRoll by CassiniEU](https://www.curseforge.com/wow/addons/autoroll-classic)

## 🐛 Known Issues

- Rules are currently defined in Profiles.lua and require addon knowledge to modify
- Profile selection is automatic based on class/spec and cannot be manually overridden
- Some complex item types may not map correctly 