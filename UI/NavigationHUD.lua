local _, ns = ...

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
local secureOverlayBtn = nil

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
    ITEM         = "使用物品",
    TOY          = "使用玩具",
    HEARTHSTONE  = "使用炉石",
    DIRECT       = "直接前往",
}

-- 解析 Porta 自定义超链接 (porta:toy:id / porta:item:id / porta:spell:id / porta:coord:mapID:x:y)
local function ParsePortaHyperlink(link)
    if type(link) ~= "string" then return nil end
    local kind, a1, a2, a3 = string.match(link, "^porta:([^:]+):([^:]+):?([^:]*):?([^:]*)$")
    if not kind then return nil end
    kind = string.upper(kind)

    if kind == "COORD" then
        local mapID = tonumber(a1)
        local x = tonumber(a2)
        local y = tonumber(a3)
        if x and y then
            return { kind = "COORD", mapID = mapID or 0, x = x, y = y }
        end
    elseif kind == "TOY" or kind == "ITEM" or kind == "SPELL" then
        local id = tonumber(a1)
        if id then
            return { kind = kind, id = id }
        end
    end
    return nil
end

-- 打开玩具/物品/技能的独立详情浮窗 (ItemRefTooltip)，并在玩具箱未解锁时辅助定位
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
        local mapName = "当前区域"
        if parsed.mapID and parsed.mapID > 0 and C_Map and C_Map.GetMapInfo then
            local info = C_Map.GetMapInfo(parsed.mapID)
            if info and info.name then
                mapName = info.name
            end
        end
        GameTooltip:SetText(string.format("%s 坐标 (%.1f, %.1f)", mapName, parsed.x, parsed.y), 1.0, 0.82, 0.0)
        GameTooltip:AddLine("点击：在世界地图中查看位置并设置导航航标", 0.0, 1.0, 0.4)
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

    GameTooltip:AddLine(" ")
    if hasIt then
        if ns.PlayerTeleports and ns.PlayerTeleports.GetCooldownStatus then
            local isReady, cdSec = ns.PlayerTeleports.GetCooldownStatus(parsed.kind == "SPELL" and "SPELL" or "ITEM", parsed.id)
            if not isReady and cdSec > 0 then
                GameTooltip:AddLine(string.format("状态：冷却中 (剩余 %d 秒)", cdSec), 1.0, 0.35, 0.35)
            else
                GameTooltip:AddLine("状态：已拥有，当前就绪", 0.0, 1.0, 0.2)
            end
        end
        if parsed.kind == "SPELL" then
            GameTooltip:AddLine("左键点击：立即施放该技能", 0.0, 1.0, 0.6)
        elseif parsed.kind == "TOY" then
            GameTooltip:AddLine("左键点击：立即使用该玩具", 0.0, 1.0, 0.6)
        else
            GameTooltip:AddLine("左键点击：立即使用/穿戴该物品", 0.0, 1.0, 0.6)
        end
        GameTooltip:AddLine("右键点击：打开固定详情窗口查看", 0.75, 0.75, 0.75)
    else
        GameTooltip:AddLine("⚠ " .. (missingReason or "当前角色尚未拥有该传送方式"), 1.0, 0.35, 0.25, true)
        GameTooltip:AddLine("点击：打开详情窗口查看物品/玩具说明", 0.0, 0.85, 1.0)
    end

    GameTooltip:Show()
end

-- 将安全点击按钮定位到当前鼠标悬停的超链接处，支持左键直接使用玩具/物品/技能、右键查看详情
local function ActivateSecureOverlayForLink(parsed)
    if not secureOverlayBtn or not hudFrame or not parsed then return end
    if InCombatLockdown and InCombatLockdown() then return end

    local hasIt, missingReason = true, nil
    if ns.PlayerTeleports and ns.PlayerTeleports.CheckTeleportOwnership then
        hasIt, missingReason = ns.PlayerTeleports:CheckTeleportOwnership(parsed.kind, parsed.id)
    end

    secureOverlayBtn.parsedLink = parsed
    secureOverlayBtn.hasIt = hasIt
    secureOverlayBtn.missingReason = missingReason

    secureOverlayBtn:SetAttribute("type", nil)
    secureOverlayBtn:SetAttribute("type1", nil)
    secureOverlayBtn:SetAttribute("type2", nil)
    secureOverlayBtn:SetAttribute("spell", nil)
    secureOverlayBtn:SetAttribute("spell1", nil)
    secureOverlayBtn:SetAttribute("toy", nil)
    secureOverlayBtn:SetAttribute("toy1", nil)
    secureOverlayBtn:SetAttribute("item", nil)
    secureOverlayBtn:SetAttribute("item1", nil)

    if hasIt then
        if parsed.kind == "SPELL" then
            secureOverlayBtn:SetAttribute("type1", "spell")
            secureOverlayBtn:SetAttribute("spell1", parsed.id)
        elseif parsed.kind == "TOY" then
            if PlayerHasToy and PlayerHasToy(parsed.id) then
                secureOverlayBtn:SetAttribute("type1", "toy")
                secureOverlayBtn:SetAttribute("toy1", parsed.id)
            else
                secureOverlayBtn:SetAttribute("type1", "item")
                secureOverlayBtn:SetAttribute("item1", "item:" .. tostring(parsed.id))
            end
        else
            secureOverlayBtn:SetAttribute("type1", "item")
            secureOverlayBtn:SetAttribute("item1", "item:" .. tostring(parsed.id))
        end
    end

    local scale = hudFrame:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    cx = cx / scale
    cy = cy / scale
    local left = hudFrame:GetLeft() or 0
    local bottom = hudFrame:GetBottom() or 0

    secureOverlayBtn:ClearAllPoints()
    secureOverlayBtn:SetPoint("CENTER", hudFrame, "BOTTOMLEFT", cx - left, cy - bottom)
    secureOverlayBtn:SetSize(96, 20)
    secureOverlayBtn:Show()
end

-- 统一绑定富文本区域的超链接交互事件
local function BindHyperlinkScripts(targetFrame)
    targetFrame:SetHyperlinksEnabled(true)

    targetFrame:SetScript("OnHyperlinkEnter", function(_, link)
        local parsed = ParsePortaHyperlink(link)
        if not parsed then return end

        ShowPortaLinkTooltip(hudFrame, parsed)
        if parsed.kind == "COORD" then
            if secureOverlayBtn and secureOverlayBtn:IsShown() and not (InCombatLockdown and InCombatLockdown()) then
                secureOverlayBtn:Hide()
            end
        else
            ActivateSecureOverlayForLink(parsed)
        end
    end)

    targetFrame:SetScript("OnHyperlinkLeave", function()
        if secureOverlayBtn and secureOverlayBtn:IsShown() and secureOverlayBtn:IsMouseOver() then
            return
        end
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
            -- 战斗中或回退状态下点击玩具/物品/技能链接，打开详情窗口
            OpenTeleportDetailView(parsed)
            if InCombatLockdown and InCombatLockdown() then
                ns.Print("战斗中无法直接施放传送，已为你打开详情窗口查看。")
            end
        end
    end)
end

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

    -- 当前步骤富文本容器（启用超链接交互，支持点击【玩具/物品/技能】与(坐标)）
    stepTextFrame = CreateFrame("Frame", nil, hudFrame)
    stepTextFrame:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -38)
    stepTextFrame:SetSize(388, 24)
    BindHyperlinkScripts(stepTextFrame)

    currentStepText = stepTextFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
    currentStepText:SetPoint("TOPLEFT", stepTextFrame, "TOPLEFT", 0, 0)
    currentStepText:SetWidth(388)
    currentStepText:SetJustifyH("LEFT")
    currentStepText:SetJustifyV("TOP")
    currentStepText:SetWordWrap(true)
    if currentStepText.SetNonSpaceWrap then
        currentStepText:SetNonSpaceWrap(true)
    end
    currentStepText:SetSpacing(3)

    -- 前置任务解锁 & 缺失玩具/道具提醒专属提示框 (高度随文本行数动态伸缩，同样支持超链接点击)
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
    questWarnText:SetWidth(368)
    questWarnText:SetJustifyH("LEFT")
    questWarnText:SetJustifyV("TOP")
    questWarnText:SetWordWrap(true)
    if questWarnText.SetNonSpaceWrap then
        questWarnText:SetNonSpaceWrap(true)
    end
    questWarnText:SetSpacing(3)
    questWarnBox:Hide()

    -- 动态安全动作浮层按钮（使点击步骤文本中的【玩具/物品/技能】能够直接触发暴雪安全施法/使用接口）
    secureOverlayBtn = CreateFrame("Button", "PortaStepSecureOverlayButton", hudFrame, "SecureActionButtonTemplate")
    secureOverlayBtn:SetSize(96, 20)
    secureOverlayBtn:SetFrameLevel(hudFrame:GetFrameLevel() + 25)
    secureOverlayBtn:RegisterForClicks("AnyUp", "AnyDown")

    local overlayHighlight = secureOverlayBtn:CreateTexture(nil, "HIGHLIGHT")
    overlayHighlight:SetAllPoints()
    overlayHighlight:SetColorTexture(0.0, 0.85, 1.0, 0.18)

    secureOverlayBtn:SetScript("OnEnter", function(self)
        if self.parsedLink then
            ShowPortaLinkTooltip(hudFrame, self.parsedLink)
        end
    end)
    secureOverlayBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        if not (InCombatLockdown and InCombatLockdown()) then
            self:Hide()
        end
    end)
    secureOverlayBtn:SetScript("PostClick", function(self, button, down)
        local useKeyDown = (GetCVarBool and GetCVarBool("ActionButtonUseKeyDown")) or false
        if (useKeyDown and not down) or (not useKeyDown and down) then
            return
        end

        local parsed = self.parsedLink
        if not parsed then return end

        if button == "RightButton" or not self.hasIt then
            OpenTeleportDetailView(parsed)
            if not self.hasIt and button == "LeftButton" then
                ns.Print("|cffff6600[未拥有提示]|r " .. (self.missingReason or "当前尚未拥有该传送道具/玩具。") .. " 已为你打开详情窗口查看。")
            end
        else
            if ns.PlayerTeleports and ns.PlayerTeleports.GetCooldownStatus then
                local isReady, cdSec = ns.PlayerTeleports.GetCooldownStatus(parsed.kind == "SPELL" and "SPELL" or "ITEM", parsed.id)
                if not isReady and cdSec > 0 then
                    ns.Print(string.format("|cffff4040[冷却中]|r 该传送方式正在冷却中（剩余 %d 秒）。", cdSec))
                    return
                end
            end
            if parsed.kind == "ITEM" and C_Item and C_Item.IsEquippableItem and C_Item.IsEquippableItem(parsed.id) then
                if not (C_Item.IsEquippedItem and C_Item.IsEquippedItem(parsed.id)) then
                    ns.Print("已自动为你穿戴该传送装备，请等待 30 秒穿戴冷却结束后再次点击即可传送！")
                end
            end
        end
    end)
    secureOverlayBtn:Hide()

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
        local missingTag = alt.isMissingTeleport and string.format(" |cffff4444[%s]|r", alt.missingShortTag or "未拥有") or ""
        local tag = (i == 1) and " |cff00ff00[推荐]|r" or (alt.isUncertainWormhole and " |cffffaa00[备选/不确定]|r" or "")
        local label = string.format("%s方案 %d: %s%s%s%s", radio, i, alt.name, distTag, missingTag, tag)
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
            if alt.isUncertainWormhole then
                GameTooltip:AddLine("提示：虫洞发生器落点具有不确定性（随机或需自选），落地后需自行飞往目标点。", 1.0, 0.75, 0.25, true)
            end
            if alt.isMissingTeleport then
                GameTooltip:AddLine("⚠ " .. (alt.missingReason or "当前角色未检测到该玩具或物品，或不满足专业条件"), 1.0, 0.35, 0.25, true)
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

-- 辅助：计算带自动换行的中英文混排文本安全高度（剥离超链接与纹理标签后再估算折行）
local function GetSafeFontStringHeight(fontString, rawText, bytesPerLine, lineHeight, minHeight)
    local measured = (fontString and fontString.GetStringHeight and fontString:GetStringHeight()) or 0
    if not rawText or rawText == "" then
        return math.max(measured, minHeight or 18)
    end

    -- 剥离魔兽颜色控制码、超链接协议头与纹理标签后按真实可见字符估算折行高度
    local clean = rawText
        :gsub("|c%x%x%x%x%x%x%x%x", "")
        :gsub("|r", "")
        :gsub("|H[^|]*|h", "")
        :gsub("|h", "")
        :gsub("|T[^|]*|t", "xx")

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

    if secureOverlayBtn and secureOverlayBtn:IsShown() and not (InCombatLockdown and InCombatLockdown()) then
        secureOverlayBtn:Hide()
    end

    -- 标题显示
    titleText:SetText(string.format("|cff00ccff%s|r", route.destination.name or "目的地"))
    stepCounterText:SetText(string.format("|cffffcc00第 %d / %d 步|r", stepIndex, route.totalSteps))

    -- 1. 多路线单选选项栏渲染 (自适应高度)
    local altOffset = UpdateAlternativeButtons(route, stepIndex)

    -- 2. 步骤描述文本排版（内含可点击的【玩具/物品/技能】与(坐标)超链接）
    local descStr = string.format("|cffffffff%s|r", currentStep.description or "")
    stepTextFrame:ClearAllPoints()
    stepTextFrame:SetPoint("TOPLEFT", hudFrame, "TOPLEFT", 16, -36 - altOffset)
    stepTextFrame:SetWidth(388)

    currentStepText:SetWidth(388)
    currentStepText:SetText(descStr)

    local descHeight = GetSafeFontStringHeight(currentStepText, descStr, 78, 17, 20)
    stepTextFrame:SetHeight(descHeight + 4)

    -- 3. 缺失玩具/物品提示 & 前置任务提醒框排版 (位于步骤描述下方，高度随内容行数完全自适应)
    local warnBlocks = {}

    if currentStep.isMissingTeleport and currentStep.teleportInfo then
        local tp = currentStep.teleportInfo
        local kindLabel = (tp.type == "TOY" and "玩具") or (tp.type == "SPELL" and "技能") or "物品"
        local tpLink = (ns.Pathfinder and ns.Pathfinder.FormatTeleportLink and ns.Pathfinder:FormatTeleportLink(tp.type, tp.id, tp.name)) or ("【" .. tostring(tp.name or "") .. "】")
        local headerLabel
        if tp.isOwned and (tp.missingEngineering or tp.isToyUnusable) then
            headerLabel = string.format("不满足该传送%s使用条件（%s）", kindLabel, tp.missingShortTag or "需工程学")
        elseif tp.missingEngineering then
            headerLabel = string.format("未拥有该传送%s且需工程学专业", kindLabel)
        else
            headerLabel = string.format("未拥有该传送%s", kindLabel)
        end
        local reasonText = tp.missingReason or string.format("当前角色未检测到传送%s %s。", kindLabel, tpLink)
        local noteLine = (tp.note and tp.note ~= "") and ("\n获取/使用说明：" .. tp.note) or ""
        table.insert(warnBlocks, string.format(
            "|cffff6600⚠ %s|r\n%s%s\n|cffaaaaaa提示：可直接点击 %s 查看详情，或在上方切换其他备选方案。|r",
            headerLabel, reasonText, noteLine, tpLink
        ))
    elseif currentStep.isUncertainWormhole and currentStep.teleportInfo then
        local tp = currentStep.teleportInfo
        table.insert(warnBlocks, string.format(
            "|cffffaa00⚠ 虫洞落点不确定提示|r\n【%s】传送落点具有不确定性（随机落地或需对话选择），落地后需自行乘飞行坐骑前往目标区域。",
            tp.name or "虫洞发生器"
        ))
    end

    if currentStep.isQuestGated and currentStep.questGateInfo then
        local gate = currentStep.questGateInfo
        local questWarnStr
        if gate.unlockGuide and gate.unlockGuide ~= "" then
            questWarnStr = string.format("|cffff4444⚠ 传送门未解锁|r\n%s", gate.unlockGuide)
        else
            questWarnStr = string.format("|cffff4444⚠ 传送门未解锁|r\n当前角色需在%s接取%s开启；或请队友在副本门口拉人。", gate.startNPC or "主城", gate.questName or "前置任务")
        end
        table.insert(warnBlocks, questWarnStr)
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

        local warnTextH = GetSafeFontStringHeight(questWarnText, warnStr, 72, 16, 20)
        local boxHeight = warnTextH + 18
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

    -- 6. 动态总高度计算：顶部(36) + 方案栏(altOffset) + 描述(descHeight) + 警告框(questWarnHeight) + 底部按钮间距(48)
    local totalFrameHeight = 36 + altOffset + descHeight + questWarnHeight + 48
    hudFrame:SetHeight(math.max(130, totalFrameHeight))

    -- 7. 下一渲染帧二次校准：待客户端引擎完成字形折行后，自动对齐真实渲染高度
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if not hudFrame or not hudFrame:IsShown() then return end
            local realDescH = math.max(descHeight, currentStepText:GetStringHeight() or 0)
            stepTextFrame:SetHeight(realDescH + 4)
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
        if secureOverlayBtn and not (InCombatLockdown and InCombatLockdown()) then
            secureOverlayBtn:Hide()
        end
        hudFrame:Hide()
    end
end

