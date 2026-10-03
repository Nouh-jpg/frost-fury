# ❄️ Frost Fury: Chronicles of the Frostbound

> **A 16-bit Sega Genesis-era Arcade Fantasy Hybrid Brawler**  
> Blending the meaty melee combos of *Streets of Rage 3* with the chaotic bowling ball mechanics of *Snow Bros*.

[![Godot 4.7](https://img.shields.io/badge/Engine-Godot%204.7+-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Platform - Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Platform - Steam / PC](https://img.shields.io/badge/Platform-Steam%20%2F%20PC-171A21?logo=steam&logoColor=white)](https://store.steampowered.com)
[![Style - 16-Bit Pixel Art](https://img.shields.io/badge/Art-16--Bit%20Sega%20Genesis-FF6B6B)](#)

---

## 📖 Storyline
In the shattered realm of **Aethelgard**, the Corrupted Warlords of the **Cinder Legion** led by **Ignis the Ashlord** have unleashed volcanic hellfire upon the Crystal Citadels.

You play as **Kaelen**, a valiant Frost Knight master of cryogenic martial arts. Striking down enemy swarms chills their life force, encasing them in giant frosty rolling orbs that can be kicked into lethal bowling wrecking balls to shatter enemy legions!

---

## 🎮 Core Mechanics

### 1. Melee Combat System (*Streets of Rage 3* Style)
- **3-Hit Punch Sequence:** Tap Attack to unleash **Jab &rarr; Hook / Cross &rarr; Grand Rising Ice Uppercut** (launches enemies).
- **Blitz Rush Strike:** Hold Blitz / Shift + Attack to lunge forward with an ice fist, piercing through rows of enemies.
- **Air Dive Kick:** Jump and attack in mid-air to slam down onto enemies with a diving frost boot.
- **Screen Shake & Hit-Stop:** Meaty hit-freezes and dynamic screen impacts on heavy hits.

### 2. The Frost Sphere & Bowling System (*Snow Bros* Style)
- **Freeze Buildup:** Every punch inflicts damage and stacks Frost buildup on enemies.
- **Encased Sphere:** At 100% Frost, the enemy is completely trapped inside a **Frost Sphere**!
- **The Wrecking Ball Kick:** Walk up to a Frost Sphere and press **Attack** to kick it!
  - Hurtles across platforms at **380 px/s**.
  - Bounces off walls up to 4 times.
  - Obliterates and bowls down entire enemy swarms in a single shot!
  - **Multi-kill multipliers:** High multi-kills trigger rare loot drops.

### 3. Loot Drops & Power-Ups
- 🍷 **Red Potion:** Restores 40 HP.
- 🥾 **Golden Speed Boots:** Increases movement speed and jump height for 15 seconds.
- 💎 **Ice Diamond:** Grants +1,500 bonus score.
- ⭐ **Blitz Star:** Fully recharges the screen-clearing **Frost Nova** special gauge.

---

## 🕹️ Controls

| Action | Keyboard (PC) | Gamepad / Steam Deck | Mobile (Android) |
|---|---|---|---|
| **Move / Walk** | `A` / `D` or `Arrow Keys` | `D-Pad` / `Left Stick` | Virtual Touch D-Pad |
| **Attack / Kick Sphere** | `J` / `Z` / `F` | `X` / `B` Button | `[A]` Button (Red) |
| **Jump** | `K` / `Space` | `A` Button | `[B]` Button (Cyan) |
| **Blitz Rush** | `L` / `Shift` | `Right Bumper` / `Y` | `[X]` Button (Yellow) |
| **Frost Nova Special** | `I` | `Left Bumper` | `[Y]` Button (Purple) |
| **Pause / Start** | `Enter` / `Escape` | `Start` / `Options` | Touch Menu |

---

## 🚀 Running the Project

### In Godot Editor
1. Open the **Godot Engine (v4.3+)**.
2. Click **Import** and choose the `frost-fury/project.godot` file.
3. Press **F5** to run the game!

### In Antigravity IDE
The workspace `.vscode/settings.json` is configured with `godot-tools`. You can open any GDScript file or scene to view and edit code with full LSP integration.

---

## 📱 Publishing to Android & Steam

### Android Export
1. In Godot, go to **Project &rarr; Install Android Build Template**.
2. Configure **Project &rarr; Export &rarr; Add &rarr; Android**.
3. Set your keystore and package name (`com.nouh.frostfury`).
4. Export as `.apk` for direct testing or `.aab` for the Google Play Store.

### Steam Export
1. Add a **Windows Desktop** / **Linux** export preset in **Project &rarr; Export**.
2. Compatible with Steamworks via the **GodotSteam** GDExtension for achievements, cloud saves, and Steam Deck verification.
