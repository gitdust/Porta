local _, ns = ...

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
                title = title or "Porta 导航目标",
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
    if not mapID then return end
    pcall(function()
        if not WorldMapFrame:IsShown() then
            ShowUIPanel(WorldMapFrame)
        end
        WorldMapFrame:SetMapID(mapID)
    end)
end

-- =========================================================================
-- 启动路线导航，并自动设置目的地地图航标点
-- =========================================================================
function Navigation:StartRoute(route)
    if not route or not route.steps or #route.steps == 0 then
        ns.Print("无法启动空路线导航")
        return
    end

    activeRoute = route
    currentStepIndex = 1

    local dest = route.destination

    -- 1. 自动为目的地打上世界地图点 (暴雪原生航标 + TomTom 兼容)
    SetBlizzardWaypoint(dest.mapID, dest.x, dest.y)
    SetTomTomWaypoint(dest.mapID, dest.x, dest.y, dest.name)

    ns.Print(string.format("已启动前往【%s】的路线导航（共 %d 步）", dest.name, route.totalSteps))
    ns.Print(string.format("已自动在地图【%s】(%.1f, %.1f) 设置目的地航标点！", dest.zoneName or ("地图 #" .. dest.mapID), dest.x * 100, dest.y * 100))

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

    -- 如果当前步骤是中间跳转点（如主城传送门坐标），将导航箭头临时指向该传送门
    if not step.isFinal and step.x and step.y and step.mapID then
        local currentMapID = C_Map.GetBestMapForUnit("player")
        if currentMapID == step.mapID then
            SetBlizzardWaypoint(step.mapID, step.x, step.y)
        end
    else
        -- 最终步骤直接指向终点
        local dest = activeRoute.destination
        SetBlizzardWaypoint(dest.mapID, dest.x, dest.y)
    end

    if ns.NavigationHUD then
        ns.NavigationHUD:UpdateStep(activeRoute, currentStepIndex)
    end
end

-- 推进到下一步
function Navigation:NextStep()
    if not activeRoute then return end

    if currentStepIndex < activeRoute.totalSteps then
        currentStepIndex = currentStepIndex + 1
        ns.Print(string.format("已推进到第 %d/%d 步", currentStepIndex, activeRoute.totalSteps))
        self:ApplyCurrentStep()
    else
        self:FinishRoute()
    end
end

-- 路线结束
function Navigation:FinishRoute()
    if not activeRoute then return end
    ns.Print(string.format("已顺利抵达目的地【%s】！导航结束。", activeRoute.destination.name))
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
    ns.Print("已取消当前导航。")
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
