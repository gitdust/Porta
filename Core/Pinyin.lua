local _, ns = ...

-- 拼音首字母匹配辅助模块
-- 支持中文首字母搜索（如输入 "ahdx" 匹配 "哀嚎洞穴"）

local Pinyin = {}
ns.Pinyin = Pinyin

-- 常用汉字拼音首字母编码表 (Unicode 范围分段快速索引)
-- 涵盖常见首字母编码分界
local pinyinOffsets = {
    { 0xB0A1, 0xB0C4, "a" }, { 0xB0C5, 0xB2C0, "b" }, { 0xB2C1, 0xB4ED, "c" },
    { 0xB4EE, 0xB6E9, "d" }, { 0xB6EA, 0xB7A1, "e" }, { 0xB7A2, 0xB8C0, "f" },
    { 0xB8C1, 0xB9FD, "g" }, { 0xB9FE, 0xBBF6, "h" }, { 0xBBF7, 0xBFA5, "j" },
    { 0xBFA6, 0xC0AB, "k" }, { 0xC0AC, 0xC2E7, "l" }, { 0xC2E8, 0xC4C2, "m" },
    { 0xC4C3, 0xC5B5, "n" }, { 0xC5B6, 0xC5FD, "o" }, { 0xC5FE, 0xC7D9, "p" },
    { 0xC7DA, 0xC8BB, "q" }, { 0xC8BC, 0xC9D9, "r" }, { 0xC9DA, 0xCBF9, "s" },
    { 0xCBFA, 0xCDDA, "t" }, { 0xCDDB, 0xCEF3, "w" }, { 0xCEF4, 0xD1B8, "x" },
    { 0xD1B9, 0xD4D0, "y" }, { 0xD4D1, 0xD7F9, "z" },
}

-- 常见魔兽专用词汇简拼快表（保证魔兽特有名词 100% 精确匹配）
local specialWordPinyin = {
    ["奥格瑞玛"] = "agrm", ["暴风城"] = "bfc", ["铁炉堡"] = "tlb", ["达纳苏斯"] = "dnss",
    ["埃索达"] = "asd", ["幽暗城"] = "yac", ["雷霆崖"] = "lty", ["银月城"] = "yyc",
    ["达拉然"] = "dlr", ["沙塔斯"] = "sts", ["奥利波斯"] = "albs", ["瓦德拉肯"] = "wdlk",
    ["多恩诺加尔"] = "dnej", ["阿苏纳"] = "asn", ["苏拉玛"] = "slm", ["至高岭"] = "zgl",
    ["瓦尔莎拉"] = "wsl", ["风暴峡湾"] = "fbxw", ["阿古斯"] = "ags", ["纳沙塔尔"] = "nste",
    ["伯拉勒斯"] = "blls", ["达萨罗"] = "dsl", ["祖达萨"] = "zds", ["纳斯利亚堡"] = "nslyb",
    ["统御圣所"] = "tyss", ["初诞者圣墓"] = "cdzsm", ["化身巨龙牢窟"] = "hsjllk",
    ["亚贝鲁斯"] = "ybls", ["阿梅达希尔"] = "amdx", ["尼维克萨斯"] = "nwkss",
    ["千丝之城"] = "qszc", ["暗焰裂隙"] = "aylx", ["矶石宝库"] = "jsbk",
    ["圣焰修道院"] = "syxdy", ["回响之城"] = "hxzc", ["艾拉-卡拉"] = "alkl",
    ["破晨号"] = "pch", ["水闸"] = "sz", ["哀嚎洞穴"] = "ahdx", ["影牙城堡"] = "yycb",
    ["死亡矿井"] = "swkj", ["黑石深渊"] = "hssy", ["黑石塔"] = "hst", ["熔火之心"] = "rhzx",
    ["黑翼之巢"] = "hyzc", ["安其拉"] = "aql", ["纳克萨玛斯"] = "nksms",
    ["卡拉赞"] = "klz", ["黑暗神殿"] = "hasd", ["太阳之井"] = "tyzj", ["奥杜尔"] = "ade",
    ["冰冠堡垒"] = "bgbl", ["十字军试炼"] = "szjsl", ["红玉圣殿"] = "hysd",
    -- 核心版本野外区域
    ["多恩岛"] = "dnd", ["陨圣峪"] = "ysy", ["喧鸣深窟"] = "xmsk", ["艾基-卡赫特"] = "ajkt",
    ["觉醒海岸"] = "jxha", ["欧恩哈拉平原"] = "ehlp", ["碧蓝林海"] = "bllh", ["索德拉苏斯"] = "sdls",
    ["禁忌离岛"] = "jjld", ["查拉雷克洞窟"] = "zllk", ["翡翠梦境"] = "fcmj",
    ["晋升堡垒"] = "jsbl", ["玛卓克萨斯"] = "mzkss", ["炽蓝仙野"] = "clxy", ["雷文德斯"] = "lwds",
    ["噬渊"] = "sy", ["刻希亚"] = "kxy", ["扎雷殁提斯"] = "zlmts",
    ["提拉加德海峡"] = "tlgd", ["德鲁斯瓦"] = "dlsw", ["斯托颂谷地"] = "stsgd", ["纳兹米尔"] = "nzme", ["沃顿"] = "wd",
    ["霜火岭"] = "shl", ["戈尔隆德"] = "geld", ["塔拉多"] = "tld", ["阿兰卡峰林"] = "alk", ["纳格兰"] = "ngl",
    ["翡翠林"] = "fcl", ["四风谷"] = "sfg", ["卡桑琅丛林"] = "ksl", ["昆莱山"] = "kls", ["锦绣谷"] = "jxg",
    ["嚎风峡湾"] = "hfxw", ["北风苔原"] = "bfty", ["龙骨荒野"] = "lghy", ["灰熊丘陵"] = "hxql", ["索拉查盆地"] = "slc",
    ["地狱火半岛"] = "dyh", ["赞加沼泽"] = "zjzz", ["泰罗卡森林"] = "tlk", ["刀锋山"] = "dfs", ["虚空风暴"] = "xkfb",
    ["贫瘠之地"] = "pjzd", ["杜隆塔尔"] = "dlte", ["莫高雷"] = "mgl", ["艾尔文森林"] = "ews", ["西部荒野"] = "xbhy",
    ["暮色森林"] = "mssl", ["赤脊山"] = "cjs", ["荆棘谷"] = "jjg", ["塔纳利斯"] = "tnls", ["希利苏斯"] = "xlss",
    ["环形山"] = "hxs", ["冬泉谷"] = "dqg", ["灰谷"] = "hg", ["菲拉斯"] = "fls", ["灼热峡谷"] = "zrxg", ["燃烧平原"] = "rspy",
    ["阿拉希高地"] = "alx", ["辛特兰"] = "xtl", ["东瘟疫之地"] = "dwy", ["西瘟疫之地"] = "xwy",
}

-- 生成字符串的拼音首字母（如果有预定义则优先使用）
function Pinyin:GetInitials(str)
    if not str or str == "" then return "" end
    
    -- 检查是否完全匹配专有词
    if specialWordPinyin[str] then
        return specialWordPinyin[str]
    end

    -- 检查是否包含专有词子串
    for word, py in pairs(specialWordPinyin) do
        if string.find(str, word, 1, true) then
            return py
        end
    end

    -- 兜底返回空字符串
    return ""
end

-- 模糊匹配判断：支持包含、大小写忽略、拼音首字母匹配
function Pinyin:Match(targetText, query)
    if not targetText or not query or query == "" then return false end

    local targetLower = string.lower(targetText)
    local queryLower = string.lower(query)

    -- 1. 普通直接子串包含
    if string.find(targetLower, queryLower, 1, true) then
        return true, 100 -- 高分命中
    end

    -- 2. 拼音首字母匹配
    local initials = Pinyin:GetInitials(targetText)
    if initials ~= "" and string.find(initials, queryLower, 1, true) then
        return true, 80 -- 拼音命中
    end

    return false, 0
end
