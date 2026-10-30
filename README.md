<p align="center">
  <img src="Images/logo.png" alt="Porta Logo" width="128" height="128" />
</p>

<h1 align="center">Porta</h1>

<p align="center">
  <strong>《魔兽世界》智能路线规划与快捷传送导航插件</strong><br>
  <em>World of Warcraft In-Game Spotlight Navigation & Teleport Assistant</em>
</p>

<p align="center">
  <a href="README.md"><strong>简体中文</strong></a> | <a href="README_EN.md">English</a>
</p>

<p align="center">
  <a href="https://www.curseforge.com/wow/addons/porta"><img src="Images/badge-curseforge.svg" alt="Download on CurseForge" /></a>
  <img src="Images/badge-wow-retail.svg" alt="WoW Retail" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License" />
</p>

---

## 🌟 简介

**Porta** 是一款专为《魔兽世界》（World of Warcraft）打造的高性能路线规划与智能导航插件。

如同 macOS 的 Spotlight / Raycast 一样，输入 `/porta` 即可唤出居中极速搜索框，输入你想去的目标地下城、团本或世界地图（支持中英文地名模糊匹配，如输入「哀嚎」即可匹配「哀嚎洞穴」）。插件会自动结合你当前所在位置、阵营、**背包与玩具箱中的传送道具、职业传送技能以及历届史诗钥石限时传送门**，秒级计算最优路线，并在游戏内通过暴雪原生金色超追踪光标与分步指引带你前往目的地。

> 📦 **CurseForge 官方主页**：[https://www.curseforge.com/wow/addons/porta](https://www.curseforge.com/wow/addons/porta)

---

## 🚀 核心特性

- 🔍 **Spotlight 极速居中搜索**：支持拼音与中英文模糊检索、空格多词匹配，点击列表中的目标即可启程。
- 🎒 **全版本传送资产动态感知**：自动感知背包/装备道具（如卡拉波勋章、肯瑞托戒指、虫洞发生器等）、玩具箱、职业/种族技能、历代挑战模式与英雄之路大秘境直达传送门。
- 🗺️ **多源多跳最优图寻路算法**：融合各大主城传送网络（多恩诺嘉尔、暴风城、奥格瑞玛、达拉然等）与世界交通（飞艇、班船、深矿地铁等），计算代价最低的最优路线。
- 🧭 **暴雪现代原生超追踪与分步 HUD**：调用暴雪原生超追踪 API，在游戏视野中呈现金色光标指引，并在屏幕侧边提供分步交互卡片。

---

## 🎮 使用方法

- 在聊天框输入 `/porta` 打开搜索面板；
- 也可在系统【按键设置】中为 Porta 绑定一键唤出快捷键；
- 键入目标地名，点击列表中的目标开始导航。

---

## 📥 安装说明

### 方式一：通过 CurseForge 客户端（推荐）
在 **CurseForge App** 或 **WowUp** 中直接搜索 `Porta`，点击安装即可实现一键安装与自动更新：
👉 [访问 CurseForge 页面](https://www.curseforge.com/wow/addons/porta)

### 方式二：手动安装
1. 前往 [CurseForge](https://www.curseforge.com/wow/addons/porta) 或 GitHub Releases 下载最新版本的压缩包；
2. 将解压后的 `Porta` 文件夹放入魔兽世界的插件目录：
   - **Retail（正式服）**：`World of Warcraft/_retail_/Interface/AddOns/`
3. 重启游戏或在游戏内输入 `/reload` 即可加载。
