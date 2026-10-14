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

    -- 1. 核心图标 (32-bit RGBA Logo，精确居中于圆环内)
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(18, 18)
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -6)
    icon:SetTexture("Interface\\AddOns\\Porta\\Images\\Logo")

    -- 在现代魔兽版本中应用平滑圆形遮罩，裁切边缘
    if button.CreateMaskTexture and icon.AddMaskTexture then
        local mask = button:CreateMaskTexture()
        mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetAllPoints(icon)
        icon:AddMaskTexture(mask)
    end
    button.icon = icon

    -- 2. 暴雪原生小地图圆形圆环边框 (53x53 顶点对齐)
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.border = border

    -- 按下与抬起视觉微移反馈
    button:SetScript("OnMouseDown", function()
        icon:SetPoint("TOPLEFT", button, "TOPLEFT", 8, -7)
    end)
    button:SetScript("OnMouseUp", function()
        icon:SetPoint("TOPLEFT", button, "TOPLEFT", 7, -6)
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
            if ns.Navigation and ns.Navigation:IsActive() then
                ns.Navigation:StopRoute()
            else
                if ns.SearchDialog then
                    ns.SearchDialog:Toggle()
                end
            end
        end
    end)

    -- 悬停提示
    button:SetScript("OnEnter", function(self)
        if isDragging then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["MINIMAP_TOOLTIP_TITLE"] or "Porta", 0.0, 0.8, 1.0)
        GameTooltip:AddLine(L["MINIMAP_TOOLTIP_LCLICK"], 0.2, 1.0, 0.4)
        if ns.Navigation and ns.Navigation:IsActive() then
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
function MinimapButton:Toggle(silent)
    PortaDB = PortaDB or {}
    PortaDB.showMinimapButton = not PortaDB.showMinimapButton
    if button then
        if PortaDB.showMinimapButton then
            button:Show()
            UpdatePosition(PortaDB.minimapPos)
            if not silent then
                ns.Print(L["CMD_MINIMAP_TOGGLE_ON"])
            end
        else
            button:Hide()
            if not silent then
                ns.Print(L["CMD_MINIMAP_TOGGLE_OFF"])
            end
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
