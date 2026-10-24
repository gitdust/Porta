local _, ns = ...
local L = ns.L

local PlayerTeleports = {}
ns.PlayerTeleports = PlayerTeleports

-- =========================================================================
-- 1. 常用传送玩具与物品定义表 (供跨地图寻路算法评估优先跳数使用)
--    名称通过暴雪客户端 API (C_Item / C_ToyBox) 动态获取当前客户端语言文本
-- =========================================================================
local TELEPORT_ITEMS = {
    -- 核心炉石系列
    {
        id = 140192,
        kind = "TOY_OR_ITEM",
        name = L["ITEM_NAME_140192"],
        toMap = 627, -- 军团再临达拉然
        x = 0.50, y = 0.50,
        faction = "NEUTRAL",
        priority = 10,
    },
    {
        id = 110560,
        kind = "TOY_OR_ITEM",
        name = L["ITEM_NAME_110560"],
        toMapHorde = 590, -- 霜壁要塞
        toMapAlliance = 582, -- 落月要塞
        x = 0.50, y = 0.50,
        faction = "NEUTRAL",
        priority = 8,
    },
    {
        id = 128353,
        kind = "ITEM",
        name = L["ITEM_NAME_128353"],
        toMapHorde = 590,
        toMapAlliance = 582,
        x = 0.50, y = 0.50,
        faction = "NEUTRAL",
        priority = 7,
    },

    -- 公会传送披风（直达主城传送大厅，自动附加目标主城名称区分）
    { id = 65360, kind = "ITEM", name = L["ITEM_NAME_65360"], toMap = 84, suffixMapID = 84, x = 0.49, y = 0.87, faction = "ALLIANCE", priority = 9 },
    { id = 65274, kind = "ITEM", name = L["ITEM_NAME_65274"], toMap = 85, suffixMapID = 85, x = 0.57, y = 0.89, faction = "HORDE", priority = 9 },
    { id = 63206, kind = "ITEM", name = L["ITEM_NAME_63206"], toMap = 84, suffixMapID = 84, x = 0.49, y = 0.87, faction = "ALLIANCE", priority = 9 },
    { id = 63352, kind = "ITEM", name = L["ITEM_NAME_63352"], toMap = 85, suffixMapID = 85, x = 0.57, y = 0.89, faction = "HORDE", priority = 9 },
    { id = 63207, kind = "ITEM", name = L["ITEM_NAME_63207"], toMap = 84, suffixMapID = 84, x = 0.49, y = 0.87, faction = "ALLIANCE", priority = 9 },
    { id = 63353, kind = "ITEM", name = L["ITEM_NAME_63353"], toMap = 85, suffixMapID = 85, x = 0.57, y = 0.89, faction = "HORDE", priority = 9 },

    -- 黑暗神殿专属传送
    {
        id = 151016,
        kind = "TOY",
        name = L["ITEM_NAME_151016"],
        toMap = 104, -- 外域影月谷
        x = 0.71, y = 0.46, -- 黑暗神殿大门前
        faction = "NEUTRAL",
        priority = 9,
        noteKey = "NOTE_NECROLYTE_SKULL",
    },
    {
        id = 32757,
        kind = "ITEM",
        name = L["ITEM_NAME_32757"],
        toMap = 104,
        x = 0.71, y = 0.46,
        faction = "NEUTRAL",
        priority = 9,
        noteKey = "NOTE_KARABOR_MEDALLION",
    },

    -- 永恒岛传送
    {
        id = 103678,
        kind = "ITEM",
        name = L["ITEM_NAME_103678"],
        toMap = 554, -- 潘达利亚永恒岛
        suffixMapID = 554,
        x = 0.65, y = 0.75,
        faction = "NEUTRAL",
        priority = 8,
        noteKey = "NOTE_TIMELOST_ARTIFACT",
    },

    -- 肯瑞托紫罗兰印戒 (卡拉赞)
    {
        id = 142469,
        kind = "ITEM",
        name = L["ITEM_NAME_142469"],
        toMap = 42, -- 逆风小径
        suffixInstanceID = 745, -- 卡拉赞
        x = 0.47, y = 0.74, -- 卡拉赞正门
        faction = "NEUTRAL",
        priority = 8,
    },

    -- 烈酒的遥控器 (黑石深渊黑铁酒吧 / 熔火之心 / 黑石山)
    {
        id = 37863,
        kind = "ITEM",
        name = L["ITEM_NAME_37863"],
        toMap = 33, -- 燃烧平原/黑石山
        suffixInstanceID = 228, -- 黑石深渊
        x = 0.45, y = 0.50,
        faction = "NEUTRAL",
        priority = 8,
        noteKey = "NOTE_DIREBREW_REMOTE_MC",
    },

    -- 达拉然肯瑞托戒指系列 (诺森德达拉然)
    {
        ids = {
            40586, 40585, 44934, 44935, 45688, 45689, 45690, 45691,
            48954, 48955, 48956, 48957, 51557, 51558, 51559, 51560
        },
        kind = "ITEM",
        name = L["ITEM_NAME_40586"],
        toMap = 125,
        suffixMapID = 113, -- 诺森德
        x = 0.50, y = 0.50,
        faction = "NEUTRAL",
        priority = 8,
    },
    -- 强化肯瑞托徽记 (军团再临达拉然)
    {
        id = 139599,
        kind = "ITEM",
        name = L["ITEM_NAME_139599"],
        toMap = 627,
        suffixMapID = 619, -- 破碎群岛
        x = 0.50, y = 0.50,
        faction = "NEUTRAL",
        priority = 8,
    },

    -- 搏击俱乐部拳手戒指
    { id = 144369, kind = "ITEM", name = L["ITEM_NAME_144369"], toMap = 84, suffixMapID = 84, x = 0.50, y = 0.35, faction = "ALLIANCE", priority = 7 },
    { id = 144370, kind = "ITEM", name = L["ITEM_NAME_144370"], toMap = 85, suffixMapID = 85, x = 0.42, y = 0.70, faction = "HORDE", priority = 7 },

    -- 特殊传送战袍与项坠
    { id = 52251, kind = "ITEM", name = L["ITEM_NAME_52251"], toMap = 125, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 7 },
    { id = 46874, kind = "ITEM", name = L["ITEM_NAME_46874"], toMap = 118, x = 0.69, y = 0.23, faction = "NEUTRAL", priority = 7, noteKey = "NOTE_ARGENT_TABARD_ICC" },
    { id = 92510, kind = "ITEM", name = L["ITEM_NAME_92510"], toMap = 1, x = 0.55, y = 0.74, faction = "HORDE", priority = 6, noteKey = "NOTE_VOLJIN_RING" },
    { id = 63378, kind = "ITEM", name = L["ITEM_NAME_63378"], toMap = 244, x = 0.50, y = 0.50, faction = "ALLIANCE", priority = 7 },
    { id = 63379, kind = "ITEM", name = L["ITEM_NAME_63379"], toMap = 245, x = 0.50, y = 0.50, faction = "HORDE", priority = 7 },

    -- 工程学虫洞发生器全集 (玩具 - 落点随机或需菜单选择，仅在前往对应大洲时作为补充备选方案提供)
    { id = 248485, kind = "TOY", name = L["ITEM_NAME_248485"], toMap = 2537, continentID = 2537, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 6, isWormhole = true, wormholeMode = "RANDOM", requiresEngineering = true },
    { id = 221966, kind = "TOY", name = L["ITEM_NAME_221966"], toMap = 2274, continentID = 2274, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 6, isWormhole = true, wormholeMode = "MENU", requiresEngineering = true },
    { id = 198156, kind = "TOY", name = L["ITEM_NAME_198156"], toMap = 1978, continentID = 1978, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 6, isWormhole = true, wormholeMode = "MENU", requiresEngineering = true },
    { id = 172924, kind = "TOY", name = L["ITEM_NAME_172924"], toMap = 1670, continentID = 1550, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 6, isWormhole = true, wormholeMode = "MENU", requiresEngineering = true },
    { id = 168807, kind = "TOY", name = L["ITEM_NAME_168807"], toMap = 876, continentID = 876, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 5, isWormhole = true, wormholeMode = "RANDOM", requiresEngineering = true },
    { id = 168808, kind = "TOY", name = L["ITEM_NAME_168808"], toMap = 875, continentID = 875, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 5, isWormhole = true, wormholeMode = "RANDOM", requiresEngineering = true },
    { id = 151652, kind = "TOY", name = L["ITEM_NAME_151652"], toMap = 905, continentID = 905, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 5, isWormhole = true, wormholeMode = "RANDOM", requiresEngineering = true },
    { id = 112059, kind = "TOY", name = L["ITEM_NAME_112059"], toMap = 572, continentID = 572, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 6, isWormhole = true, wormholeMode = "MENU", requiresEngineering = true },
    { id = 87215, kind = "TOY", name = L["ITEM_NAME_87215"], toMap = 424, continentID = 424, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 5, isWormhole = true, wormholeMode = "RANDOM", requiresEngineering = true },
    { id = 48933, kind = "TOY", name = L["ITEM_NAME_48933"], toMap = 113, continentID = 113, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 6, isWormhole = true, wormholeMode = "MENU", requiresEngineering = true },

    -- 工程学经典定点传送器 (空间撕裂器 / 安全传送器 - 落点固定，纳入常规路线评估，不满足专业或未拥有时提示)
    { id = 18984, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_18984"], toMap = 83, continentID = 12, x = 0.61, y = 0.38, faction = "NEUTRAL", priority = 8, requiresEngineering = true, noteKey = "NOTE_EVERLOOK_RIPPER" },
    { id = 18986, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_18986"], toMap = 71, continentID = 12, x = 0.52, y = 0.28, faction = "NEUTRAL", priority = 8, requiresEngineering = true, noteKey = "NOTE_GADGETZAN_TRANSPORTER" },
    { id = 30542, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_30542"], toMap = 109, continentID = 101, x = 0.33, y = 0.64, faction = "NEUTRAL", priority = 8, requiresEngineering = true, noteKey = "NOTE_AREA52_RIPPER" },
    { id = 30544, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_30544"], toMap = 105, continentID = 101, x = 0.60, y = 0.69, faction = "NEUTRAL", priority = 8, requiresEngineering = true, noteKey = "NOTE_TOSHLEY_TRANSPORTER" },

    -- 常用传送药水与消耗品道具
    {
        id = 58487,
        kind = "ITEM",
        name = L["ITEM_NAME_58487"],
        toMap = 207, -- 深岩之洲：大地神殿 (神殿内常驻暴风城与奥格瑞玛传送门)
        x = 0.49, y = 0.52,
        faction = "NEUTRAL",
        priority = 8,
        noteKey = "NOTE_POTION_OF_DEEPHOLM",
    },
    {
        id = 200613,
        kind = "ITEM",
        name = L["ITEM_NAME_200613"],
        toMap = 2023, -- 欧恩哈拉平原：艾拉格半人马营地
        x = 0.60, y = 0.40,
        faction = "NEUTRAL",
        priority = 7,
        noteKey = "NOTE_AYLAAG_WINDSTONE",
    },
    {
        id = 167075,
        kind = "ITEM",
        name = L["ITEM_NAME_167075"],
        toMap = 1462, -- 麦卡贡岛：锈栓镇
        x = 0.73, y = 0.35,
        faction = "NEUTRAL",
        priority = 8,
        requiresEngineering = true,
        noteKey = "NOTE_MECHAGON_TRANSPORTER",
    },
    {
        id = 139590,
        kind = "ITEM",
        name = L["ITEM_NAME_139590"],
        toMap = 25, -- 希尔斯布莱德丘陵：拉文霍德庄园
        x = 0.75, y = 0.24,
        faction = "NEUTRAL",
        class = "ROGUE",
        priority = 7,
        noteKey = "NOTE_RAVENHOLDT_SCROLL",
    },
    {
        id = 202046,
        kind = "TOY_OR_ITEM",
        name = L["ITEM_NAME_202046"],
        toMap = 942, -- 斯托颂谷地：探索者高地
        continentID = 876,
        x = 0.60, y = 0.69,
        faction = "NEUTRAL",
        priority = 8,
        noteKey = "NOTE_TORTALLAN_CHARM",
    },
}

-- =========================================================================
-- 2. 职业传送技能定义表 (技能名称通过 C_Spell API 动态获取当前客户端语言)
-- =========================================================================
local CLASS_TELEPORT_SPELLS = {
    -- 德鲁伊：梦境行者 (直达翡翠梦境之道，连通海加尔/暮色/灰谷/菲拉斯等)
    { id = 193753, class = "DRUID", name = "Dreamwalk", toMap = 715, x = 0.50, y = 0.50, priority = 10 },
    { id = 18960, class = "DRUID", name = "Teleport: Moonglade", toMap = 80, x = 0.56, y = 0.30, priority = 8 },

    -- 死亡骑士：黑锋之门 (阿彻鲁斯黑锋要塞)
    { id = 50977, class = "DEATHKNIGHT", name = "Death Gate", toMap = 647, x = 0.50, y = 0.50, priority = 10 },

    -- 武僧：禅宗朝圣 (晴日峰 / 迷踪岛)
    { id = 126892, class = "MONK", name = "Zen Pilgrimage", toMap = 378, x = 0.50, y = 0.50, priority = 8 },

    -- 黑铁矮人种族特长：钻地机
    { id = 265225, class = "ALL", name = L["SPELL_NAME_265225"], toMap = 84, x = 0.50, y = 0.50, priority = 8 },

    -- 法师全套传送门与传送技能
    { id = 3567, class = "MAGE", name = "Teleport: Orgrimmar", toMap = 85, x = 0.57, y = 0.89, priority = 10 },
    { id = 3561, class = "MAGE", name = "Teleport: Stormwind", toMap = 84, x = 0.49, y = 0.87, priority = 10 },
    { id = 3562, class = "MAGE", name = "Teleport: Ironforge", toMap = 87, x = 0.50, y = 0.50, priority = 9 },
    { id = 3565, class = "MAGE", name = "Teleport: Darnassus", toMap = 89, x = 0.50, y = 0.50, priority = 9 },
    { id = 32271, class = "MAGE", name = "Teleport: Exodar", toMap = 103, x = 0.50, y = 0.50, priority = 9 },
    { id = 3563, class = "MAGE", name = "Teleport: Undercity", toMap = 90, x = 0.50, y = 0.50, priority = 9 },
    { id = 3566, class = "MAGE", name = "Teleport: Thunder Bluff", toMap = 88, x = 0.50, y = 0.50, priority = 9 },
    { id = 32272, class = "MAGE", name = "Teleport: Silvermoon", toMap = 110, x = 0.50, y = 0.50, priority = 9 },
    { id = 33690, class = "MAGE", name = "Teleport: Shattrath", toMap = 111, x = 0.50, y = 0.50, priority = 9 },
    { id = 35715, class = "MAGE", name = "Teleport: Shattrath", toMap = 111, x = 0.50, y = 0.50, priority = 9 },
    { id = 53140, class = "MAGE", name = "Teleport: Dalaran - Northrend", toMap = 125, x = 0.50, y = 0.50, priority = 9 },
    { id = 120145, class = "MAGE", name = "Ancient Teleport: Dalaran", toMap = 25, x = 0.55, y = 0.24, priority = 9 },
    { id = 49359, class = "MAGE", name = "Teleport: Theramore", toMap = 70, x = 0.67, y = 0.48, priority = 8 },
    { id = 49358, class = "MAGE", name = "Teleport: Stonard", toMap = 47, x = 0.47, y = 0.55, priority = 8 },
    { id = 88342, class = "MAGE", name = "Teleport: Tol Barad", toMap = 244, x = 0.50, y = 0.50, priority = 9 },
    { id = 88344, class = "MAGE", name = "Teleport: Tol Barad", toMap = 245, x = 0.50, y = 0.50, priority = 9 },
    { id = 132621, class = "MAGE", name = "Teleport: Vale of Eternal Blossoms", toMap = 390, x = 0.50, y = 0.50, priority = 9 },
    { id = 132627, class = "MAGE", name = "Teleport: Vale of Eternal Blossoms", toMap = 390, x = 0.50, y = 0.50, priority = 9 },
    { id = 176248, class = "MAGE", name = "Teleport: Stormshield", toMap = 622, x = 0.50, y = 0.50, priority = 9 },
    { id = 176242, class = "MAGE", name = "Teleport: Warspear", toMap = 624, x = 0.50, y = 0.50, priority = 9 },
    { id = 224869, class = "MAGE", name = "Teleport: Dalaran - Broken Isles", toMap = 627, x = 0.50, y = 0.50, priority = 10 },
    { id = 281403, class = "MAGE", name = "Teleport: Boralus", toMap = 1161, x = 0.50, y = 0.50, priority = 9 },
    { id = 281404, class = "MAGE", name = "Teleport: Dazar'alor", toMap = 1165, x = 0.50, y = 0.50, priority = 9 },
    { id = 344587, class = "MAGE", name = "Teleport: Oribos", toMap = 1670, x = 0.50, y = 0.50, priority = 10 },
    { id = 395277, class = "MAGE", name = "Teleport: Valdrakken", toMap = 2112, x = 0.50, y = 0.50, priority = 10 },
    { id = 446540, class = "MAGE", name = "Teleport: Dornogal", toMap = 2339, x = 0.50, y = 0.50, priority = 10 },
    { id = 1259190, class = "MAGE", name = "Teleport: Silvermoon City", toMap = 2393, x = 0.50, y = 0.50, priority = 10 },
}

-- =========================================================================
-- 3. 历届史诗钥石 (Hero's Path) 与挑战模式 (Challenge Mode) 副本/团本直达传送门
--    映射关系：[journalInstanceID] = spellID 或 { spellID1, spellID2, ... }
-- =========================================================================
local MYTHIC_PLUS_DUNGEON_SPELLS = {
    -- ---------------------------------------------------------------------
    -- 至暗之夜 (Midnight 12.0 / 12.1)
    -- ---------------------------------------------------------------------
    [1299] = 1254400, -- 风行者之塔 (Windrunner Spire)
    [1300] = 1254572, -- 魔导师平台 (Magisters' Terrace)
    [1315] = 1254559, -- 迈萨拉洞窟 (Maisara Caverns)
    [1316] = 1254563, -- 虚空焦点塞纳斯 (Nexus-Point Xenas)

    -- ---------------------------------------------------------------------
    -- 地心之战 (The War Within 11.0 / 11.1 / 11.2)
    -- ---------------------------------------------------------------------
    [1269] = 445269, -- 矶石宝库 (The Stonevault) - Path of the Corrupted Foundry
    [1270] = 445414, -- 破晨号 (The Dawnbreaker) - Path of the Arathi Flagship
    [1271] = 445417, -- 艾拉-卡拉，回响之城 (Ara-Kara, City of Echoes) - Path of the Ruined City
    [1210] = 445441, -- 暗焰裂隙 (Darkflame Cleft) - Path of the Warding Candles
    [1267] = 445444, -- 圣焰修道院 (Priory of the Sacred Flame) - Path of the Light's Reverence
    [1268] = 445443, -- 驭雷栖巢 (The Rookery) - Path of the Fallen Stormriders
    [1272] = 445440, -- 燧酿酒庄 (Cinderbrew Meadery) - Path of the Flaming Brewery
    [1274] = 445416, -- 千丝之城 (City of Threads) - Path of Nerubian Ascension
    [1296] = 1226482, -- 解放安德麦 (Liberation of Undermine) - Path of the Full House
    [1298] = 1216786, -- 水闸行动 (Operation: Floodgate) - Path of the Circuit Breaker
    [1302] = 1239155, -- 法力熔炉：欧米伽 (Manaforge Omega) - Path of the All-Devouring
    [1303] = 1237215, -- 生态圆顶阿尔达尼 (Eco-Dome Al'dani) - Path of the Eco-Dome

    -- ---------------------------------------------------------------------
    -- 巨龙时代 (Dragonflight)
    -- ---------------------------------------------------------------------
    [1202] = 393256, -- 红玉新生圣所 (Ruby Life Pools) - Path of the Clutch Defender
    [1198] = 393262, -- 诺库德阻击战 (The Nokhud Offensive) - Path of the Windswept Plains
    [1203] = 393279, -- 碧蓝魔馆 (The Azure Vault) - Path of Arcane Secrets
    [1201] = 393273, -- 艾杰斯亚学院 (Algeth'ar Academy) - Path of the Draconic Diploma
    [1196] = 393267, -- 蕨皮山谷 (Brackenhide Hollow) - Path of the Rotting Woods
    [1199] = 393276, -- 奈萨鲁斯 (Neltharus) - Path of the Obsidian Hoard
    [1204] = 393283, -- 注能大厅 (Halls of Infusion) - Path of the Titanic Reservoir
    [1197] = 393222, -- 奥达曼：提尔的遗产 (Uldaman: Legacy of Tyr) - Path of the Watcher's Legacy
    [1209] = 424197, -- 永恒黎明 (Dawn of the Infinite) - Path of Twisted Time
    [1200] = 432254, -- 化身巨龙牢窟 (Vault of the Incarnates) - Path of the Primal Prison
    [1208] = 432257, -- 亚贝鲁斯，焰影熔炉 (Aberrus) - Path of the Bitter Legacy
    [1207] = 432258, -- 阿梅达希尔，梦境之愿 (Amirdrassil) - Path of the Scorching Dream

    -- ---------------------------------------------------------------------
    -- 暗影国度 (Shadowlands)
    -- ---------------------------------------------------------------------
    [1182] = 354462, -- 通灵战潮 (The Necrotic Wake) - Path of the Courageous
    [1183] = 354463, -- 凋魂之殇 (Plaguefall) - Path of the Plagued
    [1184] = 354464, -- 塞兹仙林的迷雾 (Mists of Tirna Scithe) - Path of the Misty Forest
    [1185] = 354465, -- 赎罪大厅 (Halls of Atonement) - Path of the Sinful Soul
    [1186] = 354466, -- 晋升高塔 (Spires of Ascension) - Path of the Ascendant
    [1187] = 354467, -- 伤逝剧场 (Theater of Pain) - Path of the Undefeated
    [1188] = 354468, -- 彼界 (De Other Side) - Path of the Scheming Loa
    [1189] = 354469, -- 赤红深渊 (Sanguine Depths) - Path of the Stone Warden
    [1194] = 367416, -- 塔扎维什，帷纱集市 (Tazavesh) - Path of the Streetwise Merchant
    [1190] = 373190, -- 纳斯利亚堡 (Castle Nathria) - Path of the Sire
    [1193] = 373191, -- 统御圣所 (Sanctum of Domination) - Path of the Tormented Soul
    [1195] = 373192, -- 初诞者圣墓 (Sepulcher of the First Ones) - Path of the First Ones

    -- ---------------------------------------------------------------------
    -- 争霸艾泽拉斯 (Battle for Azeroth)
    -- ---------------------------------------------------------------------
    [968]  = 424187, -- 阿塔达萨 (Atal'Dazar) - Path of the Golden Tomb
    [1001] = 410071, -- 自由镇 (Freehold) - Path of the Freebooter
    [1012] = { 467553, 467555 }, -- 暴富矿区 (The MOTHERLODE!!)
    [1021] = 424167, -- 维克雷斯庄园 (Waycrest Manor) - Path of Heart's Bane
    [1022] = 410074, -- 地渊孢林 (The Underrot) - Path of Festering Rot
    [1023] = { 445418, 464256 }, -- 围攻伯拉勒斯 (Siege of Boralus)
    [1178] = 373274, -- 麦卡贡行动 (Operation: Mechagon) - Path of the Scrappy Prince

    -- ---------------------------------------------------------------------
    -- 军团再临 (Legion)
    -- ---------------------------------------------------------------------
    [721] = 393764, -- 英灵殿 (Halls of Valor) - Path of Proven Worth
    [740] = 424153, -- 黑鸦堡垒 (Black Rook Hold) - Path of Ancient Horrors
    [762] = 424163, -- 黑心林地 (Darkheart Thicket) - Path of the Nightmare Lord
    [767] = 410078, -- 奈萨里奥的巢穴 (Neltharion's Lair) - Path of the Earth-Warder
    [800] = 393766, -- 群星庭院 (Court of Stars) - Path of the Grand Magistrix
    [860] = 373262, -- 重返卡拉赞 (Return to Karazhan) - Path of the Fallen Guardian
    [945] = 1254551, -- 执政团之座 (Seat of the Triumvirate) - Path of Dark Dereliction

    -- ---------------------------------------------------------------------
    -- 德拉诺之王 (Warlords of Draenor 挑战模式黄金 / M+)
    -- ---------------------------------------------------------------------
    [385] = 159895, -- 血槌炉渣矿井 (Bloodmaul Slag Mines) - Path of the Bloodmaul
    [476] = 159898, -- 通天峰 (Skyreach) - Path of the Skies
    [536] = 159900, -- 恐轨车站 (Grimrail Depot) - Path of the Dark Rail
    [537] = 159899, -- 影月墓地 (Shadowmoon Burial Grounds) - Path of the Crescent Moon
    [547] = 159897, -- 奥金顿 (Auchindoun) - Path of the Vigilant
    [556] = 159901, -- 永茂林地 (The Everbloom) - Path of the Verdant
    [558] = 159896, -- 钢铁码头 (Iron Docks) - Path of the Iron Prow
    [559] = 159902, -- 黑石塔上层 (Upper Blackrock Spire) - Path of the Burning Mountain

    -- ---------------------------------------------------------------------
    -- 潘达利亚之谜 (Mists of Pandaria 挑战模式黄金 / M+)
    -- ---------------------------------------------------------------------
    [302] = 131205, -- 风暴烈酒酿造厂 (Stormstout Brewery) - Path of the Stout Brew
    [303] = 131225, -- 围攻残阳关 (Gate of the Setting Sun) - Path of the Setting Sun
    [311] = 131231, -- 血色大厅 (Scarlet Halls) - Path of the Scarlet Blade
    [312] = 131206, -- 影踪禅院 (Shado-Pan Monastery) - Path of the Shado-Pan
    [313] = 131204, -- 青玉寺 (Temple of the Jade Serpent) - Path of the Jade Serpent
    [316] = 131229, -- 血色修道院 (Scarlet Monastery) - Path of the Scarlet Mitre
    [321] = 131222, -- 魔古山宫殿 (Mogu'shan Palace) - Path of the Mogu King
    [324] = 131228, -- 围攻砮皂寺 (Siege of Niuzao Temple) - Path of the Black Ox
    [246] = 131232, -- 通灵学院 (Scholomance) - Path of the Necromancer

    -- ---------------------------------------------------------------------
    -- 经典旧世 / 大地的裂变 / 巫妖王之怒 (大秘境重做地下城)
    -- ---------------------------------------------------------------------
    [65]  = 424142, -- 潮汐王座 (Throne of the Tides) - Path of the Tidehunter
    [68]  = 410080, -- 旋云之巅 (The Vortex Pinnacle) - Path of Wind's Domain
    [71]  = 445424, -- 格瑞姆巴托 (Grim Batol) - Path of the Twilight Fortress
    [278] = 1254555, -- 萨隆矿坑 (Pit of Saron) - Path of Unyielding Blight
}

-- =========================================================================
-- 4. 副本/团队副本专属直达道具定义表 (按 journalInstanceID 匹配)
-- =========================================================================
local DIRECT_DESTINATION_ITEMS = {
    -- 黑暗神殿 (journalInstanceID = 751)
    [751] = {
        { id = 32757, kind = "ITEM", name = L["ITEM_NAME_32757"], faction = "NEUTRAL", noteKey = "NOTE_KARABOR_MEDALLION" },
        { id = 151016, kind = "TOY", name = L["ITEM_NAME_151016"], faction = "NEUTRAL", noteKey = "NOTE_NECROLYTE_SKULL" },
    },
    -- 重返卡拉赞 (860) 与 老卡拉赞 (745)
    [860] = {
        { id = 142469, kind = "ITEM", name = L["ITEM_NAME_142469"], faction = "NEUTRAL", noteKey = "NOTE_VIOLET_SEAL" },
    },
    [745] = {
        { id = 142469, kind = "ITEM", name = L["ITEM_NAME_142469"], faction = "NEUTRAL", noteKey = "NOTE_VIOLET_SEAL" },
    },
    -- 黑石深渊 (228) 及黑石山系列副本
    [228] = {
        { id = 37863, kind = "ITEM", name = L["ITEM_NAME_37863"], faction = "NEUTRAL", noteKey = "NOTE_DIREBREW_REMOTE_BRD" },
    },
    [741] = { -- 熔火之心
        { id = 37863, kind = "ITEM", name = L["ITEM_NAME_37863"], faction = "NEUTRAL", noteKey = "NOTE_DIREBREW_REMOTE_MC" },
    },
    -- 巴拉丁监狱 (75 - 托尔巴拉德)
    [75] = {
        { id = 63378, kind = "ITEM", name = L["ITEM_NAME_63378"], faction = "ALLIANCE", noteKey = "NOTE_TOL_BARAD_TABARD" },
        { id = 63379, kind = "ITEM", name = L["ITEM_NAME_63379"], faction = "HORDE", noteKey = "NOTE_TOL_BARAD_TABARD" },
    },
    -- 冰冠堡垒 (758) 与 十字军的试炼 (757)
    [758] = {
        { id = 46874, kind = "ITEM", name = L["ITEM_NAME_46874"], faction = "NEUTRAL", noteKey = "NOTE_ARGENT_TABARD_ICC" },
    },
    [757] = {
        { id = 46874, kind = "ITEM", name = L["ITEM_NAME_46874"], faction = "NEUTRAL", noteKey = "NOTE_ARGENT_TABARD_TOC" },
    },
    -- 巨石之核 (67 - 深岩之洲)
    [67] = {
        { id = 58487, kind = "ITEM", name = L["ITEM_NAME_58487"], faction = "NEUTRAL", noteKey = "NOTE_POTION_OF_DEEPHOLM" },
    },
    -- 麦卡贡行动 (1178)
    [1178] = {
        { id = 167075, kind = "ITEM", name = L["ITEM_NAME_167075"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_MECHAGON_TRANSPORTER" },
    },
    -- 诺库德阻击战 (1198 - 欧恩哈拉平原)
    [1198] = {
        { id = 200613, kind = "ITEM", name = L["ITEM_NAME_200613"], faction = "NEUTRAL", noteKey = "NOTE_AYLAAG_WINDSTONE" },
    },
    -- 祖尔法拉克 (241 - 塔纳利斯)
    [241] = {
        { id = 18986, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_18986"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_GADGETZAN_TRANSPORTER" },
    },
    -- 格鲁尔的巢穴 (746 - 刀锋山)
    [746] = {
        { id = 30544, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_30544"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_TOSHLEY_TRANSPORTER" },
    },
    -- 虚空风暴副本群 (254 禁魔监狱, 257 生态船, 258 能源舰, 749 风暴要塞)
    [254] = {
        { id = 30542, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_30542"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_AREA52_RIPPER" },
    },
    [257] = {
        { id = 30542, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_30542"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_AREA52_RIPPER" },
    },
    [258] = {
        { id = 30542, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_30542"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_AREA52_RIPPER" },
    },
    [749] = {
        { id = 30542, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_30542"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_AREA52_RIPPER" },
    },
    -- 风暴神殿 (1036 - 斯托颂谷地) 与 风暴熔炉 (1177)
    [1036] = {
        { id = 202046, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_202046"], faction = "NEUTRAL", noteKey = "NOTE_TORTALLAN_CHARM" },
    },
    [1177] = {
        { id = 202046, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_202046"], faction = "NEUTRAL", noteKey = "NOTE_TORTALLAN_CHARM" },
    },
}

-- =========================================================================
-- 5. 目标地图专属直达道具定义表 (按 mapID 匹配，如直接搜索永恒岛等地图)
-- =========================================================================
local DIRECT_MAP_ITEMS = {
    -- 永恒岛 (mapID = 554)
    [554] = {
        { id = 103678, kind = "ITEM", name = L["ITEM_NAME_103678"], faction = "NEUTRAL", noteKey = "NOTE_TIMELOST_ARTIFACT" },
    },
    -- 托尔巴拉德半岛 (244 联盟, 245 部落)
    [244] = {
        { id = 63378, kind = "ITEM", name = L["ITEM_NAME_63378"], faction = "ALLIANCE", noteKey = "NOTE_TOL_BARAD_TABARD" },
    },
    [245] = {
        { id = 63379, kind = "ITEM", name = L["ITEM_NAME_63379"], faction = "HORDE", noteKey = "NOTE_TOL_BARAD_TABARD" },
    },
    -- 深岩之洲 (mapID = 207)
    [207] = {
        { id = 58487, kind = "ITEM", name = L["ITEM_NAME_58487"], faction = "NEUTRAL", noteKey = "NOTE_POTION_OF_DEEPHOLM" },
    },
    -- 麦卡贡 (mapID = 1462)
    [1462] = {
        { id = 167075, kind = "ITEM", name = L["ITEM_NAME_167075"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_MECHAGON_TRANSPORTER" },
    },
    -- 欧恩哈拉平原 (mapID = 2023)
    [2023] = {
        { id = 200613, kind = "ITEM", name = L["ITEM_NAME_200613"], faction = "NEUTRAL", noteKey = "NOTE_AYLAAG_WINDSTONE" },
    },
    -- 希尔斯布莱德丘陵 (mapID = 25)
    [25] = {
        { id = 139590, kind = "ITEM", name = L["ITEM_NAME_139590"], faction = "NEUTRAL", class = "ROGUE", noteKey = "NOTE_RAVENHOLDT_SCROLL" },
    },
    -- 塔纳利斯 (mapID = 71)
    [71] = {
        { id = 18986, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_18986"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_GADGETZAN_TRANSPORTER" },
    },
    -- 冬泉谷 (mapID = 83)
    [83] = {
        { id = 18984, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_18984"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_EVERLOOK_RIPPER" },
    },
    -- 刀锋山 (mapID = 105)
    [105] = {
        { id = 30544, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_30544"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_TOSHLEY_TRANSPORTER" },
    },
    -- 虚空风暴 (mapID = 109)
    [109] = {
        { id = 30542, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_30542"], faction = "NEUTRAL", requiresEngineering = true, noteKey = "NOTE_AREA52_RIPPER" },
    },
    -- 斯托颂谷地 (mapID = 942)
    [942] = {
        { id = 202046, kind = "TOY_OR_ITEM", name = L["ITEM_NAME_202046"], faction = "NEUTRAL", noteKey = "NOTE_TORTALLAN_CHARM" },
    },
}

-- =========================================================================
-- 动态名称与说明获取工具 (基于暴雪原生 API 实时适配当前客户端语言)
-- =========================================================================
local function GetMapLocalizedName(mapID)
    if not mapID or mapID <= 0 then return nil end
    if C_Map and C_Map.GetMapInfo then
        local info = C_Map.GetMapInfo(mapID)
        if info and info.name and info.name ~= "" then
            return info.name
        end
    end
    return nil
end

local function GetInstanceLocalizedName(instanceID)
    if not instanceID or instanceID <= 0 then return nil end
    if EJ_GetInstanceInfo then
        local name = EJ_GetInstanceInfo(instanceID)
        if name and name ~= "" then
            return name
        end
    end
    return nil
end

-- 动态获取法术在当前客户端语言下的名称
function PlayerTeleports:GetSpellDisplayName(spellID, fallbackName)
    if not spellID then
        return fallbackName or L["UNKNOWN_NAME"]
    end
    if C_Spell and C_Spell.GetSpellName then
        local name = C_Spell.GetSpellName(spellID)
        if name and name ~= "" then
            return name
        end
    end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info and info.name and info.name ~= "" then
            return info.name
        end
    end
    local localeKey = "SPELL_NAME_" .. tostring(spellID)
    if rawget(L, localeKey) then
        return L[localeKey]
    end
    return fallbackName or string.format(L["SPELL_FALLBACK_FMT"], tostring(spellID))
end

-- 动态获取物品/玩具在当前客户端语言下的名称（同名披风/戒指等自动拼接目标地图/副本名区分）
function PlayerTeleports:GetItemDisplayName(itemID, fallbackName, suffixMapID, suffixInstanceID)
    if not itemID then
        return fallbackName or L["UNKNOWN_NAME"]
    end

    local baseName = nil

    if C_ToyBox and C_ToyBox.GetToyInfo then
        local _, toyName = C_ToyBox.GetToyInfo(itemID)
        if type(toyName) == "string" and toyName ~= "" then
            baseName = toyName
        end
    end

    if not baseName and C_Item and C_Item.GetItemNameByID then
        local itemName = C_Item.GetItemNameByID(itemID)
        if type(itemName) == "string" and itemName ~= "" then
            baseName = itemName
        end
    end

    if not baseName then
        if C_Item and C_Item.RequestLoadItemDataByID then
            pcall(C_Item.RequestLoadItemDataByID, itemID)
        end
        local localeKey = "ITEM_NAME_" .. tostring(itemID)
        baseName = rawget(L, localeKey) or fallbackName or string.format(L["ITEM_FALLBACK_FMT"], tostring(itemID))
    end

    local suffixName = nil
    if suffixMapID then
        suffixName = GetMapLocalizedName(suffixMapID)
    elseif suffixInstanceID then
        suffixName = GetInstanceLocalizedName(suffixInstanceID)
    end

    if suffixName and suffixName ~= "" and not string.find(baseName, suffixName, 1, true) then
        return string.format("%s (%s)", baseName, suffixName)
    end

    return baseName
end

-- 动态获取条目备注说明 (Note)
local function ResolveEntryNote(entry)
    if not entry then return nil end
    if entry.isWormhole then
        local contName = GetMapLocalizedName(entry.continentID or entry.toMap) or string.format(L["MAP_FALLBACK_FMT"], tostring(entry.continentID or entry.toMap or 0))
        if entry.wormholeMode == "MENU" then
            return string.format(L["NOTE_WORMHOLE_MENU_FMT"], contName)
        else
            return string.format(L["NOTE_WORMHOLE_RANDOM_FMT"], contName)
        end
    end
    if entry.noteKey and L[entry.noteKey] then
        return L[entry.noteKey]
    end
    return entry.note
end

-- 登录时预热所有传送物品、玩具、技能的客户端本地化名称缓存
function PlayerTeleports:PreloadCache()
    local function requestItem(id)
        if id and C_Item and C_Item.RequestLoadItemDataByID then
            pcall(C_Item.RequestLoadItemDataByID, id)
        end
    end
    local function requestSpell(id)
        if id and C_Spell and C_Spell.RequestLoadSpellData then
            pcall(C_Spell.RequestLoadSpellData, id)
        end
    end

    requestItem(129929) -- 百变之镜 (玩具)
    for _, item in ipairs(TELEPORT_ITEMS) do
        if item.id then requestItem(item.id) end
        if item.ids then
            for _, cid in ipairs(item.ids) do
                requestItem(cid)
            end
        end
    end
    for _, list in pairs(DIRECT_DESTINATION_ITEMS) do
        for _, item in ipairs(list) do
            requestItem(item.id)
        end
    end
    for _, list in pairs(DIRECT_MAP_ITEMS) do
        for _, item in ipairs(list) do
            requestItem(item.id)
        end
    end
    for _, spell in ipairs(CLASS_TELEPORT_SPELLS) do
        requestSpell(spell.id)
    end
    for _, entry in pairs(MYTHIC_PLUS_DUNGEON_SPELLS) do
        if type(entry) == "table" then
            for _, sid in ipairs(entry) do requestSpell(sid) end
        else
            requestSpell(entry)
        end
    end
end

-- =========================================================================
-- 辅助判断函数
-- =========================================================================
local function GetBagItemCount(itemID)
    if not itemID then return 0 end
    if C_Item and C_Item.GetItemCount then
        return C_Item.GetItemCount(itemID, false) or 0
    end
    return 0
end

local function GetTotalItemCountWithBank(itemID)
    if not itemID then return 0 end
    if C_Item and C_Item.GetItemCount then
        -- includeBank, includeUses, includeReagentBank, includeAccountBank (战团银行)
        return C_Item.GetItemCount(itemID, true, false, true, true) or 0
    end
    return 0
end

local function HasItem(itemID)
    return GetBagItemCount(itemID) > 0
end

local function IsItemInBank(itemID)
    local bagCount = GetBagItemCount(itemID)
    local totalCount = GetTotalItemCountWithBank(itemID)
    return (bagCount == 0) and (totalCount > 0)
end

local function HasToyCollected(toyID)
    if not toyID then return false end
    if PlayerHasToy and PlayerHasToy(toyID) then
        return true
    end
    return false
end

-- 检查法术是否习得 (优先采用 11.0 / 12.1 现代法术书 API，精准识别账号钥石直达门)
local function IsSpellKnown(spellID)
    if not spellID then return false end
    if C_SpellBook and C_SpellBook.IsSpellKnown then
        if C_SpellBook.IsSpellKnown(spellID) then
            return true
        end
    end
    -- 含覆盖法术 (includeOverrides)，替代已弃用的 IsSpellKnownOrOverridesKnown / IsPlayerSpell
    if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
        if C_SpellBook.IsSpellInSpellBook(spellID, Enum.SpellBookSpellBank.Player, true) then
            return true
        end
    end
    return false
end

local ENGINEERING_REQ_MAP = {}
for _, item in ipairs(TELEPORT_ITEMS) do
    if item.requiresEngineering then
        if item.id then
            ENGINEERING_REQ_MAP[item.id] = item
        end
        if item.ids then
            for _, cid in ipairs(item.ids) do
                ENGINEERING_REQ_MAP[cid] = item
            end
        end
    end
end

-- 检查当前角色是否学习了工程学专业 (以专业技能线 ID 202 为唯一依据，与客户端语言无关)
local ENGINEERING_SKILL_LINE = 202

local function HasEngineeringProfession()
    if not GetProfessions or not GetProfessionInfo then
        return false
    end
    local prof1, prof2 = GetProfessions()
    for _, idx in ipairs({ prof1, prof2 }) do
        if idx then
            local skillLine = select(7, GetProfessionInfo(idx))
            if skillLine == ENGINEERING_SKILL_LINE then
                return true
            end
        end
    end
    return false
end

PlayerTeleports.HasEngineeringProfession = HasEngineeringProfession

local function IsToyUsableByPlayer(toyID)
    if not toyID then return false end
    -- 若为工程学专属玩具且当前角色已学习工程学，直接视为可用（避免客户端刚登录或玩具箱未打开时 C_ToyBox.IsToyUsable 误返回 false/nil）
    if ENGINEERING_REQ_MAP[toyID] and HasEngineeringProfession() then
        return true
    end
    if C_ToyBox and C_ToyBox.IsToyUsable then
        local isUsable = C_ToyBox.IsToyUsable(toyID)
        if isUsable ~= nil then
            return isUsable
        end
    end
    return true
end

-- 供外部（如 HUD 点击/悬停时）实时检测某玩具、物品或技能当前是否拥有/可用
function PlayerTeleports:CheckTeleportOwnership(kind, id, displayName)
    if not id then return false, L["ERR_UNKNOWN_TELEPORT_ID"] end
    local uKind = string.upper(tostring(kind or "ITEM"))
    local resolvedName = displayName
    if not resolvedName or resolvedName == "" then
        if uKind == "SPELL" then
            resolvedName = self:GetSpellDisplayName(id)
        else
            resolvedName = self:GetItemDisplayName(id)
        end
    end
    local label = ns.FormatBracket(resolvedName or ("#" .. tostring(id)))
    local reqEng = (ENGINEERING_REQ_MAP[id] ~= nil)
    local hasEng = (not reqEng) or HasEngineeringProfession()

    local _, playerClass = UnitClass("player")
    if id == 139590 and playerClass ~= "ROGUE" then
        return false, string.format(L["REASON_ROGUE_ONLY_FMT"], label)
    end

    if uKind == "SPELL" then
        if IsSpellKnown(id) then
            return true, nil
        end
        return false, string.format(L["REASON_SPELL_NOT_KNOWN_FMT"], label)
    elseif uKind == "TOY" then
        if HasToyCollected(id) then
            if reqEng and not hasEng then
                return false, string.format(L["REASON_TOY_NO_ENG_FMT"], label)
            end
            if not IsToyUsableByPlayer(id) then
                return false, string.format(L["REASON_TOY_UNUSABLE_FMT"], label)
            end
            return true, nil
        elseif HasItem(id) then
            if reqEng and not hasEng then
                return false, string.format(L["REASON_ITEM_NO_ENG_FMT"], label)
            end
            return true, nil
        end
        if reqEng and not hasEng then
            return false, string.format(L["REASON_TOY_MISSING_ENG_FMT"], label)
        end
        return false, string.format(L["REASON_TOY_MISSING_FMT"], label)
    else
        local ownedInBag = HasItem(id)
        local ownedAsToy = HasToyCollected(id)
        if ownedInBag or ownedAsToy then
            if reqEng and not hasEng then
                return false, string.format(L["REASON_ITEM_NO_ENG_FMT"], label)
            end
            if ownedAsToy and not ownedInBag and not IsToyUsableByPlayer(id) then
                return false, string.format(L["REASON_TOY_UNUSABLE_FMT"], label)
            end
            return true, nil
        elseif IsItemInBank(id) then
            if reqEng and not hasEng then
                return false, string.format(L["REASON_BANK_NO_ENG_FMT"], label)
            end
            return false, string.format(L["REASON_BANK_FMT"], label)
        end
        if reqEng and not hasEng then
            return false, string.format(L["REASON_ITEM_MISSING_ENG_FMT"], label)
        end
        return false, string.format(L["REASON_ITEM_MISSING_FMT"], label)
    end
end

-- 检查物品/玩具条目状态（不因未拥有或专业不符而丢弃，返回详细状态以供方案生成时提示）
local function InspectItemOrToyEntry(entry)
    local candidateIDs = entry.ids or { entry.id }
    local matchedID = candidateIDs[1]
    local actualKind = (entry.kind == "TOY" or entry.kind == "TOY_OR_ITEM") and "TOY" or "ITEM"
    local isOwned = false
    local inBank = false
    local isToyUnusable = false

    for _, id in ipairs(candidateIDs) do
        if entry.kind == "TOY" then
            if HasToyCollected(id) then
                matchedID = id
                actualKind = "TOY"
                isOwned = true
                if not IsToyUsableByPlayer(id) then
                    isToyUnusable = true
                else
                    isToyUnusable = false
                    break
                end
            end
        elseif entry.kind == "ITEM" then
            if HasItem(id) then
                matchedID = id
                actualKind = "ITEM"
                isOwned = true
                break
            elseif IsItemInBank(id) then
                matchedID = id
                inBank = true
            end
        else -- TOY_OR_ITEM
            if HasToyCollected(id) then
                matchedID = id
                actualKind = "TOY"
                isOwned = true
                if not IsToyUsableByPlayer(id) then
                    isToyUnusable = true
                else
                    isToyUnusable = false
                    break
                end
            elseif HasItem(id) then
                matchedID = id
                actualKind = "ITEM"
                isOwned = true
                break
            elseif IsItemInBank(id) then
                matchedID = id
                actualKind = "ITEM"
                inBank = true
            end
        end
    end

    local resolvedName = PlayerTeleports:GetItemDisplayName(matchedID, entry.name, entry.suffixMapID, entry.suffixInstanceID)
    local label = ns.FormatBracket(resolvedName)

    local reqEng = entry.requiresEngineering and true or false
    local hasEng = (not reqEng) or HasEngineeringProfession()

    local _, playerClass = UnitClass("player")
    local reqClass = entry.class
    local isClassMatched = (not reqClass) or (reqClass == playerClass)
    local hasIt = isOwned and hasEng and isClassMatched and (not isToyUnusable)

    local missingReason = nil
    local missingShortTag = nil
    if not hasIt then
        if not isClassMatched then
            missingShortTag = L["TAG_ROGUE_ONLY"] or L["TAG_UNUSABLE"]
            missingReason = string.format(L["REASON_ROGUE_ONLY_FMT"], label)
        elseif reqEng and not hasEng then
            missingShortTag = L["TAG_REQ_ENG"]
            missingReason = string.format(actualKind == "TOY" and L["REASON_TOY_NO_ENG_FMT"] or L["REASON_ITEM_NO_ENG_FMT"], label)
        elseif isToyUnusable then
            missingShortTag = L["TAG_UNUSABLE"]
            missingReason = string.format(L["REASON_TOY_UNUSABLE_FMT"], label)
        elseif inBank then
            missingShortTag = L["TAG_IN_BANK"]
            missingReason = string.format(L["REASON_BANK_FMT"], label)
        else
            missingShortTag = L["TAG_MISSING"]
            missingReason = string.format(actualKind == "TOY" and L["REASON_TOY_MISSING_FMT"] or L["REASON_ITEM_MISSING_FMT"], label)
        end
    end

    return {
        hasItem = hasIt,
        isOwned = isOwned,
        id = matchedID,
        name = resolvedName,
        note = ResolveEntryNote(entry),
        kind = actualKind,
        inBank = inBank,
        isToyUnusable = isToyUnusable,
        missingEngineering = (reqEng and not hasEng),
        missingShortTag = missingShortTag,
        missingReason = missingReason,
    }
end

-- =========================================================================
-- 核心检测接口 1：获取所有通用传送手段（供 Dijkstra/BFS 寻路）
-- 规则：玩具与物品不因玩家未拥有或未学专业而过滤，默认纳入算路；若实际未拥有或不满足条件则在方案中提示
-- =========================================================================
function PlayerTeleports:GetAvailableTeleports()
    local available = {}
    local playerFaction = ns.GetPlayerFaction()
    local _, playerClass = UnitClass("player")

    -- 1. 扫描传送物品与玩具（全部纳入候选，记录真实拥有与专业条件状态，并动态获取客户端本地化名称）
    for _, item in ipairs(TELEPORT_ITEMS) do
        local classMatch = (not item.class) or (item.class == playerClass)
        local toMap = item.toMap
        if item.toMapHorde and item.toMapAlliance then
            toMap = (playerFaction == "HORDE") and item.toMapHorde or item.toMapAlliance
        end
        if toMap and classMatch and (item.faction == "NEUTRAL" or item.faction == playerFaction) then
            local state = InspectItemOrToyEntry(item)

            table.insert(available, {
                type = state.kind, -- "TOY" 或 "ITEM"
                id = state.id,
                name = state.name,
                toMap = toMap,
                x = item.x or 0.50,
                y = item.y or 0.50,
                priority = item.priority or 5,
                hasItem = state.hasItem,
                isOwned = state.isOwned,
                inBank = state.inBank,
                isToyUnusable = state.isToyUnusable,
                missingEngineering = state.missingEngineering,
                missingShortTag = state.missingShortTag,
                missingReason = state.missingReason,
                note = state.note,
                isWormhole = item.isWormhole or false,
                continentID = item.continentID,
                wormholeMode = item.wormholeMode,
                requiresEngineering = item.requiresEngineering or false,
            })
        end
    end

    -- 2. 扫描职业专属法术与种族特长（通过 C_Spell 动态获取当前客户端语言名称）
    for _, spell in ipairs(CLASS_TELEPORT_SPELLS) do
        local classMatch = (spell.class == "ALL") or (spell.class == playerClass)
        if classMatch and IsSpellKnown(spell.id) then
            local spellName = self:GetSpellDisplayName(spell.id, spell.name)
            table.insert(available, {
                type = "SPELL",
                id = spell.id,
                name = spellName,
                toMap = spell.toMap,
                x = spell.x or 0.50,
                y = spell.y or 0.50,
                priority = spell.priority or 5,
                hasItem = true,
            })
        end
    end

    return available
end

-- =========================================================================
-- 核心检测接口 2：获取特定目的地的所有直达传送手段列表
-- 包含：史诗大秘境英雄之路门、团本门、专属直达玩具/道具（不管玩家是否拥有玩具/物品，均生成并在缺失时提示）
-- =========================================================================
function PlayerTeleports:GetDirectDestinationTeleports(destination)
    if not destination then return {} end
    local results = {}
    local playerFaction = ns.GetPlayerFaction()
    local _, playerClass = UnitClass("player")

    -- 1. 检测【大秘境 / 挑战模式 / 团队副本英雄之路传送门】
    if destination.id and destination.id > 0 then
        local entry = MYTHIC_PLUS_DUNGEON_SPELLS[destination.id]
        if entry then
            local candidateSpells = (type(entry) == "table") and entry or { entry }
            for _, spellID in ipairs(candidateSpells) do
                if IsSpellKnown(spellID) then
                    local fallbackSpellName = string.format(
                        L["TELEPORT_FALLBACK_FMT"],
                        destination.name or string.format(L["INSTANCE_FALLBACK_FMT"], tostring(destination.id))
                    )
                    local spellName = self:GetSpellDisplayName(spellID, fallbackSpellName)

                    table.insert(results, {
                        type = "SPELL",
                        id = spellID,
                        name = spellName,
                        hasItem = true,
                    })
                    break
                end
            end
        end
    end

    -- 2. 检测【副本专属直达道具/玩具】（不因未拥有而过滤，记录未拥有提示）
    if destination.id and destination.id > 0 and DIRECT_DESTINATION_ITEMS[destination.id] then
        for _, itemEntry in ipairs(DIRECT_DESTINATION_ITEMS[destination.id]) do
            local classMatch = (not itemEntry.class) or (itemEntry.class == playerClass)
            if classMatch and (itemEntry.faction == "NEUTRAL" or itemEntry.faction == playerFaction) then
                local state = InspectItemOrToyEntry(itemEntry)
                table.insert(results, {
                    type = state.kind, -- "TOY" 或 "ITEM"
                    id = state.id,
                    name = state.name,
                    note = state.note,
                    hasItem = state.hasItem,
                    isOwned = state.isOwned,
                    inBank = state.inBank,
                    isToyUnusable = state.isToyUnusable,
                    missingEngineering = state.missingEngineering,
                    missingShortTag = state.missingShortTag,
                    missingReason = state.missingReason,
                    requiresEngineering = itemEntry.requiresEngineering or false,
                })
            end
        end
    end

    -- 3. 检测【目标区域专属直达道具/玩具】（如永恒岛 554、托尔巴拉德 244/245 等）
    if destination.mapID and DIRECT_MAP_ITEMS[destination.mapID] then
        for _, itemEntry in ipairs(DIRECT_MAP_ITEMS[destination.mapID]) do
            local classMatch = (not itemEntry.class) or (itemEntry.class == playerClass)
            if classMatch and (itemEntry.faction == "NEUTRAL" or itemEntry.faction == playerFaction) then
                local state = InspectItemOrToyEntry(itemEntry)
                table.insert(results, {
                    type = state.kind, -- "TOY" 或 "ITEM"
                    id = state.id,
                    name = state.name,
                    note = state.note,
                    hasItem = state.hasItem,
                    isOwned = state.isOwned,
                    inBank = state.inBank,
                    isToyUnusable = state.isToyUnusable,
                    missingEngineering = state.missingEngineering,
                    missingShortTag = state.missingShortTag,
                    missingReason = state.missingReason,
                    requiresEngineering = itemEntry.requiresEngineering or false,
                })
            end
        end
    end

    -- 已拥有的排前面
    table.sort(results, function(a, b)
        if (a.hasItem and true or false) ~= (b.hasItem and true or false) then
            return a.hasItem and true or false
        end
        return (a.id or 0) < (b.id or 0)
    end)

    return results
end

function PlayerTeleports:GetDirectDestinationTeleport(destination)
    local list = self:GetDirectDestinationTeleports(destination)
    return list[1]
end

-- =========================================================================
-- 6. 德拉诺之王要塞建筑状态感知（法师之塔 / 灵魂之塔）
-- =========================================================================
local cachedMageTowerInfo = nil

function PlayerTeleports:InvalidateGarrisonCache()
    cachedMageTowerInfo = nil
end

function PlayerTeleports:GetGarrisonMageTowerInfo()
    if cachedMageTowerInfo ~= nil then
        return cachedMageTowerInfo.hasBuilding, cachedMageTowerInfo.rank, cachedMageTowerInfo.buildingName, cachedMageTowerInfo.buildingID
    end

    cachedMageTowerInfo = {
        hasBuilding = false,
        rank = 0,
        buildingName = nil,
        buildingID = nil,
    }

    if not C_Garrison or not C_Garrison.GetBuildings then
        return false, 0, nil, nil
    end

    local garrisonType = (Enum and Enum.GarrisonType and Enum.GarrisonType.Type_6_0_Garrison) or 2
    local ok, buildings = pcall(C_Garrison.GetBuildings, garrisonType)
    if not ok or not buildings or type(buildings) ~= "table" then
        return false, 0, nil, nil
    end

    for _, b in ipairs(buildings) do
        local bID = b.buildingID
        if bID then
            local infoOk, _, name, textureKit = pcall(C_Garrison.GetBuildingInfo, bID)
            local bName = infoOk and tostring(name or "") or ""
            local bNameLower = string.lower(bName)
            local texLower = infoOk and string.lower(tostring(textureKit or "")) or ""
            local rank = b.rank or 1

            -- 联盟法师之塔 (Mage Tower)：ID 37, 38, 39
            -- 部落灵魂之塔 (Spirit Lodge)：ID 103, 104, 105
            -- 增加多维度安全检测 (ID + 贴图路径 + 建筑名称)
            local isMageTower = (bID == 37 or bID == 38 or bID == 39)
                or (bID == 103 or bID == 104 or bID == 105)
                or string.find(texLower, "magetower")
                or string.find(texLower, "spiritlodge")
                or string.find(bNameLower, "mage tower")
                or string.find(bNameLower, "spirit lodge")
                or string.find(bNameLower, "法师之塔")
                or string.find(bNameLower, "灵魂之塔")
                or string.find(bNameLower, "靈魂之塔")
                or string.find(bNameLower, "灵魂之阁")
                or string.find(bNameLower, "靈魂之閣")

            if isMageTower then
                cachedMageTowerInfo.hasBuilding = true
                cachedMageTowerInfo.rank = rank
                cachedMageTowerInfo.buildingName = (bName ~= "") and bName or L["BUILDING_MAGE_TOWER"]
                cachedMageTowerInfo.buildingID = bID
                break
            end
        end
    end

    return cachedMageTowerInfo.hasBuilding, cachedMageTowerInfo.rank, cachedMageTowerInfo.buildingName, cachedMageTowerInfo.buildingID
end

-- 兼容老接口
function PlayerTeleports:GetDirectDungeonPortal(journalInstanceID)
    if not journalInstanceID then return nil end
    return self:GetDirectDestinationTeleport({ id = journalInstanceID })
end

-- =========================================================================
-- 7. 时空漫游玩具：百变之镜 (Ever-Shifting Mirror, ID: 129929) 状态感知
-- =========================================================================
function PlayerTeleports:GetMirrorToyInfo()
    local toyID = 129929
    local toyName = self:GetItemDisplayName(toyID, L["TOY_NAME_129929"])
    local hasToy, missingReason = false, nil

    if PlayerHasToy and PlayerHasToy(toyID) then
        local usable = true
        if C_ToyBox and C_ToyBox.IsToyUsable then
            usable = C_ToyBox.IsToyUsable(toyID)
        end
        if usable then
            hasToy = true
        else
            hasToy = false
            missingReason = L["STATUS_UNAVAILABLE"]
        end
    else
        hasToy = false
        missingReason = L["MIRROR_MISSING_GUIDE"] or L["STATUS_NOT_OWNED"]
    end

    return {
        id = toyID,
        type = "TOY",
        kind = "TOY",
        name = toyName,
        hasItem = hasToy,
        missingReason = missingReason,
        missingShortTag = L["TAG_MISSING"],
    }
end

-- 供 /porta diag 诊断读取的静态数据表 (只读引用)
PlayerTeleports.Data = {
    TELEPORT_ITEMS = TELEPORT_ITEMS,
    CLASS_TELEPORT_SPELLS = CLASS_TELEPORT_SPELLS,
    MYTHIC_PLUS_DUNGEON_SPELLS = MYTHIC_PLUS_DUNGEON_SPELLS,
    DIRECT_DESTINATION_ITEMS = DIRECT_DESTINATION_ITEMS,
    DIRECT_MAP_ITEMS = DIRECT_MAP_ITEMS,
}
