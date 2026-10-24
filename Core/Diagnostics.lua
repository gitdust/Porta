local _, ns = ...
local L = ns.L

-- =========================================================================
-- /porta diag：一次性采集游戏内验证数据 (对应仓库根目录 game.md 第 1–14 节)
-- 结果写入 PortaDB.diag[角色名-服务器]，/reload 后可在
-- WTF/Account/<账号>/SavedVariables/Porta.lua 中查看
-- =========================================================================
local Diagnostics = {}
ns.Diagnostics = Diagnostics

local PRELOAD_DELAY = 2.0
local MAX_PARENT_DEPTH = 8
local isRunning = false

-- 关注的关键地图：至暗之夜各区域、千禧阈限、心之密室、纳沙塔尔、卡兹阿加主城
local WATCH_MAP_IDS = { 2537, 2393, 2512, 2395, 2405, 2413, 2424, 2437, 2266, 1473, 1355, 2339, 2248 }

local function StripCodes(text)
    if type(text) ~= "string" then return text end
    return (text
        :gsub("|T[^|]*|t", "")
        :gsub("|c%x%x%x%x%x%x%x%x", "")
        :gsub("|r", "")
        :gsub("|H[^|]*|h", "")
        :gsub("|h", ""))
end

local function IsQuestDone(questID)
    return C_QuestLog.IsQuestFlaggedCompleted(questID) and true or false
end

local function QuestRow(questID)
    return {
        id = questID,
        title = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID),
        done = IsQuestDone(questID),
    }
end

local function MapChain(mapID)
    local chain = {}
    local curr = mapID
    for _ = 1, MAX_PARENT_DEPTH do
        local info = curr and C_Map.GetMapInfo(curr)
        if not info then break end
        table.insert(chain, {
            id = curr,
            name = info.name,
            mapType = info.mapType,
            canWaypoint = C_Map.CanSetUserWaypointOnMap and C_Map.CanSetUserWaypointOnMap(curr) or nil,
        })
        if not info.parentMapID or info.parentMapID <= 0 then break end
        curr = info.parentMapID
    end
    return chain
end

local function PlayerPosition()
    local mapID = C_Map.GetBestMapForUnit("player")
    local pos = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then
        return { mapID = mapID }
    end
    local x, y = pos:GetXY()
    return { mapID = mapID, x = math.floor(x * 10000 + 0.5) / 100, y = math.floor(y * 10000 + 0.5) / 100 }
end

-- 计算前往目的地的全部备选路线，记录方案名与每一步的地图跳转
local function DescribeRoute(destination)
    local route = ns.Pathfinder:CalculateRoute(destination)
    if not route then
        return { found = false }
    end
    local alternatives = {}
    for _, alt in ipairs(route.alternatives) do
        local steps = {}
        for _, step in ipairs(alt.steps) do
            table.insert(steps, string.format("%s>%s %s: %s",
                tostring(step.mapID), tostring(step.toMapID), tostring(step.action), StripCodes(step.description or "")))
        end
        table.insert(alternatives, {
            name = StripCodes(alt.name),
            score = alt.score,
            missing = alt.isMissingTeleport and true or false,
            steps = steps,
        })
    end
    return { found = true, alternatives = alternatives }
end

local function CollectMeta()
    local version, build, _, toc = GetBuildInfo()
    local _, playerClass = UnitClass("player")
    local _, _, raceID = UnitRace("player")
    return {
        addonVersion = ns.version,
        client = string.format("%s (%s) toc %s", tostring(version), tostring(build), tostring(toc)),
        locale = GetLocale(),
        faction = ns.GetPlayerFaction(),
        class = playerClass,
        raceID = raceID,
        level = UnitLevel("player"),
        serverExpansionLevel = GetServerExpansionLevel and GetServerExpansionLevel(),
        LE_EXPANSION_WAR_WITHIN = LE_EXPANSION_WAR_WITHIN,
        LE_EXPANSION_MIDNIGHT = LE_EXPANSION_MIDNIGHT,
        generatedAt = date("%Y-%m-%d %H:%M:%S"),
        position = PlayerPosition(),
    }
end

-- §1 / §2：补充门禁表 (纳沙塔尔、阿古斯、麦卡贡等)
local function CollectPortalGates(faction)
    local gates = {}
    for mapID, config in pairs(ns.Pathfinder.Data.PORTAL_QUEST_GATES) do
        local mapInfo = C_Map.GetMapInfo(mapID)
        local entry = {
            mapID = mapID,
            mapName = mapInfo and mapInfo.name,
            unlockedForPlayer = ns.Pathfinder:CheckPortalQuestStatus(mapID, faction, true) and true or false,
            factions = {},
        }
        for gateFaction, gate in pairs(config) do
            local quests = {}
            for _, questID in ipairs(gate.questIDs) do
                table.insert(quests, QuestRow(questID))
            end
            entry.factions[gateFaction] = quests
        end
        table.insert(gates, entry)
    end
    table.sort(gates, function(a, b) return a.mapID < b.mapID end)
    return gates
end

-- §3：路网中所有带任务 / 成就前置的交通边
local function CollectEdgeRequirements()
    local _, fwdAdj = ns.Pathfinder.Data.GetGraphData()
    local rows, seen = {}, {}
    for _, edges in pairs(fwdAdj) do
        for _, edge in ipairs(edges) do
            if edge.questID or edge.achievementID then
                local key = string.format("%d>%d|%s|%s", edge.from, edge.to, tostring(edge.questID), tostring(edge.achievementID))
                if not seen[key] then
                    seen[key] = true
                    local row = { from = edge.from, to = edge.to, type = edge.type }
                    if edge.questID then
                        row.quest = QuestRow(edge.questID)
                    end
                    if edge.achievementID then
                        local _, achName, _, completed = GetAchievementInfo(edge.achievementID)
                        row.achievement = { id = edge.achievementID, name = achName, completed = completed }
                    end
                    table.insert(rows, row)
                end
            end
        end
    end
    table.sort(rows, function(a, b)
        if a.from ~= b.from then return a.from < b.from end
        return a.to < b.to
    end)
    return rows
end

-- §4：千禧阈限入口
local function CollectTimeways()
    local entryMaps = {}
    for mapID in pairs(ns.Pathfinder.Data.GetTimewaysEntryMaps()) do
        table.insert(entryMaps, mapID)
    end
    table.sort(entryMaps)
    return {
        entryMaps = entryMaps,
        route = DescribeRoute({ id = 0, name = "Timeways", mapID = 2266, x = 0.5, y = 0.5, type = "zone" }),
    }
end

-- §6：专业
local function CollectProfessions()
    local rows = {}
    local prof1, prof2 = GetProfessions()
    for _, idx in ipairs({ prof1 or 0, prof2 or 0 }) do
        if idx > 0 then
            local name, _, skillLevel, _, _, _, skillLine = GetProfessionInfo(idx)
            table.insert(rows, { name = name, skillLine = skillLine, skillLevel = skillLevel })
        end
    end
    return { professions = rows, hasEngineering = ns.PlayerTeleports.HasEngineeringProfession() }
end

local function SpellRow(spellID)
    return {
        id = spellID,
        name = C_Spell.GetSpellName(spellID),
        known = (C_SpellBook.IsSpellKnown and C_SpellBook.IsSpellKnown(spellID)) or (C_SpellBook.IsSpellInSpellBook and C_SpellBook.IsSpellInSpellBook(spellID, Enum.SpellBookSpellBank.Player, true)) or false,
    }
end

-- §7 / §8：职业传送技能与大秘境传送门
local function CollectSpells()
    local data = ns.PlayerTeleports.Data
    local _, playerClass = UnitClass("player")

    local classSpells = {}
    for _, spell in ipairs(data.CLASS_TELEPORT_SPELLS) do
        if spell.class == "ALL" or spell.class == playerClass then
            local row = SpellRow(spell.id)
            row.toMap = spell.toMap
            table.insert(classSpells, row)
        end
    end

    -- 按旧版「传送：银月城」(32272) 的本地化名称反查当前已学会的同名法术 ID (用于核对 1259190)
    local silvermoonName = C_Spell.GetSpellName(32272)
    local silvermoonInfo = silvermoonName and C_Spell.GetSpellInfo(silvermoonName)

    local mythicPlus = {}
    for journalID, entry in pairs(data.MYTHIC_PLUS_DUNGEON_SPELLS) do
        local spellIDs = (type(entry) == "table") and entry or { entry }
        for _, spellID in ipairs(spellIDs) do
            local row = SpellRow(spellID)
            row.journalID = journalID
            row.instanceName = EJ_GetInstanceInfo(journalID)
            table.insert(mythicPlus, row)
        end
    end
    table.sort(mythicPlus, function(a, b) return a.journalID < b.journalID end)

    return {
        classSpells = classSpells,
        silvermoonByName = {
            name = silvermoonName,
            spellID = silvermoonInfo and silvermoonInfo.spellID,
        },
        mythicPlus = mythicPlus,
    }
end

local function ForEachTeleportItemID(fn)
    local data = ns.PlayerTeleports.Data
    for _, item in ipairs(data.TELEPORT_ITEMS) do
        for _, id in ipairs(item.ids or { item.id }) do
            fn(id, item)
        end
    end
    for _, group in ipairs({ data.DIRECT_DESTINATION_ITEMS, data.DIRECT_MAP_ITEMS }) do
        for _, list in pairs(group) do
            for _, item in ipairs(list) do
                fn(item.id, item)
            end
        end
    end
end

-- §9：传送物品 / 玩具
local function CollectItems()
    local rows, seen = {}, {}
    ForEachTeleportItemID(function(id, item)
        if seen[id] then return end
        seen[id] = true
        local _, toyName = C_ToyBox.GetToyInfo(id)
        table.insert(rows, {
            id = id,
            kind = item.kind,
            itemName = C_Item.GetItemNameByID(id),
            toyName = toyName,
            hasToy = PlayerHasToy(id) and true or false,
            bagCount = C_Item.GetItemCount(id, false),
            totalCount = C_Item.GetItemCount(id, true, false, true, true),
        })
    end)
    table.sort(rows, function(a, b) return a.id < b.id end)

    local available = {}
    for _, tp in ipairs(ns.PlayerTeleports:GetAvailableTeleports()) do
        table.insert(available, {
            type = tp.type,
            id = tp.id,
            name = tp.name,
            toMap = tp.toMap,
            hasItem = tp.hasItem and true or false,
            tag = tp.missingShortTag and StripCodes(tp.missingShortTag) or nil,
        })
    end
    return { items = rows, availableTeleports = available }
end

-- §11 / §12：当前地图与关键地图的父级链
local function CollectMaps()
    local rawMapID = C_Map.GetBestMapForUnit("player")
    local watch = {}
    for _, mapID in ipairs(WATCH_MAP_IDS) do
        table.insert(watch, {
            mapID = mapID,
            continentGroup = ns.Pathfinder.Data.ZONE_TO_CONTINENT[mapID],
            chain = MapChain(mapID),
        })
    end
    return {
        current = {
            rawMapID = rawMapID,
            resolvedMapID = ns.Pathfinder:ResolveMapID(rawMapID),
            chain = MapChain(rawMapID),
        },
        watch = watch,
    }
end

-- §13：要塞法师之塔 / 灵魂之塔
local function CollectGarrison()
    local hasTower, rank, towerName, buildingID = ns.PlayerTeleports:GetGarrisonMageTowerInfo()
    local buildings = {}
    local garrisonType = (Enum.GarrisonType and Enum.GarrisonType.Type_6_0_Garrison) or 2
    local ok, list = pcall(C_Garrison.GetBuildings, garrisonType)
    if ok and type(list) == "table" then
        for _, b in ipairs(list) do
            local _, name, textureKit = C_Garrison.GetBuildingInfo(b.buildingID)
            table.insert(buildings, { buildingID = b.buildingID, rank = b.rank, name = name, textureKit = textureKit })
        end
    end
    return {
        mageTower = { hasTower = hasTower, rank = rank, name = towerName, buildingID = buildingID },
        buildings = buildings,
    }
end

-- §14：全部目的地在当前客户端中的名称 (名称为空即数据 ID 有误)
local function CollectDestinations()
    local rows, missing = {}, 0
    for _, dest in ipairs(ns.PortaData.destinations) do
        local name
        if dest.type == "delve" then
            local info = C_Map.GetMapInfo(dest.id)
            name = info and info.name
        else
            name = EJ_GetInstanceInfo(dest.id)
        end
        if not name or name == "" then
            missing = missing + 1
        end
        table.insert(rows, { id = dest.id, type = dest.type, mapID = dest.mapID, comment = dest.comment, name = name })
    end
    return { missingNameCount = missing, list = rows }
end

local function Collect()
    local faction = ns.GetPlayerFaction()
    return {
        meta = CollectMeta(),
        s01_s02_portalGates = CollectPortalGates(faction),
        s03_edgeRequirements = CollectEdgeRequirements(),
        s04_timeways = CollectTimeways(),
        s05_coiledIsle = DescribeRoute({ id = 0, name = "Coiled Isle", mapID = 2512, x = 0.5, y = 0.5, type = "zone" }),
        s06_professions = CollectProfessions(),
        s07_s08_spells = CollectSpells(),
        s09_items = CollectItems(),
        s11_s12_maps = CollectMaps(),
        s13_garrison = CollectGarrison(),
        s14_destinations = CollectDestinations(),
    }
end

-- 预加载物品 / 法术名称缓存，避免首次查询返回 nil
local function PreloadNames()
    ForEachTeleportItemID(function(id)
        C_Item.RequestLoadItemDataByID(id)
    end)
    for _, spell in ipairs(ns.PlayerTeleports.Data.CLASS_TELEPORT_SPELLS) do
        C_Spell.RequestLoadSpellData(spell.id)
    end
    for _, entry in pairs(ns.PlayerTeleports.Data.MYTHIC_PLUS_DUNGEON_SPELLS) do
        for _, spellID in ipairs((type(entry) == "table") and entry or { entry }) do
            C_Spell.RequestLoadSpellData(spellID)
        end
    end
end

function Diagnostics:Run()
    if isRunning then return end
    if InCombatLockdown() then
        return
    end

    isRunning = true
    PreloadNames()

    C_Timer.After(PRELOAD_DELAY, function()
        isRunning = false
        local ok, result = pcall(Collect)
        local charKey = string.format("%s-%s", UnitName("player"), GetRealmName())

        PortaDB = PortaDB or {}
        PortaDB.diag = PortaDB.diag or {}
        if ok then
            PortaDB.diag[charKey] = result
        else
            -- 采集过程出错时也落盘错误信息，便于定位
            PortaDB.diag[charKey] = { error = tostring(result), meta = { generatedAt = date("%Y-%m-%d %H:%M:%S") } }
        end
    end)
end
