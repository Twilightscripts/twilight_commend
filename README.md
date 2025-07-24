# QBCore / Qbox Commend System

A lightweight and modular script for QBCore-based servers (Qbox compatible) that allows admins to commend players for good behavior, immersive RP, or meaningful contributions. Uses `ox_lib` for notifications, menus, and optional logging.
https://discord.gg/Bx22Trwsd2
---

## 🚀 Features

- ✅ **Admin-Only Commend Command/UI**  
- 📣 **Global Chat Notifications** when a player is commended  
- 📊 **Leaderboard UI** showing most commended players  
- 💾 **Persistent Storage** using player identifiers (citizenid)  
- 📝 **Optional Logging** to Discord or file  
- 🎨 **ox_lib UI** for viewing commend history and leaderboard  

---

## 📦 Requirements

- [ox_lib](https://github.com/overextended/ox_lib)  
- oxmysql
- QBCore Framework (Qbox compatible)

---

## 🛠️ Installation

1. **Download or clone this repository** into your `resources` folder.

2. **Ensure ox_lib is started before this resource** in your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure twilight_commend
