local _, ns = ...

-- 注册聊天命令行
SLASH_PORTA1 = "/porta"
SlashCmdList["PORTA"] = function(msg)
    local query = type(msg) == "string" and (strtrim and strtrim(msg) or string.gsub(msg, "^%s*(.-)%s*$", "%1")) or ""
    if query ~= "" then
        -- 如果带参数输入，直接带关键词打开搜索框
        ns.SearchDialog:Toggle(query)
    else
        ns.SearchDialog:Toggle()
    end
end

local L = ns.L

-- 按键绑定显示文本 (在游戏按键绑定设置界面显示)
_G["BINDING_HEADER_PORTA"] = L["BINDING_HEADER"]
_G["BINDING_NAME_PORTA_TOGGLE"] = L["BINDING_TOGGLE"]

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

    ns.Print(L["ADDON_LOADED_MSG"])
end
