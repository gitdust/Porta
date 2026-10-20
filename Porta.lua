local _, ns = ...
local L = ns.L

-- 注册聊天命令行
SLASH_PORTA1 = "/porta"
SlashCmdList["PORTA"] = function(msg)
    local raw = type(msg) == "string" and (strtrim and strtrim(msg) or string.gsub(msg, "^%s*(.-)%s*$", "%1")) or ""
    local lower = string.lower(raw)

    -- 1. 小地图图标显隐切换: /porta minimap
    if lower == "minimap" then
        if ns.MinimapButton then
            ns.MinimapButton:Toggle()
        end
        return
    end

    -- 2. 帮助说明: /porta help
    if lower == "help" or lower == "?" then
        ns.Print(L["CMD_HELP_HEADER"])
        print("|cffffcc00" .. L["CMD_HELP_SEARCH"] .. "|r")
        print("|cffffcc00" .. L["CMD_HELP_MINIMAP"] .. "|r")
        return
    end

    -- 3. 正常搜索呼出 (若带有参数则直接输入关键词)
    if raw ~= "" then
        ns.SearchDialog:Toggle(raw)
    else
        ns.SearchDialog:Toggle()
    end
end

-- 监听插件配置加载
ns.EventFrame:RegisterEvent("ADDON_LOADED")
function ns.EventFrame:ADDON_LOADED(addonName)
    if addonName == "Porta" then
        PortaDB = PortaDB or {}
        if PortaDB.showMinimapButton == nil then
            PortaDB.showMinimapButton = true
        end
        if PortaDB.minimapPos == nil then
            PortaDB.minimapPos = 215
        end

        if ns.MinimapButton and ns.MinimapButton.Initialize then
            ns.MinimapButton:Initialize()
        end
    end
end

-- 监听玩家进入游戏世界
ns.EventFrame:RegisterEvent("PLAYER_LOGIN")
function ns.EventFrame:PLAYER_LOGIN()
    -- 预热传送物品/玩具/技能名称缓存
    if ns.PlayerTeleports and ns.PlayerTeleports.PreloadCache then
        ns.PlayerTeleports:PreloadCache()
    end

    -- 初始化搜索索引
    if ns.SearchEngine then
        ns.SearchEngine:Initialize()
    end

    -- 兜底检查小地图按钮初始化
    if ns.MinimapButton and ns.MinimapButton.Initialize then
        ns.MinimapButton:Initialize()
    end

    ns.Print(L["ADDON_LOADED_MSG"])
end

-- 监听德拉诺要塞建筑变更，动态失效建筑缓存
local garrisonEvents = {
    "GARRISON_BUILDING_ACTIVATED",
    "GARRISON_BUILDING_UPDATE",
    "GARRISON_BUILDING_PLACED",
    "GARRISON_BUILDING_REMOVED",
    "GARRISON_BUILDING_LIST_UPDATE",
}

local function OnGarrisonBuildingChanged()
    if ns.PlayerTeleports and ns.PlayerTeleports.InvalidateGarrisonCache then
        ns.PlayerTeleports:InvalidateGarrisonCache()
    end
end

for _, event in ipairs(garrisonEvents) do
    pcall(function()
        ns.EventFrame:RegisterEvent(event)
    end)
    ns.EventFrame[event] = OnGarrisonBuildingChanged
end
