local _, ns = ...
local L = ns.L

local Pathfinder = {}
ns.Pathfinder = Pathfinder

-- =========================================================================
-- 1. 交通方式显示文本与基础代价权重
-- =========================================================================
local TRANSPORT_TEXT = {
    PORTAL        = L["TRANSPORT_PORTAL"],
    ZEPPELIN      = L["TRANSPORT_ZEPPELIN"],
    SHIP          = L["TRANSPORT_SHIP"],
    WAYGATE       = L["TRANSPORT_WAYGATE"],
    MIRROR        = L["TRANSPORT_MIRROR"],
    MOLE_MACHINE  = L["TRANSPORT_MOLE_MACHINE"],
    TRAM          = L["TRANSPORT_TRAM"],
    CLASS_PORTAL  = L["TRANSPORT_CLASS_PORTAL"],
    TRANSPORT     = L["TRANSPORT_PASSAGE"],
    CAVE_ENTER    = L["TRANSPORT_CAVE_ENTER"],
    CAVE_EXIT     = L["TRANSPORT_CAVE_EXIT"],
    FLY           = L["TRANSPORT_FLY"],
}

local EDGE_COSTS = {
    PORTAL        = 1.0,
    WAYGATE       = 1.0,
    MIRROR        = 1.0,
    CLASS_PORTAL  = 1.0,
    CAVE_ENTER    = 1.0,
    CAVE_EXIT     = 1.0,
    MOLE_MACHINE  = 1.5,
    TRANSPORT     = 1.2,
    FLY           = 2.0,
    TRAM          = 3.0,
    ZEPPELIN      = 8.0,
    SHIP          = 8.0,
}

-- 地下垂直层级地图定义 (与地表地图之间存在岩层遮挡，严禁无视入口的同大陆直线平原飞行)
local UNDERGROUND_ZONES = {
    [2133] = { surfaceContID = 1978, name = "查拉雷克洞窟" },
    [2509] = { surfaceContID = 2537, name = "阿塔乌特克地窟" },
}

-- 核心位面传送门的前置任务解锁补充清单
-- (用于补全 HandyNotes_MapNotes 未标注在入口侧的跨资料片镜像开门任务)
local PORTAL_QUEST_GATES = {
    -- 纳沙塔尔 (1355)
    [1355] = {
        HORDE = {
            questIDs = { 55095, 55122, 56043 }, -- 发送舰队 / 新生家园 / 下潜
            questName = L["GATE_NAZJATAR_H_QUEST"],
            startNPC = L["GATE_NAZJATAR_H_NPC"],
            unlockGuide = L["GATE_NAZJATAR_H_GUIDE"],
        },
        ALLIANCE = {
            questIDs = { 54022, 55121, 56044, 55175 }, -- 发送舰队 / 麦扎梅尔
            questName = L["GATE_NAZJATAR_A_QUEST"],
            startNPC = L["GATE_NAZJATAR_A_NPC"],
            unlockGuide = L["GATE_NAZJATAR_A_GUIDE"],
        },
    },
    -- 阿古斯维迪卡尔 (971 / 885 / 882)
    [971] = {
        HORDE = { questIDs = { 47221, 47835, 48440 }, questName = L["GATE_ARGUS_QUEST"], startNPC = L["GATE_ARGUS_NPC"], unlockGuide = L["GATE_ARGUS_GUIDE"] },
        ALLIANCE = { questIDs = { 47221, 47835, 48440 }, questName = L["GATE_ARGUS_QUEST"], startNPC = L["GATE_ARGUS_NPC"], unlockGuide = L["GATE_ARGUS_GUIDE"] },
    },
    -- 麦卡贡 (1462)
    [1462] = {
        HORDE = { questIDs = { 55651, 55609 }, questName = L["GATE_MECHAGON_H_QUEST"], startNPC = L["GATE_MECHAGON_H_NPC"], unlockGuide = L["GATE_MECHAGON_H_GUIDE"] },
        ALLIANCE = { questIDs = { 54992, 55609 }, questName = L["GATE_MECHAGON_A_QUEST"], startNPC = L["GATE_MECHAGON_A_NPC"], unlockGuide = L["GATE_MECHAGON_A_GUIDE"] },
    },
    -- 深岩之洲 (207)
    [207] = {
        HORDE = { questIDs = { 27727 }, questName = L["GATE_DEEPHOLM_QUEST"], startNPC = L["GATE_DEEPHOLM_H_NPC"], unlockGuide = L["GATE_DEEPHOLM_H_GUIDE"] },
        ALLIANCE = { questIDs = { 27722 }, questName = L["GATE_DEEPHOLM_QUEST"], startNPC = L["GATE_DEEPHOLM_A_NPC"], unlockGuide = L["GATE_DEEPHOLM_A_GUIDE"] },
    },
    -- 暮光高地 (241)
    [241] = {
        HORDE = { questIDs = { 28716, 26798 }, questName = L["GATE_TWILIGHT_QUEST"], startNPC = L["GATE_TWILIGHT_H_NPC"], unlockGuide = L["GATE_TWILIGHT_H_GUIDE"] },
        ALLIANCE = { questIDs = { 28717, 26797 }, questName = L["GATE_TWILIGHT_QUEST"], startNPC = L["GATE_TWILIGHT_A_NPC"], unlockGuide = L["GATE_TWILIGHT_A_GUIDE"] },
    },
    -- 刻希亚 (1961)
    [1961] = {
        NEUTRAL = { questIDs = { 63662, 63902 }, questName = L["GATE_KORTHIA_QUEST"], startNPC = L["GATE_KORTHIA_NPC"], unlockGuide = L["GATE_KORTHIA_GUIDE"] },
    },
    -- 扎雷殁提斯 (1970)
    [1970] = {
        NEUTRAL = { questIDs = { 64957, 64942 }, questName = L["GATE_ZERETH_QUEST"], startNPC = L["GATE_ZERETH_NPC"], unlockGuide = L["GATE_ZERETH_GUIDE"] },
    },
    -- 雷神岛 (504)
    [504] = {
        HORDE = { questIDs = { 32680 }, questName = L["GATE_ISLE_THUNDER_QUEST"], startNPC = L["GATE_ISLE_THUNDER_H_NPC"], unlockGuide = L["GATE_ISLE_THUNDER_H_GUIDE"] },
        ALLIANCE = { questIDs = { 32681 }, questName = L["GATE_ISLE_THUNDER_QUEST"], startNPC = L["GATE_ISLE_THUNDER_A_NPC"], unlockGuide = L["GATE_ISLE_THUNDER_A_GUIDE"] },
    },
}

-- 补充任务门只应用于实际“进入式”交通设施；船只/飞艇/通道不能因为目标地图的镜像门任务被误判为锁定
local PORTAL_GATE_EDGE_TYPES = {
    PORTAL = true,
    WAYGATE = true,
    MIRROR = true,
    CLASS_PORTAL = true,
}

-- 检测特定目标传送门/交通节点是否已被当前角色解锁
-- 数据获取三层机制：
--   1. HandyNotes_MapNotes 节点原生携带的 questID / achievementID（由 _parser 自动提取至 MapNotesData.lua）
--   2. 跨资料片主城镜像传送门补充表 PORTAL_QUEST_GATES（补全 MapNotes 未标注的资料片开门任务）
--   3. 魔兽客户端原生 API 动态查询：C_QuestLog.IsQuestFlaggedCompleted / C_QuestLog.GetTitleForQuestID / GetAchievementInfo
function Pathfinder:CheckPortalQuestStatus(edgeOrToMapID, playerFaction)
    local edge = type(edgeOrToMapID) == "table" and edgeOrToMapID or nil
    local toMapID = edge and edge.to or edgeOrToMapID
    if not toMapID then return true, nil end

    -- 1. 优先检测 HandyNotes_MapNotes 自动提取的节点级前置成就 (achievementID)
    if edge and edge.achievementID and GetAchievementInfo then
        local ok, _, achName, _, completed, _, _, _, description = pcall(GetAchievementInfo, edge.achievementID)
        if ok and completed == false then
            local displayAch = (achName and achName ~= "") and ns.FormatBracket(achName) or string.format(L["ACHIEVEMENT_FALLBACK_FMT"], tostring(edge.achievementID))
            local descHint = (description and description ~= "") and (" (" .. description .. ")") or ""
            return false, {
                achievementID = edge.achievementID,
                questName = string.format(L["GATE_ACH_PREFIX_FMT"], displayAch),
                startNPC = L["GATE_ACH_START_NPC"],
                unlockGuide = string.format(L["GATE_ACH_UNLOCK_FMT"], displayAch, descHint),
            }
        end
    end

    -- 2. 检测 HandyNotes_MapNotes 自动提取的节点级前置任务 (questID)
    if edge and edge.questID and C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(edge.questID)
        if not isCompleted then
            if C_QuestLog.RequestLoadQuestByID then
                pcall(C_QuestLog.RequestLoadQuestByID, edge.questID)
            end
            local dynamicTitle = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(edge.questID)
            local displayQuest = (dynamicTitle and dynamicTitle ~= "") and string.format(L["QUEST_TITLE_FMT"], dynamicTitle) or string.format(L["QUEST_FALLBACK_FMT"], tostring(edge.questID))
            return false, {
                questIDs = { edge.questID },
                questName = displayQuest,
                startNPC = L["GATE_QUEST_START_NPC"],
                unlockGuide = string.format(L["GATE_QUEST_UNLOCK_FMT"], displayQuest, edge.questID),
            }
        end
    end

    -- 3. 检测跨资料片镜像位面传送门补充表 (PORTAL_QUEST_GATES)
    -- 该补充表描述的是“通过传送设施进入目标地图”的前置；物理交通（船/艇/通道）不适用
    if edge and not PORTAL_GATE_EDGE_TYPES[edge.type] then
        return true, nil
    end

    local gateConfig = PORTAL_QUEST_GATES[toMapID]
    if not gateConfig then return true, nil end

    local factionConfig = gateConfig[playerFaction] or gateConfig.NEUTRAL or gateConfig.HORDE
    if not factionConfig then return true, nil end

    if not C_QuestLog or not C_QuestLog.IsQuestFlaggedCompleted then
        return true, factionConfig
    end

    local isUnlocked = false
    local dynamicTitle = nil
    for _, qID in ipairs(factionConfig.questIDs) do
        if C_QuestLog.IsQuestFlaggedCompleted(qID) then
            isUnlocked = true
            break
        end
        if not dynamicTitle and C_QuestLog.GetTitleForQuestID then
            if C_QuestLog.RequestLoadQuestByID then
                pcall(C_QuestLog.RequestLoadQuestByID, qID)
            end
            local t = C_QuestLog.GetTitleForQuestID(qID)
            if t and t ~= "" then
                dynamicTitle = string.format(L["QUEST_TITLE_FMT"], t)
            end
        end
    end

    if not isUnlocked and dynamicTitle then
        local enriched = {}
        for k, v in pairs(factionConfig) do enriched[k] = v end
        enriched.questName = dynamicTitle
        return false, enriched
    end

    return isUnlocked, factionConfig
end

-- 获取友好的地图名称（当前客户端语言）
local function GetMapDisplayName(mapID)
    if not mapID then return L["UNKNOWN_MAP"] end
    if C_Map and C_Map.GetMapInfo then
        local info = C_Map.GetMapInfo(mapID)
        if info and info.name then
            return info.name
        end
    end
    return string.format(L["MAP_FALLBACK_FMT"], tostring(mapID))
end

-- 检测千禧阈限 (The Timeways - 2266) 是否处于有效版本与赛季生命周期
local function IsTimewaysActive()
    if ns.config and ns.config.forceTimewaysActive ~= nil then
        return ns.config.forceTimewaysActive
    end
    if GetBuildInfo then
        local _, _, _, tocVersion = GetBuildInfo()
        if tocVersion and tocVersion > 0 then
            -- 仅在 11.x (地心之战) 大秘境赛季周期内有效；跨入 12.0 及更高版本 (如 12.1) 时下线
            return tocVersion >= 110000 and tocVersion < 120000
        end
    end
    -- 默认以当前 12.1 大秘境第一赛季环境为准，千禧阈限处于关闭下线状态
    return false
end
Pathfinder.IsTimewaysActive = IsTimewaysActive

-- 计算暗月马戏团当前活动状态 (每月第一个周日 00:01 ~ 次周六 23:59)
local function GetDarkmoonFaireStatus()
    local now
    if C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime then
        local ok, cTime = pcall(C_DateAndTime.GetCurrentCalendarTime)
        if ok and cTime and cTime.year and cTime.month and cTime.monthDay then
            now = {
                year = cTime.year,
                month = cTime.month,
                day = cTime.monthDay,
                hour = cTime.hour or 12,
                wday = cTime.weekday or 1,
            }
        end
    end
    local getTimeStamp = time or (os and os.time) or function() return 0 end
    local getDateTable = date or (os and os.date) or function() return {} end

    if not now then
        local ok, d = pcall(getDateTable, "*t")
        now = ok and d or { year = 2026, month = 10, day = 13, hour = 12, wday = 3 }
    end

    -- 计算当月 1 号星期几 (wday: 1=周日, 2=周一, ..., 7=周六)
    local t1 = getTimeStamp({ year = now.year, month = now.month, day = 1, hour = 12 })
    local d1 = getDateTable("*t", t1)
    local firstSunday = (1 - (d1.wday or 1) + 7) % 7 + 1
    local faireEndDay = firstSunday + 6

    local isOpen = (now.day >= firstSunday and now.day <= faireEndDay)

    -- 计算下次开放日期
    local nextMonth = now.month
    local nextYear = now.year
    if now.day > faireEndDay then
        nextMonth = nextMonth + 1
        if nextMonth > 12 then
            nextMonth = 1
            nextYear = nextYear + 1
        end
    end
    local nextT1 = getTimeStamp({ year = nextYear, month = nextMonth, day = 1, hour = 12 })
    local nextD1 = getDateTable("*t", nextT1)
    local nextSundayDay = (1 - (nextD1.wday or 1) + 7) % 7 + 1
    local nextOpenStr = string.format(L["DARKMOON_NEXT_DATE_FMT"] or "%d月%d日", nextMonth, nextSundayDay)

    return isOpen, nextOpenStr, firstSunday, faireEndDay
end
Pathfinder.GetDarkmoonFaireStatus = GetDarkmoonFaireStatus

-- 计算重访惊魂幻象当前周轮换状态 (每周服务器维护后轮换：暴风城 vs 奥格瑞玛)
local function GetHorrificVisionRotationStatus(visionType)
    local activeCity = nil
    -- 1. 优先尝试从多恩诺嘉尔 (2339) 实时地图 AreaPOI 探测当前激活的幻象
    if C_AreaPoiInfo and C_AreaPoiInfo.GetAreaPOIsForPlayerByMapID and C_AreaPoiInfo.GetAreaPOIInfo then
        local pois = C_AreaPoiInfo.GetAreaPOIsForPlayerByMapID(2339)
        if pois then
            for _, poiID in ipairs(pois) do
                local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(2339, poiID)
                if poiInfo and poiInfo.position then
                    local px, py = poiInfo.position:GetXY()
                    if px and py and math.abs(px - 0.346) < 0.08 and math.abs(py - 0.684) < 0.08 then
                        local text = string.lower((poiInfo.name or "") .. " " .. (poiInfo.description or ""))
                        if string.find(text, "stormwind") or string.find(text, "暴风城") or string.find(text, "暴風城") or string.find(text, "roccavento") or string.find(text, "sturmwind") or string.find(text, "hurlevent") or string.find(text, "ventormenta") then
                            activeCity = "STORMWIND"
                            break
                        elseif string.find(text, "orgrimmar") or string.find(text, "奥格瑞玛") or string.find(text, "奧格瑪") then
                            activeCity = "ORGRIMMAR"
                            break
                        end
                    end
                end
            end
        end
    end

    -- 2. 获取下次周重置日期 (用于显示下周轮换时间)
    local getTimeStamp = time or (os and os.time) or function() return 0 end
    local getDateTable = date or (os and os.date) or function() return {} end
    local secsUntilReset = 0
    if C_DateAndTime and C_DateAndTime.GetSecondsUntilWeeklyReset then
        local ok, s = pcall(C_DateAndTime.GetSecondsUntilWeeklyReset)
        if ok and s and s > 0 then
            secsUntilReset = s
        end
    end
    if secsUntilReset <= 0 then
        -- 兜底：若 API 不可用，假设 3 天后重置
        secsUntilReset = 86400 * 3
    end

    local resetTimestamp = getTimeStamp() + secsUntilReset
    local resetDate = getDateTable("*t", resetTimestamp)
    local nextResetDateStr = ""
    if resetDate and resetDate.month and resetDate.day then
        nextResetDateStr = string.format(L["DARKMOON_NEXT_DATE_FMT"] or "%d/%d", resetDate.month, resetDate.day)
    end

    -- 3. 若 POI 未能匹配，基于双周交替基准算法兜底
    if not activeCity then
        local weekIndex = math.floor(resetTimestamp / (7 * 86400))
        if (weekIndex % 2) == 0 then
            activeCity = "STORMWIND"
        else
            activeCity = "ORGRIMMAR"
        end
    end

    local isActive = (visionType == activeCity)
    return isActive, activeCity, nextResetDateStr
end
Pathfinder.GetHorrificVisionRotationStatus = GetHorrificVisionRotationStatus

-- =========================================================================
-- 2. 真实物理距离计算器 (支持计算玩家当前位置到起点的真实码数)
-- =========================================================================
function Pathfinder:GetDistanceInYards(mapID, targetX, targetY)
    if not mapID or not targetX or not targetY then return nil end
    if not C_Map or not C_Map.GetPlayerMapPosition then return nil end

    local playerPos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not playerPos then return nil end

    -- 方案 A：通过暴雪原生世界空间坐标计算绝对真实码数 (Yards)
    if C_Map.GetWorldPosFromMapPos and CreateVector2D then
        local ok1, playerWorld = pcall(function()
            local _, pos = C_Map.GetWorldPosFromMapPos(mapID, playerPos)
            return pos
        end)
        local ok2, targetWorld = pcall(function()
            local targetVec = CreateVector2D(targetX, targetY)
            local _, pos = C_Map.GetWorldPosFromMapPos(mapID, targetVec)
            return pos
        end)

        if ok1 and ok2 and playerWorld and targetWorld then
            local dx = playerWorld.x - targetWorld.x
            local dy = playerWorld.y - targetWorld.y
            local dist = math.sqrt(dx * dx + dy * dy)
            -- 仅当在同一有效世界坐标实例内 (距离小于 20,000 码) 时采纳世界坐标
            if dist and dist >= 0 and dist < 20000 then
                return math.floor(dist)
            end
        end
    end

    -- 方案 B：回退机制：根据地图归一化坐标欧氏距离折算（魔兽野外区域宽约 3500 码）
    local px, py = playerPos:GetXY()
    if px and py and px > 0 and py > 0 then
        local dx = (px - targetX)
        local dy = (py - targetY)
        local coordDist = math.sqrt(dx * dx + dy * dy)
        return math.floor(coordDist * 3500)
    end

    return nil
end

-- 格式化距离文本 (例如 "450码"/"450 yds" 或 "1.8千码"/"1.8k yds")
local function FormatDistanceText(yards)
    if not yards then return "" end
    if yards >= 1000 then
        return string.format(L["DIST_KYARDS_FMT"], yards / 1000)
    else
        return string.format(L["DIST_YARDS_FMT"], yards)
    end
end

-- =========================================================================
-- 2.5 可点击富文本超链接格式化工具 (玩具 / 物品 / 技能 / 坐标)
-- =========================================================================
function Pathfinder:FormatTeleportLink(kind, id, name)
    if not id or not name then
        return ns.FormatBracket(name or L["UNKNOWN_NAME"])
    end
    local uKind = string.upper(tostring(kind or "ITEM"))
    local linkKind = "item"
    local color = "|cff00ff99"
    local icon = nil

    if uKind == "SPELL" then
        linkKind = "spell"
        color = "|cff71d5ff"
        if C_Spell and C_Spell.GetSpellTexture then
            icon = C_Spell.GetSpellTexture(id)
        end
    elseif uKind == "TOY" then
        linkKind = "toy"
        color = "|cff00ccff"
        if C_Item and C_Item.GetItemIconByID then
            icon = C_Item.GetItemIconByID(id)
        elseif GetItemIcon then
            icon = GetItemIcon(id)
        end
    else
        linkKind = "item"
        color = "|cff00ff99"
        if C_Item and C_Item.GetItemIconByID then
            icon = C_Item.GetItemIconByID(id)
        elseif GetItemIcon then
            icon = GetItemIcon(id)
        end
    end

    local iconTag = icon and string.format("|T%s:14:14:0:0|t", tostring(icon)) or ""
    return string.format("%s|Hporta:%s:%d|h%s%s|r|h", iconTag, linkKind, id, color, ns.FormatBracket(name))
end

function Pathfinder:FormatCoordLink(mapID, x, y)
    if not x or not y then return "" end
    local pctX = (x <= 1.0) and (x * 100) or x
    local pctY = (y <= 1.0) and (y * 100) or y
    return string.format("|Hporta:coord:%d:%.2f:%.2f|h|cffffd100(%.2f, %.2f)|r|h", mapID or 0, pctX, pctY, pctX, pctY)
end

-- =========================================================================
-- 3. 真实物理连通的陆地大陆划分 (仅收录可物理直飞的开阔地表区域)
-- =========================================================================
local CONTIGUOUS_CONTINENTS = {
    [12] = {
        1, 7, 10, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 74, 76, 77, 78, 80,
        81, 83, 85, 88, 198, 199, 1527
    },
    [13] = {
        14, 15, 17, 18, 21, 22, 23, 25, 26, 27, 32, 33, 36, 37, 42, 48, 50,
        51, 52, 55, 56, 84, 87, 217, 224, 241, 2070
    },
    [113] = {
        114, 115, 116, 117, 118, 119, 120, 121, 123, 125, 127
    },
    [424] = {
        371, 376, 379, 388, 390, 391, 392, 393, 394, 418, 422, 433, 554, 1530
    },
    [572] = {
        525, 534, 535, 539, 542, 543, 550, 582, 588, 590, 622, 624
    },
    [101] = {
        100, 102, 104, 105, 107, 108, 109, 111
    },
    [619] = {
        627, 630, 634, 641, 646, 647, 650, 680, 790
    },
    [905] = {
        830, 882, 885, 971
    },
    [875] = {
        862, 863, 864, 1163, 1165
    },
    [876] = {
        895, 896, 942, 1161, 1462
    },
    [1978] = {
        2022, 2023, 2024, 2025, 2112, 2133, 2151
    },
    [2274] = {
        2248, 2339, 2213, 2214, 2215, 2216, 2255, 2256
    },
    [2400] = {
        2401, 2402, 2403, 2404, 2405, 2406, 2407
    },
    [2537] = {
        2393, 2395, 2405, 2413, 2424, 2437, 2444, 2509, 2512, 2536, 2576, 2613
    },
}

local ZONE_TO_CONTINENT = {}
for contID, zones in pairs(CONTIGUOUS_CONTINENTS) do
    ZONE_TO_CONTINENT[contID] = contID
    for _, zID in ipairs(zones) do
        ZONE_TO_CONTINENT[zID] = contID
    end
end

-- 供工程学虫洞发生器匹配目标大洲使用（包含不可直飞但同属该资料片大洲的子区域，如雷神岛、暗影界各领域等）
local WORMHOLE_ZONE_TO_CONTINENT = {}
for zID, contID in pairs(ZONE_TO_CONTINENT) do
    WORMHOLE_ZONE_TO_CONTINENT[zID] = contID
end
for _, zID in ipairs({ 504, 507 }) do
    WORMHOLE_ZONE_TO_CONTINENT[zID] = 424 -- 潘达利亚：雷神岛、巨兽岛
end
for _, zID in ipairs({ 1550, 1670, 1671, 1525, 1533, 1536, 1543, 1565, 1961, 1970, 2016 }) do
    WORMHOLE_ZONE_TO_CONTINENT[zID] = 1550 -- 暗影界全境
end

local CONTINENT_CAPITAL_HUBS = {
    [12] = { HORDE = { 85, 88 }, ALLIANCE = {} },
    [13] = { HORDE = { 18, 50 }, ALLIANCE = { 84, 87 } },
    [113] = { HORDE = { 125 }, ALLIANCE = { 125 } },
    [424] = { HORDE = { 371, 390, 393 }, ALLIANCE = { 371, 390, 392 } },
    [572] = { HORDE = { 624, 590 }, ALLIANCE = { 622, 582 } },
    [101] = { HORDE = { 111 }, ALLIANCE = { 111 } },
    [619] = { HORDE = { 627, 630 }, ALLIANCE = { 627, 630 } },
    [905] = { HORDE = { 971 }, ALLIANCE = { 971 } },
    [875] = { HORDE = { 1163, 862 }, ALLIANCE = {} },
    [876] = { HORDE = {}, ALLIANCE = { 1161 } },
    [1978] = { HORDE = { 2112 }, ALLIANCE = { 2112 } },
    [2274] = { HORDE = { 2339 }, ALLIANCE = { 2339 } },
    [2400] = { HORDE = { 2401 }, ALLIANCE = { 2401 } },
    [2537] = { HORDE = { 2393 }, ALLIANCE = { 2393 } },
}

-- =========================================================================
-- 4. 核心子区域、主城传送大厅互通与孤立地下城通道拓扑
-- =========================================================================
local SUBZONE_CONNECTIONS = {
    -- 【主城传送大厅直达枢纽】
    { from = 85, to = 2401, x = 0.58, y = 0.90, type = "PORTAL", faction = "HORDE", note = "传送大厅：新银月城传送门", cost = 1.0 },
    { from = 2401, to = 85, x = 0.50, y = 0.50, type = "PORTAL", faction = "HORDE", note = "新银月城：奥格瑞玛传送门", cost = 1.0 },
    { from = 84, to = 2401, x = 0.41, y = 0.93, type = "PORTAL", faction = "ALLIANCE", note = "法师圣所：新银月城传送门", cost = 1.0 },
    { from = 2401, to = 84, x = 0.50, y = 0.50, type = "PORTAL", faction = "ALLIANCE", note = "新银月城：暴风城传送门", cost = 1.0 },
    { from = 85, to = 1163, x = 0.58, y = 0.90, type = "PORTAL", faction = "HORDE", note = "传送大厅：达萨罗传送门", cost = 1.0 },
    { from = 1163, to = 85, x = 0.74, y = 0.70, type = "PORTAL", faction = "HORDE", note = "大封印：奥格瑞玛传送门", cost = 1.0 },
    { from = 84, to = 1161, x = 0.41, y = 0.93, type = "PORTAL", faction = "ALLIANCE", note = "法师圣所：伯拉勒斯传送门", cost = 1.0 },
    { from = 1161, to = 84, x = 0.70, y = 0.17, type = "PORTAL", faction = "ALLIANCE", note = "贤者要塞：暴风城传送门", cost = 1.0 },

    -- 祖达萨野外 (862) <-> 达萨罗巨石印章 (1163)
    { from = 862, to = 1163, x = 0.58, y = 0.44, type = "TRANSPORT", faction = "HORDE", note = "前往达萨罗巨石印章", cost = 1.2 },
    { from = 1163, to = 862, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "HORDE", note = "前往祖达萨野外", cost = 1.2 },

    -- 提拉加德海峡野外 (895) <-> 伯拉勒斯城内 (1161)
    { from = 895, to = 1161, x = 0.67, y = 0.15, type = "TRANSPORT", faction = "ALLIANCE", note = "进入伯拉勒斯城内", cost = 1.2 },
    { from = 1161, to = 895, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "ALLIANCE", note = "前往提拉加德海峡野外", cost = 1.2 },

    -- 【纳沙塔尔 & 永恒王宫专属通道】
    { from = 1355, to = 1528, x = 0.48, y = 0.24, type = "TRANSPORT", faction = "NEUTRAL", note = "永恒王宫入口通道", cost = 1.0 },
    { from = 1528, to = 1355, x = 0.47, y = 0.32, type = "TRANSPORT", faction = "NEUTRAL", note = "永恒王宫出口通道", cost = 1.0 },

    -- 【黑石山完整体系】
    { from = 36, to = 33, x = 0.21, y = 0.33, type = "TRANSPORT", faction = "NEUTRAL", note = "黑石山大门入口", cost = 1.0 },
    { from = 33, to = 36, x = 0.50, y = 0.85, type = "TRANSPORT", faction = "NEUTRAL", note = "走出黑石山前往燃烧平原", cost = 1.0 },
    { from = 32, to = 33, x = 0.35, y = 0.84, type = "TRANSPORT", faction = "NEUTRAL", note = "黑石山大门入口", cost = 1.0 },
    { from = 33, to = 32, x = 0.45, y = 0.15, type = "TRANSPORT", faction = "NEUTRAL", note = "走出黑石山前往灼热峡谷", cost = 1.0 },
    { from = 33, to = 35, x = 0.45, y = 0.47, type = "TRANSPORT", faction = "NEUTRAL", note = "黑石深渊入口通道", cost = 1.0 },
    { from = 35, to = 33, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "NEUTRAL", note = "黑石深渊出口", cost = 1.0 },

    -- 奥达曼 / 玛拉顿 / 诺莫瑞根
    { from = 15, to = 16, x = 0.58, y = 0.43, type = "TRANSPORT", faction = "NEUTRAL", note = "奥达曼洞穴入口", cost = 1.0 },
    { from = 16, to = 15, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "NEUTRAL", note = "走出奥达曼洞穴", cost = 1.0 },
    { from = 66, to = 67, x = 0.28, y = 0.62, type = "TRANSPORT", faction = "NEUTRAL", note = "玛拉顿毒菇洞穴入口", cost = 1.0 },
    { from = 67, to = 66, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "NEUTRAL", note = "走出玛拉顿洞穴", cost = 1.0 },
    { from = 27, to = 469, x = 0.30, y = 0.37, type = "TRANSPORT", faction = "NEUTRAL", note = "诺莫瑞根升降梯入口", cost = 1.0 },
    { from = 469, to = 27, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "NEUTRAL", note = "乘升降梯返回丹莫罗", cost = 1.0 },

    -- 锦绣谷突袭位面 / 提瑞斯法历史位面 / 托达戈尔
    { from = 390, to = 1530, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "NEUTRAL", note = "锦绣谷突袭位面", cost = 1.0 },
    { from = 1530, to = 390, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "NEUTRAL", note = "常规锦绣谷位面", cost = 1.0 },
    { from = 390, to = 433, x = 0.67, y = 0.43, type = "TRANSPORT", faction = "NEUTRAL", note = "永春台入口", cost = 1.0 },
    { from = 18, to = 2070, x = 0.60, y = 0.67, type = "TRANSPORT", faction = "NEUTRAL", note = "提瑞斯法林地历史位面", cost = 1.0 },
    { from = 2070, to = 18, x = 0.60, y = 0.67, type = "TRANSPORT", faction = "NEUTRAL", note = "现代提瑞斯法林地位面", cost = 1.0 },
    { from = 895, to = 1169, x = 0.68, y = 0.58, type = "SHIP", faction = "NEUTRAL", note = "托达戈尔渡口", cost = 3.0 },
    { from = 1169, to = 895, x = 0.50, y = 0.50, type = "SHIP", faction = "NEUTRAL", note = "返回提拉加德海峡", cost = 3.0 },

    -- 【暗影界诸界连接】
    { from = 1671, to = 1533, x = 0.63, y = 0.49, type = "PORTAL", faction = "NEUTRAL", note = "晋升堡垒之门/飞行路线", cost = 2.5 },
    { from = 1533, to = 1671, x = 0.50, y = 0.50, type = "PORTAL", faction = "NEUTRAL", note = "返回奥利波斯", cost = 2.5 },
    { from = 1671, to = 1536, x = 0.49, y = 0.64, type = "PORTAL", faction = "NEUTRAL", note = "玛卓克萨斯之门/飞行路线", cost = 2.5 },
    { from = 1536, to = 1671, x = 0.50, y = 0.50, type = "PORTAL", faction = "NEUTRAL", note = "返回奥利波斯", cost = 2.5 },
    { from = 1671, to = 1565, x = 0.37, y = 0.49, type = "PORTAL", faction = "NEUTRAL", note = "炽蓝仙野之门/飞行路线", cost = 2.5 },
    { from = 1565, to = 1671, x = 0.50, y = 0.50, type = "PORTAL", faction = "NEUTRAL", note = "返回奥利波斯", cost = 2.5 },
    { from = 1671, to = 1525, x = 0.49, y = 0.35, type = "PORTAL", faction = "NEUTRAL", note = "雷文德斯之门/飞行路线", cost = 2.5 },
    { from = 1525, to = 1671, x = 0.50, y = 0.50, type = "PORTAL", faction = "NEUTRAL", note = "返回奥利波斯", cost = 2.5 },
    { from = 1670, to = 1543, x = 0.50, y = 0.50, type = "PORTAL", faction = "NEUTRAL", note = "跃入噬渊", cost = 1.2 },
    { from = 1670, to = 2016, x = 0.34, y = 0.66, type = "TRANSPORT", faction = "NEUTRAL", note = "塔扎维什飞艇渡口", cost = 2.0 },
    { from = 2016, to = 1670, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "NEUTRAL", note = "返回奥利波斯", cost = 2.0 },

    -- 【阿古斯诸界连接】
    { from = 627, to = 971, x = 0.69, y = 0.43, type = "PORTAL", faction = "NEUTRAL", note = "维迪卡尔圣光信标 (前往阿古斯)", cost = 1.0 },
    { from = 971, to = 627, x = 0.50, y = 0.50, type = "PORTAL", faction = "NEUTRAL", note = "维迪卡尔返回达拉然传送门", cost = 1.0 },
    { from = 971, to = 885, x = 0.50, y = 0.50, type = "PORTAL", faction = "NEUTRAL", note = "圣光矩阵：前往玛凯雷", cost = 1.0 },
    { from = 971, to = 882, x = 0.50, y = 0.50, type = "PORTAL", faction = "NEUTRAL", note = "圣光矩阵：前往安托兰废土", cost = 1.0 },

    -- 【银月城萨拉斯之门 / 秘蓝岛 / 查拉雷克洞窟 / 千丝之城】
    { from = 23, to = 95, x = 0.55, y = 0.12, type = "PORTAL", faction = "NEUTRAL", note = "萨拉斯之门 (进入幽魂之地)", cost = 1.0 },
    { from = 95, to = 23, x = 0.44, y = 0.90, type = "PORTAL", faction = "NEUTRAL", note = "萨拉斯之门 (进入东瘟疫之地)", cost = 1.0 },
    { from = 95, to = 110, x = 0.50, y = 0.10, type = "TRANSPORT", faction = "HORDE", note = "银月城正门", cost = 1.0 },
    { from = 110, to = 95, x = 0.50, y = 0.90, type = "TRANSPORT", faction = "HORDE", note = "离开银月城前往幽魂之地", cost = 1.0 },
    { from = 62, to = 97, x = 0.56, y = 0.92, type = "PORTAL", faction = "ALLIANCE", note = "黑海岸渡口传送门 (前往秘蓝岛)", cost = 1.0 },
    { from = 97, to = 103, x = 0.34, y = 0.21, type = "TRANSPORT", faction = "ALLIANCE", note = "埃索达正门", cost = 1.0 },
    -- 【巨龙群岛：查拉雷克洞窟 (2133) 三大地面入口与内部出口】
    -- 1. 宏图通道 / 穿孔 (索德拉苏斯 2025 / 瓦德拉肯 2112 ⇋ 查拉雷克洞窟 2133 穿孔)
    { from = 2025, to = 2133, x = 0.298, y = 0.630, type = "CAVE_ENTER", faction = "NEUTRAL", note = L["CAVE_THROUGHWAY_NAME"], cost = 1.0 },
    { from = 2112, to = 2133, x = 0.360, y = 0.510, type = "CAVE_ENTER", faction = "NEUTRAL", note = L["CAVE_THROUGHWAY_NAME"], cost = 1.0 },
    { from = 2133, to = 2025, x = 0.726, y = 0.494, type = "CAVE_EXIT", faction = "NEUTRAL", note = L["CAVE_THROUGHWAY_EXIT_NAME"], cost = 1.0 },
    { from = 2133, to = 2112, x = 0.726, y = 0.494, type = "CAVE_EXIT", faction = "NEUTRAL", note = L["CAVE_THROUGHWAY_EXIT_NAME"], cost = 1.0 },

    -- 2. 峈姆老路 (欧恩哈拉平原 2023 ⇋ 查拉雷克洞窟 2133 守卫之齿)
    { from = 2023, to = 2133, x = 0.359, y = 0.594, type = "CAVE_ENTER", faction = "NEUTRAL", note = L["CAVE_LOAMM_NAME"], cost = 1.0 },
    { from = 2133, to = 2023, x = 0.364, y = 0.588, type = "CAVE_EXIT", faction = "NEUTRAL", note = L["CAVE_LOAMM_EXIT_NAME"], cost = 1.0 },

    -- 3. 哨兵裂口 (碧蓝林海 2024 ⇋ 查拉雷克洞窟 2133 守卫之齿)
    { from = 2024, to = 2133, x = 0.180, y = 0.230, type = "CAVE_ENTER", faction = "NEUTRAL", note = L["CAVE_LOOKOUT_NAME"], cost = 1.0 },
    { from = 2133, to = 2024, x = 0.391, y = 0.657, type = "CAVE_EXIT", faction = "NEUTRAL", note = L["CAVE_LOOKOUT_EXIT_NAME"], cost = 1.0 },

    { from = 2216, to = 2256, x = 0.56, y = 0.38, type = "TRANSPORT", faction = "NEUTRAL", note = "千丝之城 / 尼鲁巴尔王宫下层通道", cost = 1.0 },
    { from = 2256, to = 2216, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "NEUTRAL", note = "返回艾基-卡赫特", cost = 1.0 },
    { from = 2339, to = 2371, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "NEUTRAL", note = "生态圆顶通道", cost = 1.0 },
    { from = 2339, to = 2437, x = 0.50, y = 0.50, type = "TRANSPORT", faction = "NEUTRAL", note = "纳洛拉克之穴通道", cost = 1.0 },
    -- 【奎尔萨拉斯：银月城阿斯塔洛的圣殿 (2393) ⇋ 盘卷蛇岛 (2512) ⇋ 阿塔乌特克地窟 (2509) ⇋ 地下坟茔 (2613)】
    { from = 2393, to = 2512, x = 0.568, y = 0.674, type = "PORTAL", faction = "NEUTRAL", note = "通往盘卷蛇岛的传送门", cost = 1.0 },
    { from = 2512, to = 2393, x = 0.582, y = 0.485, type = "PORTAL", faction = "NEUTRAL", note = "通往阿斯塔洛的圣殿的传送门", cost = 1.0 },

    -- 阿塔乌特克地窟三大地表大门与内部出口
    -- 1. 蛇眼之门 (北门)
    { from = 2512, to = 2509, x = 0.4372, y = 0.4419, type = "CAVE_ENTER", faction = "NEUTRAL", note = L["CAVE_ATAL_NORTH_NAME"], cost = 1.0 },
    { from = 2509, to = 2512, x = 0.4383, y = 0.4424, type = "CAVE_EXIT", faction = "NEUTRAL", note = L["CAVE_ATAL_NORTH_EXIT_NAME"], cost = 1.0 },

    -- 2. 西牙之门 (西门)
    { from = 2512, to = 2509, x = 0.3129, y = 0.6418, type = "CAVE_ENTER", faction = "NEUTRAL", note = L["CAVE_ATAL_WEST_NAME"], cost = 1.0 },
    { from = 2509, to = 2512, x = 0.3110, y = 0.6494, type = "CAVE_EXIT", faction = "NEUTRAL", note = L["CAVE_ATAL_WEST_EXIT_NAME"], cost = 1.0 },

    -- 3. 东牙之门 (东门)
    { from = 2512, to = 2509, x = 0.4567, y = 0.6490, type = "CAVE_ENTER", faction = "NEUTRAL", note = L["CAVE_ATAL_EAST_NAME"], cost = 1.0 },
    { from = 2509, to = 2512, x = 0.4590, y = 0.6493, type = "CAVE_EXIT", faction = "NEUTRAL", note = L["CAVE_ATAL_EAST_EXIT_NAME"], cost = 1.0 },

    { from = 2509, to = 2613, x = 0.472, y = 0.450, type = "TRANSPORT", faction = "NEUTRAL", note = "进入地下坟茔 (基西克斯破封)", cost = 1.0 },
    { from = 2613, to = 2509, x = 0.500, y = 0.500, type = "TRANSPORT", faction = "NEUTRAL", note = "返回阿塔乌特克地窟", cost = 1.0 },

    -- 【暗月马戏团主城秘法师直达通道】
    { from = 85, to = 407, x = 0.48, y = 0.70, type = "TRANSPORT", faction = "HORDE", note = "暗月马戏团秘法师 (力量谷入口)", isDarkmoon = true, cost = 1.0 },
    { from = 88, to = 407, x = 0.54, y = 0.51, type = "TRANSPORT", faction = "HORDE", note = "暗月马戏团秘法师 (长者高地)", isDarkmoon = true, cost = 1.0 },
    { from = 84, to = 407, x = 0.62, y = 0.32, type = "TRANSPORT", faction = "ALLIANCE", note = "暗月马戏团秘法师 (法师区)", isDarkmoon = true, cost = 1.0 },
    { from = 87, to = 407, x = 0.61, y = 0.89, type = "TRANSPORT", faction = "ALLIANCE", note = "暗月马戏团秘法师 (平民区)", isDarkmoon = true, cost = 1.0 },

    -- 【死亡骑士职业大厅：阿彻鲁斯黑锋要塞 (647)】
    { from = 647, to = 646, x = 0.50, y = 0.50, type = "FLY", faction = "NEUTRAL", note = "俯冲飞往破碎海滩野外", cost = 0.8 },
    { from = 646, to = 647, x = 0.45, y = 0.60, type = "FLY", faction = "NEUTRAL", note = "飞往阿彻鲁斯：黑锋要塞", cost = 0.8 },
    { from = 647, to = 627, x = 0.28, y = 0.35, type = "PORTAL", faction = "NEUTRAL", note = "阿彻鲁斯：达拉然传送门", cost = 1.0 },
    { from = 627, to = 647, x = 0.68, y = 0.42, type = "PORTAL", faction = "NEUTRAL", note = "克拉苏斯平台：黑锋要塞传送门", cost = 1.0 },
}

-- =========================================================================
-- 5. 零内存分配最小优先队列 (Flat Array Min-Heap 实现)
-- =========================================================================
local heapNodes = {}
local heapCosts = {}
local heapSize = 0

local function HeapPush(node, cost)
    heapSize = heapSize + 1
    local idx = heapSize
    heapNodes[idx] = node
    heapCosts[idx] = cost
    while idx > 1 do
        local parent = math.floor(idx / 2)
        if heapCosts[idx] < heapCosts[parent] then
            heapNodes[idx], heapNodes[parent] = heapNodes[parent], heapNodes[idx]
            heapCosts[idx], heapCosts[parent] = heapCosts[parent], heapCosts[idx]
            idx = parent
        else
            break
        end
    end
end

local function HeapPop()
    if heapSize == 0 then return nil, nil end
    local topNode = heapNodes[1]
    local topCost = heapCosts[1]
    local lastNode = heapNodes[heapSize]
    local lastCost = heapCosts[heapSize]
    heapNodes[heapSize] = nil
    heapCosts[heapSize] = nil
    heapSize = heapSize - 1

    if heapSize > 0 then
        heapNodes[1] = lastNode
        heapCosts[1] = lastCost
        local idx = 1
        while true do
            local left = idx * 2
            local right = idx * 2 + 1
            local smallest = idx
            if left <= heapSize and heapCosts[left] < heapCosts[smallest] then
                smallest = left
            end
            if right <= heapSize and heapCosts[right] < heapCosts[smallest] then
                smallest = right
            end
            if smallest ~= idx then
                heapNodes[idx], heapNodes[smallest] = heapNodes[smallest], heapNodes[idx]
                heapCosts[idx], heapCosts[smallest] = heapCosts[smallest], heapCosts[idx]
                idx = smallest
            else
                break
            end
        end
    end
    return topNode, topCost
end

local function HeapReset()
    for i = 1, heapSize do
        heapNodes[i] = nil
        heapCosts[i] = nil
    end
    heapSize = 0
end

-- 军团再临职业大厅专属地图（仅对应职业可进出，严禁跨职业借道）
local CLASS_HALL_MAPS = {
    [24] = "PALADIN",       -- 圣光之愿礼拜堂圣所
    [626] = "ROGUE",        -- 无冕者密室
    [695] = "WARRIOR",      -- 苍穹要塞
    [702] = "PRIEST",       -- 虚空之光神殿
    [720] = "DEMONHUNTER",  -- 邪能之槌
    [726] = "SHAMAN",       -- 漩涡之隙
    [717] = "WARLOCK",      -- 恐惧痕迹
    [747] = "DRUID",        -- 梦境林地
    [647] = "DEATHKNIGHT",  -- 阿彻鲁斯：黑锋要塞
    [648] = "DEATHKNIGHT",  -- 阿彻鲁斯：黑锋要塞下层
    [739] = "HUNTER",       -- 神射手营地
    [715] = "DRUID",        -- 翡翠梦境之道
    [734] = "MAGE",         -- 守护者圣殿
}

-- =========================================================================
-- 历史时间线/多位面区域与兹多米 (Zidormi) 切换 NPC 定义表
-- =========================================================================
local PHASE_SHIFT_ZONES = {
    [81] = { -- 希利苏斯 (Silithus)
        npcMapID = 81,
        x = 0.789,
        y = 0.220,
        tipKey = "PHASE_TIP_SILITHUS",
        relatedMaps = { [81] = true, [1021] = true, [1473] = true, [1604] = true, [2321] = true },
    },
    [18] = { -- 提瑞斯法林地 / 幽暗城 (Tirisfal Glades / Undercity)
        npcMapID = 18,
        x = 0.695,
        y = 0.628,
        tipKey = "PHASE_TIP_TIRISFAL",
        relatedMaps = { [18] = true, [90] = true, [2070] = true },
    },
    [390] = { -- 锦绣谷 (Vale of Eternal Blossoms)
        npcMapID = 390,
        x = 0.805,
        y = 0.320,
        tipKey = "PHASE_TIP_VALE",
        relatedMaps = { [390] = true, [1530] = true },
    },
    [1527] = { -- 奥丹姆 (Uldum)
        npcMapID = 1527,
        x = 0.560,
        y = 0.351,
        tipKey = "PHASE_TIP_ULDUM",
        relatedMaps = { [249] = true, [1527] = true },
    },
    [17] = { -- 诅咒之地 (Blasted Lands)
        npcMapID = 17,
        x = 0.482,
        y = 0.073,
        tipKey = "PHASE_TIP_BLASTED_LANDS",
        relatedMaps = { [17] = true },
    },
    [62] = { -- 黑海岸 / 达纳苏斯 (Darkshore / Darnassus)
        npcMapID = 62,
        x = 0.489,
        y = 0.245,
        tipKey = "PHASE_TIP_DARKSHORE",
        relatedMaps = { [62] = true, [89] = true },
    },
    [14] = { -- 阿拉希高地 (Arathi Highlands)
        npcMapID = 14,
        x = 0.382,
        y = 0.901,
        tipKey = "PHASE_TIP_ARATHI",
        relatedMaps = { [14] = true },
    },
    [70] = { -- 尘泥沼泽 / 塞拉摩 (Dustwallow Bay / Theramore)
        npcMapID = 70,
        x = 0.564,
        y = 0.500,
        tipKey = "PHASE_TIP_THERAMORE",
        relatedMaps = { [70] = true },
    },
}

local MAP_TO_PHASE_INFO = {}
for _, entry in pairs(PHASE_SHIFT_ZONES) do
    for mID in pairs(entry.relatedMaps) do
        MAP_TO_PHASE_INFO[mID] = entry
    end
end

-- 获取指定地图对应的时间线位面切换信息
function Pathfinder:GetPhaseShiftInfo(mapID)
    if not mapID then return nil end
    local entry = MAP_TO_PHASE_INFO[mapID]
    if not entry then return nil end
    local coordLink = self:FormatCoordLink(entry.npcMapID, entry.x, entry.y)
    return {
        zoneName = GetMapDisplayName(entry.npcMapID),
        npcName = L["NPC_ZIDORMI"] or "兹多米",
        npcMapID = entry.npcMapID,
        x = entry.x,
        y = entry.y,
        tip = L[entry.tipKey] or "",
        coordLink = coordLink,
    }
end

-- =========================================================================
-- 6. 构建双向拓扑图 (支持正向与反向遍历及常驻内存缓存，杜绝重复构图 GC)
-- =========================================================================
local cachedRevAdj = nil
local cachedFwdAdj = nil
local cachedGraphFaction = nil

local function GetGraphData(playerFaction)
    playerFaction = playerFaction or ns.GetPlayerFaction()
    if cachedRevAdj and cachedGraphFaction == playerFaction then
        return cachedRevAdj, cachedFwdAdj
    end

    local revAdj = {}
    local fwdAdj = {}
    local edgeSet = {}

    local _, _, playerRaceID = UnitRace("player")
    local isDarkIron = (playerRaceID == 34)
    local _, playerClass = UnitClass("player")
    local isTimeways = IsTimewaysActive()

    local function addEdge(fromNode, toNode, x, y, edgeType, faction, note, cost, questID, achievementID, isDarkmoon)
        if not fromNode or not toNode or fromNode == toNode then return end
        if edgeType == "MOLE_MACHINE" and not isDarkIron then return end

        -- 1. 资料片与赛季生命周期守卫：千禧阈限 (2266)
        if (fromNode == 2266 or toNode == 2266) and not isTimeways then
            return
        end

        -- 2. 职业专属大厅地图隔离（防止跨职业穿梭圣所/大厅通道）
        local reqClass = CLASS_HALL_MAPS[fromNode] or CLASS_HALL_MAPS[toNode]
        if reqClass and reqClass ~= playerClass then
            return
        end

        local fMatch = (faction == "NEUTRAL") or (faction == playerFaction)
        if not fMatch then return end

        local edge = {
            from = fromNode,
            to = toNode,
            x = x or 0.5,
            y = y or 0.5,
            type = edgeType or "TRANSPORT",
            faction = faction or "NEUTRAL",
            note = note or "",
            cost = cost or (EDGE_COSTS[edgeType] or 1.5),
            questID = questID,
            achievementID = achievementID,
            isDarkmoon = isDarkmoon or (fromNode == 407 or toNode == 407),
        }

        -- 避免上游 MapNotes 中粗糙提取的 2512->2509 边与手工校准的 CAVE_ENTER 边重复
        if edgeType == "TRANSPORT" and fromNode == 2512 and toNode == 2509 then
            if fwdAdj[2512] then
                for _, existEdge in ipairs(fwdAdj[2512]) do
                    if existEdge.to == 2509 and math.abs(existEdge.x - (x or 0.5)) < 0.05 and math.abs(existEdge.y - (y or 0.5)) < 0.05 then
                        return
                    end
                end
            end
        end

        -- 同一地图上的同一交互点可能同时来自 MapNotes 与手工拓扑；保留第一条，并只补齐缺失的前置 ID
        local edgeKey = string.format(
            '%d|%d|%.6f|%.6f|%s|%s',
            edge.from, edge.to, edge.x, edge.y, edge.type, edge.faction
        )
        local existing = edgeSet[edgeKey]
        if existing then
            if not existing.questID and edge.questID then
                existing.questID = edge.questID
            end
            if not existing.achievementID and edge.achievementID then
                existing.achievementID = edge.achievementID
            end
            return
        end
        edgeSet[edgeKey] = edge

        if not revAdj[toNode] then revAdj[toNode] = {} end
        table.insert(revAdj[toNode], edge)

        if not fwdAdj[fromNode] then fwdAdj[fromNode] = {} end
        table.insert(fwdAdj[fromNode], edge)
    end

    -- 优先加载手工定义的高精通道 (SUBZONE_CONNECTIONS)
    for _, s in ipairs(SUBZONE_CONNECTIONS) do
        addEdge(s.from, s.to, s.x, s.y, s.type, s.faction, s.note, s.cost or EDGE_COSTS[s.type], s.questID, s.achievementID, s.isDarkmoon)
    end

    if ns.PortaData and ns.PortaData.transports then
        for _, t in ipairs(ns.PortaData.transports) do
            addEdge(t.from, t.to, t.x, t.y, t.type, t.faction, t.note, EDGE_COSTS[t.type], t.questID, t.achievementID)
        end
    end

    cachedRevAdj = revAdj
    cachedFwdAdj = fwdAdj
    cachedGraphFaction = playerFaction

    return cachedRevAdj, cachedFwdAdj
end

-- =========================================================================
-- 7. 核心反推算法：从目的地逆向 Dijkstra 求解全局到达成本与后继指针
-- =========================================================================
function Pathfinder:ReverseDijkstra(destMapID, playerFaction, currentMapID)
    if not destMapID then return {}, {}, {} end

    local revAdj, fwdAdj = GetGraphData(playerFaction)
    local dist = {}
    local nextEdge = {}

    local isDarkmoonOpen = GetDarkmoonFaireStatus()

    HeapReset()
    dist[destMapID] = 0
    HeapPush(destMapID, 0)

    while heapSize > 0 do
        local curr, currCost = HeapPop()

        if currCost <= dist[curr] then
            -- 1. 沿所有真实物理入边 (u -> curr) 逆向回溯
            local incoming = revAdj[curr]
            if incoming then
                for _, edge in ipairs(incoming) do
                    local skipEdge = false
                    local edgeCost = edge.cost or (EDGE_COSTS[edge.type] or 1.5)

                    -- 暗月马戏团周期守卫：未开放期间禁止经暗月岛中转；目的地非暗月岛时跳过；若是暗月岛则仅允许单向进入
                    local isDarkmoonEdge = edge.isDarkmoon or (edge.from == 407) or (edge.to == 407)
                    if isDarkmoonEdge and not isDarkmoonOpen then
                        if destMapID ~= 407 or edge.from == 407 then
                            skipEdge = true
                        end
                    end

                    -- 前置任务守卫：未解锁的任务/成就门禁止作为中转枢纽通道
                    if not skipEdge then
                        local isUnlocked = self:CheckPortalQuestStatus(edge, playerFaction)
                        if not isUnlocked then
                            if edge.to ~= destMapID then
                                skipEdge = true
                            else
                                edgeCost = edgeCost + 10.0
                            end
                        end
                    end

                    if not skipEdge then
                        local u = edge.from
                        local newCost = currCost + edgeCost

                        if not dist[u] or newCost < dist[u] then
                            dist[u] = newCost
                            nextEdge[u] = edge
                            HeapPush(u, newCost)
                        end
                    end
                end
            end

            -- 2. 同大陆物理飞行连通扩展 (仅限地表地图；地下区域必须通过洞窟出入口通道通行)
            local contID = ZONE_TO_CONTINENT[curr]
            if contID and not UNDERGROUND_ZONES[curr] then
                -- 2a. 大陆主城枢纽直飞扩展
                local hubs = CONTINENT_CAPITAL_HUBS[contID] and CONTINENT_CAPITAL_HUBS[contID][playerFaction] or {}
                for _, h in ipairs(hubs) do
                    if h ~= curr and not UNDERGROUND_ZONES[h] then
                        local flyCost = currCost + (EDGE_COSTS.FLY or 2.0)
                        if not dist[h] or flyCost < dist[h] then
                            dist[h] = flyCost
                            nextEdge[h] = {
                                from = h,
                                to = curr,
                                x = 0.5,
                                y = 0.5,
                                type = "FLY",
                                faction = "NEUTRAL",
                                cost = EDGE_COSTS.FLY or 2.0,
                                note = "跨区域飞行前往",
                            }
                            HeapPush(h, flyCost)
                        end
                    end
                end

                -- 2b. 若当前玩家所在地图与当前探索节点同属该地表大洲，建立地表飞行连通
                if currentMapID and currentMapID ~= curr and not UNDERGROUND_ZONES[currentMapID] and ZONE_TO_CONTINENT[currentMapID] == contID then
                    local curFlyCost = currCost + (EDGE_COSTS.FLY or 2.0)
                    if not dist[currentMapID] or curFlyCost < dist[currentMapID] then
                        dist[currentMapID] = curFlyCost
                        nextEdge[currentMapID] = {
                            from = currentMapID,
                            to = curr,
                            x = 0.5,
                            y = 0.5,
                            type = "FLY",
                            faction = "NEUTRAL",
                            cost = EDGE_COSTS.FLY or 2.0,
                            note = "飞行前往目标地表区域",
                        }
                        HeapPush(currentMapID, curFlyCost)
                    end
                end

                -- 2c. 大洲根地图节点连通扩展（支持工程学虫洞发生器等按大洲 ID 落地的传送玩具）
                if contID ~= curr then
                    local contFlyCost = currCost + (EDGE_COSTS.FLY or 2.0)
                    if not dist[contID] or contFlyCost < dist[contID] then
                        dist[contID] = contFlyCost
                        nextEdge[contID] = {
                            from = contID,
                            to = curr,
                            x = 0.5,
                            y = 0.5,
                            type = "FLY",
                            faction = "NEUTRAL",
                            cost = EDGE_COSTS.FLY or 2.0,
                            note = "在大洲内飞行前往目标区域",
                        }
                        HeapPush(contID, contFlyCost)
                    end
                end
            end
        end
    end

    HeapReset()
    return dist, nextEdge, fwdAdj
end

-- 辅助：获取黑铁矮人钻地机的当前客户端语言名称
local function GetMoleMachineName()
    if ns.PlayerTeleports and ns.PlayerTeleports.GetSpellDisplayName then
        return ns.PlayerTeleports:GetSpellDisplayName(265225, L["SPELL_NAME_265225"])
    end
    return L["SPELL_NAME_265225"]
end

-- 辅助：获取交通动作描述（若为黑铁钻地机，则内嵌可点击技能链接）
local function GetEdgeVerbText(edgeType)
    if edgeType == "MOLE_MACHINE" then
        local moleName = GetMoleMachineName()
        return string.format(L["TRANSPORT_USE_MOLE_FMT"], Pathfinder:FormatTeleportLink("SPELL", 265225, moleName))
    end
    return TRANSPORT_TEXT[edgeType] or L["TRANSPORT_DEFAULT"]
end

-- 辅助：构建最终到达终点步骤（内嵌可点击坐标链接）
local function BuildFinalArriveStep(stepIndex, destination)
    local finalDesc
    local isMoltenCore = (destination.id == 741)

    if destination.isHorrificVision then
        local entryCoord = Pathfinder:FormatCoordLink(destination.mapID, destination.x, destination.y)
        local dornName = GetMapDisplayName(destination.mapID)
        finalDesc = string.format(L["STEP_ARRIVE_HORRIFIC_VISION"], dornName, entryCoord, destination.name)
    elseif destination.type == "zone" or destination.type == "continent" then
        finalDesc = string.format(L["STEP_ARRIVE_ZONE"], destination.name)
    elseif destination.type == "delve" then
        local entryCoord = Pathfinder:FormatCoordLink(destination.mapID, destination.x, destination.y)
        finalDesc = string.format(L["STEP_ARRIVE_DELVE"] or L["STEP_ARRIVE_INSTANCE"], destination.name, entryCoord)
    else
        local entryCoord = Pathfinder:FormatCoordLink(destination.mapID, destination.x, destination.y)
        finalDesc = string.format(L["STEP_ARRIVE_INSTANCE"], destination.name, entryCoord)
        if isMoltenCore then
            local mcNpcCoord = Pathfinder:FormatCoordLink(33, 0.543, 0.848)
            finalDesc = finalDesc .. string.format(L["STEP_ARRIVE_MC_HINT"], mcNpcCoord)
        end
    end

    local phaseInfo = Pathfinder:GetPhaseShiftInfo(destination.mapID)
    if phaseInfo then
        finalDesc = finalDesc .. string.format(L["STEP_ARRIVE_PHASE_HINT"], phaseInfo.coordLink, phaseInfo.npcName)
    end

    return {
        stepIndex = stepIndex,
        mapID = destination.mapID,
        x = destination.x,
        y = destination.y,
        action = "ARRIVE",
        description = finalDesc,
        isFinal = true,
        isPhaseShiftZone = (phaseInfo ~= nil),
        phaseShiftInfo = phaseInfo,
    }
end

-- =========================================================================
-- 8. 辅助：根据一条起始边与后继指针生成完整步骤序列
-- =========================================================================
local function BuildStepsFromStart(startEdge, destMapID, destination, nextEdge, playerFaction)
    local steps = {}
    local stepCount = 0

    local currNode = startEdge.to
    stepCount = stepCount + 1

    local fromName = GetMapDisplayName(startEdge.from)
    local toName = GetMapDisplayName(startEdge.to)
    local verb = GetEdgeVerbText(startEdge.type)
    local distYards = Pathfinder:GetDistanceInYards(startEdge.from, startEdge.x, startEdge.y)
    local distTag = distYards and string.format(L["STEP_DIST_TAG_FMT"], FormatDistanceText(distYards)) or ""
    local startCoord = Pathfinder:FormatCoordLink(startEdge.from, startEdge.x, startEdge.y)

    local firstUnlocked, firstGate = Pathfinder:CheckPortalQuestStatus(startEdge, playerFaction)

    local isDarkmoonStart = (startEdge.to == 407) and (startEdge.from == 85 or startEdge.from == 84 or startEdge.from == 88 or startEdge.from == 87)
    local isDarkmoonOpen, nextDarkmoonDate = GetDarkmoonFaireStatus()

    local firstDesc
    if isDarkmoonStart then
        local statusNotice = isDarkmoonOpen and L["DARKMOON_FAIRE_OPEN_TAG"] or string.format(L["DARKMOON_FAIRE_CLOSED_TAG_FMT"], nextDarkmoonDate)
        firstDesc = string.format(L["STEP_DARKMOON_NPC"], fromName, startCoord, distTag, statusNotice)
    elseif startEdge.type == "FLY" then
        firstDesc = string.format(L["STEP_START_FLY"], fromName, toName)
    elseif startEdge.type == "PORTAL" then
        firstDesc = string.format(L["STEP_START_PORTAL"], fromName, startCoord, distTag, toName)
    elseif startEdge.type == "SHIP" then
        firstDesc = string.format(L["STEP_START_SHIP"], fromName, startCoord, distTag, toName)
    elseif startEdge.type == "ZEPPELIN" then
        firstDesc = string.format(L["STEP_START_ZEPPELIN"], fromName, startCoord, distTag, toName)
    elseif startEdge.type == "CAVE_ENTER" then
        firstDesc = string.format(L["STEP_START_CAVE_ENTER"], fromName, startCoord, distTag, toName)
    elseif startEdge.type == "CAVE_EXIT" then
        firstDesc = string.format(L["STEP_START_CAVE_EXIT"], fromName, startCoord, distTag, toName)
    elseif startEdge.type == "TRANSPORT" then
        firstDesc = string.format(L["STEP_START_TRANSPORT"], fromName, startCoord, distTag, toName)
    else
        firstDesc = string.format(L["STEP_START_GENERIC"], fromName, startCoord, distTag, verb, toName)
    end
    if not firstUnlocked and firstGate then
        firstDesc = firstDesc .. L["QUEST_GATE_INLINE_TAG"]
    end

    local moleName = (startEdge.type == "MOLE_MACHINE") and GetMoleMachineName() or nil

    table.insert(steps, {
        stepIndex = stepCount,
        mapID = startEdge.from,
        x = startEdge.x,
        y = startEdge.y,
        toMapID = startEdge.to,
        action = startEdge.type,
        description = firstDesc,
        isFinal = false,
        distanceYards = distYards,
        isQuestGated = (not firstUnlocked and firstGate ~= nil),
        questGateInfo = (not firstUnlocked and firstGate ~= nil) and firstGate or nil,
        teleportInfo = (startEdge.type == "MOLE_MACHINE") and { kind = "SPELL", id = 265225, name = moleName, hasItem = true } or nil,
    })

    -- 沿后继指针继续推导
    local visitedMaps = { [startEdge.from] = true }
    local guard = 0
    while currNode ~= destMapID and nextEdge[currNode] and guard < 20 do
        guard = guard + 1
        if visitedMaps[currNode] then
            -- 环路检测：如果在到达目的地前重复访问了某地图，直接废弃此分支
            return nil
        end
        visitedMaps[currNode] = true

        local edge = nextEdge[currNode]
        stepCount = stepCount + 1

        local fName = GetMapDisplayName(edge.from)
        local tName = GetMapDisplayName(edge.to)
        local v = GetEdgeVerbText(edge.type)
        local isUnlocked, gateConfig = Pathfinder:CheckPortalQuestStatus(edge, playerFaction)
        local questTag = (not isUnlocked and gateConfig) and L["QUEST_GATE_INLINE_TAG"] or ""

        local desc
        if (edge.to == 407) and (edge.from == 85 or edge.from == 84 or edge.from == 88 or edge.from == 87) then
            local edgeCoord = Pathfinder:FormatCoordLink(edge.from, edge.x, edge.y)
            local statusNotice = isDarkmoonOpen and L["DARKMOON_FAIRE_OPEN_TAG"] or string.format(L["DARKMOON_FAIRE_CLOSED_TAG_FMT"], nextDarkmoonDate)
            desc = string.format(L["STEP_DARKMOON_NPC_HOP"], fName, edgeCoord, statusNotice)
        elseif edge.type == "FLY" then
            desc = string.format(L["STEP_HOP_FLY"], fName, tName, questTag)
        elseif edge.type == "CAVE_ENTER" then
            local edgeCoord = Pathfinder:FormatCoordLink(edge.from, edge.x, edge.y)
            desc = string.format(L["STEP_HOP_CAVE_ENTER"], fName, edgeCoord, tName, questTag)
        elseif edge.type == "CAVE_EXIT" then
            local edgeCoord = Pathfinder:FormatCoordLink(edge.from, edge.x, edge.y)
            desc = string.format(L["STEP_HOP_CAVE_EXIT"], fName, edgeCoord, tName, questTag)
        else
            local edgeCoord = Pathfinder:FormatCoordLink(edge.from, edge.x, edge.y)
            desc = string.format(L["STEP_HOP_GENERIC"], fName, edgeCoord, v, tName, questTag)
        end

        local hopMoleName = (edge.type == "MOLE_MACHINE") and GetMoleMachineName() or nil

        table.insert(steps, {
            stepIndex = stepCount,
            mapID = edge.from,
            x = edge.x,
            y = edge.y,
            toMapID = edge.to,
            action = edge.type,
            description = desc,
            isFinal = false,
            isQuestGated = (not isUnlocked and gateConfig ~= nil),
            questGateInfo = (not isUnlocked and gateConfig ~= nil) and gateConfig or nil,
            teleportInfo = (edge.type == "MOLE_MACHINE") and { kind = "SPELL", id = 265225, name = hopMoleName, hasItem = true } or nil,
        })

        currNode = edge.to
    end

    -- 必须确实到达了目标地图，否则路径无效
    if currNode ~= destMapID then
        return nil
    end

    -- 最终终点
    stepCount = stepCount + 1
    table.insert(steps, BuildFinalArriveStep(stepCount, destination))

    return steps
end

-- 辅助：根据通用定点传送手段 (玩具/物品/技能) 构建完整步骤列表
local function BuildTeleportRouteSteps(tp, destMapID, destination, nextEdge, playerFaction)
    local tpSteps = {}
    local linkStr = Pathfinder:FormatTeleportLink(tp.type, tp.id, tp.name)
    local coordStr = Pathfinder:FormatCoordLink(tp.toMap, tp.x or 0.5, tp.y or 0.5)

    local statusTag = ""
    if not tp.hasItem then
        statusTag = string.format(L["STATUS_MISSING_TAG_FMT"], tp.missingShortTag or L["TAG_MISSING"])
    elseif not tp.isReady and (tp.cdSeconds or 0) > 0 then
        statusTag = string.format(L["STATUS_CD_TAG_FMT"], tp.cdSeconds)
    else
        statusTag = L["STATUS_READY_TAG"]
    end

    local actionPrefix = L["ACTION_USE_ITEM"]
    if tp.type == "SPELL" then
        actionPrefix = L["ACTION_CAST_SPELL"]
    elseif tp.type == "TOY" then
        actionPrefix = L["ACTION_USE_TOY"]
    end

    local toMapName = GetMapDisplayName(tp.toMap)
    local noteSuffix = (tp.note and tp.note ~= "") and (" (" .. tp.note .. ")") or ""

    table.insert(tpSteps, {
        stepIndex = 1,
        mapID = tp.toMap,
        x = tp.x or 0.5,
        y = tp.y or 0.5,
        toMapID = tp.toMap,
        action = tp.type,
        description = string.format(L["STEP_TELEPORT_USE"], actionPrefix, linkStr, statusTag, toMapName, coordStr, noteSuffix),
        isFinal = false,
        isMissingTeleport = (not tp.hasItem),
        teleportInfo = tp,
    })

    local curr = tp.toMap
    local guard = 0
    local visitedTpMaps = { [tp.toMap] = true }

    while curr ~= destMapID and nextEdge[curr] and guard < 20 do
        guard = guard + 1
        local edge = nextEdge[curr]
        if visitedTpMaps[edge.to] then
            return nil
        end
        visitedTpMaps[edge.to] = true

        local fName = GetMapDisplayName(edge.from)
        local tName = GetMapDisplayName(edge.to)
        local v = GetEdgeVerbText(edge.type)
        local isUnlocked, gateConfig = Pathfinder:CheckPortalQuestStatus(edge, playerFaction)
        local questTag = (not isUnlocked and gateConfig) and L["QUEST_GATE_INLINE_TAG"] or ""

        local stepDesc
        if edge.type == "FLY" then
            stepDesc = string.format(L["STEP_HOP_FLY"], fName, tName, questTag)
        else
            local edgeCoord = Pathfinder:FormatCoordLink(edge.from, edge.x, edge.y)
            stepDesc = string.format(L["STEP_HOP_GENERIC"], fName, edgeCoord, v, tName, questTag)
        end

        local hopMoleName = (edge.type == "MOLE_MACHINE") and GetMoleMachineName() or nil

        table.insert(tpSteps, {
            stepIndex = #tpSteps + 1,
            mapID = edge.from,
            x = edge.x,
            y = edge.y,
            toMapID = edge.to,
            action = edge.type,
            description = stepDesc,
            isFinal = false,
            isQuestGated = (not isUnlocked and gateConfig ~= nil),
            questGateInfo = (not isUnlocked and gateConfig ~= nil) and gateConfig or nil,
            teleportInfo = (edge.type == "MOLE_MACHINE") and { kind = "SPELL", id = 265225, name = hopMoleName, hasItem = true } or nil,
        })
        curr = edge.to
    end

    if curr ~= destMapID then
        return nil
    end

    table.insert(tpSteps, BuildFinalArriveStep(#tpSteps + 1, destination))
    return tpSteps
end

-- 辅助：构建工程学虫洞发生器方案步骤（直接指引选择对应子区域）
local function BuildWormholeRouteSteps(tp, destMapID, destination)
    local linkStr = Pathfinder:FormatTeleportLink(tp.type, tp.id, tp.name)
    local statusTag
    if not tp.hasItem then
        statusTag = string.format(L["STATUS_MISSING_TAG_FMT"], tp.missingShortTag or L["TAG_MISSING"])
    elseif not tp.isReady and (tp.cdSeconds or 0) > 0 then
        statusTag = string.format(L["STATUS_CD_TAG_FMT"], tp.cdSeconds)
    else
        statusTag = L["STATUS_READY_TAG"]
    end

    local destZoneName = GetMapDisplayName(destMapID)
    local stepDesc = string.format(L["STEP_WORMHOLE"] or L["STEP_WORMHOLE_MENU"], linkStr, statusTag, destZoneName)

    return {
        {
            stepIndex = 1,
            mapID = tp.toMap,
            x = tp.x or 0.5,
            y = tp.y or 0.5,
            toMapID = destMapID,
            action = tp.type,
            description = stepDesc,
            isFinal = false,
            isMissingTeleport = (not tp.hasItem),
            teleportInfo = tp,
        },
        BuildFinalArriveStep(2, destination),
    }
end

-- =========================================================================
-- 9. 智能路线计算主引擎 (支持多起始点感知、距离择优与多备选方案列表)
-- =========================================================================
function Pathfinder:CalculateRoute(destination)
    if not destination or not destination.mapID then return nil end

    local currentMapID = C_Map.GetBestMapForUnit("player")
    if not currentMapID then
        ns.Print(L["ERR_NO_PLAYER_MAP"])
        return nil
    end

    local playerFaction = ns.GetPlayerFaction()
    local destMapID = destination.mapID

    -- 0. 检查千禧阈限 (2266) 是否在当前版本/赛季中有效开放
    if destMapID == 2266 and not IsTimewaysActive() then
        ns.Print(L["ERR_TIMEWAYS_INACTIVE"])
        return nil
    end

    -- =====================================================================
    -- 1. 已在同一地图：直接前往目标点
    -- =====================================================================
    if currentMapID == destMapID then
        local arriveDesc
        if destination.isHorrificVision then
            local coordLink = self:FormatCoordLink(destMapID, destination.x, destination.y)
            arriveDesc = string.format(L["STEP_ALREADY_IN_MAP_VISION"], coordLink, destination.name)
        elseif destination.type == "zone" or destination.type == "continent" then
            arriveDesc = string.format(L["STEP_ALREADY_IN_ZONE"], destination.name)
        elseif destination.type == "delve" then
            local coordLink = self:FormatCoordLink(destMapID, destination.x, destination.y)
            arriveDesc = string.format(L["STEP_ALREADY_IN_MAP_DELVE"] or L["STEP_ALREADY_IN_MAP_INSTANCE"], destination.name, coordLink)
        else
            local coordLink = self:FormatCoordLink(destMapID, destination.x, destination.y)
            arriveDesc = string.format(L["STEP_ALREADY_IN_MAP_INSTANCE"], destination.name, coordLink)
        end
        local phaseInfo = self:GetPhaseShiftInfo(destMapID)
        if phaseInfo then
            arriveDesc = arriveDesc .. string.format(L["STEP_ARRIVE_PHASE_HINT"], phaseInfo.coordLink, phaseInfo.npcName)
        end
        local directSteps = {
            {
                stepIndex = 1,
                mapID = destMapID,
                x = destination.x,
                y = destination.y,
                action = "DIRECT",
                description = arriveDesc,
                isFinal = true,
                isPhaseShiftZone = (phaseInfo ~= nil),
                phaseShiftInfo = phaseInfo,
            }
        }
        local directAlt = {
            name = L["ALT_DIRECT_RUN"],
            viaDesc = string.format(L["ALT_DESC_ALREADY_IN_MAP"], destination.name),
            distanceYards = self:GetDistanceInYards(destMapID, destination.x, destination.y),
            distanceText = L["ALT_DIST_SAME_MAP"],
            score = 0.5,
            steps = directSteps,
            totalSteps = 1,
            phaseShiftInfo = phaseInfo,
        }
        local visionRotationInfo = nil
        if destination.isHorrificVision and destination.visionType then
            local isActive, activeCity, nextResetDate = GetHorrificVisionRotationStatus(destination.visionType)
            visionRotationInfo = {
                isActive = isActive,
                activeCity = activeCity,
                nextResetDate = nextResetDate,
                tip = isActive and L["VISION_ACTIVE_DESC"] or string.format(L["VISION_INACTIVE_DESC_FMT"], nextResetDate),
                tag = isActive and L["VISION_ACTIVE_TAG"] or string.format(L["VISION_INACTIVE_TAG_FMT"], nextResetDate),
            }
            directAlt.visionRotationInfo = visionRotationInfo
        end
        return {
            destination = destination,
            steps = directSteps,
            totalSteps = 1,
            alternatives = { directAlt },
            selectedAltIndex = 1,
            phaseShiftInfo = phaseInfo,
            visionRotationInfo = visionRotationInfo,
        }
    end

    local alternatives = {}
    local seenTeleportIDs = {}

    -- =====================================================================
    -- 2. 专属直达传送方案收集 (大秘境门 / 副本专属玩具与道具 / 地图专属道具)
    -- 规则：玩具、物品默认当成玩家拥有并生成直达方案；若实际没有，则在方案与步骤中明确提示
    -- =====================================================================
    if ns.PlayerTeleports and ns.PlayerTeleports.GetDirectDestinationTeleports then
        local directList = ns.PlayerTeleports:GetDirectDestinationTeleports(destination)
        for _, direct in ipairs(directList) do
            seenTeleportIDs[direct.id] = true

            local linkStr = self:FormatTeleportLink(direct.type, direct.id, direct.name)
            local coordStr = self:FormatCoordLink(destMapID, destination.x, destination.y)

            local statusTag
            if not direct.hasItem then
                statusTag = string.format(L["STATUS_MISSING_TAG_FMT"], direct.missingShortTag or L["TAG_MISSING"])
            elseif direct.isReady then
                statusTag = L["STATUS_READY_TAG"]
            else
                statusTag = string.format(L["STATUS_CD_TAG_FMT"], direct.cdSeconds or 0)
            end

            local desc
            if direct.type == "SPELL" then
                desc = string.format(L["STEP_DIRECT_SPELL"], linkStr, statusTag, destination.name, coordStr)
            else
                local kindText = (direct.type == "TOY") and L["KIND_TELEPORT_TOY"] or L["KIND_TELEPORT_ITEM"]
                local noteSuffix = (direct.note and direct.note ~= "") and (" (" .. direct.note .. ")") or ""
                desc = string.format(L["STEP_DIRECT_ITEM_OR_TOY"], kindText, linkStr, statusTag, destination.name, coordStr, noteSuffix)
            end

            local directSteps = {
                {
                    stepIndex = 1,
                    mapID = destMapID,
                    x = destination.x,
                    y = destination.y,
                    action = direct.type,
                    description = desc,
                    isFinal = true,
                    isMissingTeleport = (not direct.hasItem),
                    teleportInfo = direct,
                }
            }

            local directScore = direct.isReady and 0.5 or (0.5 + math.min((direct.cdSeconds or 0) / 30, 8.0))
            local altNameFmt = (direct.type == "SPELL") and L["ALT_CAST_FMT"] or L["ALT_USE_FMT"]

            table.insert(alternatives, {
                name = string.format(altNameFmt, direct.name),
                viaDesc = direct.note or L["ALT_DESC_DIRECT"],
                distanceYards = 0,
                distanceText = L["ALT_DIST_DIRECT"],
                isMissingTeleport = (not direct.hasItem),
                missingShortTag = direct.missingShortTag,
                missingReason = direct.missingReason,
                score = directScore,
                steps = directSteps,
                totalSteps = 1,
            })
        end
    end

    -- =====================================================================
    -- 3. 核心逆向反推 (Reverse Dijkstra)
    -- =====================================================================
    local dist, nextEdge, fwdAdj = self:ReverseDijkstra(destMapID, playerFaction, currentMapID)

    local curContID = ZONE_TO_CONTINENT[currentMapID]
    local destContID = ZONE_TO_CONTINENT[destMapID]
    local isSameContinent = curContID and destContID and (curContID == destContID)

    -- 判断当前是否已处于目的地前置集结大区 (如纳沙塔尔/永恒王宫对应部落达萨罗、联盟伯拉勒斯)
    local isAtDestinationStaging = (destMapID == 1528 or destMapID == 1355) and
        ((playerFaction == "HORDE" and curContID == 875) or (playerFaction == "ALLIANCE" and curContID == 876))

    -- =====================================================================
    -- 4. 物理出发路线收集 (含传送门/交通捷径及同大陆直飞)
    -- =====================================================================
    local validPhysical = {}
    local physicalCandidates = {}
    local outEdges = fwdAdj[currentMapID] or {}

    -- 若当前地图无固定交通设施边，但有跨大陆/区域飞行后继，加入候选
    if #outEdges == 0 and nextEdge[currentMapID] then
        table.insert(outEdges, nextEdge[currentMapID])
    end

    for _, edge in ipairs(outEdges) do
        if dist[edge.to] then
            local branchSteps = BuildStepsFromStart(edge, destMapID, destination, nextEdge, playerFaction)
            if branchSteps then
                -- 大陆折返环路检测：离开当前大陆又绕回当前大陆，判定为无效绕路
                local isContinentLoop = false
                if curContID then
                    local edgeToCont = ZONE_TO_CONTINENT[edge.to]
                    if edgeToCont and edgeToCont ~= curContID then
                        for _, s in ipairs(branchSteps) do
                            if s.toMapID and ZONE_TO_CONTINENT[s.toMapID] == curContID then
                                isContinentLoop = true
                                break
                            end
                        end
                    end
                end

                if not isContinentLoop then
                    local distYards = self:GetDistanceInYards(currentMapID, edge.x, edge.y)
                    local distText = FormatDistanceText(distYards)
                    local distanceScore = distYards and (distYards / 500.0) or 1.5
                    local totalScore = distanceScore + (edge.cost or 1.5) + dist[edge.to]

                    local targetName = GetMapDisplayName(edge.to)
                    local branchName
                    if (edge.to == 407) and (edge.from == 85 or edge.from == 84 or edge.from == 88 or edge.from == 87) then
                        branchName = string.format(L["ALT_VIA_DARKMOON_NPC_FMT"], GetMapDisplayName(edge.from))
                    elseif edge.type == "CAVE_ENTER" then
                        local edgeNote = (edge.note and edge.note ~= "") and edge.note or targetName
                        branchName = string.format(L["ALT_VIA_CAVE_ENTER_FMT"], edgeNote, targetName)
                    elseif edge.type == "CAVE_EXIT" then
                        local edgeNote = (edge.note and edge.note ~= "") and edge.note or targetName
                        branchName = string.format(L["ALT_VIA_CAVE_EXIT_FMT"], edgeNote, targetName)
                    elseif edge.type == "PORTAL" then
                        branchName = string.format(L["ALT_VIA_PORTAL_FMT"], targetName)
                    elseif edge.type == "SHIP" then
                        branchName = string.format(L["ALT_VIA_SHIP_FMT"], targetName)
                    elseif edge.type == "ZEPPELIN" then
                        branchName = string.format(L["ALT_VIA_ZEPPELIN_FMT"], targetName)
                    elseif edge.type == "FLY" then
                        branchName = string.format(L["ALT_VIA_FLY_FMT"], targetName)
                    else
                        branchName = string.format(L["ALT_VIA_GENERIC_FMT"], targetName)
                    end

                    table.insert(physicalCandidates, {
                        edge = edge,
                        name = branchName,
                        viaDesc = string.format(L["ALT_VIA_COORD_FMT"], edge.x * 100, edge.y * 100, (distText ~= "" and (" [" .. distText .. "]") or "")),
                        distanceYards = distYards,
                        distanceText = distText,
                        score = totalScore,
                        steps = branchSteps,
                        totalSteps = #branchSteps,
                    })
                end
            end
        end
    end

    -- 物理候选方案按评分排序
    table.sort(physicalCandidates, function(a, b)
        return a.score < b.score
    end)

    if #physicalCandidates > 0 then
        local best = physicalCandidates[1]
        table.insert(validPhysical, best)

        -- 寻找具有独立意义的第 2 物理备选方案
        for i = 2, #physicalCandidates do
            local cand = physicalCandidates[i]
            local dx = math.abs(cand.edge.x - best.edge.x)
            local dy = math.abs(cand.edge.y - best.edge.y)
            local isCaveEdge = (cand.edge.type == "CAVE_ENTER" or cand.edge.type == "CAVE_EXIT" or best.edge.type == "CAVE_ENTER" or best.edge.type == "CAVE_EXIT")
            local isDistinctLoc
            if isCaveEdge then
                -- 地下洞窟出入口：即使去往同一张地图，不同地理坐标的入口大门即代表独立路线
                isDistinctLoc = (dx > 0.05 or dy > 0.05)
            else
                isDistinctLoc = (dx > 0.08 or dy > 0.08) and (cand.edge.to ~= best.edge.to)
            end

            local isSubzoneDetour = false
            if cand.steps[2] and best.steps[1] and cand.steps[2].toMapID == best.steps[1].toMapID then
                isSubzoneDetour = true
            end

            local isCompetitive = (cand.score <= best.score + 3.5) and (cand.score <= best.score * 1.6)

            if isDistinctLoc and not isSubzoneDetour and isCompetitive then
                table.insert(validPhysical, cand)
                break
            end
        end
    end

    -- 同大陆时：无论是否有物理交通/传送门捷径，直接飞行均可作为有效方案（无捷径时为推荐方案；有捷径时捷径优先，直飞作为备选）
    -- 注意：若当前位置或目的地涉及地下垂直层级地图（UNDERGROUND_ZONES），地表与地下之间隔着实心岩层，禁止生成穿透岩层的同大陆平原直飞！
    local isCurUnderground = (UNDERGROUND_ZONES[currentMapID] ~= nil)
    local isDestUnderground = (UNDERGROUND_ZONES[destMapID] ~= nil)
    local isCrossUnderground = (isCurUnderground ~= isDestUnderground)

    if isSameContinent and not isCrossUnderground then
        local destName = destination.name or GetMapDisplayName(destMapID)
        local flySteps = {
            {
                stepIndex = 1,
                mapID = currentMapID,
                x = destination.x,
                y = destination.y,
                toMapID = destMapID,
                action = "FLY",
                description = string.format(L["STEP_SAME_CONT_FLY"], GetMapDisplayName(currentMapID), destName),
                isFinal = false,
            },
            BuildFinalArriveStep(2, destination),
        }
        -- 若存在物理交通/传送门捷径，直接飞行评分略低于捷径（捷径优先推荐，直飞作为备选）；若无捷径，直接飞行作为首选推荐 (score 2.0)
        local flyScore = (#validPhysical > 0) and (validPhysical[1].score + 1.2) or 2.0
        table.insert(validPhysical, {
            name = string.format(L["ALT_FLY_DIRECT_FMT"], destName),
            viaDesc = L["ALT_DESC_SAME_CONT_FLY"],
            distanceYards = nil,
            distanceText = L["ALT_DIST_SAME_CONT_FLY"],
            score = flyScore,
            steps = flySteps,
            totalSteps = 2,
        })
    end

    for _, p in ipairs(validPhysical) do
        table.insert(alternatives, p)
    end

    local bestPhysicalScore = (#validPhysical > 0) and validPhysical[1].score or (dist[currentMapID] or 999)

    -- =====================================================================
    -- 5. 个人专属传送玩具/物品/技能方案 & 工程学虫洞补充方案
    -- 规则：
    -- 1) 定点传送器、玩具、物品不因未拥有或专业限制而过滤，默认纳入算路；若不满足条件则在方案中提示。
    -- 2) 工程学虫洞发生器因落点随机/不确定，不作为跨大陆通用中转枢纽，但在目的地位于对应大洲时作为补充备选方案提供。
    -- =====================================================================
    if ns.PlayerTeleports and not isAtDestinationStaging then
        local availableTeleports = ns.PlayerTeleports:GetAvailableTeleports()

        -- 预先排序：同一目标地图下，优先使用玩家已拥有、已就绪、优先级更高的传送手段
        table.sort(availableTeleports, function(a, b)
            if (a.hasItem and true or false) ~= (b.hasItem and true or false) then
                return a.hasItem and true or false
            end
            if (a.isReady and true or false) ~= (b.isReady and true or false) then
                return a.isReady and true or false
            end
            return (a.priority or 5) > (b.priority or 5)
        end)

        local tpCandidates = {}
        local wormholeCandidates = {}
        local seenTpTarget = {}
        local destWormholeCont = WORMHOLE_ZONE_TO_CONTINENT[destMapID]

        for _, tp in ipairs(availableTeleports) do
            if tp.isWormhole then
                -- 工程学虫洞发生器：仅当目的地所在大洲与虫洞大洲一致时，作为补充不确定方案纳入
                if destWormholeCont and tp.continentID == destWormholeCont and not seenTeleportIDs[tp.id] then
                    table.insert(wormholeCandidates, tp)
                end
            elseif tp.toMap and tp.toMap ~= currentMapID and dist[tp.toMap] and not seenTeleportIDs[tp.id] and not seenTpTarget[tp.toMap] then
                -- 若当前所在地图已有直达同一枢纽的物理传送门，且玩家并未持有该主城披风/戒指，则不重复叠加同落点道具
                local isRedundantWithPhysicalFirstHop = (validPhysical[1] and validPhysical[1].edge and validPhysical[1].edge.to == tp.toMap and not tp.hasItem)
                -- 若玩家已在同大陆，仅当该玩具/物品能直接把玩家送到目标地图 (dist == 0) 时才推荐
                local allowTp = (not isRedundantWithPhysicalFirstHop) and ((not isSameContinent) or (tp.toMap == destMapID) or (dist[tp.toMap] == 0))
                -- 仅当传送落点比当前地图更接近目的地时才纳入候选
                if allowTp and dist[tp.toMap] < (dist[currentMapID] or 999) then
                    seenTpTarget[tp.toMap] = true

                    local itemCost = tp.isReady and 1.0 or (1.0 + math.min((tp.cdSeconds or 0) / 30, 8.0))
                    if tp.priority and tp.priority > 8 then
                        itemCost = itemCost - 0.5
                    end
                    local totalScore = itemCost + dist[tp.toMap]

                    table.insert(tpCandidates, {
                        tp = tp,
                        score = totalScore,
                    })
                end
            end
        end

        table.sort(tpCandidates, function(a, b)
            if math.abs(a.score - b.score) > 0.01 then
                return a.score < b.score
            end
            if (a.tp.hasItem and true or false) ~= (b.tp.hasItem and true or false) then
                return a.tp.hasItem and true or false
            end
            return (a.tp.priority or 5) > (b.tp.priority or 5)
        end)

        -- 选取最优的定点传送方案：
        -- 1) 加入第 1 优方案 (firstCand)
        -- 2) 若第 1 优为职业技能 (SPELL)，且存在具有高竞争力的通用玩具/物品 (TOY / ITEM)，也可作为备选方案展示给玩家
        -- 3) 若第 1 优方案未拥有/专业不符，且存在另一款已拥有的高竞争力传送方案，也同时提供
        local chosenTpCands = {}
        if #tpCandidates > 0 then
            local firstCand = tpCandidates[1]
            if firstCand.score <= bestPhysicalScore + 0.8 then
                table.insert(chosenTpCands, firstCand)
            end
            for i = 2, #tpCandidates do
                local cand = tpCandidates[i]
                local isDifferentType = (firstCand.tp.type == "SPELL" and cand.tp.type ~= "SPELL")
                local isFallbackOwned = (not firstCand.tp.hasItem and cand.tp.hasItem)
                if (isDifferentType or isFallbackOwned) and cand.score <= bestPhysicalScore + 0.5 then
                    table.insert(chosenTpCands, cand)
                    break
                end
            end
        end

        for _, cand in ipairs(chosenTpCands) do
            local tp = cand.tp
            local tpSteps = BuildTeleportRouteSteps(tp, destMapID, destination, nextEdge, playerFaction)
            if tpSteps then
                local altNameFmt = (tp.type == "SPELL") and L["ALT_CAST_FMT"] or L["ALT_USE_FMT"]
                local fallbackViaDesc = (tp.type == "TOY" and L["ALT_DESC_TOY_TELEPORT"]) or (tp.type == "SPELL" and L["ALT_DESC_SPELL_TELEPORT"]) or L["ALT_DESC_ITEM_TELEPORT"]
                table.insert(alternatives, {
                    name = string.format(altNameFmt, tp.name),
                    viaDesc = tp.note or fallbackViaDesc,
                    distanceYards = 0,
                    distanceText = L["ALT_DIST_USE_DIRECT"],
                    isMissingTeleport = (not tp.hasItem),
                    missingShortTag = tp.missingShortTag,
                    missingReason = tp.missingReason,
                    score = cand.score,
                    steps = tpSteps,
                    totalSteps = #tpSteps,
                })
            end
        end

        -- 追加目标大洲对应的工程学虫洞发生器方案
        for _, wTp in ipairs(wormholeCandidates) do
            local wSteps = BuildWormholeRouteSteps(wTp, destMapID, destination)
            if wSteps then
                local destZoneName = GetMapDisplayName(destMapID)
                table.insert(alternatives, {
                    name = string.format(L["ALT_USE_FMT"], wTp.name),
                    viaDesc = string.format(L["ALT_DESC_WORMHOLE_FMT"] or L["ALT_DESC_WORMHOLE"], destZoneName),
                    distanceYards = 0,
                    distanceText = L["ALT_DIST_WORMHOLE"],
                    isMissingTeleport = (not wTp.hasItem),
                    missingShortTag = wTp.missingShortTag,
                    missingReason = wTp.missingReason,
                    score = math.min(bestPhysicalScore, 10.0) + 0.5,
                    steps = wSteps,
                    totalSteps = #wSteps,
                })
            end
        end
    end

    -- =====================================================================
    -- 6. 若没有找到任何可行方案，尝试常规主城炉石兜底
    -- =====================================================================
    if #alternatives == 0 then
        local hubMapID = (playerFaction == "HORDE") and 85 or 84
        if dist[hubMapID] then
            local hsName = (ns.PlayerTeleports and ns.PlayerTeleports.GetItemDisplayName and ns.PlayerTeleports:GetItemDisplayName(6948, L["ITEM_NAME_6948"])) or L["ITEM_NAME_6948"]
            local hasHearthstone, hsMissingReason = true, nil
            if ns.PlayerTeleports and ns.PlayerTeleports.CheckTeleportOwnership then
                hasHearthstone, hsMissingReason = ns.PlayerTeleports:CheckTeleportOwnership("ITEM", 6948, hsName)
            end
            local hsInfo = {
                type = "ITEM",
                id = 6948,
                name = hsName,
                toMap = hubMapID,
                x = 0.5,
                y = 0.5,
                hasItem = hasHearthstone,
                missingReason = hsMissingReason,
                isReady = true,
                cdSeconds = 0,
            }
            local hubSteps = BuildTeleportRouteSteps(hsInfo, destMapID, destination, nextEdge, playerFaction)
            if hubSteps then
                table.insert(alternatives, {
                    name = string.format(L["ALT_USE_FMT"], hsName),
                    viaDesc = L["ALT_DESC_HEARTHSTONE"],
                    distanceYards = 0,
                    distanceText = L["ALT_DIST_HEARTHSTONE"],
                    isMissingTeleport = (not hasHearthstone),
                    missingReason = hsMissingReason,
                    score = dist[hubMapID] + 5.0,
                    steps = hubSteps,
                    totalSteps = #hubSteps,
                })
            end
        end
    end

    if #alternatives == 0 then
        ns.Print(string.format(L["ERR_NO_ROUTE_FOUND_FMT"], destination.name))
        return nil
    end

    -- 暗月马戏团目标状态完善与非开放期提示
    if destMapID == 407 then
        local isDarkmoonOpen, nextDarkmoonDate = GetDarkmoonFaireStatus()
        for _, alt in ipairs(alternatives) do
            if not isDarkmoonOpen then
                alt.isDarkmoonClosed = true
                alt.viaDesc = string.format(L["DARKMOON_FAIRE_CLOSED_DESC_FMT"], nextDarkmoonDate)
                alt.distanceText = string.format(L["DARKMOON_FAIRE_CLOSED_TAG_FMT"], nextDarkmoonDate)
                alt.score = (alt.score or 5.0) + 10.0
            else
                alt.viaDesc = L["DARKMOON_FAIRE_OPEN_DESC"]
                alt.distanceText = L["DARKMOON_FAIRE_OPEN_TAG"]
            end
        end
    end

    -- 重访惊魂幻象周轮换状态与提示
    local visionRotationInfo = nil
    if destination.isHorrificVision and destination.visionType then
        local isActive, activeCity, nextResetDate = GetHorrificVisionRotationStatus(destination.visionType)
        visionRotationInfo = {
            isActive = isActive,
            activeCity = activeCity,
            nextResetDate = nextResetDate,
            tip = isActive and L["VISION_ACTIVE_DESC"] or string.format(L["VISION_INACTIVE_DESC_FMT"], nextResetDate),
            tag = isActive and L["VISION_ACTIVE_TAG"] or string.format(L["VISION_INACTIVE_TAG_FMT"], nextResetDate),
        }
        for _, alt in ipairs(alternatives) do
            alt.visionRotationInfo = visionRotationInfo
            if not isActive then
                alt.score = (alt.score or 2.0) + 5.0
            end
        end
    end

    -- 7. 对所有最终候选方案按总评分排序（玩具/物品方案默认视同已拥有参与排序，缺失时在界面与聊天中提示）
    table.sort(alternatives, function(a, b)
        if math.abs(a.score - b.score) > 0.01 then
            return a.score < b.score
        end
        if (not a.isMissingTeleport) ~= (not b.isMissingTeleport) then
            return not a.isMissingTeleport
        end
        return (a.totalSteps or 99) < (b.totalSteps or 99)
    end)

    local destPhaseInfo = self:GetPhaseShiftInfo(destMapID)
    if destPhaseInfo then
        for _, alt in ipairs(alternatives) do
            alt.phaseShiftInfo = destPhaseInfo
        end
    end

    -- 默认采用第 1 优选方案
    local selectedAlt = alternatives[1]

    return {
        destination = destination,
        steps = selectedAlt.steps,
        totalSteps = selectedAlt.totalSteps,
        alternatives = alternatives,
        selectedAltIndex = 1,
        phaseShiftInfo = destPhaseInfo,
        visionRotationInfo = visionRotationInfo,
    }
end

-- 兼容老接口
function Pathfinder:FindShortestPath(startMapID, targetMapID, playerFaction)
    if not startMapID or not targetMapID then return nil end
    if startMapID == targetMapID then return {} end

    local dist, nextEdge = self:ReverseDijkstra(targetMapID, playerFaction or ns.GetPlayerFaction(), startMapID)
    if not dist[startMapID] then return nil end

    local path = {}
    local curr = startMapID
    local guard = 0
    while curr ~= targetMapID and nextEdge[curr] and guard < 30 do
        guard = guard + 1
        local edge = nextEdge[curr]
        table.insert(path, edge)
        curr = edge.to
    end

    if curr == targetMapID then
        return path
    end
    return nil
end
