local _, ns = ...

-- 注册聊天命令行
SLASH_PORTA1 = "/porta"
SLASH_PORTA2 = "/go"
SlashCmdList["PORTA"] = function(msg)
    local query = string.trim and string.trim(msg) or msg
    if query and query ~= "" then
        -- 如果带参数输入，直接尝试搜索并展示
        ns.SearchDialog:Toggle()
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

    ns.Print("已加载完成！输入 |cffffcc00/porta|r 或 |cffffcc00/go|r 快速打开目的地搜索。")
end
