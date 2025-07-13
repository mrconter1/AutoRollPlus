# 🎲 AutoRollPlus

**AutoRollPlus automatically handles loot rolling decisions in World of Warcraft Classic MOP using customizable profile-based rules that adapt to your character's class and specialization.**

## ✨ Main Features

- **🤖 Intelligent Automation**: Automatically makes Need/Greed/Pass decisions without manual intervention
- **🎯 Profile-Based Rules**: Different rule sets for each class and specialization combination
- **🔧 Visual Configuration**: Easy-to-use graphical interface for managing profiles and rules
- **🧪 Item Testing**: Test how any item would be handled before encountering it in dungeons/raids
- **⚡ Zero Configuration**: Works immediately after installation with smart defaults

## 📋 Commands

```
/arp profiles                # Browse profiles rollScripts
/arp test                    # Open test GUI
/arp test [item-link]        # Test how a specific item would be handled
```

## 🖥️ User Interfaces

**Profile Configuration GUI (`/arp profiles`)**
- View rule scripts for different class/spec combinations
- Browse rolling logic for different character types
- See how rules are structured and prioritized

**Test Terminal GUI (`/arp test`)**
- Drag items or paste item links to see how they would be handled
- See exactly which rules matched and why a decision was made
- Test items against different class/spec profiles with instant feedback

## 🧠 How It Works

1. **Automatic Profile Selection**: Detects your character's class and specialization, applies appropriate rules
2. **Rule-Based Decisions**: Items are evaluated against your profile's rule set in priority order
3. **Automatic Rolling**: Based on matching rules, addon automatically rolls Need, Greed, or Pass
4. **Manual Fallback**: Items with no matching rules show the normal roll dialog

## 🎯 Perfect For

- Players who want to focus on gameplay instead of constant loot decisions
- Frequent dungeon/raid runners with consistent rolling preferences
- Anyone wanting to avoid accidentally rolling on wrong items
- Testing item compatibility before raids

**Example**: Tank warrior automatically passes on caster gear and needs plate armor, while priest healer needs healing gear and passes on melee weapons.

## 🛠️ Technical Details

- **Requirements**: World of Warcraft Classic MOP
- **Performance**: Lightweight with minimal memory footprint
- **Customization**: Visual rule editor, priority organization, manual override options

## 🙏 Credits

Loosely built upon [AutoRoll by CassiniEU](https://www.curseforge.com/wow/addons/autoroll-classic), though the codebase has been completely rewritten with new features and enhanced functionality.

## 📝 Known Limitations

- Profile selection is automatic based on class/spec detection
- Some complex item types may require manual rule creation
- Rule modifications require UI reload to take effect 