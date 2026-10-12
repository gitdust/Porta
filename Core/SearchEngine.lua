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

-- 初始化搜索索引（在 PLAYER_LOGIN 时调用）
function SearchEngine:Initialize()
    if isInitialized then return end
    wipe(searchIndex)

    local seenMapIDs = {}

    -- 1. 建立副本目的地索引 (地下城、团队副本、地下堡)
    if ns.PortaData and ns.PortaData.destinations then
        for _, dest in ipairs(ns.PortaData.destinations) do
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

            -- 获取所属地图名称
            local zoneName = "未知区域"
            if dest.mapID and C_Map and C_Map.GetMapInfo then
                local mapInfo = C_Map.GetMapInfo(dest.mapID)
                if mapInfo and mapInfo.name then
                    zoneName = mapInfo.name
                end
            end

            local typeMeta = TYPE_INFO[dest.type] or TYPE_INFO.dungeon

            table.insert(searchIndex, {
                id = dest.id,
                name = instanceName,
                zoneName = zoneName,
                mapID = dest.mapID,
                x = dest.x,
                y = dest.y,
                type = dest.type,
                tag = typeMeta.tag,
                color = typeMeta.color,
                comment = dest.comment or "",
            })
        end
    end

    -- 2. 动态枚举暴雪全版本各大洲与野外区域 (无需人工整理，原生多语言适配)
    local zoneType = (Enum and Enum.UIMapType and Enum.UIMapType.Zone) or 3

    for _, contID in ipairs(MAJOR_CONTINENTS) do
        -- 索引大洲自身
        if C_Map and C_Map.GetMapInfo then
            local contInfo = C_Map.GetMapInfo(contID)
            if contInfo and contInfo.name and contInfo.name ~= "" and not seenMapIDs[contID] then
                seenMapIDs[contID] = true
                table.insert(searchIndex, {
                    id = 0,
                    name = contInfo.name,
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

        -- 枚举大洲下属的所有野外区域
        if C_Map and C_Map.GetMapChildrenInfo then
            local children = C_Map.GetMapChildrenInfo(contID, zoneType, true)
            if children then
                for _, child in ipairs(children) do
                    if child.mapID and child.name and child.name ~= "" and not seenMapIDs[child.mapID] then
                        seenMapIDs[child.mapID] = true
                        table.insert(searchIndex, {
                            id = 0,
                            name = child.name,
                            zoneName = "野外地图",
                            mapID = child.mapID,
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

    -- 3. 补充交通图中直接连通的所有目标地图（如主城传送大厅、特殊枢纽）
    if ns.PortaData and ns.PortaData.transports then
        for _, edge in ipairs(ns.PortaData.transports) do
            local targetMapID = edge.to
            if targetMapID and targetMapID > 0 and not seenMapIDs[targetMapID] then
                if C_Map and C_Map.GetMapInfo then
                    local mapInfo = C_Map.GetMapInfo(targetMapID)
                    if mapInfo and mapInfo.name and mapInfo.name ~= "" then
                        seenMapIDs[targetMapID] = true
                        table.insert(searchIndex, {
                            id = 0,
                            name = mapInfo.name,
                            zoneName = "交通枢纽",
                            mapID = targetMapID,
                            x = 0.5,
                            y = 0.5,
                            type = "zone",
                            tag = TYPE_INFO.zone.tag,
                            color = TYPE_INFO.zone.color,
                            comment = edge.note or "",
                        })
                    end
                end
            end
        end
    end

    isInitialized = true
end

-- 模糊搜索核心方法
function SearchEngine:Search(query, limit)
    limit = limit or 10
    if not isInitialized then
        self:Initialize()
    end

    local queryTrimmed = string.trim and string.trim(query) or query
    if not queryTrimmed or queryTrimmed == "" then
        return {}
    end

    local matched = {}

    for _, item in ipairs(searchIndex) do
        local isMatch, score = ns.Pinyin:Match(item.name, queryTrimmed)
        
        -- 也可以匹配所属地图名或备注
        if not isMatch and item.zoneName then
            isMatch, score = ns.Pinyin:Match(item.zoneName, queryTrimmed)
            if isMatch then score = score - 20 end
        end
        if not isMatch and item.comment and item.comment ~= "" then
            isMatch, score = ns.Pinyin:Match(item.comment, queryTrimmed)
            if isMatch then score = score - 30 end
        end

        if isMatch then
            table.insert(matched, {
                item = item,
                score = score,
            })
        end
    end

    -- 按匹配分数和名字长短排序
    table.sort(matched, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        return #a.item.name < #b.item.name
    end)

    -- 截取前 limit 个结果
    local results = {}
    for i = 1, math.min(#matched, limit) do
        table.insert(results, matched[i].item)
    end

    return results
end
