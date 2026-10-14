local _, ns = ...
local L = ns.L

-- 按键绑定显示文本 (在暴雪原生按键绑定设置界面与 Bindings.xml 对应)
_G["BINDING_HEADER_PORTA"] = L["BINDING_HEADER"]
_G["BINDING_NAME_PORTA_TOGGLE"] = L["BINDING_TOGGLE"]

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

    -- 2. 快捷键设置与查询: /porta bind 或 /porta key
    if lower == "bind" or lower == "key" or string.find(lower, "^bind%s*") or string.find(lower, "^key%s*") then
        local subArgs = ""
        local s = string.find(raw, "%s+")
        if s then
            subArgs = strtrim and strtrim(string.sub(raw, s + 1)) or string.gsub(string.sub(raw, s + 1), "^%s*(.-)%s*$", "%1")
        end

        if subArgs == "" then
            -- 查询当前已绑定按键
            local k1, k2 = GetBindingKey("PORTA_TOGGLE")
            if k1 then
                local keyStr = k2 and (k1 .. ", " .. k2) or k1
                ns.Print(string.format(L["CMD_BIND_CURRENT_FMT"], keyStr))
            else
                ns.Print(L["CMD_BIND_NONE"])
            end
            ns.Print(L["CMD_BIND_HINT"])

            -- 尝试直接唤出暴雪原生按键设置界面 (兼容 Retail 10.0+)
            if Settings and Settings.OpenToCategory and Settings.KEYBINDINGS_CATEGORY_ID then
                pcall(function() Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID) end)
            end
            return
        end

        local subLower = string.lower(subArgs)
        if subLower == "clear" or subLower == "reset" or subLower == "none" then
            local k1, k2 = GetBindingKey("PORTA_TOGGLE")
            if k1 then SetBinding(k1, nil) end
            if k2 then SetBinding(k2, nil) end
            local bindSet = GetCurrentBindingSet()
            if SaveBindings and bindSet then
                SaveBindings(bindSet)
            end
            ns.Print(L["CMD_BIND_CLEARED"])
            return
        end

        -- 设置新按键 (如 /porta bind CTRL-P 或 /porta bind F)
        local targetKey = string.upper(subArgs)
        local ok = SetBinding(targetKey, "PORTA_TOGGLE")
        if ok then
            local bindSet = GetCurrentBindingSet()
            if SaveBindings and bindSet then
                SaveBindings(bindSet)
            end
            ns.Print(string.format(L["CMD_BIND_SUCCESS_FMT"], targetKey))
        else
            ns.Print(string.format(L["CMD_BIND_INVALID_FMT"], targetKey))
        end
        return
    end

    -- 3. 帮助说明: /porta help
    if lower == "help" or lower == "?" then
        ns.Print(L["CMD_HELP_HEADER"])
        print("|cffffcc00" .. L["CMD_HELP_SEARCH"] .. "|r")
        print("|cffffcc00" .. L["CMD_HELP_MINIMAP"] .. "|r")
        print("|cffffcc00" .. L["CMD_HELP_BIND"] .. "|r")
        return
    end

    -- 4. 正常搜索呼出 (若带有参数则直接输入关键词)
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
