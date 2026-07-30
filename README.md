# EZPZ Banking
A simple, yet elegant solution to banking!\
Only on Steam's Workshop at: https://steamcommunity.com/sharedfiles/filedetails/?id=3624100352 \
If found elsewhere, please report.

## What This Mod Does
* Adds functional ATMs.
* Adds an ATM hacking minigame.
* Adds new professions.
* Adds new traits.
* Integrates with [Hacking Skill](https://steamcommunity.com/sharedfiles/filedetails/?id=3539339798) and [Mail Order Catalogs](https://steamcommunity.com/sharedfiles/filedetails/?id=3555453653).

Please check the Steam Workshop page for full details.

This is built as a **framework**. You can easily add new ATMs that will gain automatic functionality for EZPZ Banking.

### API for Modders
These are the **official functions** your mod can call to interact with EZPZ Banking.
You do **not** need to repack or include this mod to use them, but your mod must require EZPZ Banking.\
Bank account functions are multiplayer ready, secure, and handle all money handling.

### Available Functions
``` lua
EZPZBanking_API.registerATM(spriteName, facingDir)
-- Registers an ATM in the world.
-- facingDir: 0 = North, 1 = East, 2 = South, 3 = West.

EZPZBanking_API.deposit(player, amount)
-- Deposits money into the player's bank account.
-- Removes money from all inventories.
-- Doesn't require the player to have their credit card to work.

EZPZBanking_API.withdraw(player, amount)
-- Withdraws money from the player's bank account.
-- Adds money to main inventory.
-- Doesn't require the player to have their credit card to work.

EZPZBanking_API.giveMoney(player, amount)
-- Deposits money into the player's bank account.
-- Doesn't require actual money.
-- Doesn't require the player to have their credit card to work.
```

## 🌐 Translation Progress
<!-- AUTO-GENERATED-TABLE:START -->
| Language                | Progress      | Completed | Status        |
|-------------------------|---------------|-----------|---------------|
| 🇺🇸 English              | ██████████ 100% | 53/53     | ✅ Done      |
| 🇦🇷 Argentina            | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🏴 Catalan             | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇹🇼 Traditional Chinese  | ██████████ 96% | 51/53     | 🔃 In Progress |
| 🇨🇳 Simplified Chinese   | ██████████ 96% | 51/53     | 🔃 In Progress |
| 🇨🇿 Czech                | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇩🇰 Danish               | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇩🇪 German               | ██████████ 96% | 51/53     | 🔃 In Progress |
| 🇪🇸 Spanish              | ██████████ 96% | 51/53     | 🔃 In Progress |
| 🇫🇮 Finnish              | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇫🇷 French               | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇭🇺 Hungarian            | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇮🇩 Indonesian           | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇮🇹 Italian              | ██████████ 96% | 51/53     | 🔃 In Progress |
| 🇯🇵 Japanese             | ██████████ 96% | 51/53     | 🔃 In Progress |
| 🇰🇷 Korean               | ██████████ 96% | 51/53     | 🔃 In Progress |
| 🇳🇱 Dutch                | ██████████ 96% | 51/53     | 🔃 In Progress |
| 🇳🇴 Norwegian            | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇵🇭 Filipino             | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇵🇱 Polish               | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇵🇹 Portuguese           | ██████████ 96% | 51/53     | 🔃 In Progress |
| 🇧🇷 Brazilian Portuguese | ██████████ 96% | 51/53     | 🔃 In Progress |
| 🇷🇴 Romanian             | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇷🇺 Russian              | ██████████ 96% | 51/53     | 🔃 In Progress |
| 🇹🇭 Thai                 | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇹🇷 Turkish              | ░░░░░░░░░░ 0% | 0/53     | ❌ Not Started |
| 🇺🇦 Ukrainian            | ██████████ 96% | 51/53     | 🔃 In Progress |
<!-- AUTO-GENERATED-TABLE:END -->

### Translation Notice
Translations are provided by AI for your benefit. There are bound to be some errors. If you would like to contribiute, please reach out to me; I will happily replace AI-generated translations.

## Support
Come find me on discord! Be sure to grab the Project Zomboid Modding Role once you arrive.\
[![Discord](https://raw.githubusercontent.com/Jusblazm/pz-archive/refs/heads/main/_imgs/discordinvite.png)](https://discord.gg/yqstRpuGXy)

A simple like and a favorite is more than enough, but if you would like to do more:\
[![Ko-fi](https://i.imgur.com/vs8dr3R.png)](https://ko-fi.com/jusblazm)
