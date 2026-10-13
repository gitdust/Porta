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

-- 按键绑定显示文本 (在游戏按键绑定设置界面显示)
_G["BINDING_HEADER_PORTA"] = "Porta 路线导航"
_G["BINDING_NAME_PORTA_TOGGLE"] = "唤出/关闭导航搜索框"

-- 监听玩家进入游戏世界
ns.EventFrame:RegisterEvent("PLAYER_LOGIN")
function ns.EventFrame:PLAYER_LOGIN()
    -- 初始化搜索索引
    if ns.SearchEngine then
        ns.SearchEngine:Initialize()
    end

    ns.Print("已加载完成！输入 |cffffcc00/porta|r 快速打开目的地搜索。")
end
