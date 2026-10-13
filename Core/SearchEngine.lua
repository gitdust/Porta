local _, ns = ...

local SearchEngine = {}
ns.SearchEngine = SearchEngine

local searchIndex = {}
local isInitialized = false

-- 类别显示文本与颜色
local TYPE_INFO = {
    dungeon = { tag = "地下城", color = "|cff00ccff" },
    raid    = { tag = "团队副本", color = "|cffff8000" },
    delve   = { tag = "地下堡", color = "|cffffff00" },
    zone    = { tag = "区域", color = "|cff00ff00" },
    continent = { tag = "大陆", color = "|cff00ff7f" },
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

    -- 1. 建立副本目的地索引 (地下城、团队副本、地下堡)
    if ns.PortaData and ns.PortaData.destinations then
        for _, dest in ipairs(ns.PortaData.destinations) do
            if not (dest.id and seenDestIDs[dest.id]) then
                local instanceName = nil
                -- 尝试通过暴雪原生 Journal API 获取对应语言的名称
                if dest.id and dest.id > 0 and EJ_GetInstanceInfo then
                    local name = EJ_GetInstanceInfo(dest.id)
                    if name and name ~= "" then
                        instanceName = name
                    end
                end

                -- 回退到 comment
                if not instanceName or instanceName == "" then
                    instanceName = dest.comment or ("未知目的地 #" .. tostring(dest.id))
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

                    -- 获取所属地图名称
                    local zoneName = "未知区域"
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

    -- 2. 动态枚举暴雪全版本各大洲与野外区域 (无需人工整理，原生多语言适配)
    local zoneType = (Enum and Enum.UIMapType and Enum.UIMapType.Zone) or 3
    local dungeonMapType = (Enum and Enum.UIMapType and Enum.UIMapType.Dungeon) or 4
    local microMapType = (Enum and Enum.UIMapType and Enum.UIMapType.Micro) or 5
    local orphanMapType = (Enum and Enum.UIMapType and Enum.UIMapType.Orphan) or 6

    for _, contID in ipairs(MAJOR_CONTINENTS) do
        local contName = "野外地图"
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
                        zoneName = "世界大洲",
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
                                zoneName = "交通枢纽",
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

-- 纯地名文本匹配
local function MatchText(targetText, queryLower)
    if not targetText or not queryLower or queryLower == "" then return false, 0 end

    local targetLower = string.lower(TrimText(targetText))
    if targetLower == "" then return false, 0 end

    -- 1. 完全一致
    if targetLower == queryLower then
        return true, 100
    end

    -- 2. 前缀匹配
    local s = string.find(targetLower, queryLower, 1, true)
    if s == 1 then
        return true, 80
    end

    -- 3. 子串包含
    if s then
        return true, 60
    end

    -- 4. 多关键词分词包含 (支持空格分隔，如 "永恒 王宫" 匹配 "永恒王宫")
    local words = {}
    for word in string.gmatch(queryLower, "%S+") do
        table.insert(words, word)
    end
    if #words > 1 then
        local allMatch = true
        for _, w in ipairs(words) do
            if not string.find(targetLower, w, 1, true) then
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

-- 搜索核心方法（优先精确匹配，杜绝无关项与重复项）
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
    local isAsciiQuery = not string.find(queryLower, "[\128-\255]")
    local matched = {}
    local hasExactMatch = false

    for _, item in ipairs(searchIndex) do
        local isMatch, score = MatchText(item.name, queryLower)

        -- 仅当玩家输入纯英文时才回退匹配副本的英文原名备注
        if not isMatch and isAsciiQuery and item.type ~= "zone" and item.comment and item.comment ~= "" then
            isMatch, score = MatchText(item.comment, queryLower)
            if isMatch then score = score - 25 end
        end

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

    -- 如果存在名称完全一致的精确匹配（如输入“永恒王宫”），只保留完全匹配项，过滤掉其他模糊/前缀结果
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
