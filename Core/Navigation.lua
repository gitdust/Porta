local _, ns = ...
local L = ns.L

local Navigation = {}
ns.Navigation = Navigation

local activeRoute = nil
local currentStepIndex = 1
local tomtomWaypoint = nil

-- 设置暴雪原生航标与超追踪
local function SetBlizzardWaypoint(mapID, x, y)
    if not C_Map or not C_Map.SetUserWaypoint then return end

    pcall(function()
        C_Map.ClearUserWaypoint()
        if mapID and x and y and x > 0 and y > 0 then
            local point = UiMapPoint.CreateFromCoordinates(mapID, x, y)
            C_Map.SetUserWaypoint(point)
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
        end
    end)
end

-- 清除暴雪原生航标
local function ClearBlizzardWaypoint()
    if C_Map and C_Map.ClearUserWaypoint then
        pcall(function()
            C_Map.ClearUserWaypoint()
        end)
    end
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
    if _G.TomTom and TomTom.RemoveWaypoint and tomtomWaypoint then
        pcall(function()
            TomTom:RemoveWaypoint(tomtomWaypoint)
            tomtomWaypoint = nil
        end)
    end
end

-- 打开世界地图并定位到指定地图
function Navigation:OpenWorldMap(mapID)
    if not mapID or mapID <= 0 then return end
    pcall(function()
        if not WorldMapFrame:IsShown() then
            ShowUIPanel(WorldMapFrame)
        end
        WorldMapFrame:SetMapID(mapID)
    end)
end

-- 点击步骤中的坐标时：设置暴雪/TomTom 航标并打开世界地图查看
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
    SetTomTomWaypoint(mapID, normX, normY, label or string.format("%s (%.1f, %.1f)", mapName, normX * 100, normY * 100))
    self:OpenWorldMap(mapID)

    ns.Print(string.format(L["MSG_FOCUS_COORD_FMT"], mapName, normX * 100, normY * 100))
end

-- 检查并提示当前方案中缺失的传送玩具或物品
local function NotifyMissingTeleportIfAny(route)
    if not route or not route.steps then return end
    for _, step in ipairs(route.steps) do
        if step.isMissingTeleport and step.teleportInfo then
            local tp = step.teleportInfo
            local kindName = (tp.type == "TOY" and L["KIND_TOY"]) or (tp.type == "SPELL" and L["KIND_SPELL"]) or L["KIND_ITEM"]
            local reason = tp.missingReason or string.format(L["MSG_MISSING_TELEPORT_REASON_FALLBACK_FMT"], kindName)
            ns.Print(string.format(L["MSG_MISSING_TELEPORT_NOTIFY_FMT"], kindName, tp.name or "", reason))
            break
        end
    end
end

-- =========================================================================
-- 启动路线导航，并自动设置目的地地图航标点
-- =========================================================================
function Navigation:StartRoute(route)
    if not route or not route.steps or #route.steps == 0 then
        ns.Print(L["ERR_EMPTY_ROUTE"])
        return
    end

    activeRoute = route
    currentStepIndex = 1

    local dest = route.destination

    -- 1. 自动为目的地打上世界地图点 (暴雪原生航标 + TomTom 兼容)
    SetBlizzardWaypoint(dest.mapID, dest.x, dest.y)
    SetTomTomWaypoint(dest.mapID, dest.x, dest.y, dest.name)

    ns.Print(string.format(L["MSG_ROUTE_STARTED_FMT"], dest.name, route.totalSteps))
    ns.Print(string.format(L["MSG_WAYPOINT_SET_FMT"], dest.zoneName or string.format(L["MAP_FALLBACK_FMT"], tostring(dest.mapID)), dest.x * 100, dest.y * 100))

    -- 若当前默认方案使用了玩家尚未拥有的玩具/物品，主动提示
    NotifyMissingTeleportIfAny(activeRoute)

    -- 2. 应用当前步骤状态与指引
    self:ApplyCurrentStep()

    -- 3. 唤起屏幕 HUD
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

    local altName = alt.name or string.format(L["ALT_OPTION_FALLBACK_FMT"], altIndex)
    local distInfo = (alt.distanceText and alt.distanceText ~= "") and (" (" .. alt.distanceText .. ")") or ""
    ns.Print(string.format(L["MSG_SWITCHED_ALT_FMT"], altName, distInfo))
    NotifyMissingTeleportIfAny(activeRoute)
end

-- 回退到上一步
function Navigation:PrevStep()
    if not activeRoute then return end

    if currentStepIndex > 1 then
        currentStepIndex = currentStepIndex - 1
        ns.Print(string.format(L["MSG_STEP_PREV_FMT"], currentStepIndex, activeRoute.totalSteps))
        self:ApplyCurrentStep()
    end
end

-- 推进到下一步
function Navigation:NextStep()
    if not activeRoute then return end

    if currentStepIndex < activeRoute.totalSteps then
        currentStepIndex = currentStepIndex + 1
        ns.Print(string.format(L["MSG_STEP_NEXT_FMT"], currentStepIndex, activeRoute.totalSteps))
        self:ApplyCurrentStep()
    else
        self:FinishRoute()
    end
end

-- 路线结束
function Navigation:FinishRoute()
    if not activeRoute then return end
    ns.Print(string.format(L["MSG_ROUTE_FINISHED_FMT"], activeRoute.destination.name))
    ClearBlizzardWaypoint()
    ClearTomTomWaypoint()
    activeRoute = nil
    currentStepIndex = 1

    if ns.NavigationHUD then
        ns.NavigationHUD:Hide()
    end
end

-- 取消导航
function Navigation:CancelRoute()
    if not activeRoute then return end
    ns.Print(L["MSG_ROUTE_CANCELLED"])
    ClearBlizzardWaypoint()
    ClearTomTomWaypoint()
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

-- 监听地图切换事件，自动推进步骤
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:SetScript("OnEvent", function()
    if not activeRoute then return end

    local currentMapID = C_Map.GetBestMapForUnit("player")
    if not currentMapID then return end

    local currentStep = activeRoute.steps[currentStepIndex]
    if not currentStep then return end

    -- 如果当前步骤是跨地图交通，并且玩家已经进入了目标地图，自动推进
    if currentStep.toMapID and currentMapID == currentStep.toMapID then
        Navigation:NextStep()
    elseif currentStep.isFinal and currentMapID == activeRoute.destination.mapID then
        -- 已经在目标地图，航标自动刷新为终点
        local dest = activeRoute.destination
        SetBlizzardWaypoint(dest.mapID, dest.x, dest.y)
    end
end)
