local _, ns = ...

local Pathfinder = {}
ns.Pathfinder = Pathfinder

-- 交通方式文本与图标
local TRANSPORT_TEXT = {
    PORTAL        = "穿过传送门",
    ZEPPELIN      = "乘坐飞艇",
    SHIP          = "乘坐轮船",
    WAYGATE       = "进入传送门道",
    MIRROR        = "穿过传送之镜",
    MOLE_MACHINE  = "使用钻地机",
    TRAM          = "乘坐矿道地铁",
    CLASS_PORTAL  = "使用职业传送门",
    TRANSPORT     = "搭乘交通设施",
}

-- 获取友好的地图名称
local function GetMapDisplayName(mapID)
    if not mapID then return "未知地图" end
    if C_Map and C_Map.GetMapInfo then
        local info = C_Map.GetMapInfo(mapID)
        if info and info.name then
            return info.name
        end
    end
    return "地图 #" .. tostring(mapID)
end

-- 构建基于阵营过滤的邻接表图
local function BuildGraph(playerFaction)
    local graph = {}
    if not ns.PortaData or not ns.PortaData.transports then return graph end

    for _, edge in ipairs(ns.PortaData.transports) do
        -- 阵营过滤：中立或匹配本阵营
        local factionMatch = (edge.faction == "NEUTRAL") or (edge.faction == playerFaction)
        if factionMatch and edge.from and edge.to and edge.from ~= edge.to then
            if not graph[edge.from] then
                graph[edge.from] = {}
            end
            table.insert(graph[edge.from], edge)
        end
    end

    return graph
end

-- 广度优先搜索 (BFS) 计算从当前地图到达目标地图的最少跳数路径
function Pathfinder:FindShortestPath(startMapID, targetMapID, playerFaction)
    if not startMapID or not targetMapID then return nil end
    if startMapID == targetMapID then return {} end

    local graph = BuildGraph(playerFaction or ns.GetPlayerFaction())
    local queue = { { mapID = startMapID, edges = {} } }
    local visited = { [startMapID] = true }

    while #queue > 0 do
        local current = table.remove(queue, 1)
        local neighbors = graph[current.mapID]

        if neighbors then
            for _, edge in ipairs(neighbors) do
                local nextMap = edge.to
                if nextMap == targetMapID then
                    -- 找到目标！
                    local finalEdges = {}
                    for _, e in ipairs(current.edges) do
                        table.insert(finalEdges, e)
                    end
                    table.insert(finalEdges, edge)
                    return finalEdges
                end

                if not visited[nextMap] then
                    visited[nextMap] = true
                    local nextEdges = {}
                    for _, e in ipairs(current.edges) do
                        table.insert(nextEdges, e)
                    end
                    table.insert(nextEdges, edge)
                    table.insert(queue, { mapID = nextMap, edges = nextEdges })
                end
            end
        end
    end

    return nil -- 未找到可行连通路径
end

-- 计算完整导航步骤序列
function Pathfinder:CalculateRoute(destination)
    if not destination or not destination.mapID then return nil end

    local currentMapID = C_Map.GetBestMapForUnit("player")
    if not currentMapID then
        ns.Print("无法获取当前玩家所在地图")
        return nil
    end

    local playerFaction = ns.GetPlayerFaction()
    local steps = {}

    -- =====================================================================
    -- 0. 优先检测：玩家是否拥有该副本的【英雄之路大秘境直达传送门】
    -- =====================================================================
    if destination.id and destination.id > 0 and ns.PlayerTeleports then
        local directPortal = ns.PlayerTeleports:GetDirectDungeonPortal(destination.id)
        if directPortal then
            local cdText = directPortal.isReady and "|cff00ff00[就绪]|r" or string.format("|cffff4040[CD: %d秒]|r", directPortal.cdSeconds)
            table.insert(steps, {
                stepIndex = 1,
                mapID = destination.mapID,
                x = destination.x,
                y = destination.y,
                action = "SPELL",
                description = string.format("施放传送技能【%s】%s 直达副本门口", directPortal.spellName, cdText),
                isFinal = true,
            })
            return {
                destination = destination,
                steps = steps,
                totalSteps = 1,
                isDirect = true,
            }
        end
    end

    -- =====================================================================
    -- 1. 同一地图：直接前往
    -- =====================================================================
    if currentMapID == destination.mapID then
        local arriveDesc
        if destination.type == "zone" or destination.type == "continent" then
            arriveDesc = string.format("你当前已在【%s】，已抵达目标区域！", destination.name)
        else
            arriveDesc = string.format("你已在该地图，直接前往【%s】入口 (%.1f, %.1f)", destination.name, destination.x * 100, destination.y * 100)
        end
        table.insert(steps, {
            stepIndex = 1,
            mapID = destination.mapID,
            x = destination.x,
            y = destination.y,
            action = "DIRECT",
            description = arriveDesc,
            isFinal = true,
        })
        return {
            destination = destination,
            steps = steps,
            totalSteps = 1,
        }
    end

    -- =====================================================================
    -- 2. 跨地图寻路：结合玩家个人传送物品/玩具/技能，寻找全局最优路径
    -- =====================================================================
    -- 2.1 先算从当前位置出发的纯物理交通路径
    local directEdges = self:FindShortestPath(currentMapID, destination.mapID, playerFaction)
    local bestEdges = directEdges
    local bestTeleportPrefix = nil
    local minHops = directEdges and #directEdges or 9999

    -- 2.2 扫描玩家拥有的传送物品、玩具、职业技能（达拉然炉石、公会披风、虫洞、法师开门等）
    if ns.PlayerTeleports then
        local availableTeleports = ns.PlayerTeleports:GetAvailableTeleports()
        for _, tp in ipairs(availableTeleports) do
            -- 如果该传送直接到达目标地图
            if tp.toMap == destination.mapID then
                bestEdges = {}
                bestTeleportPrefix = tp
                minHops = 0
                break
            else
                -- 计算从传送目的地到最终目标的跳数
                local tpEdges = self:FindShortestPath(tp.toMap, destination.mapID, playerFaction)
                if tpEdges then
                    -- 评估代价：使用传送道具相当于 1 跳，且如果是达拉然炉石/主城披风通常比长途跋涉更快捷
                    local costHops = #tpEdges + 1
                    if costHops < minHops or (costHops == minHops and tp.priority > 8) then
                        minHops = costHops
                        bestEdges = tpEdges
                        bestTeleportPrefix = tp
                    end
                end
            end
        end
    end

    -- 2.3 兜底：若前两者都找不到路（如身处偏远孤立副本），尝试回主城传送大厅
    local hubMapID = (playerFaction == "HORDE") and 85 or 84
    local needFallbackHearthstone = false

    if not bestEdges and not bestTeleportPrefix then
        bestEdges = self:FindShortestPath(hubMapID, destination.mapID, playerFaction)
        if bestEdges then
            needFallbackHearthstone = true
        end
    end

    if not bestEdges and not bestTeleportPrefix then
        ns.Print("未能找到前往【" .. destination.name .. "】的有效交通路径")
        return nil
    end

    -- =====================================================================
    -- 3. 构造完整步骤链条
    -- =====================================================================
    local stepCount = 0

    -- 步骤 A：使用了个人专属传送手段（玩具/物品/法术）
    if bestTeleportPrefix then
        stepCount = stepCount + 1
        local cdTag = bestTeleportPrefix.isReady and "" or string.format(" |cffff4040[CD: %d秒]|r", bestTeleportPrefix.cdSeconds)
        local toMapName = GetMapDisplayName(bestTeleportPrefix.toMap)
        local actionDesc = string.format("使用【%s】%s传送前往【%s】", bestTeleportPrefix.name, cdTag, toMapName)

        table.insert(steps, {
            stepIndex = stepCount,
            mapID = bestTeleportPrefix.toMap,
            x = bestTeleportPrefix.x or 0.5,
            y = bestTeleportPrefix.y or 0.5,
            action = bestTeleportPrefix.type,
            description = actionDesc,
            isFinal = (bestTeleportPrefix.toMap == destination.mapID and (destination.type == "zone" or destination.type == "continent")),
        })
    elseif needFallbackHearthstone then
        stepCount = stepCount + 1
        local hubName = GetMapDisplayName(hubMapID)
        table.insert(steps, {
            stepIndex = stepCount,
            mapID = hubMapID,
            x = 0.5,
            y = 0.5,
            action = "HEARTHSTONE",
            description = string.format("使用炉石或常规手段前往【%s】传送门大厅", hubName),
            isFinal = false,
        })
    end

    -- 步骤 B：中间公共交通（传送门/飞艇/船只）
    if bestEdges then
        for _, edge in ipairs(bestEdges) do
            stepCount = stepCount + 1
            local fromName = GetMapDisplayName(edge.from)
            local toName = GetMapDisplayName(edge.to)
            local verb = TRANSPORT_TEXT[edge.type] or "搭乘交通设施"

            table.insert(steps, {
                stepIndex = stepCount,
                mapID = edge.from,
                x = edge.x,
                y = edge.y,
                toMapID = edge.to,
                action = edge.type,
                description = string.format("在【%s】前往坐标 (%.1f, %.1f)，%s前往【%s】", fromName, edge.x * 100, edge.y * 100, verb, toName),
                isFinal = false,
            })
        end
    end

    -- 步骤 C：最终抵达目标
    stepCount = stepCount + 1
    local finalDesc
    if destination.type == "zone" or destination.type == "continent" then
        finalDesc = string.format("抵达【%s】，已成功进入目标区域！", destination.name)
    else
        finalDesc = string.format("抵达【%s】，前往【%s】入口 (%.1f, %.1f)", GetMapDisplayName(destination.mapID), destination.name, destination.x * 100, destination.y * 100)
    end

    table.insert(steps, {
        stepIndex = stepCount,
        mapID = destination.mapID,
        x = destination.x,
        y = destination.y,
        action = "ARRIVE",
        description = finalDesc,
        isFinal = true,
    })

    return {
        destination = destination,
        steps = steps,
        totalSteps = stepCount,
    }
end
