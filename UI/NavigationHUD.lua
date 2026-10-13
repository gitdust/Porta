local _, ns = ...

local NavigationHUD = {}
ns.NavigationHUD = NavigationHUD

local hudFrame = nil
local titleText = nil
local stepCounterText = nil
local currentStepText = nil
local nextStepText = nil
local altContainer = nil
local altButtons = {}
local questWarnBox = nil
local questWarnText = nil

local ACTION_LABELS = {
    PORTAL       = "穿过传送门",
    ZEPPELIN     = "搭乘飞艇",
    SHIP         = "搭乘轮船",
    WAYGATE      = "进入传送门道",
    MIRROR       = "穿过传送之镜",
    MOLE_MACHINE = "使用钻地机",
    TRAM         = "搭乘矿道地铁",
    CLASS_PORTAL = "使用职业传送门",
    TRANSPORT    = "穿过通道",
    FLY          = "飞行前往",
    ARRIVE       = "抵达终点",
    SPELL        = "施放技能",
    ITEM         = "使用道具",
    HEARTHSTONE  = "使用炉石",
    DIRECT       = "直接前往",
}

local function InitHUD()
    if hudFrame then return end

    hudFrame = CreateFrame("Frame", "PortaNavigationHUD", UIParent, "BackdropTemplate")
    hudFrame:SetSize(420, 140)
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
    hudFrame:SetBackdropColor(0.06, 0.08, 0.12, 0.92)
    hudFrame:SetBackdropBorderColor(0.0, 0.8, 1.0, 0.85)

    -- 标题：目的地
    titleText = hudFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
    titleText:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -14)
    titleText:SetText("|cff00ccff路线指引|r")

    -- 点击目的地标题打开世界地图定位目的地
    local mapBtn = CreateFrame("Button", nil, hudFrame)
    mapBtn:SetPoint("TOPLEFT", titleText, "TOPLEFT", -2, 2)
    mapBtn:SetPoint("BOTTOMRIGHT", titleText, "BOTTOMRIGHT", 2, -2)
    mapBtn:SetScript("OnClick", function()
        local activeRoute = ns.Navigation:GetActiveRoute()
        if activeRoute and activeRoute.destination and activeRoute.destination.mapID then
            ns.Navigation:OpenWorldMap(activeRoute.destination.mapID)
        end
    end)
    mapBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("点击在世界地图中定位终点航标")
        GameTooltip:Show()
    end)
    mapBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- 步骤计数 (例如 "第 1/3 步")
    stepCounterText = hudFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    stepCounterText:SetPoint("TOPRIGHT", hudFrame, "TOPRIGHT", -36, -14)
    stepCounterText:SetText("第 1/1 步")

    -- 关闭 / 取消导航按钮
    local closeBtn = CreateFrame("Button", nil, hudFrame, "UIPanelCloseButton")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", hudFrame, "TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        ns.Navigation:CancelRoute()
    end)

    -- 多路线单选选项容器 (垂直堆叠排列，杜绝横向挤压文字)
    altContainer = CreateFrame("Frame", nil, hudFrame)
    altContainer:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -36)
    altContainer:SetPoint("RIGHT", hudFrame, "RIGHT", -16, 0)
    altContainer:SetHeight(26)
    altContainer:Hide()

    -- 当前步骤描述
    currentStepText = hudFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
    currentStepText:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -38)
    currentStepText:SetWidth(388)
    currentStepText:SetJustifyH("LEFT")
    currentStepText:SetJustifyV("TOP")
    currentStepText:SetWordWrap(true)
    if currentStepText.SetNonSpaceWrap then
        currentStepText:SetNonSpaceWrap(true)
    end
    currentStepText:SetSpacing(3)

    -- 点击步骤描述直达地图
    local stepClickBtn = CreateFrame("Button", nil, hudFrame)
    stepClickBtn:SetAllPoints(currentStepText)
    stepClickBtn:SetScript("OnClick", function()
        local activeRoute, stepIdx = ns.Navigation:GetActiveRoute()
        if activeRoute and activeRoute.steps and activeRoute.steps[stepIdx] then
            local s = activeRoute.steps[stepIdx]
            ns.Navigation:OpenWorldMap(s.mapID)
        end
    end)
    stepClickBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("点击直接打开世界地图查看当前步骤的标记位置")
        GameTooltip:Show()
    end)
    stepClickBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- 前置任务解锁提醒专属提示框 (高度随文本行数动态伸缩)
    questWarnBox = CreateFrame("Frame", nil, hudFrame, "BackdropTemplate")
    questWarnBox:SetWidth(388)
    questWarnBox:SetHeight(48)
    questWarnBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    questWarnBox:SetBackdropColor(0.25, 0.05, 0.05, 0.90)
    questWarnBox:SetBackdropBorderColor(0.95, 0.35, 0.1, 0.95)

    questWarnText = questWarnBox:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    questWarnText:SetPoint("TOPLEFT", questWarnBox, "TOPLEFT", 10, -8)
    questWarnText:SetWidth(368)
    questWarnText:SetJustifyH("LEFT")
    questWarnText:SetJustifyV("TOP")
    questWarnText:SetWordWrap(true)
    if questWarnText.SetNonSpaceWrap then
        questWarnText:SetNonSpaceWrap(true)
    end
    questWarnText:SetSpacing(3)
    questWarnBox:Hide()

    -- 下一步快捷按钮
    local nextBtn = CreateFrame("Button", nil, hudFrame, "UIPanelButtonTemplate")
    nextBtn:SetSize(54, 22)
    nextBtn:SetPoint("BOTTOMRIGHT", hudFrame, "BOTTOMRIGHT", -14, 11)
    nextBtn:SetText("下一步")
    nextBtn:SetScript("OnClick", function()
        ns.Navigation:NextStep()
    end)
    hudFrame.nextBtn = nextBtn

    -- 上一步快捷按钮
    local prevBtn = CreateFrame("Button", nil, hudFrame, "UIPanelButtonTemplate")
    prevBtn:SetSize(54, 22)
    prevBtn:SetPoint("RIGHT", nextBtn, "LEFT", -5, 0)
    prevBtn:SetText("上一步")
    prevBtn:SetScript("OnClick", function()
        ns.Navigation:PrevStep()
    end)
    hudFrame.prevBtn = prevBtn

    -- 查看地图快捷按钮
    local viewMapBtn = CreateFrame("Button", nil, hudFrame, "UIPanelButtonTemplate")
    viewMapBtn:SetSize(68, 22)
    viewMapBtn:SetPoint("RIGHT", prevBtn, "LEFT", -5, 0)
    viewMapBtn:SetText("查看地图")
    viewMapBtn:SetScript("OnClick", function()
        local activeRoute, stepIdx = ns.Navigation:GetActiveRoute()
        if activeRoute and activeRoute.steps and activeRoute.steps[stepIdx] then
            local s = activeRoute.steps[stepIdx]
            ns.Navigation:OpenWorldMap(s.mapID)
        end
    end)
    viewMapBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("在世界地图中定位并查看此步骤的具体标记")
        GameTooltip:Show()
    end)
    viewMapBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    hudFrame.viewMapBtn = viewMapBtn

    -- 底部后续预告
    nextStepText = hudFrame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    nextStepText:SetPoint("BOTTOMLEFT", hudFrame, "BOTTOMLEFT", 16, 15)
    nextStepText:SetPoint("RIGHT", viewMapBtn, "LEFT", -8, 0)
    nextStepText:SetJustifyH("LEFT")
    nextStepText:SetWordWrap(false)

    hudFrame:Hide()
end

-- 刷新多路线单选按钮栏 (独占行垂直排列，彻底解决文字重叠)
local function UpdateAlternativeButtons(route, stepIndex)
    if not altContainer then return 0 end

    -- 仅在第 1 步且存在 2 个以上可行起点时展示方案单选
    if stepIndex ~= 1 or not route.alternatives or #route.alternatives <= 1 then
        altContainer:Hide()
        return 0
    end

    altContainer:Show()
    local selectedIdx = route.selectedAltIndex or 1
    local btnCount = #route.alternatives
    local rowHeight = 24
    local containerHeight = btnCount * rowHeight + 4
    altContainer:SetHeight(containerHeight)

    for i, alt in ipairs(route.alternatives) do
        local btn = altButtons[i]
        if not btn then
            btn = CreateFrame("Button", nil, altContainer, "BackdropTemplate")
            btn:SetHeight(22)
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 10,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            btn.text:SetPoint("LEFT", btn, "LEFT", 10, 0)
            btn.text:SetJustifyH("LEFT")
            altButtons[i] = btn
        end

        btn:Show()
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", altContainer, "TOPLEFT", 0, -(i - 1) * rowHeight)
        btn:SetPoint("RIGHT", altContainer, "RIGHT", 0, 0)

        local isSelected = (i == selectedIdx)
        local radio = isSelected and "|cff00ffff●|r " or "|cff888888○|r "
        local distTag = (alt.distanceText and alt.distanceText ~= "") and (" - " .. alt.distanceText) or ""
        local tag = (i == 1) and " |cff00ff00[推荐]|r" or ""
        local label = string.format("%s方案 %d: %s%s%s", radio, i, alt.name, distTag, tag)
        btn.text:SetText(label)

        if isSelected then
            btn:SetBackdropColor(0.0, 0.45, 0.75, 0.65)
            btn:SetBackdropBorderColor(0.0, 0.9, 1.0, 0.95)
            btn.text:SetTextColor(1.0, 1.0, 1.0)
        else
            btn:SetBackdropColor(0.12, 0.15, 0.20, 0.50)
            btn:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.50)
            btn.text:SetTextColor(0.75, 0.75, 0.75)
        end

        local altIndex = i
        btn:SetScript("OnClick", function()
            ns.Navigation:SelectAlternativeRoute(altIndex)
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(string.format("点击单选切换到【方案 %d：%s】", altIndex, alt.name))
            if alt.viaDesc then
                GameTooltip:AddLine(alt.viaDesc, 0.8, 0.8, 0.8)
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    for i = btnCount + 1, #altButtons do
        altButtons[i]:Hide()
    end

    return containerHeight + 4
end

-- 辅助：计算带自动换行的中英文混排文本安全高度（防止隐藏态或首帧 GetStringHeight 偏小导致内容超出边框）
local function GetSafeFontStringHeight(fontString, rawText, bytesPerLine, lineHeight, minHeight)
    local measured = (fontString and fontString.GetStringHeight and fontString:GetStringHeight()) or 0
    if not rawText or rawText == "" then
        return math.max(measured, minHeight or 18)
    end

    -- 剥离魔兽颜色控制码与纹理标签后按行估算折行高度
    local clean = rawText:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    local totalLines = 0
    for line in (clean .. "\n"):gmatch("([^\n]*)\n") do
        local byteLen = #line
        local wrappedLines = math.max(1, math.ceil(byteLen / (bytesPerLine or 72)))
        totalLines = totalLines + wrappedLines
    end

    local estimated = totalLines * (lineHeight or 16)
    return math.max(measured, estimated, minHeight or 18)
end

-- 显示路线
function NavigationHUD:ShowRoute(route, stepIndex)
    InitHUD()
    hudFrame:Show()
    self:UpdateStep(route, stepIndex)
end

-- 更新当前步骤内容
function NavigationHUD:UpdateStep(route, stepIndex)
    if not hudFrame or not route then return end

    local currentStep = route.steps[stepIndex]
    if not currentStep then return end

    -- 标题纯文本显示
    titleText:SetText(string.format("|cff00ccff%s|r", route.destination.name or "目的地"))
    stepCounterText:SetText(string.format("|cffffcc00第 %d / %d 步|r", stepIndex, route.totalSteps))

    -- 1. 多路线单选选项栏渲染 (自适应高度)
    local altOffset = UpdateAlternativeButtons(route, stepIndex)

    -- 2. 步骤描述文本排版
    local descStr = string.format("|cffffffff%s|r", currentStep.description or "")
    currentStepText:ClearAllPoints()
    currentStepText:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -36 - altOffset)
    currentStepText:SetWidth(388)
    currentStepText:SetText(descStr)

    local descHeight = GetSafeFontStringHeight(currentStepText, descStr, 78, 17, 20)

    -- 3. 前置任务提醒框排版 (位于步骤描述下方，高度随内容行数完全自适应)
    local questWarnHeight = 0
    if currentStep.isQuestGated and currentStep.questGateInfo then
        local gate = currentStep.questGateInfo
        local warnStr
        if gate.unlockGuide and gate.unlockGuide ~= "" then
            warnStr = string.format("|cffff4444⚠ 传送门未解锁|r\n%s", gate.unlockGuide)
        else
            warnStr = string.format("|cffff4444⚠ 传送门未解锁|r\n当前角色需在%s接取%s开启；或请队友在副本门口拉人。", gate.startNPC or "主城", gate.questName or "前置任务")
        end

        questWarnBox:ClearAllPoints()
        questWarnBox:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -36 - altOffset - descHeight - 8)
        questWarnBox:SetWidth(388)
        questWarnText:SetWidth(368)
        questWarnText:SetText(warnStr)
        questWarnBox:Show()

        local warnTextH = GetSafeFontStringHeight(questWarnText, warnStr, 72, 16, 20)
        local boxHeight = warnTextH + 18 -- 上下预留 18px 内边距，确保多行文字完全包裹在边框内
        questWarnBox:SetHeight(boxHeight)
        questWarnHeight = boxHeight + 8
    else
        questWarnBox:Hide()
    end

    -- 4. 按钮状态控制：第 1 步时禁用“上一步”
    if stepIndex > 1 then
        hudFrame.prevBtn:Enable()
    else
        hudFrame.prevBtn:Disable()
    end

    -- 5. 下一步预告与“下一步/完成”按钮文本
    if stepIndex < route.totalSteps then
        local nextStep = route.steps[stepIndex + 1]
        local actionLabel = (nextStep and ACTION_LABELS[nextStep.action]) or (nextStep and nextStep.action) or "前进"
        nextStepText:SetText(string.format("后续: %s", actionLabel))
        hudFrame.nextBtn:SetText("下一步")
    else
        nextStepText:SetText("|cff00ff00即将抵达目的地！|r")
        hudFrame.nextBtn:SetText("完成")
    end

    -- 6. 动态总高度计算：顶部(36) + 方案栏(altOffset) + 描述(descHeight) + 任务警告(questWarnHeight) + 底部按钮间距(48)
    local totalFrameHeight = 36 + altOffset + descHeight + questWarnHeight + 48
    hudFrame:SetHeight(math.max(130, totalFrameHeight))

    -- 7. 下一渲染帧二次校准：待客户端引擎完成字形折行后，自动对齐真实渲染高度
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if not hudFrame or not hudFrame:IsShown() then return end
            local realDescH = math.max(descHeight, currentStepText:GetStringHeight() or 0)
            local realWarnH = 0
            if questWarnBox:IsShown() then
                questWarnBox:ClearAllPoints()
                questWarnBox:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -36 - altOffset - realDescH - 8)
                local actualWarnTextH = questWarnText:GetStringHeight() or 0
                local finalBoxH = math.max(questWarnBox:GetHeight(), actualWarnTextH + 18)
                questWarnBox:SetHeight(finalBoxH)
                realWarnH = finalBoxH + 8
            end
            hudFrame:SetHeight(math.max(130, 36 + altOffset + realDescH + realWarnH + 48))
        end)
    end
end

-- 隐藏 HUD
function NavigationHUD:Hide()
    if hudFrame then
        hudFrame:Hide()
    end
end
