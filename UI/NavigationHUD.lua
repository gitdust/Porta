local _, ns = ...
local L = ns.L

local NavigationHUD = {}
ns.NavigationHUD = NavigationHUD

local hudFrame = nil
local titleText = nil
local stepCounterText = nil
local stepTextFrame = nil
local currentStepText = nil
local nextStepText = nil
local altContainer = nil
local altButtons = {}
local questWarnBox = nil
local questWarnText = nil
local actionSlotBtn = nil
local secureActionBtn = nil
local dragHeader = nil

local ACTION_LABELS = {
    PORTAL       = L["HUD_ACTION_PORTAL"],
    ZEPPELIN     = L["HUD_ACTION_ZEPPELIN"],
    SHIP         = L["HUD_ACTION_SHIP"],
    WAYGATE      = L["HUD_ACTION_WAYGATE"],
    MIRROR       = L["HUD_ACTION_MIRROR"],
    MOLE_MACHINE = L["HUD_ACTION_MOLE_MACHINE"],
    TRAM         = L["HUD_ACTION_TRAM"],
    CLASS_PORTAL = L["HUD_ACTION_CLASS_PORTAL"],
    TRANSPORT    = L["HUD_ACTION_TRANSPORT"],
    FLY          = L["HUD_ACTION_FLY"],
    ARRIVE       = L["HUD_ACTION_ARRIVE"],
    SPELL        = L["HUD_ACTION_SPELL"],
    ITEM         = L["HUD_ACTION_ITEM"],
    TOY          = L["HUD_ACTION_TOY"],
    HEARTHSTONE  = L["HUD_ACTION_HEARTHSTONE"],
    DIRECT       = L["HUD_ACTION_DIRECT"],
}

-- 缓存解析后的超链接结构，避免鼠标划过/点击富文本时频繁重复正则匹配与表对象分配
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

-- 在 GameTooltip 中渲染玩具、物品、技能或坐标的悬停说明与操作提示
local function ShowPortaLinkTooltip(owner, parsed)
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
        if ns.PlayerTeleports and ns.PlayerTeleports.GetCooldownStatus then
            local isReady, cdSec = ns.PlayerTeleports.GetCooldownStatus(parsed.kind == "SPELL" and "SPELL" or "ITEM", parsed.id)
            if not isReady and cdSec > 0 then
                GameTooltip:AddLine(string.format(L["HUD_TOOLTIP_STATUS_CD_FMT"], cdSec), 1.0, 0.35, 0.35)
            else
                GameTooltip:AddLine(L["HUD_TOOLTIP_STATUS_READY"], 0.0, 1.0, 0.2)
            end
        end
        if isCombat then
            GameTooltip:AddLine(L["HUD_TOOLTIP_COMBAT_RESTRICTED"], 1.0, 0.35, 0.35)
        end
        GameTooltip:AddLine(L["HUD_TOOLTIP_RCLICK_DETAIL"], 0.75, 0.75, 0.75)
    else
        GameTooltip:AddLine("⚠ " .. (missingReason or L["HUD_TOOLTIP_MISSING_FALLBACK"]), 1.0, 0.35, 0.25, true)
        GameTooltip:AddLine(L["HUD_TOOLTIP_CLICK_DETAIL"], 0.0, 0.85, 1.0)
    end

    GameTooltip:Show()
end

-- 统一绑定富文本区域的超链接交互事件
local function BindHyperlinkScripts(targetFrame)
    targetFrame:SetHyperlinksEnabled(true)

    targetFrame:SetScript("OnHyperlinkEnter", function(_, link)
        local parsed = ParsePortaHyperlink(link)
        if parsed then
            ShowPortaLinkTooltip(hudFrame, parsed)
        end
    end)

    targetFrame:SetScript("OnHyperlinkLeave", function()
        GameTooltip:Hide()
    end)

    targetFrame:SetScript("OnHyperlinkClick", function(_, link)
        local parsed = ParsePortaHyperlink(link)
        if not parsed then return end

        if parsed.kind == "COORD" then
            if ns.Navigation and ns.Navigation.FocusCoordinate then
                ns.Navigation:FocusCoordinate(parsed.mapID, parsed.x, parsed.y)
            end
        else
            -- 点击玩具/物品/技能链接，在安全上下文中打开原生说明窗口
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

-- 辅助：计算带自动换行的中英文混排文本安全高度（剥离颜色控制码与超链接协议头后按真实显示宽度折行）
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
    hudFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -220, -180)
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

    -- 专用顶部拖拽把手区（避免点击背景或内容误触拖动）
    dragHeader = CreateFrame("Frame", nil, hudFrame)
    dragHeader:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 0, 0)
    dragHeader:SetPoint("TOPRIGHT", hudFrame, "TOPRIGHT", -32, 0)
    dragHeader:SetHeight(32)
    dragHeader:EnableMouse(true)
    dragHeader:RegisterForDrag("LeftButton")
    dragHeader:SetScript("OnDragStart", function() hudFrame:StartMoving() end)
    dragHeader:SetScript("OnDragStop", function() hudFrame:StopMovingOrSizing() end)

    -- 标题：目的地
    titleText = dragHeader:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
    titleText:SetPoint("LEFT", dragHeader, "LEFT", 16, 0)
    titleText:SetPoint("RIGHT", dragHeader, "RIGHT", -120, 0)
    titleText:SetJustifyH("LEFT")
    titleText:SetWordWrap(false)
    titleText:SetText(L["HUD_DEFAULT_TITLE"])

    -- 点击目的地标题打开世界地图定位目的地
    local mapBtn = CreateFrame("Button", nil, dragHeader)
    mapBtn:SetPoint("TOPLEFT", titleText, "TOPLEFT", -2, 2)
    mapBtn:SetPoint("BOTTOMRIGHT", titleText, "BOTTOMRIGHT", 2, -2)
    mapBtn:SetScript("OnClick", function()
        if InCombatLockdown and InCombatLockdown() then
            local combatMsg = L["MSG_COMBAT_MAP_RESTRICTED"]
            if UIErrorsFrame and UIErrorsFrame.AddMessage then
                UIErrorsFrame:AddMessage(combatMsg, 1.0, 0.82, 0.0, 1.0, 3)
            end
            ns.Print(combatMsg)
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

    -- 关闭 / 取消导航按钮 (提高 FrameLevel 保证易点击性)
    local closeBtn = CreateFrame("Button", nil, hudFrame, "UIPanelCloseButton")
    closeBtn:SetSize(22, 22)
    closeBtn:SetPoint("TOPRIGHT", hudFrame, "TOPRIGHT", -4, -4)
    closeBtn:SetFrameLevel(hudFrame:GetFrameLevel() + 10)
    closeBtn:SetScript("OnClick", function()
        ns.Navigation:CancelRoute()
    end)

    -- 多路线单选选项容器
    altContainer = CreateFrame("Frame", nil, hudFrame)
    altContainer:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -36)
    altContainer:SetPoint("RIGHT", hudFrame, "RIGHT", -16, 0)
    altContainer:SetHeight(26)
    altContainer:Hide()

    -- 当前步骤富文本容器
    stepTextFrame = CreateFrame("Frame", nil, hudFrame)
    stepTextFrame:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -38)
    stepTextFrame:SetSize(388, 24)
    BindHyperlinkScripts(stepTextFrame)

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

    -- 固定的动作快捷插槽按钮 (视觉与非战斗状态容器，纯普通按钮，不受战斗 Taint 阻断)
    actionSlotBtn = CreateFrame("Button", "PortaStepActionSlotButton", hudFrame, "BackdropTemplate")
    actionSlotBtn:SetSize(36, 36)
    actionSlotBtn:SetFrameLevel(hudFrame:GetFrameLevel() + 5)
    actionSlotBtn:RegisterForClicks("AnyUp", "AnyDown")
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

    local slotCooldown = CreateFrame("Cooldown", nil, actionSlotBtn, "CooldownFrameTemplate")
    slotCooldown:SetAllPoints(slotIcon)
    slotCooldown:SetDrawEdge(true)
    actionSlotBtn.cooldown = slotCooldown

    actionSlotBtn:SetScript("OnEnter", function(self)
        if self.parsedLink then
            ShowPortaLinkTooltip(self, self.parsedLink)
        end
    end)
    actionSlotBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- 战斗中点击拦截提示，或在普通状态下打开说明
    actionSlotBtn:SetScript("OnClick", function(self, button)
        if InCombatLockdown and InCombatLockdown() then
            local combatMsg = L["MSG_COMBAT_ACTION_RESTRICTED"]
            if UIErrorsFrame and UIErrorsFrame.AddMessage then
                UIErrorsFrame:AddMessage(combatMsg, 1.0, 0.25, 0.25, 1.0, 3)
            end
            ns.Print(combatMsg)
            if button == "RightButton" and self.parsedLink then
                OpenTeleportDetailView(self.parsedLink)
            end
            return
        end

        local parsed = self.parsedLink
        if not parsed then return end

        if button == "RightButton" or not self.hasIt then
            OpenTeleportDetailView(parsed)
            if not self.hasIt and button == "LeftButton" then
                ns.Print(string.format(L["MSG_CLICK_MISSING_NOTIFY_FMT"], self.missingReason or L["MSG_CLICK_MISSING_FALLBACK"]))
            end
        end
    end)
    actionSlotBtn:Hide()

    -- 独立安全动作点击层 (仅脱战时激活，进战时由系统驱动隐藏并直接穿透至底层提示)
    secureActionBtn = CreateFrame("Button", "PortaStepActionSecureBtn", UIParent, "SecureActionButtonTemplate")
    secureActionBtn:SetFrameStrata("HIGH")
    secureActionBtn:RegisterForClicks("AnyUp", "AnyDown")
    secureActionBtn:SetScript("OnEnter", function()
        if actionSlotBtn and actionSlotBtn.parsedLink then
            ShowPortaLinkTooltip(actionSlotBtn, actionSlotBtn.parsedLink)
        end
    end)
    secureActionBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    secureActionBtn:SetScript("PostClick", function(self, button, down)
        local useKeyDown = (GetCVarBool and GetCVarBool("ActionButtonUseKeyDown")) or false
        if (useKeyDown and not down) or (not useKeyDown and down) then
            return
        end

        local parsed = actionSlotBtn.parsedLink
        if not parsed then return end

        if button == "RightButton" or not actionSlotBtn.hasIt then
            OpenTeleportDetailView(parsed)
            if not actionSlotBtn.hasIt and button == "LeftButton" then
                ns.Print(string.format(L["MSG_CLICK_MISSING_NOTIFY_FMT"], actionSlotBtn.missingReason or L["MSG_CLICK_MISSING_FALLBACK"]))
            end
        else
            if ns.PlayerTeleports and ns.PlayerTeleports.GetCooldownStatus then
                local isReady, cdSec = ns.PlayerTeleports.GetCooldownStatus(parsed.kind == "SPELL" and "SPELL" or "ITEM", parsed.id)
                if not isReady and cdSec > 0 then
                    ns.Print(string.format(L["MSG_CLICK_CD_NOTIFY_FMT"], cdSec))
                    return
                end
            end
            if parsed.kind == "ITEM" and C_Item and C_Item.IsEquippableItem and C_Item.IsEquippableItem(parsed.id) then
                if not (C_Item.IsEquippedItem and C_Item.IsEquippedItem(parsed.id)) then
                    ns.Print(L["MSG_EQUIPPED_WAIT_CD"])
                end
            end
        end
    end)
    secureActionBtn:Hide()

    -- 前置任务解锁 & 缺失玩具/道具提醒专属提示框
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
    BindHyperlinkScripts(questWarnBox)

    questWarnText = questWarnBox:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    questWarnText:SetPoint("TOPLEFT", questWarnBox, "TOPLEFT", 10, -8)
    questWarnText:SetPoint("RIGHT", questWarnBox, "RIGHT", -10, 0)
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
    nextBtn:SetSize(56, 22)
    nextBtn:SetPoint("BOTTOMRIGHT", hudFrame, "BOTTOMRIGHT", -14, 11)
    nextBtn:SetText(L["HUD_BTN_NEXT"])
    nextBtn:SetScript("OnClick", function()
        ns.Navigation:NextStep()
    end)
    hudFrame.nextBtn = nextBtn

    -- 上一步快捷按钮
    local prevBtn = CreateFrame("Button", nil, hudFrame, "UIPanelButtonTemplate")
    prevBtn:SetSize(56, 22)
    prevBtn:SetPoint("RIGHT", nextBtn, "LEFT", -5, 0)
    prevBtn:SetText(L["HUD_BTN_PREV"])
    prevBtn:SetScript("OnClick", function()
        ns.Navigation:PrevStep()
    end)
    hudFrame.prevBtn = prevBtn

    -- 查看地图快捷按钮
    local viewMapBtn = CreateFrame("Button", nil, hudFrame, "UIPanelButtonTemplate")
    viewMapBtn:SetSize(68, 22)
    viewMapBtn:SetPoint("RIGHT", prevBtn, "LEFT", -5, 0)
    viewMapBtn:SetText(L["HUD_BTN_MAP"])
    viewMapBtn:SetScript("OnClick", function()
        if InCombatLockdown and InCombatLockdown() then
            local combatMsg = L["MSG_COMBAT_MAP_RESTRICTED"]
            if UIErrorsFrame and UIErrorsFrame.AddMessage then
                UIErrorsFrame:AddMessage(combatMsg, 1.0, 0.82, 0.0, 1.0, 3)
            end
            ns.Print(combatMsg)
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

    -- 底部后续预告
    nextStepText = hudFrame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    nextStepText:SetPoint("BOTTOMLEFT", hudFrame, "BOTTOMLEFT", 16, 15)
    nextStepText:SetPoint("RIGHT", viewMapBtn, "LEFT", -8, 0)
    nextStepText:SetJustifyH("LEFT")
    nextStepText:SetWordWrap(false)

    -- 战斗状态事件监听：脱战安全更新属性，进战提示保护
    local combatFrame = CreateFrame("Frame")
    combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    combatFrame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_DISABLED" then
            if actionSlotBtn and actionSlotBtn:IsShown() then
                actionSlotBtn.icon:SetDesaturated(true)
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
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

-- 刷新多路线单选按钮栏
local function UpdateAlternativeButtons(route, stepIndex)
    if not altContainer then return 0 end

    if stepIndex ~= 1 or not route.alternatives or #route.alternatives <= 1 then
        altContainer:Hide()
        return 0
    end

    altContainer:Show()
    local selectedIdx = route.selectedAltIndex or 1
    local btnCount = #route.alternatives
    local currentY = 0

    for i, alt in ipairs(route.alternatives) do
        local btn = altButtons[i]
        if not btn then
            btn = CreateFrame("Button", nil, altContainer, "BackdropTemplate")
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 10,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            btn.text:SetPoint("TOPLEFT", btn, "TOPLEFT", 10, -4)
            btn.text:SetPoint("RIGHT", btn, "RIGHT", -10, 0)
            btn.text:SetWidth(368)
            btn.text:SetJustifyH("LEFT")
            btn.text:SetJustifyV("TOP")
            btn.text:SetWordWrap(true)
            if btn.text.SetNonSpaceWrap then
                btn.text:SetNonSpaceWrap(true)
            end
            btn.text:SetSpacing(2)
            altButtons[i] = btn
        end

        btn:Show()

        local isSelected = (i == selectedIdx)
        local radio = isSelected and "|cff00ffff●|r " or "|cff888888○|r "
        local distTag = (alt.distanceText and alt.distanceText ~= "") and (" - " .. alt.distanceText) or ""
        local missingTag = alt.isMissingTeleport and string.format(L["STATUS_MISSING_TAG_FMT"], alt.missingShortTag or L["TAG_MISSING"]) or ""
        local tag = (i == 1) and L["HUD_ALT_TAG_RECOMMENDED"] or (alt.isUncertainWormhole and L["HUD_ALT_TAG_UNCERTAIN"] or "")
        local label = string.format(L["HUD_ALT_LABEL_FMT"], radio, i, alt.name, distTag, missingTag, tag)

        btn.text:ClearAllPoints()
        btn.text:SetPoint("TOPLEFT", btn, "TOPLEFT", 10, -4)
        btn.text:SetPoint("RIGHT", btn, "RIGHT", -10, 0)
        btn.text:SetWidth(368)
        btn.text:SetWordWrap(true)
        if btn.text.SetNonSpaceWrap then
            btn.text:SetNonSpaceWrap(true)
        end
        btn.text:SetText(label)

        local textH = GetSafeFontStringHeight(btn.text, label, 46, 14, 14)
        local btnHeight = math.max(22, textH + 8)

        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", altContainer, "TOPLEFT", 0, -currentY)
        btn:SetPoint("RIGHT", altContainer, "RIGHT", 0, 0)
        btn:SetHeight(btnHeight)

        currentY = currentY + btnHeight + 4

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
            GameTooltip:SetText(string.format(L["HUD_ALT_TOOLTIP_TITLE_FMT"], altIndex, alt.name))
            if alt.viaDesc then
                GameTooltip:AddLine(alt.viaDesc, 0.8, 0.8, 0.8, true)
            end
            if alt.isUncertainWormhole then
                GameTooltip:AddLine(L["HUD_ALT_TOOLTIP_WORMHOLE"], 1.0, 0.75, 0.25, true)
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

    local containerHeight = math.max(26, currentY)
    altContainer:SetHeight(containerHeight)

    return containerHeight + 4
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

    -- 确保导航控制按钮恢复可见并绑定默认行为
    hudFrame.prevBtn:Show()
    hudFrame.viewMapBtn:Show()
    hudFrame.nextBtn:SetScript("OnClick", function()
        ns.Navigation:NextStep()
    end)

    -- 标题显示
    titleText:SetText(string.format("|cff00ccff%s|r", route.destination.name or L["HUD_DEST_FALLBACK"]))
    stepCounterText:SetText(string.format(L["HUD_STEP_COUNTER_FMT"], stepIndex, route.totalSteps))

    -- 1. 多路线单选选项栏渲染
    local altOffset = UpdateAlternativeButtons(route, stepIndex)

    -- 2. 检查当前步骤是否包含传送动作（技能/玩具/物品）
    local tp = currentStep.teleportInfo
    local hasActionSlot = false
    local parsedLink = nil

    if tp and tp.id and (currentStep.action == "SPELL" or currentStep.action == "TOY" or currentStep.action == "ITEM" or tp.type) then
        hasActionSlot = true
        local k = tp.type or currentStep.action
        parsedLink = ParsePortaHyperlink(string.format("porta:%s:%d", string.lower(k), tp.id))
    end

    local isCombat = (InCombatLockdown and InCombatLockdown()) or false

    if hasActionSlot and actionSlotBtn then
        actionSlotBtn:ClearAllPoints()
        actionSlotBtn:SetPoint("TOPRIGHT", hudFrame, "TOPRIGHT", -16, -36 - altOffset)
        actionSlotBtn:Show()
        actionSlotBtn.parsedLink = parsedLink

        local hasIt, missingReason = true, nil
        if ns.PlayerTeleports and ns.PlayerTeleports.CheckTeleportOwnership then
            hasIt, missingReason = ns.PlayerTeleports:CheckTeleportOwnership(parsedLink.kind, parsedLink.id)
        end
        actionSlotBtn.hasIt = hasIt
        actionSlotBtn.missingReason = missingReason

        -- 动态获取材质图标
        local texture = nil
        if parsedLink.kind == "SPELL" then
            if C_Spell and C_Spell.GetSpellTexture then
                texture = C_Spell.GetSpellTexture(parsedLink.id)
            end
        else
            if C_Item and C_Item.GetItemIconByID then
                texture = C_Item.GetItemIconByID(parsedLink.id)
            end
        end
        if not texture then
            texture = "Interface\\Icons\\INV_Misc_QuestionMark"
        end
        actionSlotBtn.icon:SetTexture(texture)
        actionSlotBtn.icon:SetDesaturated(isCombat or (not hasIt))

        -- 冷却状态监测
        if ns.PlayerTeleports and ns.PlayerTeleports.GetCooldownStatus then
            local isReady, cdSec = ns.PlayerTeleports.GetCooldownStatus(parsedLink.kind == "SPELL" and "SPELL" or "ITEM", parsedLink.id)
            if not isReady and cdSec > 0 then
                actionSlotBtn.cooldown:SetCooldown(GetTime() - 1, cdSec)
            else
                actionSlotBtn.cooldown:Clear()
            end
        end

        -- 在脱战状态下安全设置动作插槽属性
        if not isCombat and secureActionBtn then
            secureActionBtn:ClearAllPoints()
            secureActionBtn:SetAllPoints(actionSlotBtn)
            RegisterStateDriver(secureActionBtn, "visibility", "[combat] hide; show")

            secureActionBtn:SetAttribute("type", nil)
            secureActionBtn:SetAttribute("type1", nil)
            secureActionBtn:SetAttribute("type2", nil)
            secureActionBtn:SetAttribute("spell", nil)
            secureActionBtn:SetAttribute("spell1", nil)
            secureActionBtn:SetAttribute("toy", nil)
            secureActionBtn:SetAttribute("toy1", nil)
            secureActionBtn:SetAttribute("item", nil)
            secureActionBtn:SetAttribute("item1", nil)

            if hasIt then
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
            end
        end
    else
        if actionSlotBtn then
            actionSlotBtn:Hide()
        end
        if not isCombat and secureActionBtn then
            pcall(function()
                UnregisterStateDriver(secureActionBtn, "visibility")
                secureActionBtn:Hide()
            end)
        end
    end

    -- 3. 步骤描述文本排版（若存在动作插槽，留出右侧空间给按钮）
    local textWidth = hasActionSlot and 344 or 388
    local charsPerLine = hasActionSlot and 42 or 48

    local descStr = string.format("|cffffffff%s|r", currentStep.description or "")
    stepTextFrame:ClearAllPoints()
    stepTextFrame:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -36 - altOffset)
    stepTextFrame:SetWidth(textWidth)

    currentStepText:SetWidth(textWidth)
    currentStepText:SetText(descStr)

    local descHeight = GetSafeFontStringHeight(currentStepText, descStr, charsPerLine, 17, hasActionSlot and 38 or 20)
    stepTextFrame:SetHeight(descHeight + 4)

    -- 4. 缺失玩具/物品提示 & 前置任务提醒框排版
    local warnBlocks = {}

    if currentStep.isMissingTeleport and currentStep.teleportInfo then
        local tpInfo = currentStep.teleportInfo
        local kindLabel = (tpInfo.type == "TOY" and L["KIND_TOY"]) or (tpInfo.type == "SPELL" and L["KIND_SPELL"]) or L["KIND_ITEM"]
        local tpLink = (ns.Pathfinder and ns.Pathfinder.FormatTeleportLink and ns.Pathfinder:FormatTeleportLink(tpInfo.type, tpInfo.id, tpInfo.name)) or ns.FormatBracket(tpInfo.name or "")
        local headerLabel
        if tpInfo.isOwned and (tpInfo.missingEngineering or tpInfo.isToyUnusable) then
            headerLabel = string.format(L["HUD_WARN_COND_UNMET_FMT"], kindLabel, tpInfo.missingShortTag or L["TAG_REQ_ENG"])
        elseif tpInfo.missingEngineering then
            headerLabel = string.format(L["HUD_WARN_MISSING_ENG_FMT"], kindLabel)
        else
            headerLabel = string.format(L["HUD_WARN_MISSING_FMT"], kindLabel)
        end
        local reasonText = tpInfo.missingReason or string.format(L["HUD_WARN_REASON_FALLBACK_FMT"], kindLabel, tpLink)
        local noteLine = (tpInfo.note and tpInfo.note ~= "") and (L["HUD_WARN_NOTE_PREFIX"] .. tpInfo.note) or ""
        table.insert(warnBlocks, string.format(
            L["HUD_WARN_MISSING_BLOCK_FMT"],
            headerLabel, reasonText, noteLine, tpLink
        ))
    elseif currentStep.isUncertainWormhole and currentStep.teleportInfo then
        local tpInfo = currentStep.teleportInfo
        table.insert(warnBlocks, string.format(
            L["HUD_WARN_WORMHOLE_BLOCK_FMT"],
            tpInfo.name or L["KIND_TOY"]
        ))
    end

    if currentStep.isQuestGated and currentStep.questGateInfo then
        local gate = currentStep.questGateInfo
        local questWarnStr
        if gate.unlockGuide and gate.unlockGuide ~= "" then
            questWarnStr = string.format(L["HUD_WARN_QUEST_UNLOCK_FMT"], gate.unlockGuide)
        else
            questWarnStr = string.format(L["HUD_WARN_QUEST_FALLBACK_FMT"], gate.startNPC or L["HUD_WARN_CAPITAL_FALLBACK"], gate.questName or L["HUD_WARN_PREREQ_FALLBACK"])
        end
        table.insert(warnBlocks, questWarnStr)
    end

    local phaseInfo = currentStep.phaseShiftInfo or (currentStep.isFinal and route.phaseShiftInfo)
    if phaseInfo then
        local zidormiCoord = (ns.Pathfinder and ns.Pathfinder.FormatCoordLink) and ns.Pathfinder:FormatCoordLink(phaseInfo.npcMapID, phaseInfo.x, phaseInfo.y) or string.format("(%.1f, %.1f)", phaseInfo.x * 100, phaseInfo.y * 100)
        local phaseWarnStr = string.format(
            L["HUD_WARN_PHASE_SHIFT_FMT"],
            phaseInfo.zoneName or "",
            phaseInfo.tip or "",
            phaseInfo.npcName or L["NPC_ZIDORMI"],
            zidormiCoord
        )
        table.insert(warnBlocks, phaseWarnStr)
    end

    local questWarnHeight = 0
    if #warnBlocks > 0 then
        local warnStr = table.concat(warnBlocks, "\n\n")
        questWarnBox:ClearAllPoints()
        questWarnBox:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -36 - altOffset - descHeight - 8)
        questWarnBox:SetWidth(388)
        questWarnText:SetWidth(368)
        questWarnText:SetText(warnStr)
        questWarnBox:Show()

        local warnTextH = GetSafeFontStringHeight(questWarnText, warnStr, 46, 16, 20)
        local boxHeight = warnTextH + 18
        questWarnBox:SetHeight(boxHeight)
        questWarnHeight = boxHeight + 8
    else
        questWarnBox:Hide()
    end

    -- 5. 按钮状态控制
    if stepIndex > 1 then
        hudFrame.prevBtn:Enable()
    else
        hudFrame.prevBtn:Disable()
    end

    -- 6. 下一步预告与按钮文本
    if stepIndex < route.totalSteps then
        local nextStep = route.steps[stepIndex + 1]
        local actionLabel = (nextStep and ACTION_LABELS[nextStep.action]) or (nextStep and nextStep.action) or L["HUD_ACTION_DEFAULT"]
        nextStepText:SetText(string.format(L["HUD_NEXT_PREVIEW_FMT"], actionLabel))
        hudFrame.nextBtn:SetText(L["HUD_BTN_NEXT"])
    else
        nextStepText:SetText(L["HUD_ARRIVING_SOON"])
        hudFrame.nextBtn:SetText(L["HUD_BTN_DONE"])
    end

    -- 7. 动态总高度设置
    local totalFrameHeight = 36 + altOffset + descHeight + questWarnHeight + 48
    hudFrame:SetHeight(math.max(130, totalFrameHeight))

    -- 8. 下一渲染帧基于原生排版引擎二次精准校准 (移除锁死旧高度的错误逻辑)
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if not hudFrame or not hudFrame:IsShown() then return end

            local realAltOffset = 0
            if altContainer and altContainer:IsShown() and route.alternatives and #route.alternatives > 1 then
                local currentY = 0
                for i = 1, #route.alternatives do
                    local btn = altButtons[i]
                    if btn and btn:IsShown() then
                        local actualTextH = (btn.text and btn.text.GetStringHeight and btn.text:GetStringHeight()) or 0
                        local actualBtnH = math.max(22, actualTextH + 8)
                        btn:SetHeight(actualBtnH)
                        btn:ClearAllPoints()
                        btn:SetPoint("TOPLEFT", altContainer, "TOPLEFT", 0, -currentY)
                        btn:SetPoint("RIGHT", altContainer, "RIGHT", 0, 0)
                        currentY = currentY + actualBtnH + 4
                    end
                end
                local realContainerH = math.max(26, currentY)
                altContainer:SetHeight(realContainerH)
                realAltOffset = realContainerH + 4
            else
                realAltOffset = altOffset
            end

            local rawDescH = (currentStepText and currentStepText.GetStringHeight and currentStepText:GetStringHeight()) or 0
            local realDescH = math.max(hasActionSlot and 38 or 18, rawDescH)
            stepTextFrame:ClearAllPoints()
            stepTextFrame:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -36 - realAltOffset)
            stepTextFrame:SetHeight(realDescH + 4)

            local realWarnH = 0
            if questWarnBox:IsShown() then
                questWarnBox:ClearAllPoints()
                questWarnBox:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -36 - realAltOffset - realDescH - 8)
                local actualWarnTextH = (questWarnText and questWarnText.GetStringHeight and questWarnText:GetStringHeight()) or 0
                local finalBoxH = math.max(28, actualWarnTextH + 16)
                questWarnBox:SetHeight(finalBoxH)
                realWarnH = finalBoxH + 8
            end
            hudFrame:SetHeight(math.max(130, 36 + realAltOffset + realDescH + realWarnH + 48))
        end)
    end
end

-- 显示已抵达目的地状态（HUD 保持显示，直到玩家手动关闭）
function NavigationHUD:ShowArrived(destName)
    InitHUD()
    if not hudFrame then return end
    hudFrame:Show()

    local name = destName or L["HUD_DEST_FALLBACK"]
    titleText:SetText(string.format("|cff00ff00%s|r", L["HUD_DEST_ARRIVED"]))
    stepCounterText:SetText("|cff00ff00[OK]|r")

    if altContainer then altContainer:Hide() end
    if actionSlotBtn then actionSlotBtn:Hide() end
    if secureActionBtn and not InCombatLockdown() then
        pcall(function()
            UnregisterStateDriver(secureActionBtn, "visibility")
            secureActionBtn:Hide()
        end)
    end
    if questWarnBox then questWarnBox:Hide() end

    local arrivedMsg = string.format(L["MSG_ROUTE_FINISHED_FMT"], name) .. "\n\n" .. L["HUD_ARRIVED_CLOSE_HINT"]
    stepTextFrame:ClearAllPoints()
    stepTextFrame:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -38)
    stepTextFrame:SetWidth(388)

    currentStepText:SetWidth(388)
    currentStepText:SetText(string.format("|cffffffff%s|r", arrivedMsg))

    local textH = GetSafeFontStringHeight(currentStepText, arrivedMsg, 48, 17, 36)
    stepTextFrame:SetHeight(textH + 4)

    hudFrame.prevBtn:Hide()
    hudFrame.viewMapBtn:Hide()
    nextStepText:SetText("")

    hudFrame.nextBtn:SetText(L["HUD_BTN_CLOSE"])
    hudFrame.nextBtn:Show()
    hudFrame.nextBtn:Enable()
    hudFrame.nextBtn:SetScript("OnClick", function()
        ns.Navigation:CancelRoute()
    end)

    local totalH = 38 + textH + 54
    hudFrame:SetHeight(math.max(120, totalH))
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
end
