local _, ns = ...

local NavigationHUD = {}
ns.NavigationHUD = NavigationHUD

local hudFrame = nil
local titleText = nil
local stepCounterText = nil
local currentStepText = nil
local nextStepText = nil

local function InitHUD()
    if hudFrame then return end

    hudFrame = CreateFrame("Frame", "PortaNavigationHUD", UIParent, "BackdropTemplate")
    hudFrame:SetSize(360, 110)
    hudFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -220, -180)
    hudFrame:SetMovable(true)
    hudFrame:EnableMouse(true)
    hudFrame:RegisterForDrag("LeftButton")
    hudFrame:SetScript("OnDragStart", hudFrame.StartMoving)
    hudFrame:SetScript("OnDragStop", hudFrame.StopMovingOrSizing)
    hudFrame:SetClampedToScreen(true)

    -- 背景与边框
    hudFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    hudFrame:SetBackdropColor(0.06, 0.08, 0.12, 0.88)
    hudFrame:SetBackdropBorderColor(0.0, 0.8, 1.0, 0.85)

    -- 品牌标志
    local logo = hudFrame:CreateTexture(nil, "ARTWORK")
    logo:SetSize(18, 18)
    logo:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 10, -9)
    logo:SetTexture("Interface\\AddOns\\Porta\\Images\\Logo")

    -- 标题：目的地
    titleText = hudFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    titleText:SetPoint("TOPLEFT", logo, "TOPRIGHT", 6, 2)
    titleText:SetText("|cff00ccff路线指引|r")

    -- 点击标题区域打开世界地图定位目的地
    local mapBtn = CreateFrame("Button", nil, hudFrame)
    mapBtn:SetPoint("TOPLEFT", logo, "TOPLEFT")
    mapBtn:SetPoint("BOTTOMRIGHT", titleText, "BOTTOMRIGHT", 10, 0)
    mapBtn:SetScript("OnClick", function()
        local activeRoute = ns.Navigation:GetActiveRoute()
        if activeRoute and activeRoute.destination and activeRoute.destination.mapID then
            ns.Navigation:OpenWorldMap(activeRoute.destination.mapID)
        end
    end)
    mapBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("点击在世界地图中查看目的地航标")
        GameTooltip:Show()
    end)
    mapBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- 步骤计数 (例如 "第 1/3 步")
    stepCounterText = hudFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    stepCounterText:SetPoint("TOPRIGHT", hudFrame, "TOPRIGHT", -32, -10)
    stepCounterText:SetText("第 1/1 步")

    -- 关闭 / 取消导航按钮
    local closeBtn = CreateFrame("Button", nil, hudFrame, "UIPanelCloseButton")
    closeBtn:SetSize(22, 22)
    closeBtn:SetPoint("TOPRIGHT", hudFrame, "TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function()
        ns.Navigation:CancelRoute()
    end)

    -- 当前步骤描述
    currentStepText = hudFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
    currentStepText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -8)
    currentStepText:SetPoint("RIGHT", hudFrame, "RIGHT", -12, 0)
    currentStepText:SetJustifyH("LEFT")
    currentStepText:SetWordWrap(true)

    -- 下一步预告
    nextStepText = hudFrame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    nextStepText:SetPoint("BOTTOMLEFT", hudFrame, "BOTTOMLEFT", 12, 10)
    nextStepText:SetJustifyH("LEFT")

    -- 下一步快捷按钮 (用于手动提前推进)
    local nextBtn = CreateFrame("Button", nil, hudFrame, "UIPanelButtonTemplate")
    nextBtn:SetSize(58, 20)
    nextBtn:SetPoint("BOTTOMRIGHT", hudFrame, "BOTTOMRIGHT", -10, 8)
    nextBtn:SetText("下一步")
    nextBtn:SetScript("OnClick", function()
        ns.Navigation:NextStep()
    end)
    hudFrame.nextBtn = nextBtn

    hudFrame:Hide()
end

-- 显示路线
function NavigationHUD:ShowRoute(route, stepIndex)
    InitHUD()
    self:UpdateStep(route, stepIndex)
    hudFrame:Show()
end

-- 更新当前步骤内容
function NavigationHUD:UpdateStep(route, stepIndex)
    if not hudFrame or not route then return end

    local currentStep = route.steps[stepIndex]
    if not currentStep then return end

    titleText:SetText(string.format("|cff00ccff🧭 %s|r", route.destination.name))
    stepCounterText:SetText(string.format("|cffffcc00第 %d / %d 步|r", stepIndex, route.totalSteps))

    currentStepText:SetText(string.format("|cffffffff▶ %s|r", currentStep.description or ""))

    if stepIndex < route.totalSteps then
        local nextStep = route.steps[stepIndex + 1]
        nextStepText:SetText(string.format("后续: %s", nextStep.action or "前进"))
        hudFrame.nextBtn:SetText("下一步")
    else
        nextStepText:SetText("|cff00ff00最后冲刺：即将抵达目的地！|r")
        hudFrame.nextBtn:SetText("完成")
    end
end

-- 隐藏 HUD
function NavigationHUD:Hide()
    if hudFrame then
        hudFrame:Hide()
    end
end
