local _, ns = ...
local L = ns.L

local NavigationHUD = {}
ns.NavigationHUD = NavigationHUD

local hudFrame = nil
local dragHeader = nil
local titleText = nil
local stepCounterText = nil
local upperSection = nil
local altContainer = nil
local altButtons = {}
local stepTextFrame = nil
local currentStepText = nil
local lowerSection = nil
local tipTextFrame = nil
local tipText = nil
local actionSlotBtn = nil
local secureActionBtn = nil
local bottomBar = nil
local prevBtn = nil
local nextBtn = nil
local viewMapBtn = nil

-- 与暴雪动作条保持一致：UseKeyDown 开启时按下施放，关闭时抬起施放。
-- 不能同时注册 Down/Up，否则 SecureActionButton 会在同一次点击里触发两次。
local function UpdateSecureActionClickRegistration()
    if not secureActionBtn then return end
    if InCombatLockdown and InCombatLockdown() then return end

    local useKeyDown = (GetCVarBool and GetCVarBool("ActionButtonUseKeyDown")) or false
    pcall(function()
        secureActionBtn:RegisterForClicks(useKeyDown and "AnyDown" or "AnyUp")
    end)
end

local ACTION_LABELS = {
    PORTAL       = L["HUD_ACTION_PORTAL"],
    BEACON       = L["HUD_ACTION_BEACON"],
    ZEPPELIN     = L["HUD_ACTION_ZEPPELIN"],
    SHIP         = L["HUD_ACTION_SHIP"],
    WAYGATE      = L["HUD_ACTION_WAYGATE"],
    MIRROR       = L["HUD_ACTION_MIRROR"],
    MOLE_MACHINE = L["HUD_ACTION_MOLE_MACHINE"],
    TRAM         = L["HUD_ACTION_TRAM"],
    CLASS_PORTAL = L["HUD_ACTION_CLASS_PORTAL"],
    TRANSPORT    = L["HUD_ACTION_TRANSPORT"],
    CAVE_ENTER   = L["HUD_ACTION_CAVE_ENTER"],
    CAVE_EXIT    = L["HUD_ACTION_CAVE_EXIT"],
    ELEVATOR_DOWN= L["HUD_ACTION_ELEVATOR_DOWN"],
    ELEVATOR_UP  = L["HUD_ACTION_ELEVATOR_UP"],
    FLY          = L["HUD_ACTION_FLY"],
    ARRIVE       = L["HUD_ACTION_ARRIVE"],
    SPELL        = L["HUD_ACTION_SPELL"],
    ITEM         = L["HUD_ACTION_ITEM"],
    TOY          = L["HUD_ACTION_TOY"],
    HEARTHSTONE  = L["HUD_ACTION_HEARTHSTONE"],
    DIRECT       = L["HUD_ACTION_DIRECT"],
}

local ACTION_DEFAULT_TEXTURES = {}

-- 缓存解析后的超链接结构
local linkCache = {}

-- 解析 Porta 自定义超链接 (porta:toy:id / porta:item:id / porta:spell:id / porta:coord:mapID:x:y)
local function ParsePortaHyperlink(link)
    if type(link) ~= "string" then return nil end
    local cached = linkCache[link]
    if cached ~= nil then
        return cached or nil
    end

    local kind, a1, a2, a3 = string.match(link, "^porta:([^:]+):([^:]+):?([^:]*):?([^:]*)$")
    if not kind then
        linkCache[link] = false
        return nil
    end
    kind = string.upper(kind)

    local res = nil
    if kind == "COORD" then
        local mapID = tonumber(a1)
        local x = tonumber(a2)
        local y = tonumber(a3)
        if x and y then
            res = { kind = "COORD", mapID = mapID or 0, x = x, y = y }
        end
    elseif kind == "TOY" or kind == "ITEM" or kind == "SPELL" then
        local id = tonumber(a1)
        if id then
            res = { kind = kind, id = id }
        end
    end

    linkCache[link] = res or false
    return res
end

-- 打开玩具/物品/技能的独立详情浮窗 (ItemRefTooltip)
local function OpenTeleportDetailView(parsed)
    if not parsed or not parsed.id then return end
    pcall(function()
        ShowUIPanel(ItemRefTooltip)
        if not ItemRefTooltip:IsShown() then
            ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
        end
        if parsed.kind == "SPELL" then
            ItemRefTooltip:SetSpellByID(parsed.id)
        elseif parsed.kind == "TOY" then
            local ok = pcall(function() ItemRefTooltip:SetToyByItemID(parsed.id) end)
            if not ok or ItemRefTooltip:NumLines() == 0 then
                ItemRefTooltip:SetItemByID(parsed.id)
            end
        else
            ItemRefTooltip:SetItemByID(parsed.id)
        end
        ItemRefTooltip:Show()
    end)
end

-- 剥离超链接与图标控制码，生成纯文本
local function StripHyperlinksAndIcons(text)
    if type(text) ~= "string" then return "" end
    return text
        :gsub("|T[^|]*|t", "")
        :gsub("|c%x%x%x%x%x%x%x%x", "")
        :gsub("|r", "")
        :gsub("|H[^|]*|h", "")
        :gsub("|h", "")
end

-- 在 GameTooltip 中渲染玩具、物品、技能或坐标的悬停说明
local function ShowPortaLinkTooltip(owner, parsed, step)
    if not parsed then return end
    GameTooltip:SetOwner(owner or hudFrame or UIParent, "ANCHOR_TOP")
    GameTooltip:ClearLines()

    if parsed.kind == "COORD" then
        local mapName = L["HUD_TOOLTIP_CURRENT_ZONE"]
        if parsed.mapID and parsed.mapID > 0 and C_Map and C_Map.GetMapInfo then
            local info = C_Map.GetMapInfo(parsed.mapID)
            if info and info.name then
                mapName = info.name
            end
        end
        GameTooltip:SetText(string.format(L["HUD_TOOLTIP_COORD_TITLE_FMT"], mapName, parsed.x, parsed.y), 1.0, 0.82, 0.0)
        GameTooltip:AddLine(L["HUD_TOOLTIP_COORD_CLICK"], 0.0, 1.0, 0.4)
        GameTooltip:Show()
        return
    end

    if parsed.kind == "SPELL" then
        pcall(function() GameTooltip:SetSpellByID(parsed.id) end)
    elseif parsed.kind == "TOY" then
        local ok = pcall(function() GameTooltip:SetToyByItemID(parsed.id) end)
        if not ok or GameTooltip:NumLines() == 0 then
            pcall(function() GameTooltip:SetItemByID(parsed.id) end)
        end
    else
        pcall(function() GameTooltip:SetItemByID(parsed.id) end)
    end

    local hasIt, missingReason = true, nil
    if ns.PlayerTeleports and ns.PlayerTeleports.CheckTeleportOwnership then
        hasIt, missingReason = ns.PlayerTeleports:CheckTeleportOwnership(parsed.kind, parsed.id)
    end

    local isCombat = (InCombatLockdown and InCombatLockdown()) or false

    GameTooltip:AddLine(" ")
    if hasIt then
        if isCombat then
            GameTooltip:AddLine(L["HUD_TOOLTIP_COMBAT_RESTRICTED"], 1.0, 0.35, 0.35)
        end
        GameTooltip:AddLine(L["HUD_TOOLTIP_RCLICK_DETAIL"], 0.75, 0.75, 0.75)
    else
        GameTooltip:AddLine("⚠ " .. (missingReason or L["HUD_TOOLTIP_MISSING_FALLBACK"]), 1.0, 0.35, 0.25, true)
        GameTooltip:AddLine(L["HUD_TOOLTIP_CLICK_DETAIL"], 0.0, 0.85, 1.0)
    end

    if step and step.note and step.note ~= "" then
        GameTooltip:AddLine(StripHyperlinksAndIcons(step.note), 0.9, 0.9, 0.9, true)
    end
    GameTooltip:Show()
end

-- 非传送步骤悬停提示
local function ShowStepActionTooltip(owner, step)
    if not step then return end
    GameTooltip:SetOwner(owner or hudFrame or UIParent, "ANCHOR_TOP")
    GameTooltip:ClearLines()
    local actionTitle = ACTION_LABELS[step.action] or step.action or L["HUD_ACTION_DEFAULT"]
    GameTooltip:SetText(actionTitle, 1.0, 0.82, 0.0)
    if step.description then
        GameTooltip:AddLine(StripHyperlinksAndIcons(step.description), 0.9, 0.9, 0.9, true)
    end
    if step.note and step.note ~= "" then
        GameTooltip:AddLine(StripHyperlinksAndIcons(step.note), 0.9, 0.9, 0.9, true)
    end
    if step.mapID and step.x and step.y and step.x > 0 and step.y > 0 then
        GameTooltip:AddLine(L["HUD_TOOLTIP_COORD_CLICK"], 0.0, 1.0, 0.4)
    end
    GameTooltip:Show()
end

-- 统一绑定富文本区域的超链接交互事件
local function BindHyperlinkScripts(targetFrame)
    targetFrame:SetHyperlinksEnabled(true)

    targetFrame:SetScript("OnHyperlinkEnter", function(self, link)
        self.hoveredHyperlink = true
        local parsed = ParsePortaHyperlink(link)
        if parsed then
            ShowPortaLinkTooltip(hudFrame, parsed)
        end
    end)

    targetFrame:SetScript("OnHyperlinkLeave", function(self)
        self.hoveredHyperlink = false
        local step = self.currentStep
        if self.noteHovered and step and step.note and step.note ~= "" then
            ShowStepActionTooltip(self, step)
        else
            GameTooltip:Hide()
        end
    end)

    targetFrame:SetScript("OnHyperlinkClick", function(_, link)
        local parsed = ParsePortaHyperlink(link)
        if not parsed then return end

        if parsed.kind == "COORD" then
            if ns.Navigation and ns.Navigation.FocusCoordinate then
                ns.Navigation:FocusCoordinate(parsed.mapID, parsed.x, parsed.y)
            end
        else
            OpenTeleportDetailView(parsed)
        end
    end)
end

-- 辅助：计算 UTF-8 真实显示宽度 (ASCII 字符占 1 宽度，中文字符占 2 宽度)
local function GetDisplayWidth(str)
    if not str or str == "" then return 0 end
    local width = 0
    local i = 1
    local len = #str
    while i <= len do
        local b = str:byte(i)
        if b < 128 then
            width = width + 1
            i = i + 1
        elseif b >= 192 and b < 224 then
            width = width + 2
            i = i + 2
        elseif b >= 224 and b < 240 then
            width = width + 2
            i = i + 3
        elseif b >= 240 then
            width = width + 2
            i = i + 4
        else
            i = i + 1
        end
    end
    return width
end

-- 辅助：计算带自动换行的文本安全高度
local function GetSafeFontStringHeight(fontString, rawText, maxCharsPerLine, lineHeight, minHeight)
    local measured = (fontString and fontString.GetStringHeight and fontString:GetStringHeight()) or 0
    if not rawText or rawText == "" then
        return math.max(measured, minHeight or 18)
    end

    local clean = rawText
        :gsub("|c%x%x%x%x%x%x%x%x", "")
        :gsub("|r", "")
        :gsub("|H[^|]*|h", "")
        :gsub("|h", "")
        :gsub("|T[^|]*|t", "  ")

    local totalLines = 0
    local targetChars = maxCharsPerLine or 48
    for line in (clean .. "\n"):gmatch("([^\n]*)\n") do
        local dispWidth = GetDisplayWidth(line)
        local wrappedLines = math.max(1, math.ceil(dispWidth / targetChars))
        totalLines = totalLines + wrappedLines
    end

    local estimated = totalLines * (lineHeight or 16)
    return math.max(measured, estimated, minHeight or 18)
end

-- 初始化 HUD 界面
local function InitHUD()
    if hudFrame then return end

    hudFrame = CreateFrame("Frame", "PortaNavigationHUD", UIParent, "BackdropTemplate")
    hudFrame:SetSize(420, 140)
    local savedPoint = PortaDB and PortaDB.hudPoint
    if savedPoint and savedPoint.point then
        hudFrame:SetPoint(savedPoint.point, UIParent, savedPoint.relativePoint or savedPoint.point, savedPoint.x or 0, savedPoint.y or 0)
    else
        hudFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -220, -180)
    end
    hudFrame:SetMovable(true)
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

    -- 顶部拖拽把手区
    dragHeader = CreateFrame("Frame", nil, hudFrame)
    dragHeader:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 0, 0)
    dragHeader:SetPoint("TOPRIGHT", hudFrame, "TOPRIGHT", -32, 0)
    dragHeader:SetHeight(32)
    dragHeader:EnableMouse(true)
    dragHeader:RegisterForDrag("LeftButton")
    dragHeader:SetScript("OnDragStart", function() hudFrame:StartMoving() end)
    dragHeader:SetScript("OnDragStop", function()
        hudFrame:StopMovingOrSizing()
        local point, _, relativePoint, x, y = hudFrame:GetPoint(1)
        PortaDB = PortaDB or {}
        PortaDB.hudPoint = { point = point, relativePoint = relativePoint, x = x, y = y }
    end)

    -- 标题：目的地
    titleText = dragHeader:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
    titleText:SetPoint("LEFT", dragHeader, "LEFT", 16, 0)
    titleText:SetPoint("RIGHT", dragHeader, "RIGHT", -110, 0)
    titleText:SetJustifyH("LEFT")
    titleText:SetWordWrap(false)
    titleText:SetText(L["HUD_DEFAULT_TITLE"])

    -- 点击目的地标题打开世界地图定位目的地
    local mapBtn = CreateFrame("Button", nil, dragHeader)
    mapBtn:SetPoint("TOPLEFT", titleText, "TOPLEFT", -2, 2)
    mapBtn:SetPoint("BOTTOMRIGHT", titleText, "BOTTOMRIGHT", 2, -2)
    mapBtn:SetScript("OnClick", function()
        local inCombat = (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and UnitAffectingCombat("player"))
        if inCombat then
            local combatMsg = L["MSG_COMBAT_MAP_RESTRICTED"]
            if UIErrorsFrame and UIErrorsFrame.AddMessage then
                UIErrorsFrame:AddMessage(combatMsg, 1.0, 0.82, 0.0, 1.0, 3)
            end
            return
        end
        local activeRoute = ns.Navigation:GetActiveRoute()
        if activeRoute and activeRoute.destination and activeRoute.destination.mapID then
            ns.Navigation:OpenWorldMap(activeRoute.destination.mapID)
        end
    end)
    mapBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(L["HUD_TITLE_TOOLTIP"])
        GameTooltip:Show()
    end)
    mapBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- 步骤计数 (例如 "第 1/3 步" / "Step 1/3")
    stepCounterText = dragHeader:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    stepCounterText:SetPoint("RIGHT", dragHeader, "RIGHT", -10, 0)
    stepCounterText:SetText(string.format(L["HUD_STEP_COUNTER_FMT"], 1, 1))

    -- 关闭 / 取消导航按钮
    local closeBtn = CreateFrame("Button", nil, hudFrame, "UIPanelCloseButton")
    closeBtn:SetSize(22, 22)
    closeBtn:SetPoint("TOPRIGHT", hudFrame, "TOPRIGHT", -4, -4)
    closeBtn:SetFrameLevel(hudFrame:GetFrameLevel() + 10)
    closeBtn:SetScript("OnClick", function()
        ns.Navigation:CancelRoute()
    end)

    -- =========================================================================
    -- 上方区域 (Upper Section): 方案选项 (Step 1) + 具体步骤描述
    -- =========================================================================
    upperSection = CreateFrame("Frame", nil, hudFrame)
    upperSection:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -34)
    upperSection:SetPoint("RIGHT", hudFrame, "RIGHT", -16, 0)

    -- 方案选择胶囊容器 (仅在 Step 1 且备选路线 > 1 时显示)
    altContainer = CreateFrame("Frame", nil, upperSection)
    altContainer:SetPoint("TOPLEFT", upperSection, "TOPLEFT", 0, 0)
    altContainer:SetPoint("RIGHT", upperSection, "RIGHT", 0, 0)
    altContainer:SetHeight(24)
    altContainer:Hide()

    -- 步骤描述富文本框
    stepTextFrame = CreateFrame("Frame", nil, upperSection)
    stepTextFrame:SetPoint("TOPLEFT", upperSection, "TOPLEFT", 0, 0)
    stepTextFrame:SetPoint("RIGHT", upperSection, "RIGHT", 0, 0)
    stepTextFrame:SetHeight(20)
    BindHyperlinkScripts(stepTextFrame)
    stepTextFrame:EnableMouse(true)
    stepTextFrame:SetScript("OnEnter", function(self)
        self.noteHovered = true
        local step = self.currentStep
        if not self.hoveredHyperlink and step and step.note and step.note ~= "" then
            ShowStepActionTooltip(self, step)
        end
    end)
    stepTextFrame:SetScript("OnLeave", function(self)
        self.noteHovered = false
        self.hoveredHyperlink = false
        GameTooltip:Hide()
    end)

    currentStepText = stepTextFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
    currentStepText:SetPoint("TOPLEFT", stepTextFrame, "TOPLEFT", 0, 0)
    currentStepText:SetPoint("RIGHT", stepTextFrame, "RIGHT", 0, 0)
    currentStepText:SetWidth(388)
    currentStepText:SetJustifyH("LEFT")
    currentStepText:SetJustifyV("TOP")
    currentStepText:SetWordWrap(true)
    if currentStepText.SetNonSpaceWrap then
        currentStepText:SetNonSpaceWrap(true)
    end
    currentStepText:SetSpacing(3)

    -- =========================================================================
    -- 下方区域 (Lower Section): 左侧精简提示 + 右侧操作图标
    -- =========================================================================
    lowerSection = CreateFrame("Frame", nil, hudFrame)
    lowerSection:SetPoint("TOPLEFT", upperSection, "BOTTOMLEFT", 0, -8)
    lowerSection:SetPoint("RIGHT", hudFrame, "RIGHT", -16, 0)
    lowerSection:SetHeight(40)

    -- 左侧精简提示框
    tipTextFrame = CreateFrame("Frame", nil, lowerSection)
    tipTextFrame:SetPoint("TOPLEFT", lowerSection, "TOPLEFT", 0, 0)
    tipTextFrame:SetPoint("BOTTOMLEFT", lowerSection, "BOTTOMLEFT", 0, 0)
    tipTextFrame:SetPoint("RIGHT", lowerSection, "RIGHT", -48, 0)
    BindHyperlinkScripts(tipTextFrame)

    tipText = tipTextFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    tipText:SetPoint("TOPLEFT", tipTextFrame, "TOPLEFT", 0, 0)
    tipText:SetPoint("BOTTOMRIGHT", tipTextFrame, "BOTTOMRIGHT", 0, 0)
    tipText:SetJustifyH("LEFT")
    tipText:SetJustifyV("MIDDLE")
    tipText:SetWordWrap(true)
    if tipText.SetNonSpaceWrap then
        tipText:SetNonSpaceWrap(true)
    end
    tipText:SetSpacing(2)

    -- 右侧动作插槽按钮 (40x40，纯普通按钮，不受战斗 Taint 阻断)
    actionSlotBtn = CreateFrame("Button", "PortaStepActionSlotButton", lowerSection, "BackdropTemplate")
    actionSlotBtn:SetSize(40, 40)
    actionSlotBtn:SetPoint("TOPRIGHT", lowerSection, "TOPRIGHT", 0, 0)
    actionSlotBtn:SetFrameLevel(hudFrame:GetFrameLevel() + 5)
    actionSlotBtn:RegisterForClicks("AnyUp")
    actionSlotBtn:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    actionSlotBtn:SetBackdropBorderColor(0.0, 0.85, 1.0, 0.9)

    local slotIcon = actionSlotBtn:CreateTexture(nil, "ARTWORK")
    slotIcon:SetPoint("TOPLEFT", 3, -3)
    slotIcon:SetPoint("BOTTOMRIGHT", -3, 3)
    slotIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    actionSlotBtn.icon = slotIcon

    local slotHighlight = actionSlotBtn:CreateTexture(nil, "HIGHLIGHT")
    slotHighlight:SetAllPoints(slotIcon)
    slotHighlight:SetColorTexture(1.0, 1.0, 1.0, 0.25)

    actionSlotBtn:SetScript("OnEnter", function(self)
        if self.parsedLink then
            ShowPortaLinkTooltip(self, self.parsedLink, self.currentStep)
        elseif self.currentStep then
            ShowStepActionTooltip(self, self.currentStep)
        end
    end)
    actionSlotBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- 点击动作插槽：若为坐标则定位，若为缺失道具则打开说明浮窗
    actionSlotBtn:SetScript("OnClick", function(self, button)
        if InCombatLockdown and InCombatLockdown() then
            local combatMsg = L["MSG_COMBAT_ACTION_RESTRICTED"]
            if UIErrorsFrame and UIErrorsFrame.AddMessage then
                UIErrorsFrame:AddMessage(combatMsg, 1.0, 0.25, 0.25, 1.0, 3)
            end
            if button == "RightButton" and self.parsedLink then
                OpenTeleportDetailView(self.parsedLink)
            end
            return
        end

        local parsed = self.parsedLink
        if parsed then
            if button == "RightButton" or not self.hasIt then
                OpenTeleportDetailView(parsed)
            end
        elseif self.currentStep then
            local step = self.currentStep
            if step.mapID and step.x and step.y and step.x > 0 and step.y > 0 then
                ns.Navigation:FocusCoordinate(step.mapID, step.x, step.y, step.description)
            end
        end
    end)

    -- 独立安全动作点击层 (仅脱战时激活，进战时由系统驱动隐藏并直接穿透至底层提示)
    secureActionBtn = CreateFrame("Button", "PortaStepActionSecureBtn", UIParent, "SecureActionButtonTemplate")
    secureActionBtn:SetFrameStrata("HIGH")
    UpdateSecureActionClickRegistration()
    secureActionBtn:RegisterEvent("CVAR_UPDATE")
    secureActionBtn:SetScript("OnEvent", function(_, event)
        if event == "CVAR_UPDATE" then
            UpdateSecureActionClickRegistration()
        end
    end)
    secureActionBtn:SetScript("OnEnter", function()
        if actionSlotBtn and actionSlotBtn.parsedLink then
            ShowPortaLinkTooltip(actionSlotBtn, actionSlotBtn.parsedLink, actionSlotBtn.currentStep)
        elseif actionSlotBtn and actionSlotBtn.currentStep then
            ShowStepActionTooltip(actionSlotBtn, actionSlotBtn.currentStep)
        end
    end)
    secureActionBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    secureActionBtn:SetScript("PostClick", function(self, button)
        local parsed = actionSlotBtn.parsedLink
        if not parsed then return end

        if button == "RightButton" or not actionSlotBtn.hasIt then
            OpenTeleportDetailView(parsed)
        end
    end)
    secureActionBtn:Hide()

    -- =========================================================================
    -- 底部控制栏 (Bottom Bar): 查看地图 + 上一步 + 下一步/完成导航
    -- =========================================================================
    bottomBar = CreateFrame("Frame", nil, hudFrame)
    bottomBar:SetPoint("BOTTOMLEFT", hudFrame, "BOTTOMLEFT", 16, 12)
    bottomBar:SetPoint("BOTTOMRIGHT", hudFrame, "BOTTOMRIGHT", -16, 12)
    bottomBar:SetHeight(22)

    -- 查看地图快捷按钮
    viewMapBtn = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    viewMapBtn:SetSize(72, 22)
    viewMapBtn:SetPoint("LEFT", bottomBar, "LEFT", 0, 0)
    viewMapBtn:SetText(L["HUD_BTN_MAP"])
    viewMapBtn:SetScript("OnClick", function()
        local inCombat = (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and UnitAffectingCombat("player"))
        if inCombat then
            local combatMsg = L["MSG_COMBAT_MAP_RESTRICTED"]
            if UIErrorsFrame and UIErrorsFrame.AddMessage then
                UIErrorsFrame:AddMessage(combatMsg, 1.0, 0.82, 0.0, 1.0, 3)
            end
            return
        end
        local activeRoute, stepIdx = ns.Navigation:GetActiveRoute()
        if activeRoute and activeRoute.steps and activeRoute.steps[stepIdx] then
            local s = activeRoute.steps[stepIdx]
            ns.Navigation:OpenWorldMap(s.mapID)
        end
    end)
    viewMapBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(L["HUD_MAP_BTN_TOOLTIP"])
        GameTooltip:Show()
    end)
    viewMapBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    hudFrame.viewMapBtn = viewMapBtn

    -- 下一步 / 完成导航按钮
    nextBtn = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    nextBtn:SetSize(76, 22)
    nextBtn:SetPoint("RIGHT", bottomBar, "RIGHT", 0, 0)
    nextBtn:SetText(L["HUD_BTN_NEXT"])
    nextBtn:SetScript("OnClick", function()
        ns.Navigation:NextStep()
    end)
    hudFrame.nextBtn = nextBtn

    -- 上一步快捷按钮
    prevBtn = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    prevBtn:SetSize(60, 22)
    prevBtn:SetPoint("RIGHT", nextBtn, "LEFT", -6, 0)
    prevBtn:SetText(L["HUD_BTN_PREV"])
    prevBtn:SetScript("OnClick", function()
        ns.Navigation:PrevStep()
    end)
    hudFrame.prevBtn = prevBtn

    -- 战斗状态事件监听：脱战安全更新属性，图标始终保持原色不置灰
    local combatFrame = CreateFrame("Frame")
    combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    combatFrame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_ENABLED" then
            if hudFrame and hudFrame:IsShown() and ns.Navigation then
                local activeRoute, stepIdx = ns.Navigation:GetActiveRoute()
                if activeRoute and stepIdx then
                    NavigationHUD:UpdateStep(activeRoute, stepIdx)
                end
            else
                if secureActionBtn then
                    pcall(function()
                        UnregisterStateDriver(secureActionBtn, "visibility")
                        secureActionBtn:Hide()
                    end)
                end
            end
        end
    end)

    hudFrame:Hide()
end

-- 刷新多路线单选按钮栏（每个方案独占一行整齐排列）
local function UpdateAlternativeButtons(route, stepIndex)
    if not altContainer then return 0 end

    if stepIndex ~= 1 or not route.alternatives or #route.alternatives <= 1 then
        altContainer:Hide()
        return 0
    end

    altContainer:Show()
    local selectedIdx = route.selectedAltIndex or 1
    local btnCount = #route.alternatives

    local pillHeight = 22
    local gapY = 4
    local startY = 0

    for i, alt in ipairs(route.alternatives) do
        local btn = altButtons[i]
        if not btn then
            btn = CreateFrame("Button", nil, altContainer, "BackdropTemplate")
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 8,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            btn.text:SetPoint("LEFT", btn, "LEFT", 10, 0)
            btn.text:SetPoint("RIGHT", btn, "RIGHT", -10, 0)
            btn.text:SetJustifyH("LEFT")
            btn.text:SetWordWrap(false)

            local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints(btn)
            highlight:SetColorTexture(1.0, 1.0, 1.0, 0.08)

            altButtons[i] = btn
        else
            btn.text:ClearAllPoints()
            btn.text:SetPoint("LEFT", btn, "LEFT", 10, 0)
            btn.text:SetPoint("RIGHT", btn, "RIGHT", -10, 0)
            btn.text:SetJustifyH("LEFT")
            btn.text:SetWordWrap(false)
        end

        btn:Show()

        local isSelected = (i == selectedIdx)
        local radio = isSelected and "|cff00ffff●|r " or "|cff888888○|r "
        local recTag = (i == 1) and (" " .. L["HUD_ALT_TAG_RECOMMENDED"]) or ""
        local missingLabel = alt.missingShortTag == L["STATUS_UNKNOWN"] and L["STATUS_UNKNOWN"] or L["STATUS_UNAVAILABLE"]
        local missingTag = alt.isMissingTeleport and string.format(" |cffff4444[%s]|r", missingLabel) or ""
        local label = string.format("%s%s%s%s", radio, alt.name or string.format(L["ALT_OPTION_FALLBACK_FMT"], i), recTag, missingTag)

        btn.text:SetText(label)

        -- 每个方案独占一行横向铺满整行
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", altContainer, "TOPLEFT", 0, -startY)
        btn:SetPoint("RIGHT", altContainer, "RIGHT", 0, 0)
        btn:SetHeight(pillHeight)

        startY = startY + pillHeight + gapY

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
            GameTooltip:SetText(string.format(L["HUD_ALT_TOOLTIP_TITLE_FMT"], altIndex, alt.name or ""))
            if alt.viaDesc then
                GameTooltip:AddLine(alt.viaDesc, 0.8, 0.8, 0.8, true)
            end
            if alt.isMissingTeleport then
                GameTooltip:AddLine("⚠ " .. (alt.missingReason or L["HUD_ALT_TOOLTIP_MISSING_FALLBACK"]), 1.0, 0.35, 0.25, true)
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

    local totalContainerHeight = (btnCount > 0) and (startY - gapY) or 0
    altContainer:SetHeight(totalContainerHeight)

    return totalContainerHeight
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
    stepTextFrame.currentStep = currentStep

    -- 使用同一次资产评估更新状态与动作类型，避免路线快照和按钮各自判定。
    local tp = currentStep.teleportInfo
    local hasIt, missingReason, teleportState = true, nil, nil
    if tp and tp.id then
        local kind = tp.type or tp.kind or ((currentStep.action == "MIRROR") and "TOY" or currentStep.action)
        if ns.PlayerTeleports and ns.PlayerTeleports.CheckTeleportOwnership then
            hasIt, missingReason, teleportState = ns.PlayerTeleports:CheckTeleportOwnership(kind, tp.id, tp.name)
        else
            hasIt, missingReason, teleportState = tp.hasItem, tp.missingReason, tp
        end
    end

    -- 确保导航控制按钮恢复可见并绑定默认行为
    hudFrame.prevBtn:Show()
    hudFrame.viewMapBtn:Show()
    hudFrame.nextBtn:SetScript("OnClick", function()
        ns.Navigation:NextStep()
    end)

    -- 标题与计数器显示
    titleText:SetText(string.format("|cff00ccff%s|r", route.destination.name or L["HUD_DEST_FALLBACK"]))
    stepCounterText:SetText(string.format(L["HUD_STEP_COUNTER_FMT"], stepIndex, route.totalSteps))

    -- 1. 上方区域：多路线单选胶囊选项栏 (仅在 Step 1 且备选方案 > 1 时显示)
    local altHeight = UpdateAlternativeButtons(route, stepIndex)
    local hasAltPills = (altHeight > 0)

    -- 2. 上方区域：步骤描述排版 (若有方案胶囊，则位于胶囊下方；否则直接位于上方区域顶部)
    stepTextFrame:ClearAllPoints()
    if hasAltPills then
        stepTextFrame:SetPoint("TOPLEFT", altContainer, "BOTTOMLEFT", 0, -6)
    else
        stepTextFrame:SetPoint("TOPLEFT", upperSection, "TOPLEFT", 0, 0)
    end
    stepTextFrame:SetPoint("RIGHT", upperSection, "RIGHT", 0, 0)

    local stepPrefix = string.format(L["HUD_STEP_NUM_FMT"] or "Step %d: ", stepIndex)
    local descStr = string.format("|cff00ccff%s|r|cffffffff%s|r", stepPrefix, currentStep.description or "")
    currentStepText:SetText(descStr)

    local descHeight = GetSafeFontStringHeight(currentStepText, descStr, 48, 17, 20)
    stepTextFrame:SetHeight(descHeight + 2)

    local upperHeight = hasAltPills and (altHeight + 8 + descHeight + 2) or (descHeight + 2)
    upperSection:SetHeight(upperHeight)

    -- 3. 下方区域：构建精简提示文案
    local tipBlocks = {}

    -- 未知状态不能标成未拥有；银行和角色资格与收集状态分别展示。
    if tp and hasIt ~= true then
        local state = teleportState or tp
        if state.ownershipKnown == false or state.requirementsKnown == false then
            table.insert(tipBlocks, "|cffffaa00" .. L["STATUS_UNKNOWN"] .. "|r")
        elseif currentStep.action == "MIRROR" or tp.id == 129929 then
            table.insert(tipBlocks, "|cffff4444" .. L["STATUS_UNAVAILABLE"] .. "|r")
        elseif state.inBank then
            table.insert(tipBlocks, "|cffffaa00" .. L["STATUS_IN_BANK"] .. "|r")
        elseif state.missingEngineering or state.classMismatch or state.factionMismatch or state.isOwned == true then
            table.insert(tipBlocks, "|cffff4444" .. L["STATUS_UNAVAILABLE"] .. "|r")
        else
            table.insert(tipBlocks, "|cffff4444" .. L["STATUS_NOT_OWNED"] .. "|r")
        end
    end

    if currentStep.warning and currentStep.warning ~= "" then
        table.insert(tipBlocks, "|cffffaa00" .. currentStep.warning .. "|r")
    end

    -- 前置任务门控检测
    if currentStep.isQuestGated and currentStep.questGateInfo then
        local gate = currentStep.questGateInfo
        local qName = gate.questName or L["HUD_WARN_PREREQ_FALLBACK"]
        table.insert(tipBlocks, string.format(L["QUEST_GATE_SHORT_FMT"], qName))
    end

    -- 要塞食人魔道标激活提醒
    if currentStep.isWaygateStep then
        table.insert(tipBlocks, "|cffffaa00" .. L["WAYGATE_SHORT_TIP"] .. "|r")
    end

    -- 历史时间线位面切换提醒
    local phaseInfo = currentStep.phaseShiftInfo or (currentStep.isFinal and route.phaseShiftInfo)
    if phaseInfo then
        local npc = phaseInfo.npcName or L["NPC_ZIDORMI"]
        table.insert(tipBlocks, string.format(L["HUD_PHASE_SHORT_FMT"] or "|cffffaa00需与【%s】对话切换至对应历史位面|r", npc))
    end

    -- 当前步骤距离：直接展示单位文本，避免重复正文。
    local distanceText = currentStep.distanceText
    if (not distanceText or distanceText == "") and currentStep.distanceYards then
        local yards = currentStep.distanceYards
        distanceText = (yards >= 1000)
            and string.format(L["DIST_KYARDS_FMT"], yards / 1000)
            or string.format(L["DIST_YARDS_FMT"], math.floor(yards + 0.5))
    end
    if distanceText and distanceText ~= "" then
        table.insert(tipBlocks, distanceText)
    end

    local finalTipStr = (#tipBlocks > 0) and table.concat(tipBlocks, "\n") or ""
    tipText:SetText(finalTipStr)

    -- 4. 下方区域：操作图标识别与解析（仅当存在真实技能/物品/装备/玩具时才展示图标）
    local hasTeleportAction = false
    local parsedLink = nil

    if tp and tp.id and (currentStep.action == "SPELL" or currentStep.action == "TOY" or currentStep.action == "ITEM" or currentStep.action == "MIRROR" or tp.type) then
        hasTeleportAction = true
        local k = (teleportState and teleportState.kind) or tp.type or tp.kind or ((currentStep.action == "MIRROR") and "TOY" or currentStep.action)
        parsedLink = ParsePortaHyperlink(string.format("porta:%s:%d", string.lower(k), tp.id))
    end

    actionSlotBtn.parsedLink = parsedLink
    actionSlotBtn.currentStep = currentStep

    actionSlotBtn.hasIt = hasIt
    actionSlotBtn.missingReason = missingReason

    -- 动态获取材质图标：严禁使用随机或假图标！仅当为真实法术/道具/玩具时获取
    local texture = nil
    if parsedLink then
        if parsedLink.kind == "SPELL" then
            if C_Spell and C_Spell.GetSpellTexture then
                texture = C_Spell.GetSpellTexture(parsedLink.id)
            end
        else
            if C_Item and C_Item.GetItemIconByID then
                texture = C_Item.GetItemIconByID(parsedLink.id)
            end
        end
        -- 若为百变之镜且客户端缓存未就绪，兜底原生玩具图标
        if not texture and parsedLink.id == 129929 then
            texture = "Interface\\Icons\\INV_Misc_Toy_08"
        end
    end

    local hasValidActionIcon = (parsedLink ~= nil and texture ~= nil)

    -- 根据是否有具体操作图标，自适应调整提示文字宽度与区域布局
    tipTextFrame:ClearAllPoints()
    tipTextFrame:SetPoint("TOPLEFT", lowerSection, "TOPLEFT", 0, 0)
    tipTextFrame:SetPoint("BOTTOMLEFT", lowerSection, "BOTTOMLEFT", 0, 0)
    if hasValidActionIcon then
        tipTextFrame:SetPoint("RIGHT", lowerSection, "RIGHT", -48, 0)
    else
        tipTextFrame:SetPoint("RIGHT", lowerSection, "RIGHT", 0, 0)
    end

    local tipMaxChars = hasValidActionIcon and 42 or 54
    local tipTextHeight = (finalTipStr == "") and 0 or GetSafeFontStringHeight(tipText, finalTipStr, tipMaxChars, 15, 16)
    local lowerHeight = 0
    if hasValidActionIcon then
        lowerHeight = math.max(40, tipTextHeight)
        lowerSection:Show()
    elseif finalTipStr ~= "" then
        lowerHeight = math.max(18, tipTextHeight)
        lowerSection:Show()
    else
        lowerSection:Hide()
    end

    lowerSection:ClearAllPoints()
    local sectionGap = (lowerHeight > 0) and 8 or 0
    lowerSection:SetPoint("TOPLEFT", upperSection, "BOTTOMLEFT", 0, -sectionGap)
    lowerSection:SetPoint("RIGHT", hudFrame, "RIGHT", -16, 0)
    lowerSection:SetHeight(lowerHeight)

    if hasValidActionIcon then
        actionSlotBtn.icon:SetTexture(texture)
        actionSlotBtn.icon:SetDesaturated(false)
        actionSlotBtn:Show()
    else
        actionSlotBtn.icon:SetTexture(nil)
        actionSlotBtn:Hide()
    end

    -- 在脱战状态下安全配置 SecureActionButton
    local isCombat = (InCombatLockdown and InCombatLockdown()) or false
    if not isCombat and secureActionBtn then
        UpdateSecureActionClickRegistration()
        secureActionBtn:ClearAllPoints()
        secureActionBtn:SetAllPoints(actionSlotBtn)

        secureActionBtn:SetAttribute("type", nil)
        secureActionBtn:SetAttribute("type1", nil)
        secureActionBtn:SetAttribute("type2", nil)
        secureActionBtn:SetAttribute("spell", nil)
        secureActionBtn:SetAttribute("spell1", nil)
        secureActionBtn:SetAttribute("toy", nil)
        secureActionBtn:SetAttribute("toy1", nil)
        secureActionBtn:SetAttribute("item", nil)
        secureActionBtn:SetAttribute("item1", nil)

        if hasValidActionIcon and hasTeleportAction and parsedLink and hasIt then
            if parsedLink.kind == "SPELL" then
                secureActionBtn:SetAttribute("type1", "spell")
                secureActionBtn:SetAttribute("spell1", parsedLink.id)
            elseif parsedLink.kind == "TOY" then
                if PlayerHasToy and PlayerHasToy(parsedLink.id) then
                    secureActionBtn:SetAttribute("type1", "toy")
                    secureActionBtn:SetAttribute("toy1", parsedLink.id)
                else
                    secureActionBtn:SetAttribute("type1", "item")
                    secureActionBtn:SetAttribute("item1", "item:" .. tostring(parsedLink.id))
                end
            else
                secureActionBtn:SetAttribute("type1", "item")
                secureActionBtn:SetAttribute("item1", "item:" .. tostring(parsedLink.id))
            end
            RegisterStateDriver(secureActionBtn, "visibility", "[combat] hide; show")
            secureActionBtn:Show()
        else
            -- 隐藏前注销驱动，避免其在下一次状态刷新时重新显示透明点击层。
            UnregisterStateDriver(secureActionBtn, "visibility")
            secureActionBtn:Hide()
        end
    end

    -- 5. 底部控制栏状态
    hudFrame.prevBtn:SetEnabled(stepIndex > 1)

    if stepIndex < route.totalSteps then
        hudFrame.nextBtn:SetText(L["HUD_BTN_NEXT"])
    else
        hudFrame.nextBtn:SetText(L["HUD_BTN_FINISH"])
    end

    -- 6. 计算并设置总卡片高度
    local totalFrameHeight = 34 + upperHeight + sectionGap + lowerHeight + 10 + 22 + 12
    hudFrame:SetHeight(math.max(110, totalFrameHeight))

    -- 7. 渲染帧精准校准
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if not hudFrame or not hudFrame:IsShown() then return end

            local rawDescH = (currentStepText and currentStepText.GetStringHeight and currentStepText:GetStringHeight()) or 0
            local realDescH = math.max(18, rawDescH)
            stepTextFrame:SetHeight(realDescH + 2)

            local realUpperH = hasAltPills and (altHeight + 8 + realDescH + 2) or (realDescH + 2)
            upperSection:SetHeight(realUpperH)

            local rawTipH = (finalTipStr ~= "" and tipText and tipText.GetStringHeight and tipText:GetStringHeight()) or 0
            local realLowerH = 0
            if hasValidActionIcon then
                realLowerH = math.max(40, rawTipH)
                lowerSection:Show()
            elseif finalTipStr ~= "" then
                realLowerH = math.max(18, rawTipH)
                lowerSection:Show()
            else
                lowerSection:Hide()
            end

            lowerSection:SetHeight(realLowerH)
            local realGap = (realLowerH > 0) and 8 or 0
            hudFrame:SetHeight(math.max(110, 34 + realUpperH + realGap + realLowerH + 10 + 22 + 12))
        end)
    end
end

-- 显示已抵达目的地状态 (完成导航时直接关闭 HUD，不再展示冗余步骤)
function NavigationHUD:ShowArrived(destName)
    self:Hide()
end

-- 查询 HUD 是否当前正在显示
function NavigationHUD:IsShown()
    return hudFrame and hudFrame:IsShown()
end

-- 隐藏 HUD (仅在玩家主动关闭或取消导航时调用)
function NavigationHUD:Hide()
    if hudFrame then
        hudFrame:Hide()
    end
    if secureActionBtn and not InCombatLockdown() then
        pcall(function()
            UnregisterStateDriver(secureActionBtn, "visibility")
            secureActionBtn:Hide()
        end)
    end
    if ns.Navigation and ns.Navigation.ClearWaypoints then
        ns.Navigation:ClearWaypoints()
    end
end
