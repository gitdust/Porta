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
    2400, -- 至暗之夜 / 奎尔萨拉斯 (Midnight / Quel'Thalas)
    947,  -- 艾泽拉斯全局 (Azeroth)
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

    -- 0. 建立特殊地标与核心任务枢纽索引 (如心之密室等)
    for _, lm in ipairs(SPECIAL_LANDMARKS) do
        local lmName = (lm.nameKey and L[lm.nameKey]) or lm.nameFallback
        local zName = L["UNKNOWN_ZONE"]
        if C_Map and C_Map.GetMapInfo then
            local mInfo = C_Map.GetMapInfo(lm.mapID)
            if mInfo and mInfo.name then
                zName = mInfo.name
            end
        end
        local typeMeta = TYPE_INFO[lm.type] or TYPE_INFO.zone
        table.insert(searchIndex, {
            id = 0,
            name = lmName,
            zoneName = zName,
            mapID = lm.mapID,
            x = lm.x,
            y = lm.y,
            type = lm.type,
            tag = typeMeta.tag,
            color = typeMeta.color,
            comment = lm.comment or "",
        })
    end

    -- 1. 建立副本目的地索引 (地下城、团队副本、地下堡)
    if ns.PortaData and ns.PortaData.destinations then
        for _, dest in ipairs(ns.PortaData.destinations) do
            if not (dest.id and seenDestIDs[dest.id]) then
                local instanceName = nil
                -- 通过暴雪原生 Journal API 获取当前客户端语言的名称
                if dest.id and dest.id > 0 then
                    if C_EncounterJournal and C_EncounterJournal.GetInstanceInfo then
                        local name = C_EncounterJournal.GetInstanceInfo(dest.id)
                        if name and name ~= "" then
                            instanceName = name
                        end
                    end
                    if not instanceName and EJ_GetInstanceInfo then
                        local name = EJ_GetInstanceInfo(dest.id)
                        if name and name ~= "" then
                            instanceName = name
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
                    if dest.mapID and C_Map and C_Map.GetMapInfo then
                        local mapInfo = C_Map.GetMapInfo(dest.mapID)
                        if mapInfo and mapInfo.name then
                            zoneName = mapInfo.name
                        end
                    end

                    local typeMeta = TYPE_INFO[destType] or TYPE_INFO.dungeon

                    table.insert(searchIndex, {
                        id = dest.id,
                        name = instanceName,
                        zoneName = zoneName,
                        mapID = dest.mapID,
                        x = dest.x,
                        y = dest.y,
                        type = destType,
                        tag = typeMeta.tag,
                        color = typeMeta.color,
                        comment = dest.comment or "",
                    })
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
                if not seenMapIDs[contID] and not seenGlobalZoneNames[contNameLower] then
                    seenMapIDs[contID] = true
                    seenGlobalZoneNames[contNameLower] = true
                    table.insert(searchIndex, {
                        id = 0,
                        name = contName,
                        zoneName = L["WORLD_CONTINENT"],
                        mapID = contID,
                        x = 0.5,
                        y = 0.5,
                        type = "zone",
                        tag = TYPE_INFO.continent.tag,
                        color = TYPE_INFO.continent.color,
                        comment = "",
                    })
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
                        local contZoneKey = tostring(contID) .. ":" .. childNameLower
                        -- 同一大洲内同名多楼层/多相位区域仅保留一条，且不与同名副本冲突
                        if not seenContinentZoneNames[contZoneKey] and not seenInstanceNames[childNameLower] then
                            seenMapIDs[childMapID] = true
                            seenContinentZoneNames[contZoneKey] = true
                            seenGlobalZoneNames[childNameLower] = true
                            table.insert(searchIndex, {
                                id = 0,
                                name = childName,
                                zoneName = contName,
                                mapID = childMapID,
                                x = 0.5,
                                y = 0.5,
                                type = "zone",
                                tag = TYPE_INFO.zone.tag,
                                color = TYPE_INFO.zone.color,
                                comment = "",
                            })
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
                        if not isIgnoredMapType and not seenGlobalZoneNames[mapNameLower] and not seenInstanceNames[mapNameLower] then
                            seenMapIDs[targetMapID] = true
                            seenGlobalZoneNames[mapNameLower] = true
                            table.insert(searchIndex, {
                                id = 0,
                                name = mapName,
                                zoneName = L["TRANSPORT_HUB"],
                                mapID = targetMapID,
                                x = 0.5,
                                y = 0.5,
                                type = "zone",
                                tag = TYPE_INFO.zone.tag,
                                color = TYPE_INFO.zone.color,
                                comment = "",
                            })
                        end
                    end
                end
            end
        end
    end

    isInitialized = true
end

-- 当前客户端语言地名智能匹配（兼顾中文子串与英文/拉丁语系冠词、连字符/撇号忽略、词首前缀匹配）
local function MatchText(targetText, queryLower, querySpaced, queryCompact)
    if not targetText or not queryLower or queryLower == "" then return false, 0 end

    local targetLower = string.lower(TrimText(targetText))
    if targetLower == "" then return false, 0 end

    -- 1. 完全一致
    if targetLower == queryLower then
        return true, 100
    end

    local noArticleTarget = StripLeadingArticle(targetLower)
    local targetSpaced, targetCompact = NormalizeTextForms(targetLower)
    local noArtSpaced, noArtCompact = NormalizeTextForms(noArticleTarget)

    -- 1b. 去除前导冠词或标点符号后完全一致 (例如输入 "stonevault" 匹配 "The Stonevault"，或 "motherlode" 匹配 "The MOTHERLODE!!")
    if noArticleTarget == queryLower or (queryCompact ~= "" and (targetCompact == queryCompact or noArtCompact == queryCompact)) then
        return true, 95
    end

    -- 2. 前缀匹配（含去除前导冠词或忽略标点后的前缀匹配）
    local s = string.find(targetLower, queryLower, 1, true)
    if s == 1 then
        return true, 85
    end

    local sNoArt = string.find(noArticleTarget, queryLower, 1, true)
    if sNoArt == 1 then
        return true, 82
    end

    if querySpaced ~= "" then
        if string.find(targetSpaced, querySpaced, 1, true) == 1 or string.find(noArtSpaced, querySpaced, 1, true) == 1 then
            return true, 80
        end
    end

    if queryCompact ~= "" then
        if string.find(targetCompact, queryCompact, 1, true) == 1 or string.find(noArtCompact, queryCompact, 1, true) == 1 then
            return true, 78
        end
    end

    -- 3. 单词词首边界匹配 (例如英文输入 "echoes" 匹配 "Ara-Kara, City of Echoes" 中的单词首部)
    if querySpaced ~= "" and string.find(" " .. targetSpaced, " " .. querySpaced, 1, true) then
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
    local words = {}
    for word in string.gmatch(querySpaced ~= "" and querySpaced or queryLower, "%S+") do
        table.insert(words, word)
    end
    if #words > 1 then
        local allMatch = true
        for _, w in ipairs(words) do
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

-- 搜索核心方法（仅匹配当前客户端语言名称，优先精确匹配，杜绝无关项与重复项）
function SearchEngine:Search(query, limit)
    limit = limit or 10
    if not isInitialized then
        self:Initialize()
    end

    local queryTrimmed = TrimText(query)
    if queryTrimmed == "" then
        -- 默认展示前 limit 个推荐目的地
        local defaultList = {}
        for i = 1, math.min(#searchIndex, limit) do
            table.insert(defaultList, searchIndex[i])
        end
        return defaultList
    end

    local queryLower = string.lower(queryTrimmed)
    local querySpaced, queryCompact = NormalizeTextForms(queryLower)
    local matched = {}
    local hasExactMatch = false

    for _, item in ipairs(searchIndex) do
        local isMatch, score = MatchText(item.name, queryLower, querySpaced, queryCompact)

        if isMatch then
            if score == 100 then
                hasExactMatch = true
            end
            table.insert(matched, {
                item = item,
                score = score,
            })
        end
    end

    -- 如果存在名称完全一致的精确匹配（如输入“永恒王宫”或“Freehold”），只保留完全匹配项，过滤掉其他模糊/前缀结果
    if hasExactMatch then
        local exactMatches = {}
        for _, entry in ipairs(matched) do
            if entry.score == 100 then
                table.insert(exactMatches, entry)
            end
        end
        matched = exactMatches
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

    -- 截取前 limit 个结果并做最终去重保护
    local results = {}
    local seenResultKeys = {}
    for _, entry in ipairs(matched) do
        local item = entry.item
        local resultKey = tostring(item.type or "") .. ":" .. string.lower(item.name or "") .. ":" .. tostring(item.zoneName or "")
        if not seenResultKeys[resultKey] then
            seenResultKeys[resultKey] = true
            table.insert(results, item)
            if #results >= limit then
                break
            end
        end
    end

    return results
end
