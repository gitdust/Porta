local ADDON_NAME, ns = ...

_G.Porta = ns

ns.name = ADDON_NAME
ns.version = "1.1.0"

-- 默认配置
ns.defaultConfig = {
    hudLocked = false,
    hudScale = 1.0,
    autoTrack = true,
    showMinimapButton = true,
}

-- 核心事件总线
ns.EventFrame = CreateFrame("Frame", "PortaEventFrame")
ns.EventFrame:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

-- 消息打印工具
function ns.Print(msg)
    print("|cff00ccff[Porta]|r " .. tostring(msg))
end

-- 获取玩家当前所属阵营 ("Alliance" / "Horde")
function ns.GetPlayerFaction()
    local faction = UnitFactionGroup("player")
    if faction == "Alliance" then
        return "ALLIANCE"
    elseif faction == "Horde" then
        return "HORDE"
    end
    return "NEUTRAL"
end
