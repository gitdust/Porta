local _, ns = ...
local L = ns.L

local SearchDialog = {}
ns.SearchDialog = SearchDialog

local frame = nil
local editBox = nil
local noResultsText = nil
local resultButtons = {}
local currentResults = {}
local selectedIndex = 1
local lastQueryText = nil
local pollElapsed = 0
local debounceElapsed = 0
local hasPendingSearch = false
local MAX_VISIBLE_RESULTS = 7
local ROW_HEIGHT = 42

local function TrimText(s)
    if not s then return "" end
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

-- 创建结果项按钮
local function CreateResultButton(parent, index)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(ROW_HEIGHT)
    btn:SetPoint("LEFT", parent, "LEFT", 16, 0)
    btn:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
    btn:SetPoint("TOP", parent, "TOP", 0, -84 - (index - 1) * (ROW_HEIGHT + 4))

    -- 背景高亮纹理
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.25, 0.35, 0.3)
    btn.bg = bg

    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(0.0, 0.8, 1.0, 0.2)

    -- 分类标签与所在区域 (先声明并固定在右侧)
    local metaText = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    metaText:SetPoint("RIGHT", btn, "RIGHT", -12, 0)
    metaText:SetJustifyH("RIGHT")
    btn.metaText = metaText

    -- 名称文字 (左侧固定，右侧严密锚定至 metaText 左侧，杜绝长地名与右侧标签重叠)
    local nameText = btn:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
    nameText:SetPoint("LEFT", btn, "LEFT", 12, 0)
    nameText:SetPoint("RIGHT", metaText, "LEFT", -8, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    btn.nameText = nameText

    -- 点击选择
    btn:SetScript("OnClick", function()
        SearchDialog:SelectIndex(index)
        SearchDialog:ConfirmSelection()
    end)

    return btn
end

-- 刷新结果列表渲染
local function RenderResults()
    local text = editBox and editBox:GetText() or ""
    local queryTrimmed = TrimText(text)
    local isSearching = (queryTrimmed ~= "")
    local hasResults = (#currentResults > 0)

    for i = 1, MAX_VISIBLE_RESULTS do
        local btn = resultButtons[i]
        local item = currentResults[i]

        if item and isSearching then
            btn:Show()
            btn.nameText:SetText(item.name)
            btn.metaText:SetText(string.format("%s[%s]|r  |cff888888%s|r", item.color or "|cffffffff", item.tag or L["TAG_PLACE"], item.zoneName or ""))

            if i == selectedIndex then
                btn.bg:SetColorTexture(0.0, 0.5, 0.8, 0.45)
            else
                btn.bg:SetColorTexture(0.15, 0.18, 0.22, 0.4)
            end
        else
            btn:Hide()
        end
    end

    if noResultsText then
        if not isSearching then
            noResultsText:SetText(L["SEARCH_EMPTY_INPUT"])
            noResultsText:Show()
        elseif not hasResults then
            noResultsText:SetText(L["SEARCH_NO_RESULTS"])
            noResultsText:Show()
        else
            noResultsText:Hide()
        end
    end
end

-- 同步输入框文本并刷新搜索结果（兼容中文输入法内联上屏）
local function UpdateSearchResults(force)
    if not editBox then return end
    local text = editBox:GetText() or ""
    if not force and text == lastQueryText then
        return
    end
    lastQueryText = text

    local queryTrimmed = TrimText(text)
    if queryTrimmed == "" then
        wipe(currentResults)
        selectedIndex = 1
        RenderResults()
        return
    end

    currentResults = ns.SearchEngine:Search(text, MAX_VISIBLE_RESULTS)
    selectedIndex = 1
    RenderResults()
end

-- 初始化主窗口
local function InitFrame()
    if frame then return end

    frame = CreateFrame("Frame", "PortaSearchFrame", UIParent, "BackdropTemplate")
    frame:SetSize(520, 445)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- 背景与边框
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.08, 0.1, 0.13, 0.94)
    frame:SetBackdropBorderColor(0.0, 0.8, 1.0, 0.8)

    -- 品牌标志
    local logo = frame:CreateTexture(nil, "ARTWORK")
    logo:SetSize(28, 28)
    logo:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -12)
    logo:SetTexture("Interface\\AddOns\\Porta\\Images\\Logo")

    -- 标题
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, 2)
    title:SetText(L["SEARCH_TITLE"])

    local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
    subtitle:SetText(L["SEARCH_SUBTITLE"])

    -- 关闭按钮
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -6)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- 搜索输入框容器
    local inputContainer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    inputContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -46)
    inputContainer:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -46)
    inputContainer:SetHeight(32)
    inputContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    inputContainer:SetBackdropColor(0.05, 0.05, 0.07, 0.8)
    inputContainer:SetBackdropBorderColor(0.2, 0.6, 0.9, 0.6)

    -- 输入框
    editBox = CreateFrame("EditBox", nil, inputContainer)
    editBox:SetAllPoints()
    editBox:SetFontObject("GameFontHighlightMedium")
    editBox:SetAutoFocus(false)
    editBox:SetAltArrowKeyMode(false)
    editBox:SetTextInsets(10, 10, 0, 0)

    editBox:SetScript("OnTextChanged", function()
        hasPendingSearch = true
        debounceElapsed = 0
    end)

    editBox:SetScript("OnChar", function()
        hasPendingSearch = true
        debounceElapsed = 0
    end)

    editBox:SetScript("OnEscapePressed", function()
        hasPendingSearch = false
        frame:Hide()
    end)

    editBox:SetScript("OnArrowPressed", function(_, key)
        if key == "UP" then
            SearchDialog:SelectIndex(selectedIndex - 1)
        elseif key == "DOWN" then
            SearchDialog:SelectIndex(selectedIndex + 1)
        end
    end)

    -- 轮询与防抖驱动：平滑搜索响应，避免高频键入频繁重算，同时兼容 IME 内联上屏
    frame:SetScript("OnUpdate", function(_, elapsed)
        local dt = elapsed or 0
        if hasPendingSearch then
            debounceElapsed = debounceElapsed + dt
            if debounceElapsed >= 0.08 then
                hasPendingSearch = false
                debounceElapsed = 0
                UpdateSearchResults(false)
            end
        else
            pollElapsed = pollElapsed + dt
            if pollElapsed >= 0.1 then
                pollElapsed = 0
                if editBox:GetText() ~= lastQueryText then
                    UpdateSearchResults(false)
                end
            end
        end
    end)

    -- 无结果/空输入提示文案
    noResultsText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
    noResultsText:SetPoint("CENTER", frame, "CENTER", 0, -25)
    noResultsText:SetTextColor(0.65, 0.65, 0.65)
    noResultsText:SetJustifyH("CENTER")
    noResultsText:SetText(L["SEARCH_EMPTY_INPUT"])
    noResultsText:Hide()

    -- 底部提示栏
    local footer = frame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    footer:SetPoint("BOTTOM", frame, "BOTTOM", 0, 12)
    footer:SetText(L["SEARCH_FOOTER"])

    -- 创建结果条目
    for i = 1, MAX_VISIBLE_RESULTS do
        resultButtons[i] = CreateResultButton(frame, i)
    end

    -- 初始处于隐藏状态（避免 CreateFrame 默认为 Shown 导致首次 Toggle 误判为关闭）
    frame:Hide()

    -- 初始显示推荐/热搜目的地
    frame:SetScript("OnShow", function()
        pollElapsed = 0
        editBox:SetText("")
        editBox:SetFocus()
        UpdateSearchResults(true)
    end)

    -- 隐藏时主动清理结果引用并重置定时器，促使垃圾回收与内存释放
    frame:SetScript("OnHide", function()
        hasPendingSearch = false
        debounceElapsed = 0
        pollElapsed = 0
        lastQueryText = nil
        wipe(currentResults)
        if noResultsText then
            noResultsText:Hide()
        end
    end)
end

-- 选中指定索引
function SearchDialog:SelectIndex(idx)
    if #currentResults == 0 then return end
    if idx < 1 then
        selectedIndex = #currentResults
    elseif idx > #currentResults then
        selectedIndex = 1
    else
        selectedIndex = idx
    end
    RenderResults()
end

-- 确认选中的目的地并启动导航
function SearchDialog:ConfirmSelection()
    local item = currentResults[selectedIndex]
    if not item then return end

    if frame then frame:Hide() end

    -- 调用寻路引擎算路
    local route = ns.Pathfinder:CalculateRoute(item)
    if route then
        ns.Navigation:StartRoute(route)
    end
end

-- 呼出/隐藏搜索浮窗
function SearchDialog:Toggle(initialQuery)
    InitFrame()
    if initialQuery and initialQuery ~= "" then
        frame:Show()
        editBox:SetText(initialQuery)
        editBox:SetFocus()
        UpdateSearchResults(true)
        return
    end
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
