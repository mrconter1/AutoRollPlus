# AutoRollPlus

A World of Warcraft Classic addon that intelligently automates loot rolling decisions based on whether items are actual upgrades.

## 🎯 About

Enhanced version of [AutoRoll by CassiniEU](https://www.curseforge.com/wow/addons/autoroll-classic) with smart upgrade detection. The original provided basic rule-based auto-rolling - this version adds intelligence to only roll on items that are stat improvements over your current gear.

## ✨ New Features

- **Smart Upgrade Detection**: Only rolls on items that improve your stats
- **EXEMPT System**: Force manual rolls for specific item types  
- **Dynamic Rules**: Auto-pass items that aren't upgrades
- **Testing Tools**: Preview how items will be handled

## 📥 Installation

1. Download/clone this repository
2. Copy `AutoRoll` folder to `World of Warcraft\_classic_\Interface\AddOns\`
3. Restart WoW or `/reload`

## 🎮 Usage

### Original Commands
```
/ar rules                    # List all rules
/ar pass/greed/need [item]   # Set item rules
/ar greed leather           # Set item type rules
/ar enable/disable          # Toggle addon
```

### New Enhanced Commands
```
# Smart upgrade detection
/ar pass ifnotupgrade cloth intellect    # Auto-pass cloth that isn't INT upgrade

# Manual override system  
/ar exempt leather staves                # Always show manual roll

# Testing
/ar test [item-link]                     # Test how item would be handled
```

## 🧠 How It Works

1. **EXEMPT Check**: Force manual roll if item type is exempt
2. **Upgrade Analysis**: Compare item stats to your best equipped gear
3. **Smart Decision**: Roll if upgrade, auto-pass if not
4. **Fallback**: Use original rules if no dynamic rule exists

## 🎯 Example

**Caster wanting only INT cloth upgrades:**
```
/ar pass ifnotupgrade cloth intellect
```

**Always manually decide on leather:**
```
/ar exempt leather
```

## 🙏 Credits

Based on [AutoRoll by CassiniEU](https://www.curseforge.com/wow/addons/autoroll-classic)

## 🐛 Known Issues

- Currently only supports Intellect stat comparison
- Doesn't account for secondary stats or set bonuses
- Some complex item types may not map correctly

## 🤝 Contributing

Feel free to submit issues or pull requests to improve the addon!

## 📄 License

Based on the original AutoRoll addon. This enhanced version maintains the same license structure. 