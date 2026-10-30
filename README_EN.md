<p align="center">
  <img src="Images/logo.png" alt="Porta Logo" width="128" height="128" />
</p>

<h1 align="center">Porta</h1>

<p align="center">
  <strong>World of Warcraft In-Game Spotlight Navigation & Teleport Assistant</strong><br>
  <em>《魔兽世界》智能路线规划与快捷传送导航插件</em>
</p>

<p align="center">
  <a href="README.md">简体中文</a> | <a href="README_EN.md"><strong>English</strong></a>
</p>

<p align="center">
  <a href="https://www.curseforge.com/wow/addons/porta"><img src="Images/badge-curseforge.svg" alt="Download on CurseForge" /></a>
  <img src="Images/badge-wow-retail.svg" alt="WoW Retail" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License" />
</p>

---

## 🌟 Introduction

**Porta** is a high-performance in-game route planning and smart navigation addon crafted for *World of Warcraft*.

Much like macOS Spotlight or Raycast, typing `/porta` summons a centered, ultra-fast search bar. Simply type any dungeon, raid, or world map name (with multi-language fuzzy search support). Porta automatically scans your current location, faction, **inventory/equipped teleport items, toy box, class teleport spells, and all unlocked Mythic+ dungeon portals (Hero's Path)** to compute the fastest multi-hop route in milliseconds, guiding you with Blizzard's native golden super-tracking waypoint and a step-by-step HUD.

> 📦 **CurseForge Project Page**: [https://www.curseforge.com/wow/addons/porta](https://www.curseforge.com/wow/addons/porta)

---

## 🚀 Key Features

- 🔍 **Spotlight-Style Quick Search**: Fuzzy search with multi-keyword support. Click a result to start your journey.
- 🎒 **Teleport Asset Awareness**: Dynamically detects your items (e.g. Karabor Medallion, Kirin Tor rings, wormhole generators), usable toys, class spells, and seasonal Mythic+ Hero's Path portals.
- 🗺️ **Optimal Multi-Hop Graph Pathfinding**: Integrates major capital portal rooms (Dornogal, Stormwind, Orgrimmar, Dalaran, Valdrakken) and world transports (zeppelins, ships, Deeprun Tram, mole machines) to calculate the lowest-cost route.
- 🧭 **Blizzard Native SuperTrack & Step HUD**: Utilizes native SuperTrack APIs to place a 3D in-world golden beam and directional arrow, accompanied by a clean side HUD showing actionable steps and fallback routes.

---

## 🎮 How to Use

- Type `/porta` in the chat box to toggle the search dialog;
- You can also bind a shortcut key in the game's **Keybindings** menu;
- Type the destination name and click a result to start navigation.

---

## 📥 Installation

### Method 1: Via CurseForge App (Recommended)
Search for `Porta` in the **CurseForge App** or **WowUp** and click **Install** for one-click installation and automatic updates:
👉 [Visit CurseForge Page](https://www.curseforge.com/wow/addons/porta)

### Method 2: Manual Installation
1. Download the latest release from [CurseForge](https://www.curseforge.com/wow/addons/porta) or GitHub Releases;
2. Extract the archive and copy the `Porta` folder to your WoW AddOns directory:
   - **Retail**: `World of Warcraft/_retail_/Interface/AddOns/`
3. Restart the game or type `/reload` in-game to load the addon.
