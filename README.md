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

### Available Commands
```
/ar test [item-link]        # Test how item would be handled
/ar test                    # Run unit tests
/ar config                  # Open configuration GUI
```

## 🧠 How It Works

1. **Profile-Based**: Rules are automatically applied based on your character's class and specialization
2. **Rule Evaluation**: Each item is evaluated against your current profile's rule set
3. **Automatic Rolling**: Based on rule evaluation, the addon automatically rolls Need, Greed, or Pass
4. **Manual Override**: Items can be configured to always show manual roll dialog

## 🎯 Example

**Testing how an item would be handled:**
```
/ar test [Shift-click an item to get its link]
```

**Open configuration GUI:**
```
/ar config
```

## 🙏 Credits

Based on [AutoRoll by CassiniEU](https://www.curseforge.com/wow/addons/autoroll-classic)

## 🐛 Known Issues

- Rules are currently defined in Profiles.lua and require addon knowledge to modify
- Profile selection is automatic based on class/spec and cannot be manually overridden
- Some complex item types may not map correctly

## 🤝 Contributing

Feel free to submit issues or pull requests to improve the addon!

## 📄 License

Based on the original AutoRoll addon. This enhanced version maintains the same license structure. 