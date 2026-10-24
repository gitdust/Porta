local _, ns = ...
local L = ns.L

local Navigation = {}
ns.Navigation = Navigation

local activeRoute = nil
local currentStepIndex = 1
local tomtomWaypoint = nil

-- Porta 自己设置的航标 (仅清除自己设置的，不动玩家手动放置的标记与任务追踪)
local ownWaypoint = nil

-- 若地图不允许放置用户航标 (副本内部 / 部分微型地图)，沿父地图换算坐标直至可放置
local function ResolveWaypointLocation(mapID, x, y)
    if not C_Map.CanSetUserWaypointOnMap then
        return mapID, x, y
    end
    local currMap, currX, currY = mapID, x, y
    for _ = 1, 6 do
        if C_Map.CanSetUserWaypointOnMap(currMap) then
            return currMap, currX, currY
        end
        local info = C_Map.GetMapInfo(currMap)
        local parentID = info and info.parentMapID
        if not parentID or parentID <= 0 or not C_Map.GetMapRectOnMap then
            return nil
        end
        local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(currMap, parentID)
        if not minX then
            return nil
        end
        currX = minX + currX * (maxX - minX)
        currY = minY + currY * (maxY - minY)
        currMap = parentID
    end
    return nil
end

local function IsOwnWaypointActive()
    if not ownWaypoint or not C_Map.GetUserWaypoint then return false end
    local point = C_Map.GetUserWaypoint()
    if not point or point.uiMapID ~= ownWaypoint.mapID or not point.position then return false end
    -- GetUserWaypoint 返回的 position 是不带 Vector2DMixin 方法的普通表，只能直接读 x / y
    local px, py = point.position.x, point.position.y
    if not px or not py then return false end
    return math.abs(px - ownWaypoint.x) < 0.0005 and math.abs(py - ownWaypoint.y) < 0.0005
end

-- 设置暴雪原生航标与超追踪
local function SetBlizzardWaypoint(mapID, x, y)
    if not C_Map or not C_Map.SetUserWaypoint then return end
    if not mapID or not x or not y or x <= 0 or y <= 0 then return end

    local wpMap, wpX, wpY = ResolveWaypointLocation(mapID, x, y)
    if not wpMap then return end

    local ok = pcall(function()
        C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(wpMap, wpX, wpY))
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        end
    end)
    if ok then
        ownWaypoint = { mapID = wpMap, x = wpX, y = wpY }
    end
end

-- 清除 Porta 设置的暴雪原生航标与超追踪
local function ClearBlizzardWaypoint()
    if IsOwnWaypointActive() then
        pcall(function()
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                C_SuperTrack.SetSuperTrackedUserWaypoint(false)
            end
            C_Map.ClearUserWaypoint()
        end)
    end
    ownWaypoint = nil
end

-- 剥离超链接与图标控制码，生成纯文本标题
local function StripHyperlinksAndIcons(text)
    if type(text) ~= "string" then return "" end
    return text
        :gsub("|T[^|]*|t", "")
        :gsub("|H[^|]*|h", "")
        :gsub("|h", "")
end

-- 设置 TomTom 航标（如果安装了 TomTom）
local function SetTomTomWaypoint(mapID, x, y, title)
    if not _G.TomTom or not TomTom.AddWaypoint then return end

    pcall(function()
        if tomtomWaypoint then
            TomTom:RemoveWaypoint(tomtomWaypoint)
            tomtomWaypoint = nil
        end
        if mapID and x and y and x > 0 and y > 0 then
            tomtomWaypoint = TomTom:AddWaypoint(mapID, x, y, {
                title = StripHyperlinksAndIcons(title or L["TOMTOM_DEFAULT_TITLE"]),
                persistent = false,
                minimap = true,
                world = true,
            })
        end
    end)
end

-- 清除 TomTom 航标
local function ClearTomTomWaypoint()
    if _G.TomTom and tomtomWaypoint then
        pcall(function()
            if TomTom.RemoveWaypoint then
                TomTom:RemoveWaypoint(tomtomWaypoint)
            end
        end)
    end
    tomtomWaypoint = nil
end

-- 打开世界地图并定位到指定地图 (安全规避 Taint 与战斗阻断)
function Navigation:OpenWorldMap(mapID)
    local inCombat = (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and UnitAffectingCombat("player"))
    if inCombat then
        local combatMsg = L["MSG_COMBAT_MAP_RESTRICTED"]
        if UIErrorsFrame and UIErrorsFrame.AddMessage then
            UIErrorsFrame:AddMessage(combatMsg, 1.0, 0.82, 0.0, 1.0, 3)
        end
        return
    end
    if not mapID or mapID <= 0 then return end

    -- 异步延后执行，切断与外部点击事件栈的同步传递，规避暴雪原生 MapCanvas 的保护功能污染拦截
    C_Timer.After(0, function()
        local stillCombat = (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and UnitAffectingCombat("player"))
        if stillCombat then return end

        pcall(function()
            if _G.OpenWorldMap then
                _G.OpenWorldMap(mapID)
            elseif WorldMapFrame then
                if not WorldMapFrame:IsShown() then
                    if ToggleWorldMap then
                        ToggleWorldMap()
                    elseif ShowUIPanel then
                        ShowUIPanel(WorldMapFrame)
                    else
                        WorldMapFrame:Show()
                    end
                end
                if WorldMapFrame.GetMapID and WorldMapFrame:GetMapID() ~= mapID and WorldMapFrame.SetMapID then
                    WorldMapFrame:SetMapID(mapID)
                end
            end
        end)
    end)
end

-- 点击步骤中的坐标时：设置暴雪超追踪与 TomTom 航标 (无需强开大地图遮挡视野与引发 Taint)
function Navigation:FocusCoordinate(mapID, x, y, label)
    if not mapID or not x or not y then return end
    local normX = (x > 1.0) and (x / 100.0) or x
    local normY = (y > 1.0) and (y / 100.0) or y

    local mapName = L["UNKNOWN_MAP"]
    if C_Map and C_Map.GetMapInfo and mapID > 0 then
        local info = C_Map.GetMapInfo(mapID)
        if info and info.name then
            mapName = info.name
        end
    end

    SetBlizzardWaypoint(mapID, normX, normY)
    SetTomTomWaypoint(mapID, normX, normY, label or string.format("%s (%.2f, %.2f)", mapName, normX * 100, normY * 100))
end

-- =========================================================================
-- 启动路线导航，并自动设置目的地地图航标点
-- =========================================================================
function Navigation:StartRoute(route)
    if not route or not route.steps or #route.steps == 0 then
        return
    end

    activeRoute = route
    currentStepIndex = 1

    -- 应用当前第一步骤航标状态与指引 (避免首步为地表洞口时提前将航标锚定在地下终点)
    self:ApplyCurrentStep()

    -- 唤起屏幕 HUD
    if ns.NavigationHUD then
        ns.NavigationHUD:ShowRoute(activeRoute, currentStepIndex)
    end
end

-- 应用当前步骤航标与状态
function Navigation:ApplyCurrentStep()
    if not activeRoute then return end

    local step = activeRoute.steps[currentStepIndex]
    if not step then return end

    if not step.isFinal then
        if step.action == "FLY" then
            -- 飞行阶段：如果有下一步入口坐标，直接为后续目标入口打标；否则为目的地打标
            local nextStep = activeRoute.steps[currentStepIndex + 1]
            if nextStep and nextStep.mapID and nextStep.x and nextStep.y then
                SetBlizzardWaypoint(nextStep.mapID, nextStep.x, nextStep.y)
                SetTomTomWaypoint(nextStep.mapID, nextStep.x, nextStep.y, nextStep.description)
            else
                local dest = activeRoute.destination
                SetBlizzardWaypoint(dest.mapID, dest.x, dest.y)
                SetTomTomWaypoint(dest.mapID, dest.x, dest.y, dest.name)
            end
        elseif step.x and step.y and step.mapID then
            SetBlizzardWaypoint(step.mapID, step.x, step.y)
            SetTomTomWaypoint(step.mapID, step.x, step.y, step.description)
        end
    else
        -- 最终步骤直接指向终点
        local dest = activeRoute.destination
        SetBlizzardWaypoint(dest.mapID, dest.x, dest.y)
        SetTomTomWaypoint(dest.mapID, dest.x, dest.y, dest.name)
    end

    if ns.NavigationHUD then
        ns.NavigationHUD:UpdateStep(activeRoute, currentStepIndex)
    end
end

-- 切换备选路线
function Navigation:SelectAlternativeRoute(altIndex)
    if not activeRoute or not activeRoute.alternatives then return end
    local alt = activeRoute.alternatives[altIndex]
    if not alt then return end

    activeRoute.selectedAltIndex = altIndex
    activeRoute.steps = alt.steps
    activeRoute.totalSteps = alt.totalSteps
    currentStepIndex = 1

    self:ApplyCurrentStep()

    if ns.NavigationHUD then
        ns.NavigationHUD:ShowRoute(activeRoute, currentStepIndex)
    end
end

-- 回退到上一步
function Navigation:PrevStep()
    if not activeRoute then return end

    if currentStepIndex > 1 then
        currentStepIndex = currentStepIndex - 1
        self:ApplyCurrentStep()
    end
end

-- 推进到下一步
function Navigation:NextStep()
    if not activeRoute then return end

    if currentStepIndex < activeRoute.totalSteps then
        currentStepIndex = currentStepIndex + 1
        self:ApplyCurrentStep()
    else
        self:FinishRoute()
    end
end

-- 公共方法：彻底清空所有暴雪航标、超追踪与 TomTom 标记点
function Navigation:ClearWaypoints()
    ClearBlizzardWaypoint()
    ClearTomTomWaypoint()
end

-- 路线结束 (完成导航，清空航标并直接关闭 HUD)
function Navigation:FinishRoute()
    self:ClearWaypoints()
    activeRoute = nil
    currentStepIndex = 1

    if ns.NavigationHUD then
        ns.NavigationHUD:Hide()
    end
end

-- 取消/退出导航路线并清空标记点
function Navigation:CancelRoute()
    self:ClearWaypoints()
    activeRoute = nil
    currentStepIndex = 1

    if ns.NavigationHUD then
        ns.NavigationHUD:Hide()
    end
end

-- 获取当前活动路线
function Navigation:GetActiveRoute()
    return activeRoute, currentStepIndex
end

-- 检查当前是否有活跃导航路线 (含 HUD 显示中或存在地图航标)
function Navigation:IsActive()
    if activeRoute ~= nil then
        return true
    end
    if ns.NavigationHUD and ns.NavigationHUD.IsShown and ns.NavigationHUD:IsShown() then
        return true
    end
    return IsOwnWaypointActive()
end

-- 停止/退出导航路线 (兼容 MinimapButton、聊天命令等外部模块调用)
function Navigation:StopRoute()
    self:CancelRoute()
end

-- 监听地图切换事件，自动推进步骤
-- 当前地图可能是目标地图的子区域 (城内建筑等)，按父地图链匹配；玩家跳过中间步骤时直接推进到对应步骤
local function IsInMap(currentMapID, targetMapID)
    if ns.Pathfinder and ns.Pathfinder.IsMapWithin then
        return ns.Pathfinder:IsMapWithin(currentMapID, targetMapID)
    end
    return currentMapID == targetMapID
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:SetScript("OnEvent", function()
    if not activeRoute then return end

    local currentMapID = C_Map.GetBestMapForUnit("player")
    if not currentMapID then return end

    for i = activeRoute.totalSteps, currentStepIndex, -1 do
        local step = activeRoute.steps[i]
        if step and step.toMapID and IsInMap(currentMapID, step.toMapID) then
            currentStepIndex = i
            Navigation:NextStep()
            return
        end
    end

    local currentStep = activeRoute.steps[currentStepIndex]
    if currentStep and currentStep.isFinal and IsInMap(currentMapID, activeRoute.destination.mapID) then
        -- 已经在目标地图，航标自动刷新为终点
        local dest = activeRoute.destination
        SetBlizzardWaypoint(dest.mapID, dest.x, dest.y)
    end
end)
