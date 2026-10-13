local _, ns = ...

local PlayerTeleports = {}
ns.PlayerTeleports = PlayerTeleports

-- =========================================================================
-- 1. 常用传送玩具与物品定义表 (供跨地图寻路算法评估优先跳数使用)
-- =========================================================================
local TELEPORT_ITEMS = {
    -- 核心炉石系列
    {
        id = 140192,
        kind = "TOY_OR_ITEM",
        name = "达拉然炉石",
        toMap = 627, -- 军团再临达拉然
        x = 0.50, y = 0.50,
        faction = "NEUTRAL",
        priority = 10,
    },
    {
        id = 110560,
        kind = "TOY_OR_ITEM",
        name = "要塞炉石",
        toMapHorde = 590, -- 霜壁要塞
        toMapAlliance = 582, -- 落月要塞
        x = 0.50, y = 0.50,
        faction = "NEUTRAL",
        priority = 8,
    },
    {
        id = 128353,
        kind = "ITEM",
        name = "海军上将的罗盘",
        toMapHorde = 590,
        toMapAlliance = 582,
        x = 0.50, y = 0.50,
        faction = "NEUTRAL",
        priority = 7,
    },

    -- 公会传送披风（直达主城传送大厅）
    { id = 65360, kind = "ITEM", name = "协作披风 (暴风城)", toMap = 84, x = 0.49, y = 0.87, faction = "ALLIANCE", priority = 9 },
    { id = 65274, kind = "ITEM", name = "协作披风 (奥格瑞玛)", toMap = 85, x = 0.57, y = 0.89, faction = "HORDE", priority = 9 },
    { id = 63206, kind = "ITEM", name = "统御披风 (暴风城)", toMap = 84, x = 0.49, y = 0.87, faction = "ALLIANCE", priority = 9 },
    { id = 63352, kind = "ITEM", name = "统御披风 (奥格瑞玛)", toMap = 85, x = 0.57, y = 0.89, faction = "HORDE", priority = 9 },
    { id = 63207, kind = "ITEM", name = "协调披风 (暴风城)", toMap = 84, x = 0.49, y = 0.87, faction = "ALLIANCE", priority = 9 },
    { id = 63353, kind = "ITEM", name = "协调披风 (奥格瑞玛)", toMap = 85, x = 0.57, y = 0.89, faction = "HORDE", priority = 9 },

    -- 黑暗神殿专属传送
    {
        id = 151271,
        kind = "TOY",
        name = "开裂的死者之颅",
        toMap = 104, -- 外域影月谷
        x = 0.71, y = 0.46, -- 黑暗神殿大门前
        faction = "NEUTRAL",
        priority = 9,
        note = "需选中一只小动物献祭开门",
    },
    {
        id = 32757,
        kind = "ITEM",
        name = "卡拉波神圣勋章",
        toMap = 104,
        x = 0.71, y = 0.46,
        faction = "NEUTRAL",
        priority = 9,
        note = "项链直达黑暗神殿正门",
    },

    -- 永恒岛传送
    {
        id = 103678,
        kind = "ITEM",
        name = "迷时神器 (永恒岛)",
        toMap = 554, -- 潘达利亚永恒岛
        x = 0.65, y = 0.75,
        faction = "NEUTRAL",
        priority = 8,
        note = "1分钟冷却直达天神庭院",
    },

    -- 肯瑞托紫罗兰印戒 (卡拉赞)
    {
        id = 142469,
        kind = "ITEM",
        name = "肯瑞托紫罗兰印戒 (卡拉赞)",
        toMap = 42, -- 逆风小径
        x = 0.47, y = 0.74, -- 卡拉赞正门
        faction = "NEUTRAL",
        priority = 8,
    },

    -- 烈酒的遥控器 (黑石深渊黑铁酒吧 / 熔火之心 / 黑石山)
    {
        id = 37863,
        kind = "ITEM",
        name = "烈酒的遥控器 (黑铁酒吧)",
        toMap = 33, -- 燃烧平原/黑石山
        x = 0.45, y = 0.50,
        faction = "NEUTRAL",
        priority = 8,
        note = "直达黑铁酒吧，穿过酒吧即到黑石深渊与MC门前",
    },

    -- 达拉然肯瑞托戒指系列 (诺森德达拉然)
    {
        ids = {
            40586, 40585, 44934, 44935, 45688, 45689, 45690, 45691,
            48954, 48955, 48956, 48957, 51557, 51558, 51559, 51560
        },
        kind = "ITEM",
        name = "肯瑞托戒指 (诺森德达拉然)",
        toMap = 125,
        x = 0.50, y = 0.50,
        faction = "NEUTRAL",
        priority = 8,
    },
    -- 强化肯瑞托徽记 (军团再临达拉然)
    {
        id = 139599,
        kind = "ITEM",
        name = "强化肯瑞托徽记 (军团达拉然)",
        toMap = 627,
        x = 0.50, y = 0.50,
        faction = "NEUTRAL",
        priority = 8,
    },

    -- 搏击俱乐部拳手戒指
    { id = 144369, kind = "ITEM", name = "拳手强力重击戒指 (暴风城)", toMap = 84, x = 0.50, y = 0.35, faction = "ALLIANCE", priority = 7 },
    { id = 144370, kind = "ITEM", name = "拳手强力重击戒指 (奥格瑞玛)", toMap = 85, x = 0.42, y = 0.70, faction = "HORDE", priority = 7 },

    -- 特殊传送战袍与项坠
    { id = 52251, kind = "ITEM", name = "吉安娜的坠饰", toMap = 125, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 7 },
    { id = 46874, kind = "ITEM", name = "银色十字军战袍", toMap = 118, x = 0.69, y = 0.23, faction = "NEUTRAL", priority = 7, note = "直达诺森德冰冠冰川锦标赛营地，近ICC/奥杜尔" },
    { id = 92510, kind = "ITEM", name = "沃金的黄铜指环", toMap = 1, x = 0.55, y = 0.74, faction = "HORDE", priority = 6, note = "直达杜隆塔尔森金村" },
    { id = 63378, kind = "ITEM", name = "巴拉丁典狱官战袍", toMap = 244, x = 0.50, y = 0.50, faction = "ALLIANCE", priority = 7 },
    { id = 63379, kind = "ITEM", name = "地狱咆哮近卫军战袍", toMap = 245, x = 0.50, y = 0.50, faction = "HORDE", priority = 7 },

    -- 工程学虫洞发生器全集 (玩具 - 落点随机或需菜单选择，仅在前往对应大洲时作为补充备选方案提供)
    { id = 221966, kind = "TOY", name = "虫洞发生器：卡兹阿加", toMap = 2274, continentID = 2274, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 6, isWormhole = true, wormholeMode = "MENU", requiresEngineering = true, note = "需工程学专业；使用后可选择卡兹阿加各区域落点" },
    { id = 198156, kind = "TOY", name = "虫洞发生器：巨龙群岛", toMap = 1978, continentID = 1978, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 6, isWormhole = true, wormholeMode = "MENU", requiresEngineering = true, note = "需工程学专业；使用后可选择巨龙群岛各区域落点" },
    { id = 172924, kind = "TOY", name = "虫洞发生器：暗影界", toMap = 1670, continentID = 1550, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 6, isWormhole = true, wormholeMode = "MENU", requiresEngineering = true, note = "需工程学专业；使用后可选择暗影界各区域落点" },
    { id = 168807, kind = "TOY", name = "虫洞发生器：库尔提拉斯", toMap = 876, continentID = 876, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 5, isWormhole = true, wormholeMode = "RANDOM", requiresEngineering = true, note = "需工程学专业；随机传送至库尔提拉斯某处，落点不确定" },
    { id = 168808, kind = "TOY", name = "虫洞发生器：赞达拉", toMap = 875, continentID = 875, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 5, isWormhole = true, wormholeMode = "RANDOM", requiresEngineering = true, note = "需工程学专业；随机传送至赞达拉某处，落点不确定" },
    { id = 151652, kind = "TOY", name = "虫洞发生器：阿古斯", toMap = 905, continentID = 905, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 5, isWormhole = true, wormholeMode = "RANDOM", requiresEngineering = true, note = "需工程学专业；随机传送至阿古斯某处，落点不确定" },
    { id = 112059, kind = "TOY", name = "虫洞发生器：德拉诺", toMap = 572, continentID = 572, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 6, isWormhole = true, wormholeMode = "MENU", requiresEngineering = true, note = "需工程学专业；使用后可选择德拉诺各区域落点" },
    { id = 87215, kind = "TOY", name = "虫洞发生器：潘达利亚", toMap = 424, continentID = 424, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 5, isWormhole = true, wormholeMode = "RANDOM", requiresEngineering = true, note = "需工程学专业；随机传送至潘达利亚某处，落点不确定" },
    { id = 48933, kind = "TOY", name = "虫洞发生器：诺森德", toMap = 113, continentID = 113, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 6, isWormhole = true, wormholeMode = "MENU", requiresEngineering = true, note = "需工程学专业；使用后可选择诺森德各区域落点" },

    -- 工程学经典定点传送器 (空间撕裂器 / 安全传送器 - 落点固定，纳入常规路线评估，不满足专业或未拥有时提示)
    { id = 18984, kind = "TOY_OR_ITEM", name = "安全传送器：加基森", toMap = 71, x = 0.52, y = 0.28, faction = "NEUTRAL", priority = 8, requiresEngineering = true, note = "需地精工程学；定点直达塔纳利斯加基森" },
    { id = 18986, kind = "TOY_OR_ITEM", name = "空间撕裂器 - 永望镇", toMap = 83, x = 0.61, y = 0.38, faction = "NEUTRAL", priority = 8, requiresEngineering = true, note = "需侏儒工程学；定点直达冬泉谷永望镇" },
    { id = 30542, kind = "TOY_OR_ITEM", name = "空间撕裂器 - 52区", toMap = 109, x = 0.33, y = 0.64, faction = "NEUTRAL", priority = 8, requiresEngineering = true, note = "需地精工程学；定点直达虚空风暴52区" },
    { id = 30544, kind = "TOY_OR_ITEM", name = "安全传送器：托什雷的基地", toMap = 105, x = 0.60, y = 0.69, faction = "NEUTRAL", priority = 8, requiresEngineering = true, note = "需侏儒工程学；定点直达刀锋山托什雷基地" },
}

-- =========================================================================
-- 2. 职业传送技能定义表
-- =========================================================================
local CLASS_TELEPORT_SPELLS = {
    -- 德鲁伊：梦境行者 (直达翡翠梦境之道，连通海加尔/暮色/灰谷/菲拉斯等)
    { id = 193753, class = "DRUID", name = "梦境行者", toMap = 715, x = 0.50, y = 0.50, priority = 10 },
    { id = 18960, class = "DRUID", name = "传送：月光林地", toMap = 80, x = 0.56, y = 0.30, priority = 8 },

    -- 死亡骑士：黑锋之门 (阿彻鲁斯黑锋要塞)
    { id = 50977, class = "DEATHKNIGHT", name = "黑锋之门", toMap = 647, x = 0.50, y = 0.50, priority = 8 },

    -- 武僧：禅宗朝圣 (晴日峰 / 迷踪岛)
    { id = 126892, class = "MONK", name = "禅宗朝圣", toMap = 378, x = 0.50, y = 0.50, priority = 8 },

    -- 萨满祭司：星界召回
    { id = 556, class = "SHAMAN", name = "星界召回", toMap = 85, x = 0.50, y = 0.50, priority = 7 },

    -- 黑铁矮人种族特长：钻地机
    { id = 265225, class = "ALL", name = "钻地机", toMap = 84, x = 0.50, y = 0.50, priority = 8 },

    -- 法师全套传送门与传送技能
    { id = 3567, class = "MAGE", name = "传送：奥格瑞玛", toMap = 85, x = 0.57, y = 0.89, priority = 10 },
    { id = 3561, class = "MAGE", name = "传送：暴风城", toMap = 84, x = 0.49, y = 0.87, priority = 10 },
    { id = 3562, class = "MAGE", name = "传送：铁炉堡", toMap = 87, x = 0.50, y = 0.50, priority = 9 },
    { id = 3565, class = "MAGE", name = "传送：达纳苏斯", toMap = 89, x = 0.50, y = 0.50, priority = 9 },
    { id = 32271, class = "MAGE", name = "传送：埃索达", toMap = 103, x = 0.50, y = 0.50, priority = 9 },
    { id = 3563, class = "MAGE", name = "传送：幽暗城", toMap = 90, x = 0.50, y = 0.50, priority = 9 },
    { id = 3566, class = "MAGE", name = "传送：雷霆崖", toMap = 88, x = 0.50, y = 0.50, priority = 9 },
    { id = 32272, class = "MAGE", name = "传送：银月城", toMap = 110, x = 0.50, y = 0.50, priority = 9 },
    { id = 33690, class = "MAGE", name = "传送：沙塔斯", toMap = 111, x = 0.50, y = 0.50, priority = 9 },
    { id = 35715, class = "MAGE", name = "传送：沙塔斯", toMap = 111, x = 0.50, y = 0.50, priority = 9 },
    { id = 53140, class = "MAGE", name = "传送：达拉然 - 诺森德", toMap = 125, x = 0.50, y = 0.50, priority = 9 },
    { id = 120145, class = "MAGE", name = "传送：古代达拉然巨坑", toMap = 25, x = 0.55, y = 0.24, priority = 9 },
    { id = 49359, class = "MAGE", name = "传送：塞拉摩", toMap = 70, x = 0.67, y = 0.48, priority = 8 },
    { id = 49358, class = "MAGE", name = "传送：斯通纳德", toMap = 47, x = 0.47, y = 0.55, priority = 8 },
    { id = 88342, class = "MAGE", name = "传送：托尔巴拉德", toMap = 244, x = 0.50, y = 0.50, priority = 9 },
    { id = 88344, class = "MAGE", name = "传送：托尔巴拉德", toMap = 245, x = 0.50, y = 0.50, priority = 9 },
    { id = 132621, class = "MAGE", name = "传送：锦绣谷", toMap = 390, x = 0.50, y = 0.50, priority = 9 },
    { id = 132627, class = "MAGE", name = "传送：锦绣谷", toMap = 390, x = 0.50, y = 0.50, priority = 9 },
    { id = 176248, class = "MAGE", name = "传送：暴风之盾", toMap = 622, x = 0.50, y = 0.50, priority = 9 },
    { id = 176242, class = "MAGE", name = "传送：战争之矛", toMap = 624, x = 0.50, y = 0.50, priority = 9 },
    { id = 224869, class = "MAGE", name = "传送：达拉然 - 破碎群岛", toMap = 627, x = 0.50, y = 0.50, priority = 10 },
    { id = 281403, class = "MAGE", name = "传送：伯拉勒斯", toMap = 1161, x = 0.50, y = 0.50, priority = 9 },
    { id = 281404, class = "MAGE", name = "传送：达萨罗", toMap = 1165, x = 0.50, y = 0.50, priority = 9 },
    { id = 344587, class = "MAGE", name = "传送：奥利波斯", toMap = 1670, x = 0.50, y = 0.50, priority = 10 },
    { id = 395277, class = "MAGE", name = "传送：瓦德拉肯", toMap = 2112, x = 0.50, y = 0.50, priority = 10 },
    { id = 446540, class = "MAGE", name = "传送：多恩诺加尔", toMap = 2339, x = 0.50, y = 0.50, priority = 10 },
}

-- =========================================================================
-- 3. 历届史诗钥石 (Hero's Path) 与挑战模式 (Challenge Mode) 副本/团本直达传送门
--    映射关系：[journalInstanceID] = spellID 或 { spellID1, spellID2, ... }
-- =========================================================================
local MYTHIC_PLUS_DUNGEON_SPELLS = {
    -- ---------------------------------------------------------------------
    -- 地心之战 (The War Within 11.0 / 11.1 / 11.2)
    -- ---------------------------------------------------------------------
    [1269] = 445269, -- 矶石宝库 (The Stonevault) - Path of the Corrupted Foundry
    [1270] = 445414, -- 破晨号 (The Dawnbreaker) - Path of the Arathi Flagship
    [1271] = 445417, -- 艾拉-卡拉，回响之城 (Ara-Kara, City of Echoes) - Path of the Ruined City
    [1210] = 445441, -- 暗焰裂隙 (Darkflame Cleft) - Path of the Warding Candles
    [1267] = 445444, -- 圣焰修道院 (Priory of the Sacred Flame) - Path of the Light's Reverence
    [1268] = 445443, -- 驭雷栖巢 (The Rookery) - Path of the Fallen Stormriders
    [1272] = { 445440, 467546 }, -- 燧酿酒庄 (Cinderbrew Meadery)
    [1274] = 445416, -- 千丝之城 (City of Threads) - Path of Nerubian Ascension
    [1273] = 461159, -- 尼鲁巴尔王宫 (Nerub-ar Palace)
    [1296] = 1226482, -- 解放安德麦 (Liberation of Undermine) - Path of the Full House
    [1298] = 1216786, -- 水闸行动 (Operation: Floodgate) - Path of the Circuit Breaker
    [1302] = 1239155, -- 法力熔炉：欧米伽 (Manaforge Omega) - Path of the All-Devouring
    [1303] = 1237215, -- 生态圆顶阿尔达尼 (Eco-Dome Al'dani) - Path of the Eco-Dome
    [1299] = 1254400, -- 风行者之塔 (Windrunner Spire)
    [1300] = 1254572, -- 魔导师平台 (Magisters' Terrace)
    [1315] = 1254559, -- 迈萨拉洞窟 (Maisara Caverns)
    [1316] = 1254563, -- 虚空焦点塞纳斯 (Nexus-Point Xenas)

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
        { id = 32757, kind = "ITEM", name = "卡拉波神圣勋章", faction = "NEUTRAL", note = "经典项链，直达黑暗神殿正门" },
        { id = 151271, kind = "TOY", name = "开裂的死者之颅", faction = "NEUTRAL", note = "需选中一只小动物献祭开门" },
    },
    -- 重返卡拉赞 (860) 与 老卡拉赞 (745)
    [860] = {
        { id = 142469, kind = "ITEM", name = "肯瑞托紫罗兰印戒", faction = "NEUTRAL", note = "戒指直达卡拉赞正门" },
    },
    [745] = {
        { id = 142469, kind = "ITEM", name = "肯瑞托紫罗兰印戒", faction = "NEUTRAL", note = "戒指直达卡拉赞正门" },
    },
    -- 黑石深渊 (228) 及黑石山系列副本
    [228] = {
        { id = 37863, kind = "ITEM", name = "烈酒的遥控器", faction = "NEUTRAL", note = "召唤钻地机直达黑铁酒吧" },
    },
    [741] = { -- 熔火之心
        { id = 37863, kind = "ITEM", name = "烈酒的遥控器", faction = "NEUTRAL", note = "直达黑铁酒吧，穿过酒吧即到MC门前" },
    },
    -- 巴拉丁监狱 (75 - 托尔巴拉德)
    [75] = {
        { id = 63378, kind = "ITEM", name = "巴拉丁典狱官战袍", faction = "ALLIANCE", note = "战袍直达托尔巴拉德" },
        { id = 63379, kind = "ITEM", name = "地狱咆哮近卫军战袍", faction = "HORDE", note = "战袍直达托尔巴拉德" },
    },
    -- 冰冠堡垒 (758) 与 十字军的试炼 (757)
    [758] = {
        { id = 46874, kind = "ITEM", name = "银色十字军战袍", faction = "NEUTRAL", note = "直达冰冠冰川锦标赛营地，近ICC" },
    },
    [757] = {
        { id = 46874, kind = "ITEM", name = "银色十字军战袍", faction = "NEUTRAL", note = "直达十字军试炼大门前" },
    },
}

-- =========================================================================
-- 5. 目标地图专属直达道具定义表 (按 mapID 匹配，如直接搜索永恒岛等地图)
-- =========================================================================
local DIRECT_MAP_ITEMS = {
    -- 永恒岛 (mapID = 554)
    [554] = {
        { id = 103678, kind = "ITEM", name = "迷时神器", faction = "NEUTRAL", note = "1分钟冷却直达天神庭院" },
    },
    -- 托尔巴拉德半岛 (244 联盟, 245 部落)
    [244] = {
        { id = 63378, kind = "ITEM", name = "巴拉丁典狱官战袍", faction = "ALLIANCE", note = "战袍直达托尔巴拉德" },
    },
    [245] = {
        { id = 63379, kind = "ITEM", name = "地狱咆哮近卫军战袍", faction = "HORDE", note = "战袍直达托尔巴拉德" },
    },
}

-- =========================================================================
-- 辅助判断函数
-- =========================================================================
local function GetBagItemCount(itemID)
    if not itemID then return 0 end
    if C_Item and C_Item.GetItemCount then
        return C_Item.GetItemCount(itemID, false) or 0
    elseif GetItemCount then
        return GetItemCount(itemID, false) or 0
    end
    return 0
end

local function GetTotalItemCountWithBank(itemID)
    if not itemID then return 0 end
    if C_Item and C_Item.GetItemCount then
        return C_Item.GetItemCount(itemID, true) or 0
    elseif GetItemCount then
        return GetItemCount(itemID, true) or 0
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

local function IsToyUsableByPlayer(toyID)
    if not toyID then return false end
    if C_ToyBox and C_ToyBox.IsToyUsable then
        return C_ToyBox.IsToyUsable(toyID)
    end
    return true
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

-- 检查当前角色是否学习了工程学专业 (Engineering skillLine == 202)
local function HasEngineeringProfession()
    if not GetProfessions or not GetProfessionInfo then
        return true
    end
    local prof1, prof2 = GetProfessions()
    local profIndices = { prof1, prof2 }
    for _, idx in ipairs(profIndices) do
        if idx then
            local name, _, _, _, _, _, skillLine = GetProfessionInfo(idx)
            if skillLine == 202 or (name and (name:find("工程") or name:find("Engineering"))) then
                return true
            end
        end
    end
    return false
end

PlayerTeleports.HasEngineeringProfession = HasEngineeringProfession

-- 检查法术是否习得
local function IsSpellKnown(spellID)
    if not spellID then return false end
    if IsSpellKnownOrOverridesKnown then
        return IsSpellKnownOrOverridesKnown(spellID)
    end
    if IsPlayerSpell then
        return IsPlayerSpell(spellID)
    end
    return false
end

-- 供外部（如 HUD 点击/悬停时）实时检测某玩具、物品或技能当前是否拥有/可用
function PlayerTeleports:CheckTeleportOwnership(kind, id, displayName)
    if not id then return false, "未知的传送编号" end
    local uKind = string.upper(tostring(kind or "ITEM"))
    local label = displayName and ("【" .. displayName .. "】") or ("#" .. tostring(id))
    local reqEng = (ENGINEERING_REQ_MAP[id] ~= nil)
    local hasEng = (not reqEng) or HasEngineeringProfession()

    if uKind == "SPELL" then
        if IsSpellKnown(id) then
            return true, nil
        end
        return false, string.format("当前角色尚未习得传送技能%s。", label)
    elseif uKind == "TOY" then
        if HasToyCollected(id) then
            if not hasEng then
                return false, string.format("已收集玩具%s，但当前角色未学习工程学专业，无法使用。", label)
            end
            if not IsToyUsableByPlayer(id) then
                return false, string.format("已收集玩具%s，但当前角色不满足使用条件（如工程学专业分支/等级或阵营限制）。", label)
            end
            return true, nil
        elseif HasItem(id) then
            if not hasEng then
                return false, string.format("已携带%s，但当前角色未学习工程学专业，无法使用。", label)
            end
            return true, nil
        end
        if reqEng and not hasEng then
            return false, string.format("玩具箱中尚未收集%s，且该装置需要工程学专业才可使用。", label)
        end
        return false, string.format("玩具箱中尚未收集玩具%s。", label)
    else
        local ownedInBag = HasItem(id)
        local ownedAsToy = HasToyCollected(id)
        if ownedInBag or ownedAsToy then
            if not hasEng then
                return false, string.format("已拥有%s，但当前角色未学习工程学专业，无法使用。", label)
            end
            if ownedAsToy and not ownedInBag and not IsToyUsableByPlayer(id) then
                return false, string.format("已收集%s，但当前角色不满足使用条件（如工程学分支/等级限制）。", label)
            end
            return true, nil
        elseif IsItemInBank(id) then
            if not hasEng then
                return false, string.format("物品%s存放在银行中未携带，且当前角色未学习工程学专业。", label)
            end
            return false, string.format("物品%s存放在银行/战团银行中，当前背包未携带。", label)
        end
        if reqEng and not hasEng then
            return false, string.format("当前未拥有%s，且该装置需要工程学专业才可使用。", label)
        end
        return false, string.format("当前背包或装备栏中未拥有物品%s。", label)
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

    local reqEng = entry.requiresEngineering and true or false
    local hasEng = (not reqEng) or HasEngineeringProfession()
    local hasIt = isOwned and hasEng and (not isToyUnusable)

    local missingReason = nil
    local missingShortTag = nil
    if not hasIt then
        if isOwned then
            if reqEng and not hasEng then
                missingShortTag = "需工程学"
                missingReason = string.format("你已拥有【%s】，但当前角色未学习工程学专业，无法使用。", entry.name)
            else
                missingShortTag = reqEng and "工程学条件不符" or "条件不符"
                missingReason = string.format("你已收集【%s】，但当前角色不满足使用条件（如地精/侏儒工程学分支、专业点数或阵营限制）。", entry.name)
            end
        elseif inBank then
            if reqEng and not hasEng then
                missingShortTag = "在银行/需工程学"
                missingReason = string.format("物品【%s】存放在银行中未携带，且当前角色未学习工程学专业。", entry.name)
            else
                missingShortTag = "在银行"
                missingReason = string.format("物品【%s】目前存放在银行/战团银行中，当前背包未携带。", entry.name)
            end
        else
            if reqEng and not hasEng then
                missingShortTag = "未拥有/需工程学"
                missingReason = string.format("当前未拥有【%s】，且使用该传送装置需要工程学专业。", entry.name)
            elseif reqEng then
                missingShortTag = "未拥有"
                missingReason = string.format("当前尚未收集或携带工程学传送装置【%s】。", entry.name)
            elseif actualKind == "TOY" then
                missingShortTag = "未拥有"
                missingReason = string.format("当前尚未收集玩具【%s】（玩具箱中未找到）。", entry.name)
            else
                missingShortTag = "未拥有"
                missingReason = string.format("当前背包或装备栏中未检测到物品【%s】。", entry.name)
            end
        end
    end

    return {
        hasItem = hasIt,
        isOwned = isOwned,
        id = matchedID,
        kind = actualKind,
        inBank = inBank,
        isToyUnusable = isToyUnusable,
        missingEngineering = (reqEng and not hasEng),
        missingShortTag = missingShortTag,
        missingReason = missingReason,
    }
end

-- 获取法术或物品冷却状态 (返回 isReady, remainingSec)
local function GetCooldownStatus(kind, id)
    if not id then return true, 0 end

    if kind == "SPELL" then
        local start, duration = 0, 0
        if C_Spell and C_Spell.GetSpellCooldown then
            local info = C_Spell.GetSpellCooldown(id)
            if info then
                start = info.startTime or 0
                duration = info.duration or 0
            end
        elseif GetSpellCooldown then
            start, duration = GetSpellCooldown(id)
        end
        if duration and duration > 1.5 then
            local rem = (start + duration) - GetTime()
            return false, math.max(0, math.floor(rem))
        end
        return true, 0
    else
        local start, duration = 0, 0
        if C_Container and C_Container.GetItemCooldown then
            start, duration = C_Container.GetItemCooldown(id)
        elseif GetItemCooldown then
            start, duration = GetItemCooldown(id)
        end
        if duration and duration > 1.5 then
            local rem = (start + duration) - GetTime()
            return false, math.max(0, math.floor(rem))
        end
        return true, 0
    end
end

PlayerTeleports.GetCooldownStatus = GetCooldownStatus

-- =========================================================================
-- 核心检测接口 1：获取所有通用传送手段（供 Dijkstra/BFS 寻路）
-- 规则：玩具与物品不因玩家未拥有或未学专业而过滤，默认纳入算路；若实际未拥有或不满足条件则在方案中提示
-- =========================================================================
function PlayerTeleports:GetAvailableTeleports()
    local available = {}
    local playerFaction = ns.GetPlayerFaction()
    local _, playerClass = UnitClass("player")

    -- 1. 扫描传送物品与玩具（全部纳入候选，记录真实拥有与专业条件状态）
    for _, item in ipairs(TELEPORT_ITEMS) do
        if item.faction == "NEUTRAL" or item.faction == playerFaction then
            local state = InspectItemOrToyEntry(item)
            local toMap = item.toMap
            if item.toMapHorde and item.toMapAlliance then
                toMap = (playerFaction == "HORDE") and item.toMapHorde or item.toMapAlliance
            end

            local isReady, cdSeconds = true, 0
            if state.hasItem then
                isReady, cdSeconds = GetCooldownStatus("ITEM", state.id)
            end

            table.insert(available, {
                type = state.kind, -- "TOY" 或 "ITEM"
                id = state.id,
                name = item.name,
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
                isReady = isReady,
                cdSeconds = cdSeconds,
                note = item.note,
                isWormhole = item.isWormhole or false,
                continentID = item.continentID,
                wormholeMode = item.wormholeMode,
                requiresEngineering = item.requiresEngineering or false,
            })
        end
    end

    -- 2. 扫描职业专属法术与种族特长
    for _, spell in ipairs(CLASS_TELEPORT_SPELLS) do
        local classMatch = (spell.class == "ALL") or (spell.class == playerClass)
        if classMatch and IsSpellKnown(spell.id) then
            local isReady, cdSeconds = GetCooldownStatus("SPELL", spell.id)
            table.insert(available, {
                type = "SPELL",
                id = spell.id,
                name = spell.name,
                toMap = spell.toMap,
                x = spell.x or 0.50,
                y = spell.y or 0.50,
                priority = spell.priority or 5,
                hasItem = true,
                isReady = isReady,
                cdSeconds = cdSeconds,
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

    -- 1. 检测【大秘境 / 挑战模式 / 团队副本英雄之路传送门】
    if destination.id and destination.id > 0 then
        local entry = MYTHIC_PLUS_DUNGEON_SPELLS[destination.id]
        if entry then
            local candidateSpells = (type(entry) == "table") and entry or { entry }
            for _, spellID in ipairs(candidateSpells) do
                if IsSpellKnown(spellID) then
                    local spellInfo = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
                    local spellName = spellInfo and spellInfo.name or ("传送：" .. (destination.name or ("副本 #" .. tostring(destination.id))))
                    local isReady, cdSeconds = GetCooldownStatus("SPELL", spellID)

                    table.insert(results, {
                        type = "SPELL",
                        id = spellID,
                        name = spellName,
                        hasItem = true,
                        isReady = isReady,
                        cdSeconds = cdSeconds,
                    })
                    break
                end
            end
        end
    end

    -- 2. 检测【副本专属直达道具/玩具】（不因未拥有而过滤，记录未拥有提示）
    if destination.id and destination.id > 0 and DIRECT_DESTINATION_ITEMS[destination.id] then
        for _, itemEntry in ipairs(DIRECT_DESTINATION_ITEMS[destination.id]) do
            if itemEntry.faction == "NEUTRAL" or itemEntry.faction == playerFaction then
                local state = InspectItemOrToyEntry(itemEntry)
                local isReady, cdSeconds = true, 0
                if state.hasItem then
                    isReady, cdSeconds = GetCooldownStatus("ITEM", state.id)
                end
                table.insert(results, {
                    type = state.kind, -- "TOY" 或 "ITEM"
                    id = state.id,
                    name = itemEntry.name,
                    note = itemEntry.note,
                    hasItem = state.hasItem,
                    isOwned = state.isOwned,
                    inBank = state.inBank,
                    isToyUnusable = state.isToyUnusable,
                    missingEngineering = state.missingEngineering,
                    missingShortTag = state.missingShortTag,
                    missingReason = state.missingReason,
                    requiresEngineering = itemEntry.requiresEngineering or false,
                    isReady = isReady,
                    cdSeconds = cdSeconds,
                })
            end
        end
    end

    -- 3. 检测【目标区域专属直达道具/玩具】（如永恒岛 554、托尔巴拉德 244/245 等）
    if destination.mapID and DIRECT_MAP_ITEMS[destination.mapID] then
        for _, itemEntry in ipairs(DIRECT_MAP_ITEMS[destination.mapID]) do
            if itemEntry.faction == "NEUTRAL" or itemEntry.faction == playerFaction then
                local state = InspectItemOrToyEntry(itemEntry)
                local isReady, cdSeconds = true, 0
                if state.hasItem then
                    isReady, cdSeconds = GetCooldownStatus("ITEM", state.id)
                end
                table.insert(results, {
                    type = state.kind, -- "TOY" 或 "ITEM"
                    id = state.id,
                    name = itemEntry.name,
                    note = itemEntry.note,
                    hasItem = state.hasItem,
                    isOwned = state.isOwned,
                    inBank = state.inBank,
                    isToyUnusable = state.isToyUnusable,
                    missingEngineering = state.missingEngineering,
                    missingShortTag = state.missingShortTag,
                    missingReason = state.missingReason,
                    requiresEngineering = itemEntry.requiresEngineering or false,
                    isReady = isReady,
                    cdSeconds = cdSeconds,
                })
            end
        end
    end

    -- 已拥有的排前面，就绪的排前面
    table.sort(results, function(a, b)
        if (a.hasItem and true or false) ~= (b.hasItem and true or false) then
            return a.hasItem and true or false
        end
        if (a.isReady and true or false) ~= (b.isReady and true or false) then
            return a.isReady and true or false
        end
        return (a.id or 0) < (b.id or 0)
    end)

    return results
end

function PlayerTeleports:GetDirectDestinationTeleport(destination)
    local list = self:GetDirectDestinationTeleports(destination)
    return list[1]
end

-- 兼容老接口
function PlayerTeleports:GetDirectDungeonPortal(journalInstanceID)
    if not journalInstanceID then return nil end
    return self:GetDirectDestinationTeleport({ id = journalInstanceID })
end

