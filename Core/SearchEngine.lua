local _, ns = ...
local L = ns.L

local SearchEngine = {}
ns.SearchEngine = SearchEngine

local searchIndex = {}
local isInitialized = false

-- 类别显示文本与颜色
local TYPE_INFO = {
    dungeon   = { tag = L["TAG_DUNGEON"],   color = "|cff00ccff" },
    raid      = { tag = L["TAG_RAID"],      color = "|cffff8000" },
    delve     = { tag = L["TAG_DELVE"],     color = "|cffffff00" },
    zone      = { tag = L["TAG_ZONE"],      color = "|cff00ff00" },
    continent = { tag = L["TAG_CONTINENT"], color = "|cff00ff7f" },
}

local AZEROTH_MAP_ID = 947

-- 魔兽世界核心大洲 ID 列表
local MAJOR_CONTINENTS = {
    12,   -- 卡利姆多 (Kalimdor)
    13,   -- 东部王国 (Eastern Kingdoms)
    101,  -- 外域 (Outland)
    113,  -- 诺森德 (Northrend)
    424,  -- 潘达利亚 (Pandaria)
    572,  -- 德拉诺 (Draenor)
    619,  -- 破碎群岛 (Broken Isles)
    875,  -- 赞达拉 (Zandalar)
    876,  -- 库尔提拉斯 (Kul Tiras)
    1550, -- 暗影界 (Shadowlands)
    1978, -- 巨龙群岛 (Dragon Isles)
    2274, -- 卡兹阿加 (Khaz Algar)
    AZEROTH_MAP_ID, -- 艾泽拉斯全局：仅用于补充枚举未列出大洲下的区域 (如至暗之夜奎尔萨拉斯)，自身不作为目的地
}

-- 剔除多余首尾空白（兼容魔兽世界内置 strtrim 与标准 Lua）
local function TrimText(str)
    if type(str) ~= "string" then return "" end
    if strtrim then
        return strtrim(str)
    end
    return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
end

-- 旧位面/重复底层地图黑名单（优先使用主位面与主层地图）
local DEPRECATED_PHASE_MAPS = {
    [249]  = true, -- 奥丹姆旧位面（优先使用 1527）
    [1530] = true, -- 锦绣谷突袭位面（优先使用 390）
    [2070] = true, -- 提瑞斯法林地历史位面（优先使用 18）
    [2256] = true, -- 艾基-卡赫特下层重复图（优先使用 2255）
    [2216] = true, -- 千丝之城下层重复图（优先使用 2213）
    [2311] = true, -- 11.0 陨圣峪点亮余火废弃位面地图 (Spreading the Light - Disabled)
    [1469] = true, -- 奥格瑞玛的幻象（重访惊魂幻象统一导航至多恩诺嘉尔入口）
    [1470] = true, -- 暴风城的幻象（重访惊魂幻象统一导航至多恩诺嘉尔入口）
    [2403] = true, -- 奥格瑞玛的幻象（11.0 区域层地图，统一导航至多恩诺嘉尔入口）
    [2404] = true, -- 暴风城的幻象（11.0 区域层地图，统一导航至多恩诺嘉尔入口）
}

-- 拉丁语系常见前导定冠词（用于在匹配时支持忽略冠词检索，如输入 "stonevault" 匹配 "The Stonevault"）
local LEADING_ARTICLES = {
    "the ", "a ", "an ",
    "le ", "la ", "les ", "l'",
    "der ", "die ", "das ",
    "el ", "los ", "las ",
}

local function StripLeadingArticle(textLower)
    for _, art in ipairs(LEADING_ARTICLES) do
        if string.sub(textLower, 1, #art) == art then
            return TrimText(string.sub(textLower, #art + 1))
        end
    end
    return textLower
end

-- 规范化文本：生成将连字符/撇号/标点替换为空格的分词版本，以及完全剔除标点与空格的紧凑版本
-- 从而同时支持英文 "arakara" / "ara kara" 匹配 "Ara-Kara, City of Echoes"，以及中文 "艾拉卡拉" 匹配 "艾拉-卡拉，回响之城"
local function NormalizeTextForms(textLower)
    -- 将常见中西文标点符号替换为空格
    local spaced = textLower
        :gsub("['’`%-–—:,;!%?%.%(%)%[%]\"/\\]+", " ")
        :gsub("，", " ")
        :gsub("：", " ")
        :gsub("·", " ")
        :gsub("！", " ")
        :gsub("%s+", " ")
    spaced = TrimText(spaced)
    local compact = spaced:gsub("%s+", "")
    return spaced, compact
end

-- 创建搜索项辅助函数：预计算所有规范化检索字段，杜绝后续高频键入时的重复 gsub 与临时字符串重分配
local function CreateSearchItem(id, name, zoneName, mapID, x, y, itemType, tag, color, comment, aliases)
    local trimmedName = TrimText(name)
    local nameLower = string.lower(trimmedName)
    local noArticle = StripLeadingArticle(nameLower)
    local spaced, compact = NormalizeTextForms(nameLower)
    local noArtSpaced, noArtCompact = NormalizeTextForms(noArticle)
    local commentLower = (comment and comment ~= "") and string.lower(TrimText(comment)) or nil
    local tagLower = (tag and tag ~= "") and string.lower(TrimText(tag)) or nil
    local resultKey = tostring(itemType or "") .. ":" .. nameLower .. ":" .. string.lower(zoneName or "")

    local normalizedAliases = nil
    if aliases and #aliases > 0 then
        normalizedAliases = {}
        for _, alias in ipairs(aliases) do
            local aTrimmed = TrimText(alias)
            if aTrimmed ~= "" and string.lower(aTrimmed) ~= nameLower then
                local aLower = string.lower(aTrimmed)
                local aNoArt = StripLeadingArticle(aLower)
                local aSpaced, aCompact = NormalizeTextForms(aLower)
                local aNoArtSpaced, aNoArtCompact = NormalizeTextForms(aNoArt)
                table.insert(normalizedAliases, {
                    name = aTrimmed,
                    _lower = aLower,
                    _noArticle = aNoArt,
                    _spaced = aSpaced,
                    _compact = aCompact,
                    _noArtSpaced = aNoArtSpaced,
                    _noArtCompact = aNoArtCompact,
                    _spacedLead = " " .. aSpaced,
                })
            end
        end
        if #normalizedAliases == 0 then
            normalizedAliases = nil
        end
    end

    return {
        id = id,
        name = trimmedName,
        zoneName = zoneName,
        mapID = mapID,
        x = x,
        y = y,
        type = itemType,
        tag = tag,
        color = color,
        comment = comment or "",
        _lower = nameLower,
        _noArticle = noArticle,
        _spaced = spaced,
        _compact = compact,
        _noArtSpaced = noArtSpaced,
        _noArtCompact = noArtCompact,
        _spacedLead = " " .. spaced,
        _aliases = normalizedAliases,
        _commentLower = commentLower,
        _tagLower = tagLower,
        _resultKey = resultKey,
    }
end

-- 经典与多版本特殊地标/任务枢纽（非传统地下城，但玩家频繁前往的著名传送/任务地点）
local SPECIAL_LANDMARKS = {
    {
        nameKey = "DEST_CHAMBER_OF_HEART",
        nameFallback = "心之密室",
        mapID = 81,
        x = 0.422,
        y = 0.445,
        type = "zone",
        comment = "Chamber of Heart",
    },
    {
        nameKey = "DEST_DARKMOON_ISLAND",
        nameFallback = "暗月岛",
        zoneKey = "DEST_DARKMOON_FAIRE",
        zoneFallback = "暗月马戏团",
        mapID = 407,
        x = 0.500,
        y = 0.600,
        type = "zone",
        comment = "Darkmoon Island / Darkmoon Faire",
        aliasesKey = "DEST_DARKMOON_FAIRE",
        aliases = { "Darkmoon Faire", "暗月马戏团", "暗月馬戲團" },
    },
    {
        sourceMapID = 1470,
        nameKey = "DEST_VISION_STORMWIND",
        nameFallback = "暴风城的幻象",
        zoneKey = "ZONE_DORNOGAL_VISION",
        zoneFallback = "多恩诺嘉尔（重访惊魂幻象）",
        mapID = 2339,
        x = 0.346,
        y = 0.684,
        type = "zone",
        isHorrificVision = true,
        visionType = "STORMWIND",
        isSubPoint = true,
        comment = "Vision of Stormwind / Soridormi",
        aliases = { "Vision of Stormwind", "暴风城的幻象", "暴风城幻象", "暴風城的幻象", "大幻象", "重访惊魂幻象" },
    },
    {
        sourceMapID = 1469,
        nameKey = "DEST_VISION_ORGRIMMAR",
        nameFallback = "奥格瑞玛的幻象",
        zoneKey = "ZONE_DORNOGAL_VISION",
        zoneFallback = "多恩诺嘉尔（重访惊魂幻象）",
        mapID = 2339,
        x = 0.346,
        y = 0.684,
        type = "zone",
        isHorrificVision = true,
        visionType = "ORGRIMMAR",
        isSubPoint = true,
        comment = "Vision of Orgrimmar / Soridormi",
        aliases = { "Vision of Orgrimmar", "奥格瑞玛的幻象", "奥格瑞玛幻象", "奧格瑪的幻象", "大幻象", "重访惊魂幻象" },
    },
}

-- 权威地下堡多语言回退表 (覆盖 11.0 地心之战、11.1 安德麦/塞纳岛、12.0/12.1 至暗之夜)
local DELVE_FALLBACK_NAMES = {
    [2269] = { en = "Earthcrawl Mines", zhCN = "地匍矿洞", zhTW = "地行礦坑" },
    [2249] = { en = "Fungal Folly", zhCN = "真菌之愚", zhTW = "菌菇愚行" },
    [2250] = { en = "Kriegval's Rest", zhCN = "克莱格瓦之眠", zhTW = "克里格瓦之眠" },
    [2251] = { en = "The Waterworks", zhCN = "水能堡", zhTW = "水力發電壩" },
    [2302] = { en = "The Dread Pit", zhCN = "恐惧陷坑", zhTW = "恐怖地穴" },
    [2277] = { en = "Nightfall Sanctum", zhCN = "夜幕圣所", zhTW = "夜暮聖所" },
    [2301] = { en = "The Sinkhole", zhCN = "无底沉穴", zhTW = "陷坑" },
    [2312] = { en = "Mycomancer Cavern", zhCN = "丝菌师洞穴", zhTW = "真菌法師洞窟" },
    [2310] = { en = "Skittering Breach", zhCN = "飞掠裂口", zhTW = "奔蛛裂層" },
    [2299] = { en = "The Underkeep", zhCN = "幽暗要塞", zhTW = "深淵堡" },
    [2259] = { en = "Tak-Rethan Abyss", zhCN = "塔克-雷桑深渊", zhTW = "塔克-瑞桑深淵" },
    [2347] = { en = "The Spiral Weave", zhCN = "螺旋织纹", zhTW = "迴繞地道" },
    [2348] = { en = "Zekvir's Lair", zhCN = "泽克维尔的巢穴", zhTW = "澤克維爾巢穴" },
    [2423] = { en = "Sidestreet Sluice", zhCN = "闸板陋巷", zhTW = "後街水閘" },
    [2396] = { en = "Excavation Site 9", zhCN = "九号挖掘场", zhTW = "9號挖掘場" },
    [2425] = { en = "Demolition Dome", zhCN = "破拆穹顶", zhTW = "爆鬥場" },
    [2452] = { en = "Archival Assault", zhCN = "档案馆突袭", zhTW = "文庫襲擊" },
    [2484] = { en = "Voidscar Cavern", zhCN = "虚空之锋庇护所", zhTW = "虛無剃刀庇護所" },
    [2502] = { en = "Shadow Enclave", zhCN = "聚影领地", zhTW = "暗影領區" },
    [2503] = { en = "Twilight Crypts", zhCN = "暮光地穴", zhTW = "暮光墓穴" },
    [2505] = { en = "The Gulf of Memory", zhCN = "回忆深沟", zhTW = "回憶裂口" },
    [2506] = { en = "Shadowguard Point", zhCN = "影卫营", zhTW = "影衛崗哨" },
    [2510] = { en = "The Grudge Pit", zhCN = "憎怨斗坑", zhTW = "怨鬥坑洞" },
    [2525] = { en = "The Darkway", zhCN = "黑暗回廊", zhTW = "黑暗之途" },
    [2528] = { en = "Sunkiller Sanctum", zhCN = "戮日圣殿", zhTW = "戮日者聖所" },
    [2535] = { en = "Atal'Aman", zhCN = "阿塔阿曼", zhTW = "阿塔阿曼" },
    [2545] = { en = "Parhelion Plaza", zhCN = "幻日广场", zhTW = "幻日廣場" },
    [2547] = { en = "Collegiate Calamity", zhCN = "学府骚动", zhTW = "學院災禍" },
    [2633] = { en = "The Ring of Glory", zhCN = "荣耀之环", zhTW = "榮耀競技場" },
    [2635] = { en = "Gnarldor Isle", zhCN = "纳拉多尔岛", zhTW = "納爾多島" },
    [2647] = { en = "The Labyrinth of Kindo'jan", zhCN = "金多赞迷宫", zhTW = "金多贊迷宮" },
}

-- 权威团队副本多语言回退表 (覆盖最新版本与尚未缓存的团队副本)
local RAID_FALLBACK_NAMES = {
    [1324] = { en = "The Unbinding of Kith'ix", zhCN = "基西克斯破封", zhTW = "基西克斯破封" },
}

-- 包含地下堡的各大洲野外地图列表（用于动态查询 C_AreaPoiInfo）
local DELVE_SEARCH_MAPS = {
    -- Khaz Algar
    2248, 2214, 2215, 2255, 2256, 2213, 2216, 2369, 2322, 2346, 2371, 2472,
    -- Quel'Thalas / Midnight
    2393, 2395, 2437, 2424, 2405, 2444, 2413, 2536, 2576, 2509, 2512,
}

-- 初始化搜索索引（在 PLAYER_LOGIN 时调用）
function SearchEngine:Initialize()
    if isInitialized then return end
    wipe(searchIndex)

    local seenMapIDs = {}
    local seenDestIDs = {}
    local seenDestTypeNames = {}
    local seenInstanceNames = {}
    local seenContinentZoneNames = {}
    local seenGlobalZoneNames = {}
    local delveItemsByName = {}

    -- 0. 建立特殊地标与核心任务枢纽索引 (如心之密室、暗月岛、重访惊魂幻象等)
    for _, lm in ipairs(SPECIAL_LANDMARKS) do
        -- 优先通过暴雪原生 API 获取当前客户端语言的官方地图名称（完美适配任意语言客户端）
        local lmName = nil
        if lm.sourceMapID and C_Map and C_Map.GetMapInfo then
            local sInfo = C_Map.GetMapInfo(lm.sourceMapID)
            if sInfo and sInfo.name and sInfo.name ~= "" then
                lmName = sInfo.name
            end
        end
        if not lmName then
            lmName = (lm.nameKey and L[lm.nameKey]) or lm.nameFallback
        end

        local zName = (lm.zoneKey and L[lm.zoneKey]) or lm.zoneFallback
        if not zName and C_Map and C_Map.GetMapInfo then
            local mInfo = C_Map.GetMapInfo(lm.mapID)
            if mInfo and mInfo.name then
                zName = mInfo.name
            end
        end
        zName = zName or L["UNKNOWN_ZONE"]

        local aliases = {}
        if lm.aliases then
            for _, a in ipairs(lm.aliases) do
                table.insert(aliases, a)
            end
        end
        if lm.aliasesKey and L[lm.aliasesKey] then
            table.insert(aliases, L[lm.aliasesKey])
        end

        local typeMeta = TYPE_INFO[lm.type] or TYPE_INFO.zone
        if not lm.isSubPoint then
            seenMapIDs[lm.mapID] = true
        end
        seenGlobalZoneNames[string.lower(lmName)] = true

        local item = CreateSearchItem(
            0,
            lmName,
            zName,
            lm.mapID,
            lm.x,
            lm.y,
            lm.type,
            typeMeta.tag,
            typeMeta.color,
            lm.comment or "",
            aliases
        )
        if lm.isHorrificVision then
            item.isHorrificVision = true
            item.visionType = lm.visionType
            item.sourceMapID = lm.sourceMapID
        end

        table.insert(searchIndex, item)
    end

    -- 1. 建立副本目的地索引 (地下城、团队副本、地下堡)
    if ns.PortaData and ns.PortaData.destinations then
        for _, dest in ipairs(ns.PortaData.destinations) do
            if not (dest.id and seenDestIDs[dest.id]) then
                local instanceName = nil
                -- 通过暴雪原生 API 获取当前客户端语言的名称
                if dest.id and dest.id > 0 then
                    if dest.type == "delve" then
                        -- PortaData 中静态 delve 的 id 是地下堡内部 mapID；
                        -- 下方 1b 分支的 areaPoiID 是另一套 ID，只用于动态 AreaPOI 查询。
                        if C_Map and C_Map.GetMapInfo then
                            local mInfo = C_Map.GetMapInfo(dest.id)
                            if mInfo and mInfo.name and mInfo.name ~= "" then
                                instanceName = mInfo.name
                            end
                        end
                        if not instanceName or instanceName == "" then
                            local fallback = DELVE_FALLBACK_NAMES[dest.id]
                            if fallback then
                                local loc = (GetLocale and GetLocale()) or "enUS"
                                if loc == "zhCN" then
                                    instanceName = fallback.zhCN
                                elseif loc == "zhTW" then
                                    instanceName = fallback.zhTW
                                else
                                    instanceName = fallback.en
                                end
                            end
                        end
                    else
                        if EJ_GetInstanceInfo then
                            local name = EJ_GetInstanceInfo(dest.id)
                            if name and name ~= "" then
                                instanceName = name
                            end
                        end
                        if not instanceName or instanceName == "" then
                            local fallback = RAID_FALLBACK_NAMES[dest.id]
                            if fallback then
                                local loc = (GetLocale and GetLocale()) or "enUS"
                                if loc == "zhCN" then
                                    instanceName = fallback.zhCN
                                elseif loc == "zhTW" then
                                    instanceName = fallback.zhTW
                                else
                                    instanceName = fallback.en
                                end
                            end
                        end
                    end
                end

                -- 回退到 comment
                if not instanceName or instanceName == "" then
                    instanceName = dest.comment or string.format(L["UNKNOWN_DEST_FMT"], tostring(dest.id))
                end

                instanceName = TrimText(instanceName)
                local nameLower = string.lower(instanceName)
                local destType = dest.type or "dungeon"
                local typeNameKey = destType .. ":" .. nameLower

                if not seenDestTypeNames[typeNameKey] then
                    if dest.id then
                        seenDestIDs[dest.id] = true
                    end
                    seenDestTypeNames[typeNameKey] = true
                    seenInstanceNames[nameLower] = true

                    -- 获取所属地图名称（当前客户端语言）
                    local zoneName = L["UNKNOWN_ZONE"]
                    if dest.id == 1324 then
                        -- 基西克斯破封位于阿塔乌特克地窟 (2509) 深处的地下墓窖 (2613)
                        local parentMap = (C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(2509))
                        if parentMap and parentMap.name and parentMap.name ~= "" then
                            zoneName = parentMap.name
                        else
                            zoneName = L["ZONE_ATAL_UTEK"]
                        end
                    elseif dest.mapID and C_Map and C_Map.GetMapInfo then
                        local mapInfo = C_Map.GetMapInfo(dest.mapID)
                        if mapInfo and mapInfo.name then
                            zoneName = mapInfo.name
                        end
                    end

                    local typeMeta = TYPE_INFO[destType] or TYPE_INFO.dungeon

                    local customAliases = nil
                    if dest.id == 1324 then
                        customAliases = { "基西克斯", "基西克斯破封", "破封", "阿塔乌特克", "阿塔乌特克地窟", "Kith'ix", "The Unbinding of Kith'ix", "Unbinding of Kith'ix", "Atal'Utek" }
                    elseif dest.id == 2647 then
                        customAliases = { "金多赞", "金多赞迷宫", "金多赞的迷宫", "金多赞地下堡", "Kindo'jan", "The Labyrinth of Kindo'jan" }
                    end

                    local searchItem = CreateSearchItem(
                        dest.id,
                        instanceName,
                        zoneName,
                        dest.mapID,
                        dest.x,
                        dest.y,
                        destType,
                        typeMeta.tag,
                        typeMeta.color,
                        dest.comment or "",
                        customAliases
                    )
                    if destType == "delve" then
                        delveItemsByName[typeNameKey] = searchItem
                    end
                    table.insert(searchIndex, searchItem)
                end
            end
        end
    end

    -- 1b. 动态扫描暴雪官方地下堡 AreaPOI (获取实时地名、入口及最新版本内容)
    if C_AreaPoiInfo and C_AreaPoiInfo.GetDelvesForMap and C_AreaPoiInfo.GetAreaPOIInfo then
        for _, zoneMapID in ipairs(DELVE_SEARCH_MAPS) do
            local delvePoiList = C_AreaPoiInfo.GetDelvesForMap(zoneMapID)
            if delvePoiList then
                for _, areaPoiID in ipairs(delvePoiList) do
                    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(zoneMapID, areaPoiID)
                    if poiInfo and poiInfo.name and poiInfo.name ~= "" and poiInfo.position then
                        local px, py = poiInfo.position:GetXY()
                        if px and py and px > 0 and py > 0 then
                            local delveName = TrimText(poiInfo.name)
                            local delveNameLower = string.lower(delveName)
                            local delveTypeKey = "delve:" .. delveNameLower

                            -- 若已存在静态条目，以暴雪原生实时 AreaPOI 的精确坐标与地图为准进行动态校准
                            if delveItemsByName[delveTypeKey] then
                                local existing = delveItemsByName[delveTypeKey]
                                existing.x = px
                                existing.y = py
                                existing.mapID = zoneMapID
                            elseif not seenDestTypeNames[delveTypeKey] then
                                seenDestTypeNames[delveTypeKey] = true
                                seenInstanceNames[delveNameLower] = true

                                local zName = L["UNKNOWN_ZONE"]
                                if C_Map and C_Map.GetMapInfo then
                                    local mInfo = C_Map.GetMapInfo(zoneMapID)
                                    if mInfo and mInfo.name then
                                        zName = mInfo.name
                                    end
                                end

                                local customAliases = nil
                                if areaPoiID == 9035 or areaPoiID == 9036 or string.find(delveNameLower, "kindo") or string.find(delveName, "金多赞") then
                                    customAliases = { "金多赞", "金多赞迷宫", "金多赞的迷宫", "金多赞地下堡", "Kindo'jan", "The Labyrinth of Kindo'jan" }
                                end

                                table.insert(searchIndex, CreateSearchItem(
                                    areaPoiID,
                                    delveName,
                                    zName,
                                    zoneMapID,
                                    px,
                                    py,
                                    "delve",
                                    TYPE_INFO.delve.tag,
                                    TYPE_INFO.delve.color,
                                    poiInfo.description or "",
                                    customAliases
                                ))
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. 动态枚举暴雪全版本各大洲与野外区域 (原生当前客户端语言适配)
    local zoneType = (Enum and Enum.UIMapType and Enum.UIMapType.Zone) or 3
    local dungeonMapType = (Enum and Enum.UIMapType and Enum.UIMapType.Dungeon) or 4
    local microMapType = (Enum and Enum.UIMapType and Enum.UIMapType.Micro) or 5
    local orphanMapType = (Enum and Enum.UIMapType and Enum.UIMapType.Orphan) or 6

    for _, contID in ipairs(MAJOR_CONTINENTS) do
        local contName = L["OUTDOOR_MAP"]
        -- 索引大洲自身
        if C_Map and C_Map.GetMapInfo then
            local contInfo = C_Map.GetMapInfo(contID)
            if contInfo and contInfo.name and contInfo.name ~= "" then
                contName = TrimText(contInfo.name)
                local contNameLower = string.lower(contName)
                if contID ~= AZEROTH_MAP_ID and not seenMapIDs[contID] and not seenGlobalZoneNames[contNameLower] then
                    seenMapIDs[contID] = true
                    seenGlobalZoneNames[contNameLower] = true
                    table.insert(searchIndex, CreateSearchItem(
                        0,
                        contName,
                        L["WORLD_CONTINENT"],
                        contID,
                        0.5,
                        0.5,
                        "zone",
                        TYPE_INFO.continent.tag,
                        TYPE_INFO.continent.color,
                        ""
                    ))
                end
            end
        end

        -- 枚举大洲下属的所有野外区域
        if C_Map and C_Map.GetMapChildrenInfo then
            local children = C_Map.GetMapChildrenInfo(contID, zoneType, true)
            if children then
                for _, child in ipairs(children) do
                    local childMapID = child.mapID
                    local childName = child.name and TrimText(child.name) or ""
                    if childMapID and childName ~= "" and not DEPRECATED_PHASE_MAPS[childMapID] and not seenMapIDs[childMapID] then
                        local childNameLower = string.lower(childName)
                        -- 明确过滤旧大陆残留或重访幻象地图条目（统一由第0步多恩诺嘉尔入口呈现）
                        local isVisionMap = (childMapID == 1469 or childMapID == 1470 or childMapID == 2403 or childMapID == 2404 or string.find(childNameLower, "幻象") or string.find(childNameLower, "vision"))
                        local isIgnoredPhaseOrTest = (
                            string.find(childNameLower, "disabled") or
                            string.find(childNameLower, "test") or
                            string.find(childNameLower, "debug") or
                            string.find(childNameLower, "deprecated")
                        )
                        if not isVisionMap and not isIgnoredPhaseOrTest then
                            local contZoneKey = tostring(contID) .. ":" .. childNameLower
                            -- 同一大洲内同名多楼层/多相位区域仅保留一条，且不与同名副本或全局已收录地标冲突
                            if not seenContinentZoneNames[contZoneKey] and not seenGlobalZoneNames[childNameLower] and not seenInstanceNames[childNameLower] then
                                seenMapIDs[childMapID] = true
                                seenContinentZoneNames[contZoneKey] = true
                                seenGlobalZoneNames[childNameLower] = true
                                local zoneLabel = contName
                                if contID == AZEROTH_MAP_ID and child.parentMapID then
                                    local parentInfo = C_Map.GetMapInfo(child.parentMapID)
                                    if parentInfo and parentInfo.name and parentInfo.name ~= "" then
                                        zoneLabel = parentInfo.name
                                    end
                                end
                                table.insert(searchIndex, CreateSearchItem(
                                    0,
                                    childName,
                                    zoneLabel,
                                    childMapID,
                                    0.5,
                                    0.5,
                                    "zone",
                                    TYPE_INFO.zone.tag,
                                    TYPE_INFO.zone.color,
                                    ""
                                ))
                            end
                        end
                    end
                end
            end
        end
    end

    -- 3. 补充交通图中直接连通的特殊枢纽地图（排除地下城内部图层、洞穴微缩图与已收录同名区域）
    if ns.PortaData and ns.PortaData.transports then
        for _, edge in ipairs(ns.PortaData.transports) do
            local targetMapID = edge.to
            if targetMapID and targetMapID > 0 and not DEPRECATED_PHASE_MAPS[targetMapID] and not seenMapIDs[targetMapID] then
                if C_Map and C_Map.GetMapInfo then
                    local mapInfo = C_Map.GetMapInfo(targetMapID)
                    if mapInfo and mapInfo.name and mapInfo.name ~= "" then
                        local mType = mapInfo.mapType
                        local isIgnoredMapType = (mType == dungeonMapType or mType == microMapType or mType == orphanMapType)
                        local mapName = TrimText(mapInfo.name)
                        local mapNameLower = string.lower(mapName)
                        local isIgnoredPhaseOrTest = (
                            string.find(mapNameLower, "disabled") or
                            string.find(mapNameLower, "test") or
                            string.find(mapNameLower, "debug") or
                            string.find(mapNameLower, "deprecated")
                        )
                        if not isIgnoredMapType and not isIgnoredPhaseOrTest and not seenGlobalZoneNames[mapNameLower] and not seenInstanceNames[mapNameLower] then
                            seenMapIDs[targetMapID] = true
                            seenGlobalZoneNames[mapNameLower] = true
                            table.insert(searchIndex, CreateSearchItem(
                                0,
                                mapName,
                                L["TRANSPORT_HUB"],
                                targetMapID,
                                0.5,
                                0.5,
                                "zone",
                                TYPE_INFO.zone.tag,
                                TYPE_INFO.zone.color,
                                ""
                            ))
                        end
                    end
                end
            end
        end
    end

    isInitialized = true
end

-- 对象池：复用搜索匹配条目包装对象，避免每次按键触发大量小表 GC
local matchPool = {}
local matchPoolCount = 0

local function AcquireMatchEntry(item, score)
    matchPoolCount = matchPoolCount + 1
    local entry = matchPool[matchPoolCount]
    if not entry then
        entry = { item = item, score = score }
        matchPool[matchPoolCount] = entry
    else
        entry.item = item
        entry.score = score
    end
    return entry
end

-- 基础字段匹配评估辅助函数
local function MatchItemForm(targetLower, targetNoArt, targetSpaced, targetCompact, targetNoArtSpaced, targetNoArtCompact, targetSpacedLead, queryLower, querySpaced, queryCompact, querySpacedLead, queryWords)
    if not targetLower or targetLower == "" then return false, 0 end

    -- 1. 完全一致
    if targetLower == queryLower then
        return true, 100
    end

    -- 1b. 去除前导冠词或标点符号后完全一致 (例如输入 "stonevault" 匹配 "The Stonevault"，或 "motherlode" 匹配 "The MOTHERLODE!!")
    if targetNoArt == queryLower or (queryCompact ~= "" and (targetCompact == queryCompact or targetNoArtCompact == queryCompact)) then
        return true, 95
    end

    -- 2. 前缀匹配（含去除前导冠词或忽略标点后的前缀匹配）
    local s = string.find(targetLower, queryLower, 1, true)
    if s == 1 then
        return true, 85
    end

    if string.find(targetNoArt, queryLower, 1, true) == 1 then
        return true, 82
    end

    if querySpaced ~= "" then
        if string.find(targetSpaced, querySpaced, 1, true) == 1 or string.find(targetNoArtSpaced, querySpaced, 1, true) == 1 then
            return true, 80
        end
    end

    if queryCompact ~= "" then
        if string.find(targetCompact, queryCompact, 1, true) == 1 or string.find(targetNoArtCompact, queryCompact, 1, true) == 1 then
            return true, 78
        end
    end

    -- 3. 单词词首边界匹配 (例如英文输入 "echoes" 匹配 "Ara-Kara, City of Echoes" 中的单词首部)
    if querySpacedLead and string.find(targetSpacedLead, querySpacedLead, 1, true) then
        return true, 72
    end

    -- 4. 子串包含（含忽略连字符/撇号/标点的子串包含）
    if s then
        return true, 60
    end

    if querySpaced ~= "" and string.find(targetSpaced, querySpaced, 1, true) then
        return true, 58
    end

    if queryCompact ~= "" and string.find(targetCompact, queryCompact, 1, true) then
        return true, 56
    end

    -- 5. 多关键词分词包含 (支持空格分隔，如 "永恒 王宫" 或 "city echoes")
    if queryWords and #queryWords > 1 then
        local allMatch = true
        for i = 1, #queryWords do
            local w = queryWords[i]
            if not (string.find(targetLower, w, 1, true) or string.find(targetSpaced, w, 1, true) or string.find(targetCompact, w, 1, true)) then
                allMatch = false
                break
            end
        end
        if allMatch then
            return true, 50
        end
    end

    return false, 0
end

-- 当前客户端语言地名智能匹配（使用预计算字段，避免检索热路径下的任何 gsub 与字符串重分配）
local function MatchItem(item, queryLower, querySpaced, queryCompact, querySpacedLead, queryWords)
    local isMatch, score = MatchItemForm(
        item._lower,
        item._noArticle,
        item._spaced,
        item._compact,
        item._noArtSpaced,
        item._noArtCompact,
        item._spacedLead,
        queryLower,
        querySpaced,
        queryCompact,
        querySpacedLead,
        queryWords
    )

    -- 若主地名未达完全一致，检查是否命中预设别名 (如 "暗月马戏团" / "Darkmoon Faire" 等别名)
    if item._aliases then
        for _, alias in ipairs(item._aliases) do
            local aMatch, aScore = MatchItemForm(
                alias._lower,
                alias._noArticle,
                alias._spaced,
                alias._compact,
                alias._noArtSpaced,
                alias._noArtCompact,
                alias._spacedLead,
                queryLower,
                querySpaced,
                queryCompact,
                querySpacedLead,
                queryWords
            )
            if aMatch and aScore > score then
                isMatch = true
                score = aScore
                if score == 100 then
                    break
                end
            end
        end
    end

    return isMatch, score
end

-- 搜索核心方法（仅匹配当前客户端语言名称，优先精确匹配，杜绝无关项与重复项）
function SearchEngine:Search(query, limit)
    limit = limit or 10
    if not isInitialized then
        self:Initialize()
    end

    local queryTrimmed = TrimText(query)
    if queryTrimmed == "" then
        return {}
    end

    local queryLower = string.lower(queryTrimmed)
    local querySpaced, queryCompact = NormalizeTextForms(queryLower)
    local querySpacedLead = (querySpaced ~= "") and (" " .. querySpaced) or nil

    -- 预分词：在循环外部完成分词，杜绝在每个索引项中重复分配分词表与执行 gmatch
    local queryWords = nil
    local queryWordSource = (querySpaced ~= "") and querySpaced or queryLower
    for word in string.gmatch(queryWordSource, "%S+") do
        if not queryWords then queryWords = {} end
        table.insert(queryWords, word)
    end

    matchPoolCount = 0
    local matched = {}

    for i = 1, #searchIndex do
        local item = searchIndex[i]
        local isMatch, score = MatchItem(item, queryLower, querySpaced, queryCompact, querySpacedLead, queryWords)

        -- 1. 若名称未命中，支持英文备注/原名匹配（跨语言检索，如中文客户端输入 Earthcrawl）
        if not isMatch and item._commentLower then
            if item._commentLower == queryLower then
                isMatch = true
                score = 85
            elseif string.find(item._commentLower, queryLower, 1, true) then
                isMatch = true
                score = 55
            end
        end

        -- 2. 若仍未命中，支持分类标签检索（如输入“地下堡”/“delve”列出全部地下堡，“团本”/“raid”列出团队副本）
        if not isMatch and item._tagLower then
            if item._tagLower == queryLower or string.find(item._tagLower, queryLower, 1, true) then
                isMatch = true
                score = 65
            end
        end

        if isMatch then
            table.insert(matched, AcquireMatchEntry(item, score))
        end
    end

    -- 按匹配分数高低、类别优先级（副本优先于普通地图）与名字长短排序
    table.sort(matched, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        local aIsInstance = (a.item.type ~= "zone")
        local bIsInstance = (b.item.type ~= "zone")
        if aIsInstance ~= bIsInstance then
            return aIsInstance
        end
        if #a.item.name ~= #b.item.name then
            return #a.item.name < #b.item.name
        end
        return (a.item.id or 0) < (b.item.id or 0)
    end)

    -- 截取前 limit 个结果并做最终去重保护（直接使用预计算的 _resultKey 避免字符串拼接）
    local results = {}
    local seenResultKeys = {}
    for i = 1, #matched do
        local entry = matched[i]
        local item = entry.item
        local resultKey = item._resultKey
        if not seenResultKeys[resultKey] then
            seenResultKeys[resultKey] = true
            table.insert(results, item)
            if #results >= limit then
                break
            end
        end
    end

    -- 释放对象池中临时引用的对象，促使 GC 处于轻载状态
    for i = 1, matchPoolCount do
        matchPool[i].item = nil
    end

    return results
end
