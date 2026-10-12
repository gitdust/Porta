local _, ns = ...

local PlayerTeleports = {}
ns.PlayerTeleports = PlayerTeleports

-- =========================================================================
-- 1. 常用传送玩具与物品定义表
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

    -- 公会传送披风（直达主城传送大厅）
    { id = 65360, kind = "ITEM", name = "协作披风 (暴风城)", toMap = 84, x = 0.49, y = 0.87, faction = "ALLIANCE", priority = 9 },
    { id = 65274, kind = "ITEM", name = "协作披风 (奥格瑞玛)", toMap = 85, x = 0.57, y = 0.89, faction = "HORDE", priority = 9 },
    { id = 63206, kind = "ITEM", name = "统御披风 (暴风城)", toMap = 84, x = 0.49, y = 0.87, faction = "ALLIANCE", priority = 9 },
    { id = 63352, kind = "ITEM", name = "统御披风 (奥格瑞玛)", toMap = 85, x = 0.57, y = 0.89, faction = "HORDE", priority = 9 },
    { id = 63207, kind = "ITEM", name = "协调披风 (暴风城)", toMap = 84, x = 0.49, y = 0.87, faction = "ALLIANCE", priority = 9 },
    { id = 63353, kind = "ITEM", name = "协调披风 (奥格瑞玛)", toMap = 85, x = 0.57, y = 0.89, faction = "HORDE", priority = 9 },

    -- 特殊传送道具
    { id = 52251, kind = "ITEM", name = "吉安娜的坠饰", toMap = 125, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 7 }, -- 诺森德达拉然
    { id = 142469, kind = "ITEM", name = "肯瑞托紫罗兰印戒", toMap = 42, x = 0.47, y = 0.74, faction = "NEUTRAL", priority = 7 }, -- 卡拉赞
    { id = 103678, kind = "ITEM", name = "迷时神器", toMap = 554, x = 0.65, y = 0.75, faction = "NEUTRAL", priority = 6 }, -- 永恒岛
    { id = 63378, kind = "ITEM", name = "巴拉丁典狱官战袍", toMap = 244, x = 0.50, y = 0.50, faction = "ALLIANCE", priority = 6 }, -- 托尔巴拉德
    { id = 63379, kind = "ITEM", name = "地狱咆哮近卫军战袍", toMap = 245, x = 0.50, y = 0.50, faction = "HORDE", priority = 6 }, -- 托尔巴拉德

    -- 工程学虫洞发生器 (玩具)
    { id = 221966, kind = "TOY", name = "虫洞发生器：卡兹阿加", toMap = 2339, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 9 }, -- 多恩诺加尔
    { id = 198156, kind = "TOY", name = "虫洞发生器：巨龙群岛", toMap = 2112, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 9 }, -- 瓦德拉肯
    { id = 172924, kind = "TOY", name = "虫洞发生器：暗影界", toMap = 1670, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 8 }, -- 奥利波斯
    { id = 168807, kind = "TOY", name = "虫洞发生器：库尔提拉斯与赞达拉", toMap = 1165, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 8 },
    { id = 151652, kind = "TOY", name = "虫洞发生器：阿古斯", toMap = 905, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 7 },
    { id = 112059, kind = "TOY", name = "虫洞发生器：德拉诺", toMap = 572, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 7 },
    { id = 87215, kind = "TOY", name = "虫洞发生器：潘达利亚", toMap = 424, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 7 },
    { id = 48933, kind = "TOY", name = "虫洞发生器：诺森德", toMap = 113, x = 0.50, y = 0.50, faction = "NEUTRAL", priority = 7 },
}

-- =========================================================================
-- 2. 职业传送技能定义表
-- =========================================================================
local CLASS_TELEPORT_SPELLS = {
    -- 德鲁伊：梦境之路 (直达翡翠梦境之道，连通海加尔/暮色/灰谷/菲拉斯等)
    { id = 193753, class = "DRUID", name = "梦境行者", toMap = 715, x = 0.50, y = 0.50, priority = 10 },
    -- 死亡骑士：黑锋之门
    { id = 50977, class = "DEATHKNIGHT", name = "黑锋之门", toMap = 647, x = 0.50, y = 0.50, priority = 8 },
    -- 武僧：禅宗朝圣
    { id = 126892, class = "MONK", name = "禅宗朝圣", toMap = 378, x = 0.50, y = 0.50, priority = 8 },
    -- 法师主要传送门技能
    { id = 3567, class = "MAGE", name = "传送：奥格瑞玛", toMap = 85, x = 0.57, y = 0.89, priority = 10 },
    { id = 3561, class = "MAGE", name = "传送：暴风城", toMap = 84, x = 0.49, y = 0.87, priority = 10 },
    { id = 395277, class = "MAGE", name = "传送：瓦德拉肯", toMap = 2112, x = 0.50, y = 0.50, priority = 10 },
    { id = 446540, class = "MAGE", name = "传送：多恩诺加尔", toMap = 2339, x = 0.50, y = 0.50, priority = 10 },
    { id = 344587, class = "MAGE", name = "传送：奥利波斯", toMap = 1670, x = 0.50, y = 0.50, priority = 10 },
    { id = 224869, class = "MAGE", name = "传送：达拉然 - 破碎群岛", toMap = 627, x = 0.50, y = 0.50, priority = 10 },
    { id = 53140, class = "MAGE", name = "传送：达拉然 - 诺森德", toMap = 125, x = 0.50, y = 0.50, priority = 9 },
    { id = 33690, class = "MAGE", name = "传送：沙塔斯", toMap = 111, x = 0.50, y = 0.50, priority = 9 },
    { id = 281403, class = "MAGE", name = "传送：伯拉勒斯", toMap = 1161, x = 0.50, y = 0.50, priority = 9 },
    { id = 281404, class = "MAGE", name = "传送：达萨罗", toMap = 1165, x = 0.50, y = 0.50, priority = 9 },
}

-- =========================================================================
-- 3. 史诗大秘境英雄之路副本直达传送门（完成 10/20+ 层大秘境获得的法术）
--    格式: [journalInstanceID] = spellID
-- =========================================================================
local MYTHIC_PLUS_DUNGEON_SPELLS = {
    -- 地心之战 (TWW)
    [1269] = 445269, -- 矶石宝库 (The Stonevault)
    [1270] = 445417, -- 破晨号 (The Dawnbreaker)
    [1271] = 445414, -- 艾拉-卡拉，回响之城 (Ara-Kara)
    [1272] = 445440, -- 暗焰裂隙 (Darkflame Cleft)
    [1273] = 445444, -- 圣焰修道院 (Priory of the Sacred Flame)
    [1274] = 445443, -- 驭雷栖巢 (The Rookery)
    [1298] = 445416, -- 燧酿酒庄 (Cinderbrew Meadery)
    [1277] = 445418, -- 千丝之城 (City of Threads)
    -- 巨龙群岛 (DF)
    [1197] = 393256, -- 红玉新生圣所 (Ruby Life Pools)
    [1198] = 393262, -- 诺库德阻击战 (The Nokhud Offensive)
    [1199] = 393279, -- 碧蓝魔馆 (The Azure Vault)
    [1201] = 393273, -- 艾杰斯亚学院 (Algeth'ar Academy)
    [1202] = 393276, -- 红玉圣殿 / 蕨皮山谷 (Brackenhide Hollow)
    [1203] = 393267, -- 奈萨鲁斯 (Neltharus)
    [1204] = 393283, -- 注能大厅 (Halls of Infusion)
    [1209] = 424163, -- 永恒黎明 (Dawn of the Infinite)
    -- 争霸艾泽拉斯 (BfA)
    [1001] = 410078, -- 自由镇 (Freehold)
    [1023] = 410071, -- 地渊孢林 (The Underrot)
    [1022] = 424187, -- 围攻伯拉勒斯 (Siege of Boralus)
    -- 经典旧世 / 大地的裂变
    [71]   = 445424, -- 格瑞姆巴托 (Grim Batol)
}

-- 检查物品/玩具是否可用
local function HasItemOrToy(entry)
    local itemID = entry.id
    if entry.kind == "TOY" then
        if PlayerHasToy and PlayerHasToy(itemID) then
            return C_ToyBox and C_ToyBox.IsToyUsable and C_ToyBox.IsToyUsable(itemID) or true
        end
        return false
    elseif entry.kind == "ITEM" then
        if C_Item and C_Item.GetItemCount then
            return C_Item.GetItemCount(itemID) > 0
        end
        return false
    elseif entry.kind == "TOY_OR_ITEM" then
        if PlayerHasToy and PlayerHasToy(itemID) then return true end
        if C_Item and C_Item.GetItemCount and C_Item.GetItemCount(itemID) > 0 then return true end
        return false
    end
    return false
end

-- 获取法术或物品冷却状态 (返回 isReady, remainingSec)
local function GetCooldownStatus(kind, id)
    if kind == "SPELL" then
        local start, duration = 0, 0
        if C_Spell and C_Spell.GetSpellCooldown then
            local info = C_Spell.GetSpellCooldown(id)
            if info then start, duration = info.startTime, info.duration end
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

-- =========================================================================
-- 核心检测接口：获取当前玩家所拥有的所有可用传送手段
-- =========================================================================
function PlayerTeleports:GetAvailableTeleports()
    local available = {}
    local playerFaction = ns.GetPlayerFaction()
    local _, playerClass = UnitClass("player")

    -- 1. 扫描传送物品与玩具
    for _, item in ipairs(TELEPORT_ITEMS) do
        -- 阵营匹配
        if item.faction == "NEUTRAL" or item.faction == playerFaction then
            if HasItemOrToy(item) then
                local toMap = item.toMap
                if item.toMapHorde and item.toMapAlliance then
                    toMap = (playerFaction == "HORDE") and item.toMapHorde or item.toMapAlliance
                end

                local isReady, cdSeconds = GetCooldownStatus("ITEM", item.id)
                table.insert(available, {
                    type = "ITEM",
                    id = item.id,
                    name = item.name,
                    toMap = toMap,
                    x = item.x,
                    y = item.y,
                    priority = item.priority,
                    isReady = isReady,
                    cdSeconds = cdSeconds,
                })
            end
        end
    end

    -- 2. 扫描职业专属法术
    for _, spell in ipairs(CLASS_TELEPORT_SPELLS) do
        if spell.class == playerClass and IsSpellKnown(spell.id) then
            local isReady, cdSeconds = GetCooldownStatus("SPELL", spell.id)
            table.insert(available, {
                type = "SPELL",
                id = spell.id,
                name = spell.name,
                toMap = spell.toMap,
                x = spell.x,
                y = spell.y,
                priority = spell.priority,
                isReady = isReady,
                cdSeconds = cdSeconds,
            })
        end
    end

    return available
end

-- =========================================================================
-- 检测是否拥有直达特定副本的大秘境传送门 (Hero's Path)
-- =========================================================================
function PlayerTeleports:GetDirectDungeonPortal(journalInstanceID)
    if not journalInstanceID then return nil end
    local spellID = MYTHIC_PLUS_DUNGEON_SPELLS[journalInstanceID]
    if spellID and IsSpellKnown(spellID) then
        local spellInfo = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
        local spellName = spellInfo and spellInfo.name or ("传送：副本 #" .. tostring(journalInstanceID))
        local isReady, cdSeconds = GetCooldownStatus("SPELL", spellID)

        return {
            spellID = spellID,
            spellName = spellName,
            isReady = isReady,
            cdSeconds = cdSeconds,
        }
    end
    return nil
end
