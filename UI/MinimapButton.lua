local _, ns = ...
local L = ns.L

local MinimapButton = {}
ns.MinimapButton = MinimapButton

local button = nil
local isDragging = false
local DEFAULT_ANGLE = 215

-- 根据角度计算小地图周边坐标
local function UpdatePosition(angle)
    if not button or not Minimap then return end
    angle = angle or (PortaDB and PortaDB.minimapPos) or DEFAULT_ANGLE
    local rad = math.rad(angle)
    local miniW = Minimap:GetWidth() or 140
    local miniH = Minimap:GetHeight() or 140
    local radius = (math.max(miniW, miniH) / 2) + 5
    local x = math.cos(rad) * radius
    local y = math.sin(rad) * radius

    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- 拖拽移动驱动
local function OnDragUpdate(self)
    if not Minimap then return end
    local mx, my = Minimap:GetCenter()
    if not mx or not my then return end

    local cx, cy = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale() or 1
    cx, cy = cx / scale, cy / scale

    local dx, dy = cx - mx, cy - my
    local angle = math.deg(math.atan2(dy, dx))
    if angle < 0 then
        angle = angle + 360
    end

    PortaDB = PortaDB or {}
    PortaDB.minimapPos = angle
    UpdatePosition(angle)
end

-- 安全辅助：判断当前是否有活跃导航路线 (防御 MBB 插件或异步初始化时方法未就绪)
local function IsNavigationActive()
    if not ns.Navigation then return false end
    if type(ns.Navigation.IsActive) == "function" then
        return ns.Navigation:IsActive()
    elseif type(ns.Navigation.GetActiveRoute) == "function" then
        return ns.Navigation:GetActiveRoute() ~= nil
    end
    return false
end

-- 创建小地图按钮
local function CreateButton()
    if button then return button end

    button = CreateFrame("Button", "PortaMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel((Minimap:GetFrameLevel() or 5) + 8)
    button:SetClampedToScreen(true)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton", "RightButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- 1. 暴雪原生小地图深色背景 (BACKGROUND 层，20x20，居中对齐圆环镂空窗口)
    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)
    button.background = background

    -- 2. 核心图标 (ARTWORK 层，20x20 精确居中于圆环内，圆心为 (17, -15))
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)
    icon:SetTexture("Interface\\AddOns\\Porta\\Images\\Logo")
    button.icon = icon

    -- 3. 暴雪原生小地图圆形圆环边框 (OVERLAY 层，53x53 顶点对齐)
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.border = border

    -- 按下与抬起视觉微移反馈 (沿斜对角微移 1 像素)
    button:SetScript("OnMouseDown", function()
        icon:SetPoint("TOPLEFT", button, "TOPLEFT", 8, -6)
    end)
    button:SetScript("OnMouseUp", function()
        icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -5)
    end)

    -- 拖拽逻辑
    button:SetScript("OnDragStart", function(self)
        isDragging = true
        self:SetScript("OnUpdate", OnDragUpdate)
        GameTooltip:Hide()
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        C_Timer.After(0.08, function()
            isDragging = false
        end)
    end)

    -- 点击交互 (左键呼出搜索框，右键若导航中则停止导航)
    button:SetScript("OnClick", function(self, btn)
        if isDragging then return end
        if btn == "LeftButton" then
            if ns.SearchDialog then
                ns.SearchDialog:Toggle()
            end
        elseif btn == "RightButton" then
            if IsNavigationActive() then
                if ns.Navigation and ns.Navigation.StopRoute then
                    ns.Navigation:StopRoute()
                elseif ns.Navigation and ns.Navigation.CancelRoute then
                    ns.Navigation:CancelRoute()
                end
            else
                if ns.SearchDialog then
                    ns.SearchDialog:Toggle()
                end
            end
        end
    end)

    -- 悬停提示 (完全兼容 MBB 及单体原生悬停)
    button:SetScript("OnEnter", function(self)
        if isDragging then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["MINIMAP_TOOLTIP_TITLE"] or "Porta", 0.0, 0.8, 1.0)
        GameTooltip:AddLine(L["MINIMAP_TOOLTIP_LCLICK"], 0.2, 1.0, 0.4)
        if IsNavigationActive() then
            GameTooltip:AddLine(L["MINIMAP_TOOLTIP_RCLICK"], 1.0, 0.4, 0.2)
        end
        GameTooltip:AddLine(L["MINIMAP_TOOLTIP_DRAG"], 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return button
end

-- 初始化并同步持久化位置
function MinimapButton:Initialize()
    PortaDB = PortaDB or {}
    if PortaDB.showMinimapButton == nil then
        PortaDB.showMinimapButton = true
    end
    if PortaDB.minimapPos == nil then
        PortaDB.minimapPos = DEFAULT_ANGLE
    end

    CreateButton()
    UpdatePosition(PortaDB.minimapPos)

    if PortaDB.showMinimapButton then
        button:Show()
    else
        button:Hide()
    end
end

-- 切换小地图按钮显隐
function MinimapButton:Toggle()
    PortaDB = PortaDB or {}
    PortaDB.showMinimapButton = not PortaDB.showMinimapButton
    if button then
        if PortaDB.showMinimapButton then
            button:Show()
            UpdatePosition(PortaDB.minimapPos)
        else
            button:Hide()
        end
    end
    return PortaDB.showMinimapButton
end

-- 显示小地图按钮
function MinimapButton:Show()
    PortaDB = PortaDB or {}
    PortaDB.showMinimapButton = true
    if not button then
        CreateButton()
    end
    button:Show()
    UpdatePosition(PortaDB.minimapPos)
end

-- 隐藏小地图按钮
function MinimapButton:Hide()
    PortaDB = PortaDB or {}
    PortaDB.showMinimapButton = false
    if button then
        button:Hide()
    end
end

-- 更新坐标
function MinimapButton:UpdatePosition(angle)
    UpdatePosition(angle)
end
