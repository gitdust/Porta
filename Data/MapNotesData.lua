-- =========================================================================
-- Porta Data - Auto-generated from HandyNotes_MapNotes (Retail)
-- Build Date: 2026-10-25
-- Destinations: 233
-- Transport Edges: 660
-- =========================================================================

local _, ns = ...

ns.PortaData = {
    version = "1.0.0",
    buildDate = "2026-10-25",

    -- Destinations: dungeon, raid and delve entrances
    -- id: journalInstanceID for dungeon/raid; internal uiMapID for delve
    -- Names: EJ_GetInstanceInfo(id) for dungeon/raid; C_Map.GetMapInfo(id) for delve
    destinations = {
        { id = 63, mapID = 52, x = 0.4252, y = 0.7168, type = "dungeon", comment = "Deadmines" },
        { id = 64, mapID = 21, x = 0.4492, y = 0.6788, type = "dungeon", comment = "Shadowfang Keep" },
        { id = 65, mapID = 203, x = 0.4817, y = 0.4041, type = "dungeon", comment = "Throne of the Tides" },
        { id = 66, mapID = 33, x = 0.7551, y = 0.6099, type = "dungeon", comment = "Blackrock Caverns" },
        { id = 67, mapID = 207, x = 0.4738, y = 0.5205, type = "dungeon", comment = "The Stonecore" },
        { id = 68, mapID = 1527, x = 0.7670, y = 0.8435, type = "dungeon", comment = "The Vortex Pinnacle" },
        { id = 69, mapID = 1527, x = 0.6052, y = 0.6415, type = "dungeon", comment = "Lost City of the Tol'vir" },
        { id = 70, mapID = 1527, x = 0.6909, y = 0.5283, type = "dungeon", comment = "Halls of Origination" },
        { id = 71, mapID = 241, x = 0.1920, y = 0.5411, type = "dungeon", comment = "Grim Batol" },
        { id = 72, mapID = 241, x = 0.3409, y = 0.7788, type = "raid", comment = "Bastion of Twilight" },
        { id = 73, mapID = 36, x = 0.2313, y = 0.2639, type = "raid", comment = "Blackwing Descent" },
        { id = 74, mapID = 1527, x = 0.3700, y = 0.8143, type = "raid", comment = "Throne of the Four Winds" },
        { id = 75, mapID = 244, x = 0.4605, y = 0.4793, type = "raid", comment = "Baradin Hold" },
        { id = 76, mapID = 50, x = 0.7208, y = 0.3291, type = "dungeon", comment = "Zul'gurub" },
        { id = 77, mapID = 95, x = 0.8195, y = 0.6434, type = "dungeon", comment = "Zul'Aman" },
        { id = 78, mapID = 198, x = 0.4679, y = 0.7838, type = "raid", comment = "Firelands" },
        { id = 184, mapID = 75, x = 0.5704, y = 0.2578, type = "dungeon", comment = "End Time" },
        { id = 185, mapID = 75, x = 0.2213, y = 0.6381, type = "dungeon", comment = "Well of Eternity" },
        { id = 186, mapID = 75, x = 0.6838, y = 0.2951, type = "dungeon", comment = "Hour of Twilight" },
        { id = 187, mapID = 75, x = 0.6087, y = 0.2115, type = "raid", comment = "Dragon Soul" },
        { id = 226, mapID = 85, x = 0.5168, y = 0.5850, type = "dungeon", comment = "Ragefire" },
        { id = 227, mapID = 63, x = 0.1416, y = 0.1380, type = "dungeon", comment = "Blackfathom Deeps" },
        { id = 228, mapID = 35, x = 0.3928, y = 0.1819, type = "dungeon", comment = "Blackrock Depths" },
        { id = 229, mapID = 33, x = 0.8045, y = 0.4193, type = "dungeon", comment = "Lower Blackrock Spire" },
        { id = 230, mapID = 69, x = 0.6032, y = 0.3015, type = "dungeon", comment = "Dire Maul - Capital Gardens - West left Entrance" },
        { id = 231, mapID = 27, x = 0.3139, y = 0.3804, type = "dungeon", comment = "Gnomeregan" },
        { id = 232, mapID = 66, x = 0.2922, y = 0.6253, type = "dungeon", comment = "Maraudon Outside" },
        { id = 233, mapID = 199, x = 0.5189, y = 0.9825, type = "dungeon", comment = "Razorfen Downs" },
        { id = 234, mapID = 199, x = 0.4077, y = 0.9446, type = "dungeon", comment = "Razorfen Kraul" },
        { id = 236, mapID = 23, x = 0.2707, y = 0.1151, type = "dungeon", comment = "Stratholme" },
        { id = 237, mapID = 51, x = 0.6967, y = 0.5353, type = "dungeon", comment = "The Temple of Atal'hakkar" },
        { id = 238, mapID = 84, x = 0.5119, y = 0.6779, type = "dungeon", comment = "The Stockade" },
        { id = 239, mapID = 15, x = 0.4203, y = 0.1147, type = "dungeon", comment = "Uldaman" },
        { id = 240, mapID = 10, x = 0.4049, y = 0.6868, type = "dungeon", comment = "Wailing Caverns" },
        { id = 241, mapID = 71, x = 0.3948, y = 0.2205, type = "dungeon", comment = "Zul'Farrak" },
        { id = 246, mapID = 22, x = 0.6979, y = 0.7356, type = "dungeon", comment = "Scholomance" },
        { id = 247, mapID = 108, x = 0.3467, y = 0.6559, type = "dungeon", comment = "Auchenai Crypts" },
        { id = 248, mapID = 100, x = 0.4792, y = 0.5342, type = "dungeon", comment = "Hellfire Ramparts" },
        { id = 249, mapID = 122, x = 0.6097, y = 0.3073, type = "dungeon", comment = "Magisters'Terrace" },
        { id = 250, mapID = 108, x = 0.3964, y = 0.5806, type = "dungeon", comment = "Mana Tombs" },
        { id = 251, mapID = 75, x = 0.2633, y = 0.3279, type = "dungeon", comment = "Old Hillsbrad Foothills" },
        { id = 252, mapID = 108, x = 0.4459, y = 0.6560, type = "dungeon", comment = "Sethekk Halls" },
        { id = 253, mapID = 108, x = 0.3962, y = 0.7318, type = "dungeon", comment = "Shadow Labyrinth" },
        { id = 254, mapID = 109, x = 0.7436, y = 0.5774, type = "dungeon", comment = "The Arcatraz" },
        { id = 255, mapID = 75, x = 0.3443, y = 0.8489, type = "dungeon", comment = "The Black Morass" },
        { id = 256, mapID = 100, x = 0.4601, y = 0.5179, type = "dungeon", comment = "The Blood Furnace" },
        { id = 257, mapID = 109, x = 0.7169, y = 0.5506, type = "dungeon", comment = "The Botanica" },
        { id = 258, mapID = 109, x = 0.7053, y = 0.6964, type = "dungeon", comment = "The Mechanar" },
        { id = 259, mapID = 100, x = 0.4806, y = 0.5191, type = "dungeon", comment = "The Shattered Halls" },
        { id = 260, mapID = 102, x = 0.4895, y = 0.3592, type = "dungeon", comment = "The Slave Pens" },
        { id = 261, mapID = 102, x = 0.5047, y = 0.3333, type = "dungeon", comment = "The Steamvault" },
        { id = 262, mapID = 102, x = 0.5417, y = 0.3443, type = "dungeon", comment = "The Underbog" },
        { id = 271, mapID = 115, x = 0.2838, y = 0.5167, type = "dungeon", comment = "Ahn'kahet: The Old Kingdom" },
        { id = 272, mapID = 115, x = 0.2599, y = 0.5079, type = "dungeon", comment = "Azjol-Nerub" },
        { id = 273, mapID = 116, x = 0.1755, y = 0.2120, type = "dungeon", comment = "Drak'Tharon Keep" },
        { id = 274, mapID = 121, x = 0.7643, y = 0.2140, type = "dungeon", comment = "Gundrak" },
        { id = 275, mapID = 120, x = 0.4532, y = 0.2148, type = "dungeon", comment = "Halls of Lightning" },
        { id = 276, mapID = 118, x = 0.5531, y = 0.9084, type = "dungeon", comment = "Halls of Reflection" },
        { id = 277, mapID = 120, x = 0.3958, y = 0.2689, type = "dungeon", comment = "Halls of Stone" },
        { id = 278, mapID = 118, x = 0.5472, y = 0.9168, type = "dungeon", comment = "Pit of Saron" },
        { id = 279, mapID = 75, x = 0.6011, y = 0.8272, type = "dungeon", comment = "The Culling of Stratholme" },
        { id = 280, mapID = 118, x = 0.5484, y = 0.8985, type = "dungeon", comment = "The Forge of Souls" },
        { id = 281, mapID = 114, x = 0.2859, y = 0.2772, type = "dungeon", comment = "The Nexus" },
        { id = 282, mapID = 114, x = 0.2660, y = 0.2746, type = "dungeon", comment = "The Oculus" },
        { id = 283, mapID = 125, x = 0.6616, y = 0.6745, type = "dungeon", comment = "The Violet Hold" },
        { id = 284, mapID = 118, x = 0.7417, y = 0.2044, type = "dungeon", comment = "Trial of the Champion" },
        { id = 285, mapID = 117, x = 0.5788, y = 0.4951, type = "dungeon", comment = "Utgarde Keep" },
        { id = 286, mapID = 117, x = 0.5722, y = 0.4649, type = "dungeon", comment = "Utgarde Pinnacle" },
        { id = 302, mapID = 376, x = 0.3606, y = 0.6909, type = "dungeon", comment = "Stormstout Brewery" },
        { id = 303, mapID = 390, x = 0.1583, y = 0.7441, type = "dungeon", comment = "Gate of the Setting Sun" },
        { id = 311, mapID = 18, x = 0.8532, y = 0.3227, type = "dungeon", comment = "Scarlet Halls" },
        { id = 312, mapID = 379, x = 0.3671, y = 0.4746, type = "dungeon", comment = "Shado-Pan Monastery" },
        { id = 313, mapID = 371, x = 0.5617, y = 0.5786, type = "dungeon", comment = "Temple of the Jade Serpent" },
        { id = 316, mapID = 18, x = 0.8482, y = 0.3043, type = "dungeon", comment = "Scarlet Monastery" },
        { id = 317, mapID = 379, x = 0.5960, y = 0.3917, type = "raid", comment = "Mogu'Shan Vaults" },
        { id = 320, mapID = 433, x = 0.4845, y = 0.6145, type = "raid", comment = "Terrace of Endless Spring" },
        { id = 321, mapID = 390, x = 0.8060, y = 0.3303, type = "dungeon", comment = "Mogu'shan Palace" },
        { id = 324, mapID = 388, x = 0.3468, y = 0.8151, type = "dungeon", comment = "Siege of Niuzao Temple" },
        { id = 330, mapID = 422, x = 0.3892, y = 0.3499, type = "raid", comment = "Heart of Fear" },
        { id = 362, mapID = 504, x = 0.6383, y = 0.3203, type = "raid", comment = "Throne of Thunder" },
        { id = 369, mapID = 390, x = 0.7371, y = 0.4248, type = "raid", comment = "Siege of Orgrimmar" },
        { id = 385, mapID = 525, x = 0.4992, y = 0.2480, type = "dungeon", comment = "Blackmaul Slag Mines" },
        { id = 457, mapID = 543, x = 0.5156, y = 0.2719, type = "raid", comment = "Blackrock Foundry" },
        { id = 476, mapID = 542, x = 0.3558, y = 0.3361, type = "dungeon", comment = "Skyreach" },
        { id = 477, mapID = 550, x = 0.3296, y = 0.3837, type = "raid", comment = "Highmaul" },
        { id = 536, mapID = 543, x = 0.5515, y = 0.3173, type = "dungeon", comment = "Grimrail Depot" },
        { id = 537, mapID = 539, x = 0.3186, y = 0.4255, type = "dungeon", comment = "Shadowmoon Burial Grounds" },
        { id = 547, mapID = 535, x = 0.4629, y = 0.7394, type = "dungeon", comment = "Auchindoun" },
        { id = 556, mapID = 543, x = 0.5957, y = 0.4566, type = "dungeon", comment = "The Everbloom" },
        { id = 558, mapID = 543, x = 0.4541, y = 0.1353, type = "dungeon", comment = "Iron Docks" },
        { id = 559, mapID = 33, x = 0.7903, y = 0.3379, type = "dungeon", comment = "Upper Blackrock Spire" },
        { id = 669, mapID = 534, x = 0.4696, y = 0.5264, type = "raid", comment = "Hellfire Citadel" },
        { id = 707, mapID = 630, x = 0.4806, y = 0.8212, type = "dungeon", comment = "Vault of the Wardens" },
        { id = 716, mapID = 630, x = 0.6116, y = 0.4111, type = "dungeon", comment = "Eye of Azshara" },
        { id = 721, mapID = 634, x = 0.7264, y = 0.7049, type = "dungeon", comment = "Halls of Valor" },
        { id = 726, mapID = 680, x = 0.4116, y = 0.6150, type = "dungeon", comment = "The Arcway" },
        { id = 727, mapID = 634, x = 0.5247, y = 0.4544, type = "dungeon", comment = "Maw of Souls" },
        { id = 740, mapID = 641, x = 0.3721, y = 0.5031, type = "dungeon", comment = "Black Rook Hold" },
        { id = 741, mapID = 35, x = 0.5377, y = 0.8131, type = "raid", comment = "Molten Core" },
        { id = 742, mapID = 33, x = 0.6401, y = 0.7153, type = "raid", comment = "Blackwing Lair" },
        { id = 743, mapID = 81, x = 0.3644, y = 0.9403, type = "raid", comment = "Ruins of Ahn'Qiraj" },
        { id = 744, mapID = 81, x = 0.2432, y = 0.8729, type = "raid", comment = "Temple of Ahn'Qiraj" },
        { id = 745, mapID = 42, x = 0.4698, y = 0.7490, type = "raid", comment = "Karazhan" },
        { id = 746, mapID = 105, x = 0.6906, y = 0.2414, type = "raid", comment = "Gruul's Lair" },
        { id = 747, mapID = 100, x = 0.4657, y = 0.5283, type = "raid", comment = "Magtheridon's Lair" },
        { id = 748, mapID = 102, x = 0.5190, y = 0.3348, type = "raid", comment = "Serpentshrine Cavern" },
        { id = 749, mapID = 109, x = 0.7359, y = 0.6372, type = "raid", comment = "The Eye" },
        { id = 750, mapID = 75, x = 0.3960, y = 0.1704, type = "raid", comment = "The Battle of Mount Hyjal" },
        { id = 751, mapID = 104, x = 0.7105, y = 0.4628, type = "raid", comment = "Black Temple" },
        { id = 752, mapID = 122, x = 0.4426, y = 0.4560, type = "raid", comment = "Sunwell Plateau" },
        { id = 753, mapID = 123, x = 0.5004, y = 0.1168, type = "raid", comment = "Vault of Archavon" },
        { id = 754, mapID = 115, x = 0.8734, y = 0.5100, type = "raid", comment = "Naxxramas" },
        { id = 755, mapID = 115, x = 0.6000, y = 0.5701, type = "raid", comment = "The Obsidian Sanctum" },
        { id = 756, mapID = 114, x = 0.2752, y = 0.2673, type = "raid", comment = "The Eye of Eternity" },
        { id = 757, mapID = 118, x = 0.7516, y = 0.2180, type = "raid", comment = "Trial of the Crusader" },
        { id = 758, mapID = 118, x = 0.5380, y = 0.8709, type = "raid", comment = "TIcecrown Citadel" },
        { id = 759, mapID = 120, x = 0.4157, y = 0.1779, type = "raid", comment = "Ulduar" },
        { id = 760, mapID = 70, x = 0.5221, y = 0.7593, type = "raid", comment = "Onyxias Lair" },
        { id = 761, mapID = 115, x = 0.6134, y = 0.5259, type = "raid", comment = "The Ruby Sanctum" },
        { id = 762, mapID = 641, x = 0.5913, y = 0.3135, type = "dungeon", comment = "Darkheart Thicket" },
        { id = 767, mapID = 650, x = 0.4956, y = 0.6854, type = "dungeon", comment = "Neltharion's Lair" },
        { id = 768, mapID = 641, x = 0.5667, y = 0.3747, type = "raid", comment = "The Emerald Nightmare" },
        { id = 777, mapID = 627, x = 0.6557, y = 0.6738, type = "dungeon", comment = "Assault on Violet Hold" },
        { id = 786, mapID = 680, x = 0.4414, y = 0.5979, type = "raid", comment = "The Nighthold" },
        { id = 800, mapID = 680, x = 0.5076, y = 0.6553, type = "dungeon", comment = "Court of Stars" },
        { id = 860, mapID = 42, x = 0.4686, y = 0.6979, type = "dungeon", comment = "Return to Karazhan" },
        { id = 861, mapID = 634, x = 0.7112, y = 0.7281, type = "raid", comment = "Trial of Valor" },
        { id = 875, mapID = 646, x = 0.6400, y = 0.2136, type = "raid", comment = "Tomb of Sargeras" },
        { id = 900, mapID = 646, x = 0.6481, y = 0.1675, type = "dungeon", comment = "Cathedral of Eternal Night" },
        { id = 945, mapID = 882, x = 0.2216, y = 0.5661, type = "dungeon", comment = "Seat of the Triumvirate" },
        { id = 946, mapID = 885, x = 0.5482, y = 0.6253, type = "raid", comment = "Antorus, the Burning Throne" },
        { id = 968, mapID = 862, x = 0.4353, y = 0.3948, type = "dungeon", comment = "Atal'Dazar" },
        { id = 1001, mapID = 895, x = 0.8456, y = 0.7878, type = "dungeon", comment = "Freehold" },
        { id = 1002, mapID = 1169, x = 0.3892, y = 0.6976, type = "dungeon", comment = "Tol Dagor" },
        { id = 1012, mapID = 862, x = 0.5610, y = 0.5984, type = "dungeon", comment = "The Motherlode" },
        { id = 1021, mapID = 896, x = 0.3367, y = 0.1253, type = "dungeon", comment = "Waycrest Manor" },
        { id = 1022, mapID = 863, x = 0.5125, y = 0.6464, type = "dungeon", comment = "The Underrot" },
        { id = 1023, mapID = 895, x = 0.7563, y = 0.2450, type = "dungeon", comment = "Siege of Boralus" },
        { id = 1030, mapID = 864, x = 0.5192, y = 0.2546, type = "dungeon", comment = "Temple of Sethraliss" },
        { id = 1031, mapID = 863, x = 0.5414, y = 0.6302, type = "raid", comment = "Uldir" },
        { id = 1036, mapID = 942, x = 0.7859, y = 0.2663, type = "dungeon", comment = "Shrine of Storm" },
        { id = 1041, mapID = 862, x = 0.3759, y = 0.3948, type = "dungeon", comment = "Kings' Rest" },
        { id = 1176, mapID = 862, x = 0.5426, y = 0.2993, type = "raid", comment = "Battle of Dazar'alor" },
        { id = 1177, mapID = 942, x = 0.8389, y = 0.4693, type = "raid", comment = "Crucible of Storms" },
        { id = 1178, mapID = 1462, x = 0.7293, y = 0.3649, type = "dungeon", comment = "Operation: Mechagon" },
        { id = 1179, mapID = 1355, x = 0.5034, y = 0.1233, type = "raid", comment = "The Eternal Palace" },
        { id = 1180, mapID = 1527, x = 0.5518, y = 0.4395, type = "raid", comment = "Ny'alotha the Waking City" },
        { id = 1182, mapID = 1533, x = 0.4014, y = 0.5521, type = "dungeon", comment = "The Necrotic Wake" },
        { id = 1183, mapID = 1536, x = 0.5939, y = 0.6501, type = "dungeon", comment = "Plaguefall" },
        { id = 1184, mapID = 1565, x = 0.3548, y = 0.5413, type = "dungeon", comment = "Mists of Tirna Scithe" },
        { id = 1185, mapID = 1525, x = 0.7847, y = 0.4907, type = "dungeon", comment = "Halls of Atonement" },
        { id = 1186, mapID = 1533, x = 0.5855, y = 0.2857, type = "dungeon", comment = "Spires of Ascension" },
        { id = 1187, mapID = 1536, x = 0.5311, y = 0.5291, type = "dungeon", comment = "Theater of Pain" },
        { id = 1188, mapID = 1565, x = 0.6866, y = 0.6660, type = "dungeon", comment = "De Other Side" },
        { id = 1189, mapID = 1525, x = 0.5107, y = 0.3012, type = "dungeon", comment = "Sanguine Depths" },
        { id = 1190, mapID = 1525, x = 0.4642, y = 0.4149, type = "raid", comment = "Castle Nathria" },
        { id = 1193, mapID = 1543, x = 0.6974, y = 0.3201, type = "raid", comment = "Sanctum of Domination" },
        { id = 1194, mapID = 2371, x = 0.6358, y = 0.7021, type = "dungeon", comment = "Tazavesh, the Veiled Market" },
        { id = 1195, mapID = 1970, x = 0.8049, y = 0.5340, type = "raid", comment = "Sepulcher of the First Ones" },
        { id = 1196, mapID = 2024, x = 0.1151, y = 0.4885, type = "dungeon", comment = "Brackenhide Hollow" },
        { id = 1197, mapID = 15, x = 0.4112, y = 0.1030, type = "dungeon", comment = "Uldaman: Legacy of Tyr" },
        { id = 1198, mapID = 2023, x = 0.6084, y = 0.3898, type = "dungeon", comment = "The Nokhud Offensive" },
        { id = 1199, mapID = 2022, x = 0.2571, y = 0.5631, type = "dungeon", comment = "Neltharus" },
        { id = 1200, mapID = 2025, x = 0.7485, y = 0.5511, type = "raid", comment = "Vault of the Incarnates" },
        { id = 1201, mapID = 2025, x = 0.5827, y = 0.4235, type = "dungeon", comment = "Algeth'ar Academy" },
        { id = 1202, mapID = 2022, x = 0.6008, y = 0.7571, type = "dungeon", comment = "Ruby Life Pools" },
        { id = 1203, mapID = 2024, x = 0.3889, y = 0.6459, type = "dungeon", comment = "The Azure Vault" },
        { id = 1204, mapID = 2025, x = 0.5921, y = 0.6057, type = "dungeon", comment = "Halls of Infusion" },
        { id = 1207, mapID = 2200, x = 0.2731, y = 0.3104, type = "raid", comment = "Amirdrassil, the Dream's Hope" },
        { id = 1208, mapID = 2133, x = 0.4845, y = 0.1191, type = "raid", comment = "Aberrus, the Shadowed Crucible" },
        { id = 1209, mapID = 2025, x = 0.6114, y = 0.8446, type = "dungeon", comment = "Dawn of the Infinite" },
        { id = 1210, mapID = 2214, x = 0.5545, y = 0.2162, type = "dungeon", comment = "Darkflame Cleft" },
        { id = 1267, mapID = 2215, x = 0.4132, y = 0.4933, type = "dungeon", comment = "Priory of the Sacred Flame" },
        { id = 1268, mapID = 2248, x = 0.4523, y = 0.4108, type = "dungeon", comment = "The Rookery" },
        { id = 1269, mapID = 2214, x = 0.4270, y = 0.0856, type = "dungeon", comment = "The Stonevault" },
        { id = 1270, mapID = 2215, x = 0.5490, y = 0.6313, type = "dungeon", comment = "The Dawnbreaker" },
        { id = 1271, mapID = 2255, x = 0.4953, y = 0.8100, type = "dungeon", comment = "Ara-Kara, City of Echoes" },
        { id = 1272, mapID = 2248, x = 0.7658, y = 0.4378, type = "dungeon", comment = "Cinderbrew Meadery" },
        { id = 1273, mapID = 2255, x = 0.4355, y = 0.9029, type = "raid", comment = "Nerub-ar Palace" },
        { id = 1274, mapID = 2255, x = 0.4674, y = 0.6917, type = "dungeon", comment = "City of Threads" },
        { id = 1276, mapID = 69, x = 0.7645, y = 0.3593, type = "dungeon", comment = "Dire Maul - Warpwood Quarter - East above Camp Mojache -- only Minimap" },
        { id = 1277, mapID = 69, x = 0.6250, y = 0.2490, type = "dungeon", comment = "Dire Maul - Gordok Commons - North" },
        { id = 1292, mapID = 23, x = 0.4325, y = 0.1854, type = "dungeon", comment = "Stratholme Service Entrance" },
        { id = 1296, mapID = 2346, x = 0.4204, y = 0.5031, type = "raid", comment = "Liberation of Undermine" },
        { id = 1298, mapID = 2214, x = 0.4208, y = 0.3948, type = "dungeon", comment = "Operation: Floodgate" },
        { id = 1299, mapID = 2395, x = 0.3545, y = 0.7882, type = "dungeon", comment = "Windrunner Spire" },
        { id = 1300, mapID = 2424, x = 0.6346, y = 0.1538, type = "dungeon", comment = "Magisters' Terrace" },
        { id = 1302, mapID = 2371, x = 0.4166, y = 0.2152, type = "raid", comment = "Manaforge Omega" },
        { id = 1303, mapID = 2371, x = 0.6524, y = 0.6841, type = "dungeon", comment = "Eco-Dome Al'dani" },
        { id = 1304, mapID = 2395, x = 0.5400, y = 0.2432, type = "dungeon", comment = "Murder Row" },
        { id = 1305, mapID = 2413, x = 0.7355, y = 0.6635, type = "raid", comment = "Sporefall" },
        { id = 1307, mapID = 2405, x = 0.4524, y = 0.6483, type = "raid", comment = "The Voidspire" },
        { id = 1308, mapID = 2424, x = 0.5260, y = 0.8529, type = "raid", comment = "March on Quel'Danas" },
        { id = 1309, mapID = 2413, x = 0.2646, y = 0.7804, type = "dungeon", comment = "The Blinding Vale" },
        { id = 1311, mapID = 2437, x = 0.2983, y = 0.8450, type = "dungeon", comment = "Den of Nalorakk" },
        { id = 1313, mapID = 2405, x = 0.5166, y = 0.1874, type = "dungeon", comment = "Voidscar Arena" },
        { id = 1314, mapID = 2413, x = 0.6138, y = 0.6289, type = "raid", comment = "The Dreamrift" },
        { id = 1315, mapID = 2437, x = 0.4383, y = 0.3950, type = "dungeon", comment = "Maisara Caverns" },
        { id = 1316, mapID = 2405, x = 0.6497, y = 0.6178, type = "dungeon", comment = "Nexus Point Xenas" },
        { id = 1320, mapID = 2509, x = 0.4723, y = 0.2286, type = "raid", comment = "The Toxic Abyss" },
        { id = 1322, mapID = 2509, x = 0.4724, y = 0.6812, type = "dungeon", comment = "Altar of Fangs" },
        { id = 1324, mapID = 2613, x = 0.7426, y = 0.0591, type = "raid", comment = "The Unbinding of Kith'ix" },
        { id = 2249, mapID = 2248, x = 0.5252, y = 0.6626, type = "delve", comment = "Fungal Folly" },
        { id = 2250, mapID = 2248, x = 0.6164, y = 0.4271, type = "delve", comment = "Kriegval's Rest" },
        { id = 2251, mapID = 2214, x = 0.4611, y = 0.4791, type = "delve", comment = "The Waterworks" },
        { id = 2259, mapID = 2255, x = 0.5491, y = 0.7231, type = "delve", comment = "Tak-Rethan Abyss" },
        { id = 2269, mapID = 2248, x = 0.3890, y = 0.7328, type = "delve", comment = "Earthcrawl Mines" },
        { id = 2277, mapID = 2215, x = 0.3532, y = 0.4593, type = "delve", comment = "Nightfall Sanctum" },
        { id = 2299, mapID = 2255, x = 0.5185, y = 0.8822, type = "delve", comment = "The Underkeep" },
        { id = 2301, mapID = 2215, x = 0.5071, y = 0.5050, type = "delve", comment = "The Sinkhole" },
        { id = 2302, mapID = 2214, x = 0.6940, y = 0.3862, type = "delve", comment = "The Dread Pit" },
        { id = 2310, mapID = 2215, x = 0.6671, y = 0.6170, type = "delve", comment = "Skittering Breach" },
        { id = 2312, mapID = 2215, x = 0.7064, y = 0.3095, type = "delve", comment = "Mycomancer Cavern" },
        { id = 2347, mapID = 2255, x = 0.4573, y = 0.2253, type = "delve", comment = "The Spiral Weave" },
        { id = 2348, mapID = 2214, x = 0.3275, y = 0.7683, type = "delve", comment = "Zekvir's Lair" },
        { id = 2396, mapID = 2346, x = 0.6380, y = 0.6540, type = "delve", comment = "Excavation Site 9" },
        { id = 2423, mapID = 2346, x = 0.4892, y = 0.6758, type = "delve", comment = "Sidestreet Sluice" },
        { id = 2425, mapID = 2346, x = 0.5387, y = 0.0930, type = "delve", comment = "Demolition Dome" },
        { id = 2452, mapID = 2371, x = 0.3924, y = 0.8845, type = "delve", comment = "Archival Assault" },
        { id = 2484, mapID = 2472, x = 0.5380, y = 0.8881, type = "delve", comment = "Voidscar Cavern" },
        { id = 2502, mapID = 2395, x = 0.4555, y = 0.8631, type = "delve", comment = "Shadow Enclave" },
        { id = 2503, mapID = 2437, x = 0.2540, y = 0.8440, type = "delve", comment = "Twilight Crypts" },
        { id = 2505, mapID = 2413, x = 0.3670, y = 0.4960, type = "delve", comment = "The Gulf of Memory" },
        { id = 2506, mapID = 2405, x = 0.3710, y = 0.4910, type = "delve", comment = "Shadowguard Point" },
        { id = 2510, mapID = 2413, x = 0.6733, y = 0.5710, type = "delve", comment = "The Grudge Pit" },
        { id = 2525, mapID = 2393, x = 0.3931, y = 0.3207, type = "delve", comment = "The Darkway" },
        { id = 2528, mapID = 2405, x = 0.5480, y = 0.4710, type = "delve", comment = "Sunkiller Sanctum" },
        { id = 2535, mapID = 2437, x = 0.6370, y = 0.8010, type = "delve", comment = "Atal'Aman" },
        { id = 2545, mapID = 2424, x = 0.4774, y = 0.4158, type = "delve", comment = "Parhelion Plaza" },
        { id = 2547, mapID = 2393, x = 0.4076, y = 0.5406, type = "delve", comment = "Collegiate Calamity" },
        { id = 2633, mapID = 2512, x = 0.7120, y = 0.5654, type = "delve", comment = "The Ring of Glory" },
        { id = 2635, mapID = 2512, x = 0.6445, y = 0.7773, type = "delve", comment = "Gnarldor Isle" },
        { id = 2647, mapID = 2395, x = 0.6305, y = 0.7230, type = "delve", comment = "The Labyrinth of Kindo'jan" },
    },

    -- Transport graph: portals, zeppelins, ships, mirrors and other connecting edges
    transports = {
        { from = 1, to = 85, x = 0.4578, y = 0.0744, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Orgrimmar .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Silvermoon .. " (" .. EXPANSION_NAME1 ..")" .."\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Zuldazar .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.DarkPortal .. "\n" .. " ==> " .. ns.Dornogal .. "\n" .. " ==> " .. ns.Silvermoon .. " (" .. EXPANSION_NAME11 ..")" .. "\n" .. " ==> " .. ns.RazorwindShores .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.TolBarad .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Gromgol .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1
        { from = 1, to = 210, x = 0.3529, y = 0.7954, type = "SHIP", faction = "NEUTRAL" }, -- note: POSTMASTER_LETTER_STRANGLETHORNVALE .. " (" .. L["Ship"] ..")"
        { from = 1, to = 862, x = 0.7205, y = 0.7924, type = "SHIP", faction = "HORDE" }, -- note: Ship from Echo Isles to Zuldazar
        { from = 1, to = 2022, x = 0.5598, y = 0.1320, type = "ZEPPELIN", faction = "HORDE" }, -- note: Zeppelin from Orgrimmar to Waking Shores
        { from = 7, to = 85, x = 0.3342, y = 0.2231, type = "ZEPPELIN", faction = "HORDE" }, -- note: Zeppelin from Thunder Bluff to Orgrimmar
        { from = 7, to = 407, x = 0.3600, y = 0.3600, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"]
        { from = 10, to = 11, x = 0.3891, y = 0.6921, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Way to the Instance Entrance"]
        { from = 10, to = 85, x = 0.8045, y = 0.0975, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Orgrimmar .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Silvermoon .. " (" .. EXPANSION_NAME1 ..")" .. "\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Zuldazar .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.DarkPortal .. "\n" .. " ==> " .. ns.Dornogal .. "\n" .. " ==> " .. ns.Silvermoon .. " (" .. EXPANSION_NAME11 ..")" .. "\n" .. " ==> " .. ns.RazorwindShores .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.TolBarad .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Gromgol .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1
        { from = 10, to = 199, x = 0.3022, y = 0.5472, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53600 },
        { from = 10, to = 210, x = 0.7015, y = 0.7324, type = "SHIP", faction = "NEUTRAL" }, -- note: POSTMASTER_LETTER_STRANGLETHORNVALE .. " (" .. L["Ship"] ..")"
        { from = 10, to = 825, x = 0.3877, y = 0.6816, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Wailing Caverns
        { from = 10, to = 2022, x = 0.8919, y = 0.1220, type = "ZEPPELIN", faction = "HORDE" }, -- note: Zeppelin from Orgrimmar to Waking Shores
        { from = 11, to = 825, x = 0.2351, y = 0.8124, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Wailing Caverns
        { from = 12, to = 78, x = 0.5016, y = 0.7999, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53591 },
        { from = 12, to = 198, x = 0.5549, y = 0.3360, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53601 },
        { from = 12, to = 199, x = 0.5063, y = 0.5103, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53600 },
        { from = 13, to = 17, x = 0.5314, y = 0.8130, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53594 },
        { from = 13, to = 26, x = 0.4978, y = 0.4019, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53585 },
        { from = 13, to = 27, x = 0.4665, y = 0.6008, type = "MOLE_MACHINE", faction = "NEUTRAL" },
        { from = 13, to = 35, x = 0.4731, y = 0.6924, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53587 },
        { from = 13, to = 84, x = 0.4309, y = 0.7191, type = "MOLE_MACHINE", faction = "NEUTRAL" },
        { from = 14, to = 862, x = 0.2744, y = 0.2938, type = "PORTAL", faction = "HORDE" }, -- note: ns.Zandalar.. " (" .. L["Portal"] ..")\n\n(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")"
        { from = 14, to = 1161, x = 0.2224, y = 0.6515, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.Boralus.. " (" .. L["Portal"] ..")\n\n(" .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"] .. ")"
        { from = 17, to = 84, x = 0.6638, y = 0.2798, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.Stormwind .. " (" .. L["Portal"] ..")\n\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"]
        { from = 17, to = 85, x = 0.7269, y = 0.4917, type = "PORTAL", faction = "HORDE" }, -- note: ns.Orgrimmar .. " (" .. L["Portal"] ..")\n\n" .. L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"]
        { from = 17, to = 622, x = 0.5500, y = 0.5418, type = "PORTAL", faction = "NEUTRAL" }, -- note: ns.DarkPortal .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Warspear .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormshield
        { from = 17, to = 624, x = 0.5500, y = 0.5418, type = "PORTAL", faction = "NEUTRAL" }, -- note: ns.DarkPortal .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Warspear .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormshield
        { from = 18, to = 19, x = 0.8233, y = 0.3243, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Scarlet Monastery Key for Old dungeons
        { from = 18, to = 50, x = 0.6190, y = 0.5899, type = "PORTAL", faction = "HORDE" }, -- note: ns.Gromgol .. " (" .. L["Portal"] ..")"
        { from = 18, to = 85, x = 0.6073, y = 0.5867, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Orgrimmar from Tirisfal
        { from = 18, to = 90, x = 0.6216, y = 0.7276, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Undercity .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.HellfirePeninsula
        { from = 18, to = 90, x = 0.6216, y = 0.7276, type = "PORTAL", faction = "HORDE" }, -- note: ns.HellfirePeninsula .. " (" .. L["Portal"] ..")"
        { from = 18, to = 110, x = 0.5941, y = 0.6744, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Silvermoon from Tirisfal
        { from = 18, to = 117, x = 0.5908, y = 0.5891, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Howling Fjord from Tirisfal
        { from = 18, to = 302, x = 0.8476, y = 0.3039, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Scarlet Monastery - Graveyard
        { from = 18, to = 303, x = 0.8515, y = 0.3180, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Scarlet Monastery - Library
        { from = 18, to = 304, x = 0.8535, y = 0.3028, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Scarlet Monastery - Cathedral
        { from = 18, to = 304, x = 0.8557, y = 0.3138, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Scarlet Monastery - Armory
        { from = 19, to = 302, x = 0.6883, y = 0.2372, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Scarlet Monastery - Graveyard
        { from = 19, to = 303, x = 0.7825, y = 0.5762, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Scarlet Monastery -"
        { from = 19, to = 304, x = 0.7888, y = 0.2223, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Scarlet Monastery - Cathedral"
        { from = 19, to = 304, x = 0.8641, y = 0.4766, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Scarlet Mona"
        { from = 22, to = 306, x = 0.6976, y = 0.7181, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Old Scholomance version - Memory of Scholomance - Secret Entrance Old Scholomance version
        { from = 23, to = 24, x = 0.7534, y = 0.5252, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_PALADIN .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Paladin"]
        { from = 23, to = 166, x = 0.3572, y = 0.2308, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Old Naxxramas version - Secret Entrance - Wards of the Dread Citadel
        { from = 23, to = 1505, x = 0.4314, y = 0.1993, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Stratholme
        { from = 24, to = 23, x = 0.3957, y = 0.9315, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Paladin
        { from = 24, to = 627, x = 0.3760, y = 0.6406, type = "PORTAL", faction = "NEUTRAL" }, -- note: Paladin - Dalaran
        { from = 27, to = 30, x = 0.2990, y = 0.3684, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Gnomeregan
        { from = 27, to = 30, x = 0.3139, y = 0.3804, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Gnomeregan
        { from = 27, to = 87, x = 0.5973, y = 0.2929, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Ironforge .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. ns.Stormwind .. " " .. ns.Deepruntram
        { from = 30, to = 840, x = 0.3139, y = 0.7107, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Gnomeregan
        { from = 32, to = 33, x = 0.3526, y = 0.8404, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Molten Core, Blackwing Lair, Blackrock Caverns, Blackrock Depths, Lower Blackrock Spire, Upper Blackrock Spire
        { from = 32, to = 35, x = 0.3408, y = 0.8561, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53587 },
        { from = 33, to = 34, x = 0.6589, y = 0.6169, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Blackrock Caverns
        { from = 33, to = 34, x = 0.6863, y = 0.5371, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Blackrock Caverns
        { from = 33, to = 35, x = 0.4347, y = 0.4334, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53587 },
        { from = 33, to = 35, x = 0.4500, y = 0.4700, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Blackrock Deeps
        { from = 34, to = 33, x = 0.5879, y = 0.2725, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Blackrock Depths
        { from = 35, to = 33, x = 0.5816, y = 0.8728, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Blackrock Depths
        { from = 35, to = 1578, x = 0.3308, y = 0.2315, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Blackrock Deeps
        { from = 36, to = 33, x = 0.2064, y = 0.3322, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Blackrock Deeps
        { from = 36, to = 35, x = 0.2051, y = 0.3029, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53587 },
        { from = 37, to = 84, x = 0.1515, y = 0.3165, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.Stormwind .. " " .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Ashran .. "\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Boralus .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.JadeForest .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.Exodar .. "\n" .. " ==> " .. ns.Amirdrassil
        { from = 37, to = 84, x = 0.2959, y = 0.2388, type = "TRAM", faction = "NEUTRAL" }, -- note: ns.Ironforge .. " " .. ns.Deepruntram
        { from = 37, to = 84, x = 0.3289, y = 0.4742, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Stormwind .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Ashran .. "\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Boralus .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.JadeForest .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.Exodar .. "\n" .. " ==> " .. ns.Amirdrassil .. "\n" .. " ==> " .. ns.DarkPortal .. "\n" .. " ==> " .. ns.Dornogal .. "\n" .." ==> " .. ns.Silvermoon .. " (" .. EXPANSION_NAME11 ..")" .. "\n" .. " ==> " .. ns.FoundersPoint .. "\n" .. "\n" .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ns.TolBarad .. "\n" .. "\n" .. L["Ships"] .. "\n" .. " ==> " .. POSTMASTER_LETTER_VALIANCEKEEP .. "\n" .. " ==> " .. ns.Boralus .. "\n" .. " ==> " .. ns.TheWakingShores .. "\n" .. "\n" .. ns.Deepruntram .. "\n" .. " ==> " .. ns.Ironforge .. "\n" .. "\n" .. " ==> " .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_THESTOCKADE1
        { from = 37, to = 84, x = 0.3352, y = 0.1611, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.Stormwind .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ns.TolBarad
        { from = 37, to = 114, x = 0.0762, y = 0.2435, type = "SHIP", faction = "ALLIANCE" }, -- note: POSTMASTER_LETTER_VALIANCEKEEP .. " (" .. L["Ship"] ..")"
        { from = 37, to = 407, x = 0.4178, y = 0.6951, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: "\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"]
        { from = 37, to = 1161, x = 0.0872, y = 0.2976, type = "SHIP", faction = "ALLIANCE" }, -- note: L["Ships"] .. "\n" .. " ==> " .. ns.Boralus .. "\n".. " ==> " .. ns.TheWakingShores
        { from = 50, to = 18, x = 0.3754, y = 0.5100, type = "PORTAL", faction = "HORDE" }, -- note: ns.RuinsofLordaeron .. " (" .. L["Portal"] ..")"
        { from = 50, to = 85, x = 0.3695, y = 0.5279, type = "ZEPPELIN", faction = "HORDE" }, -- note: Ship from Booty Bay to Ratchet
        { from = 52, to = 55, x = 0.4252, y = 0.7168, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Deadmines
        { from = 52, to = 835, x = 0.4156, y = 0.7113, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Deadmines
        { from = 56, to = 70, x = 0.0636, y = 0.6226, type = "SHIP", faction = "ALLIANCE" }, -- note: ns.TheramoreIsle .. " (" .. L["Ship"] ..")"
        { from = 56, to = 117, x = 0.0417, y = 0.5637, type = "SHIP", faction = "ALLIANCE" }, -- note: Ship from Wettlands to Howling Fjord
        { from = 57, to = 84, x = 0.5503, y = 0.9371, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal To Stormwind from Teldrassil
        { from = 57, to = 89, x = 0.2630, y = 0.5072, type = "PORTAL", faction = "NEUTRAL" }, -- note: ns.Ruttheran .. " (" .. L["Portal"] ..")"
        { from = 57, to = 89, x = 0.2630, y = 0.5072, type = "PORTAL", faction = "ALLIANCE" }, -- note: L["Portals"] .. "\n" .. " ==> " .. ns.Ruttheran .. "\n" .. " ==> " .. ns.Exodar .. "\n" .. " ==> " .. ns.HellfirePeninsula
        { from = 57, to = 89, x = 0.5499, y = 0.8820, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal To Darnassus from Teldrassil
        { from = 57, to = 97, x = 0.5227, y = 0.8948, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal To Exodar from Teldrassil
        { from = 62, to = 862, x = 0.4624, y = 0.3511, type = "PORTAL", faction = "HORDE" }, -- note: ns.Zuldazar .. " (" .. L["Portal"] ..")\n\n" .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"]
        { from = 62, to = 1161, x = 0.4802, y = 0.3628, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.Boralus .. " (" .. L["Portal"] ..")\n\n" .. L["(its only shown up ingame if your faction\n is currently occupying Bashal'Aran)"]
        { from = 62, to = 2239, x = 0.5373, y = 0.1873, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from New Darkshore to Bel'ameth, Amirdrassil
        { from = 70, to = 56, x = 0.7154, y = 0.5615, type = "SHIP", faction = "ALLIANCE" }, -- note: Ship from Dustwallow Marsh to Wetlands
        { from = 71, to = 75, x = 0.6457, y = 0.4742, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 71, to = 75, x = 0.6486, y = 0.4997, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
        { from = 71, to = 84, x = 0.6598, y = 0.4960, type = "PORTAL", faction = "ALLIANCE" }, -- note: L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormwind
        { from = 71, to = 85, x = 0.6598, y = 0.4960, type = "PORTAL", faction = "HORDE" }, -- note: L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormwind
        { from = 74, to = 75, x = 0.3085, y = 0.7356, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Dragon Soul, The Battle for Mount Hyjal, The Culling of Stratholme, Black Morass, Old Hillsbrad Foothills, End Time, Well of Eternity, Hour of Twilight Heroic
        { from = 74, to = 84, x = 0.5814, y = 0.2669, type = "PORTAL", faction = "ALLIANCE" }, -- note: L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormwind
        { from = 74, to = 85, x = 0.5814, y = 0.2669, type = "PORTAL", faction = "HORDE" }, -- note: L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormwind
        { from = 76, to = 85, x = 0.2128, y = 0.8964, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Orgrimmar .. " - " .. FACTION_HORDE .. "\n" .. "\n" .. L["Portalroom"] .. "\n" .. " ==> " .. ns.Silvermoon .. " (" .. EXPANSION_NAME1 ..")" .. "\n" .. " ==> " .. ns.Valdrakken .. "\n" .. " ==> " .. ns.Oribos .. "\n" .. " ==> " .. ns.Azsuna .. "\n" .. " ==> " .. ns.Zuldazar .. "\n" .. " ==> " .. ns.Shattrath .. "\n" .. " ==> " .. ns.Dalaran .. "\n" .. " ==> " .. ns.CavernsOfTime .. "\n" .. " ==> " .. ns.DarkPortal .. "\n" .. " ==> " .. ns.Dornogal .. "\n" .. " ==> " .. ns.Silvermoon .. " (" .. EXPANSION_NAME11 ..")" .. "\n" .. " ==> " .. ns.RazorwindShores .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Hyjal .. "\n" .. " ==> " .. ns.TwilightHighlands .. "\n" .. " ==> " .. ARTIFACT_SHAMAN_TITLECARD_DEEPHOLM .. "\n" .. " ==> " .. ns.Vashjir .. "\n" .. " ==> " .. ns.Uldum .. "\n" .. " ==> " .. ns.TolBarad .. "\n" .. "\n" .. L["Zeppelins"] .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Gromgol .. "\n" .. " ==> " .. POSTMASTER_LETTER_WARSONGHOLD .. "\n" .. "\n" .. CALENDAR_TYPE_DUNGEON .. "\n" .. " ==> " .. DUNGEON_FLOOR_RAGEFIRE1
        { from = 78, to = 119, x = 0.5056, y = 0.0773, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal Unguro to Sholazar
        { from = 81, to = 862, x = 0.4161, y = 0.4520, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal from Silithus to Zandalar or Boralus
        { from = 81, to = 1161, x = 0.4161, y = 0.4520, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal from Silithus to Zandalar or Boralus
        { from = 81, to = 1473, x = 0.4321, y = 0.4449, type = "PORTAL", faction = "NEUTRAL" }, -- note: "\n" ..L["If you don't see this icon, it's probably in a different phase. \nChange the phase on Zidormi"]
        { from = 84, to = 17, x = 0.4911, y = 0.8734, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.DarkPortal .. "\n" .. "( " .. L["talk to"] .. ": " .. ns.HonorHoldMage .. " )"
        { from = 84, to = 37, x = 0.7339, y = 0.9051, type = "TRANSPORT", faction = "ALLIANCE" }, -- note: Passage/Exit
        { from = 84, to = 74, x = 0.4374, y = 0.8538, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Caverns of Time
        { from = 84, to = 89, x = 0.2386, y = 0.5611, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Darnassus
        { from = 84, to = 103, x = 0.4363, y = 0.8719, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Exodar
        { from = 84, to = 111, x = 0.4488, y = 0.8577, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Shattrath
        { from = 84, to = 114, x = 0.1812, y = 0.2555, type = "SHIP", faction = "ALLIANCE" }, -- note: POSTMASTER_LETTER_VALIANCEKEEP .. " (" .. L["Ship"] ..")"
        { from = 84, to = 125, x = 0.4438, y = 0.8868, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Dalaran
        { from = 84, to = 198, x = 0.7621, y = 0.1869, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Hyjal
        { from = 84, to = 203, x = 0.7330, y = 0.1687, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Vashjir
        { from = 84, to = 207, x = 0.7317, y = 0.1966, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Deepholm
        { from = 84, to = 241, x = 0.7535, y = 0.1649, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Twilight Highlands
        { from = 84, to = 245, x = 0.7322, y = 0.1836, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Tol Barad
        { from = 84, to = 371, x = 0.4570, y = 0.8715, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Jade Forest
        { from = 84, to = 407, x = 0.6204, y = 0.3235, type = "TRANSPORT", faction = "ALLIANCE" }, -- note: CALENDAR_FILTER_DARKMOON .. " (" .. L["Transport"] .. " / " .. L["Portal"] .. ")\n\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"]
        { from = 84, to = 407, x = 0.6319, y = 0.7339, type = "TRANSPORT", faction = "ALLIANCE" }, -- note: CALENDAR_FILTER_DARKMOON .. " (" .. L["Transport"] .. " / " .. L["Portal"] .. ")\n\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"]
        { from = 84, to = 499, x = 0.6678, y = 0.3455, type = "TRAM", faction = "ALLIANCE" }, -- note: ns.Deepruntram .. " - " .. ns.Ironforge
        { from = 84, to = 622, x = 0.4133, y = 0.8985, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Stormshield
        { from = 84, to = 630, x = 0.4207, y = 0.9135, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Azsuna
        { from = 84, to = 971, x = 0.5071, y = 0.0826, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Telogrus
        { from = 84, to = 1161, x = 0.2122, y = 0.5479, type = "SHIP", faction = "ALLIANCE" }, -- note: Ship from Stormwind to Boralus
        { from = 84, to = 1161, x = 0.4086, y = 0.9279, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Boralus
        { from = 84, to = 1527, x = 0.7523, y = 0.2055, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Uldum
        { from = 84, to = 1670, x = 0.4757, y = 0.9495, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Oribos
        { from = 84, to = 2022, x = 0.2203, y = 0.5670, type = "SHIP", faction = "ALLIANCE" }, -- note: Ship from Stormwind to Waking Shores
        { from = 84, to = 2112, x = 0.4884, y = 0.9344, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Valdrakken
        { from = 84, to = 2239, x = 0.4326, y = 0.9759, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Bel'ameth, Amirdrassil
        { from = 84, to = 2322, x = 0.5155, y = 0.1012, type = "PORTAL", faction = "ALLIANCE" }, -- note: Hall of Awakening
        { from = 84, to = 2339, x = 0.4811, y = 0.9195, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Dornogal
        { from = 84, to = 2352, x = 0.4690, y = 0.9335, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Founder's Point Housing
        { from = 84, to = 2393, x = 0.4875, y = 0.9519, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.Silvermoon .. " (" .. EXPANSION_NAME11 .. ") (" .. L["Portal"] ..")"
        { from = 85, to = 1, x = 0.4952, y = 0.9373, type = "TRANSPORT", faction = "HORDE" }, -- note: Passage/Exit
        { from = 85, to = 7, x = 0.4823, y = 0.6216, type = "TRANSPORT", faction = "HORDE" }, -- note: CALENDAR_FILTER_DARKMOON .. " (" .. L["Transport"] .. " / " .. L["Portal"] .. ")\n\n" .. REQUIRES_LABEL .. " " .. CALENDAR_FILTER_DARKMOON .. "\n" .. L["Starting on the first Sunday of each month for one week"]
        { from = 85, to = 10, x = 0.2018, y = 0.7080, type = "TRANSPORT", faction = "HORDE" }, -- note: Passage/Exit
        { from = 85, to = 17, x = 0.5717, y = 0.9070, type = "PORTAL", faction = "HORDE" }, -- note: ns.DarkPortal .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")"
        { from = 85, to = 18, x = 0.5076, y = 0.5561, type = "PORTAL", faction = "HORDE" }, -- note: ns.RuinsofLordaeron .. " (" .. L["Portal"] ..")"
        { from = 85, to = 50, x = 0.5237, y = 0.5330, type = "ZEPPELIN", faction = "HORDE" }, -- note: ns.Gromgol .. " (" .. L["Zeppelin"] ..")"
        { from = 85, to = 74, x = 0.5641, y = 0.9258, type = "PORTAL", faction = "HORDE" }, -- note: ns.CavernsOfTime .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")"
        { from = 85, to = 76, x = 0.7480, y = 0.0606, type = "TRANSPORT", faction = "HORDE" }, -- note: Passage/Exit
        { from = 85, to = 86, x = 0.4239, y = 0.6160, type = "TRANSPORT", faction = "HORDE" }, -- note: L["Way to the Instance Entrance"]
        { from = 85, to = 86, x = 0.4611, y = 0.6716, type = "TRANSPORT", faction = "HORDE" }, -- note: L["Way to the Instance Entrance"]
        { from = 85, to = 86, x = 0.5589, y = 0.5097, type = "TRANSPORT", faction = "HORDE" }, -- note: L["Way to the Instance Entrance"]
        { from = 85, to = 88, x = 0.4279, y = 0.6534, type = "ZEPPELIN", faction = "HORDE" }, -- note: Zeppelin from OG to Thunder Bluff
        { from = 85, to = 110, x = 0.5458, y = 0.9038, type = "PORTAL", faction = "HORDE" }, -- note: ns.Silvermoon .. " (" .. EXPANSION_NAME1 ..")" .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")"
        { from = 85, to = 111, x = 0.5751, y = 0.9166, type = "PORTAL", faction = "HORDE" }, -- note: ns.Shattrath .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")"
        { from = 85, to = 114, x = 0.4467, y = 0.6239, type = "ZEPPELIN", faction = "HORDE" }, -- note: POSTMASTER_LETTER_WARSONGHOLD .. " (" .. L["Zeppelin"] ..")"
        { from = 85, to = 125, x = 0.5621, y = 0.9180, type = "PORTAL", faction = "HORDE" }, -- note: ns.Dalaran .. " (" .. ns.Northrend .. " " .. L["Portal"] ..")"
        { from = 85, to = 198, x = 0.5120, y = 0.3832, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Hyjal
        { from = 85, to = 203, x = 0.4920, y = 0.3647, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Vashjir
        { from = 85, to = 207, x = 0.5086, y = 0.3628, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Deepholm
        { from = 85, to = 241, x = 0.5024, y = 0.3944, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Twilight Highlands
        { from = 85, to = 245, x = 0.4739, y = 0.3928, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Tol Barad
        { from = 85, to = 371, x = 0.5747, y = 0.9225, type = "PORTAL", faction = "HORDE" }, -- note: The Jade Forest
        { from = 85, to = 503, x = 0.7058, y = 0.3097, type = "TRANSPORT", faction = "HORDE" }, -- note: Portal to Shlae'gararena
        { from = 85, to = 624, x = 0.5518, y = 0.9204, type = "PORTAL", faction = "HORDE" }, -- note: ns.Warspear .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")"
        { from = 85, to = 630, x = 0.5726, y = 0.8817, type = "PORTAL", faction = "HORDE" }, -- note: ns.Azsuna .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")"
        { from = 85, to = 652, x = 0.3816, y = 0.7527, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Thundertotem
        { from = 85, to = 680, x = 0.3860, y = 0.7586, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Night Fortress
        { from = 85, to = 862, x = 0.5787, y = 0.8982, type = "PORTAL", faction = "HORDE" }, -- note: ns.Zuldazar .. " (" .. L["Portal"] .. ")\n(" .. L["in the basement"] .. ")"
        { from = 85, to = 1527, x = 0.4886, y = 0.3851, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Uldum
        { from = 85, to = 1670, x = 0.5830, y = 0.8788, type = "PORTAL", faction = "HORDE" }, -- note: Oribos
        { from = 85, to = 2112, x = 0.5710, y = 0.8729, type = "PORTAL", faction = "HORDE" }, -- note: Valdrakken
        { from = 85, to = 2322, x = 0.3743, y = 0.7619, type = "PORTAL", faction = "HORDE" }, -- note: Hall of Awakening
        { from = 85, to = 2339, x = 0.5859, y = 0.9135, type = "PORTAL", faction = "HORDE" }, -- note: Dornogal
        { from = 85, to = 2351, x = 0.5896, y = 0.8953, type = "PORTAL", faction = "HORDE" }, -- note: Razorwind
        { from = 85, to = 2393, x = 0.5598, y = 0.8821, type = "PORTAL", faction = "HORDE" }, -- note: ns.Silvermoon .. " (" .. EXPANSION_NAME11 ..") (" .. L["Portal"] ..")"
        { from = 86, to = 85, x = 0.2285, y = 0.6905, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 86, to = 85, x = 0.3420, y = 0.9104, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 86, to = 85, x = 0.7869, y = 0.1478, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 87, to = 27, x = 0.1421, y = 0.8604, type = "TRANSPORT", faction = "ALLIANCE" }, -- note: Passage/Exit
        { from = 87, to = 84, x = 0.7586, y = 0.5097, type = "TRAM", faction = "ALLIANCE" }, -- note: ns.Deepruntram .. " ==> " .. ns.Stormwind
        { from = 88, to = 7, x = 0.3123, y = 0.6257, type = "TRANSPORT", faction = "HORDE" },
        { from = 88, to = 7, x = 0.3171, y = 0.6595, type = "TRANSPORT", faction = "HORDE" },
        { from = 88, to = 7, x = 0.5223, y = 0.2561, type = "TRANSPORT", faction = "HORDE" },
        { from = 88, to = 7, x = 0.5463, y = 0.2715, type = "TRANSPORT", faction = "HORDE" },
        { from = 88, to = 85, x = 0.1429, y = 0.2570, type = "ZEPPELIN", faction = "HORDE" }, -- note: Zeppelin from Thunder Bluff to OG
        { from = 89, to = 57, x = 0.3604, y = 0.5019, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.Ruttheran .. " (" .. L["Portal"] ..")"
        { from = 89, to = 57, x = 0.7998, y = 0.4648, type = "TRANSPORT", faction = "ALLIANCE" }, -- note: Passage/Exit
        { from = 90, to = 18, x = 0.1500, y = 0.3101, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 90, to = 18, x = 0.4647, y = 0.4406, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 90, to = 18, x = 0.4979, y = 0.2975, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: REQUIRES_LABEL .. " " .. MOUNT_JOURNAL_FILTER_FLYING
        { from = 90, to = 18, x = 0.6611, y = 0.0384, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 90, to = 100, x = 0.8518, y = 0.1711, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Old Undercity to Hellfire
        { from = 94, to = 110, x = 0.5659, y = 0.3942, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Silvermoon .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.RuinsofLordaeron
        { from = 97, to = 57, x = 0.2023, y = 0.5409, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.Ruttheran .. " (" .. L["Portal"] ..")"
        { from = 97, to = 103, x = 0.2724, y = 0.3965, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Exodar .. " - " .. FACTION_ALLIANCE .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind
        { from = 100, to = 84, x = 0.8863, y = 0.5281, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.HellfirePeninsula .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind
        { from = 100, to = 84, x = 0.8921, y = 0.5101, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.HellfirePeninsula .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Stormwind
        { from = 100, to = 85, x = 0.8857, y = 0.4770, type = "PORTAL", faction = "HORDE" }, -- note: ns.HellfirePeninsula .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar
        { from = 100, to = 85, x = 0.8923, y = 0.4945, type = "PORTAL", faction = "HORDE" }, -- note: ns.HellfirePeninsula .. " " .. L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar
        { from = 100, to = 534, x = 0.5497, y = 0.4809, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.TanaanJungle .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 100, to = 534, x = 0.6404, y = 0.2173, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.TanaanJungle .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 100, to = 534, x = 0.8038, y = 0.5106, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.TanaanJungle .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 101, to = 100, x = 0.5848, y = 0.5621, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53592 },
        { from = 101, to = 104, x = 0.6617, y = 0.7787, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53599 },
        { from = 101, to = 105, x = 0.4639, y = 0.1736, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53597 },
        { from = 102, to = 535, x = 0.8259, y = 0.6613, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Talador .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 102, to = 550, x = 0.4919, y = 0.5537, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 102, to = 550, x = 0.6820, y = 0.8846, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 103, to = 84, x = 0.4832, y = 0.6264, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal Exodar to Stormwind
        { from = 103, to = 97, x = 0.3494, y = 0.7443, type = "TRANSPORT", faction = "ALLIANCE" }, -- note: Passage/Exit
        { from = 103, to = 97, x = 0.6522, y = 0.3478, type = "TRANSPORT", faction = "ALLIANCE" }, -- note: Passage/Exit
        { from = 104, to = 539, x = 0.2710, y = 0.3336, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.ShadowmoonValley .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 104, to = 539, x = 0.6153, y = 0.4607, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.ShadowmoonValley .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 105, to = 525, x = 0.3963, y = 0.7739, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.FrostfireRidge .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 105, to = 525, x = 0.4638, y = 0.6404, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.FrostfireRidge .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 105, to = 543, x = 0.5911, y = 0.7166, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Gorgrond .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 105, to = 543, x = 0.6619, y = 0.2634, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Gorgrond .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 107, to = 550, x = 0.4127, y = 0.5904, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 107, to = 550, x = 0.6036, y = 0.2556, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. SPLASH_NEW_RIGHT_TITLE .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 108, to = 111, x = 0.2865, y = 0.2247, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Shattrath .. "\n" .. "\n" .. L["Portals"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.IsleOfQuelDanas
        { from = 108, to = 111, x = 0.3133, y = 0.2481, type = "PORTAL", faction = "NEUTRAL" }, -- note: ns.Shattrath .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.IsleOfQuelDanas
        { from = 108, to = 535, x = 0.3527, y = 0.1251, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Talador .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 108, to = 535, x = 0.4537, y = 0.4753, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Talador .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 108, to = 542, x = 0.7078, y = 0.7588, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.SpiresOfArak .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 110, to = 18, x = 0.4949, y = 0.1509, type = "PORTAL", faction = "HORDE" }, -- note: ns.RuinsofLordaeron .. " (" .. L["Portal"] ..")"
        { from = 110, to = 85, x = 0.5851, y = 0.1859, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Orgrimmar from Silvermoon
        { from = 110, to = 94, x = 0.7260, y = 0.9199, type = "TRANSPORT", faction = "HORDE" }, -- note: Passage/Exit
        { from = 111, to = 74, x = 0.7467, y = 0.3144, type = "PORTAL", faction = "NEUTRAL" }, -- note: ns.CavernsOfTime .. " " .. L["Portal"] .. " (" .. L["talk to"] .. " " .. ns.Zephir .. ")"
        { from = 111, to = 84, x = 0.5721, y = 0.4825, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Shattrath to Stormwind
        { from = 111, to = 85, x = 0.5678, y = 0.4884, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Shattrath to Orgrimmar
        { from = 111, to = 107, x = 0.2234, y = 0.4989, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 111, to = 108, x = 0.6179, y = 0.0952, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 111, to = 108, x = 0.6893, y = 0.6616, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 111, to = 108, x = 0.7229, y = 0.1901, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 111, to = 108, x = 0.7726, y = 0.4326, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 111, to = 108, x = 0.7951, y = 0.5778, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 111, to = 122, x = 0.4861, y = 0.4203, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal from Shattrath to Quel'Danas
        { from = 113, to = 115, x = 0.4608, y = 0.5903, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53596 },
        { from = 113, to = 118, x = 0.4857, y = 0.1945, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53586 },
        { from = 114, to = 84, x = 0.5963, y = 0.6916, type = "SHIP", faction = "ALLIANCE" }, -- note: Ship to Stormwind from Borean Tundra
        { from = 114, to = 85, x = 0.4120, y = 0.5333, type = "ZEPPELIN", faction = "HORDE" }, -- note: Zeppelin from Borean Tundra to Ogrimmar
        { from = 114, to = 115, x = 0.7907, y = 0.5395, type = "SHIP", faction = "NEUTRAL" }, -- note: POSTMASTER_LETTER_MOAKI .. " (" .. L["Ship"] ..")"
        { from = 115, to = 114, x = 0.4759, y = 0.7897, type = "SHIP", faction = "NEUTRAL" }, -- note: Ship from Moaki to Unu'pe
        { from = 115, to = 117, x = 0.4997, y = 0.7858, type = "SHIP", faction = "NEUTRAL" }, -- note: POSTMASTER_LETTER_KAMAGUA .. " (" .. L["Ship"] ..")"
        { from = 117, to = 18, x = 0.7771, y = 0.2829, type = "PORTAL", faction = "HORDE" }, -- note: ns.RuinsofLordaeron .. " (" .. L["Portal"] ..")"
        { from = 117, to = 56, x = 0.6136, y = 0.6271, type = "SHIP", faction = "ALLIANCE" }, -- note: Ship to Wetlands from Borean Tundra
        { from = 117, to = 115, x = 0.2324, y = 0.5780, type = "SHIP", faction = "NEUTRAL" }, -- note: POSTMASTER_LETTER_MOAKI .. " (" .. L["Ship"] ..")"
        { from = 119, to = 78, x = 0.4032, y = 0.8303, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal Sholazar to Unguro
        { from = 123, to = 125, x = 0.4911, y = 0.1534, type = "PORTAL", faction = "NEUTRAL" }, -- note: LakeWintergrasp to Dalaran Portal
        { from = 125, to = 84, x = 0.4001, y = 0.6276, type = "PORTAL", faction = "ALLIANCE" }, -- note: Dalaran to Stormwind City Portal
        { from = 125, to = 85, x = 0.5532, y = 0.2545, type = "PORTAL", faction = "HORDE" }, -- note: Dalaran to Orgrimmar Portal
        { from = 125, to = 126, x = 0.3529, y = 0.4528, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN2
        { from = 125, to = 126, x = 0.4834, y = 0.3243, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: TRANSMOG_SET_PVP .. " " .. MERCHANT
        { from = 125, to = 126, x = 0.6029, y = 0.4758, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: TRANSMOG_SET_PVP .. " " .. MERCHANT
        { from = 125, to = 127, x = 0.5590, y = 0.4678, type = "PORTAL", faction = "NEUTRAL" }, -- note: Dalaran Portal to Crystalsong Forest
        { from = 126, to = 125, x = 0.2504, y = 0.4295, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN1
        { from = 126, to = 125, x = 0.6669, y = 0.4845, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN1
        { from = 126, to = 127, x = 0.1164, y = 0.8435, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 127, to = 84, x = 0.2661, y = 0.4271, type = "PORTAL", faction = "ALLIANCE" }, -- note: Dalaran to Stormwind City Portal
        { from = 127, to = 85, x = 0.3110, y = 0.3140, type = "PORTAL", faction = "HORDE" }, -- note: Dalaran to Orgrimmar Portal
        { from = 127, to = 125, x = 0.1572, y = 0.4250, type = "PORTAL", faction = "NEUTRAL", questID = 12791 }, -- note: LakeWintergrasp to Dalaran Portal
        { from = 198, to = 84, x = 0.6260, y = 0.2315, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal To Stormwind from Hyjal
        { from = 198, to = 85, x = 0.6348, y = 0.2447, type = "PORTAL", faction = "HORDE" }, -- note: Portal To Orgrimmar from Hyjal
        { from = 207, to = 84, x = 0.4852, y = 0.5385, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal To Stormwind
        { from = 207, to = 85, x = 0.5094, y = 0.5311, type = "PORTAL", faction = "HORDE" }, -- note: Portal To Orgrimmar from Deepholm
        { from = 210, to = 10, x = 0.3933, y = 0.6720, type = "SHIP", faction = "NEUTRAL" }, -- note: ns.Ratchet .. " (" .. L["Ship"] ..")"
        { from = 217, to = 2239, x = 0.6365, y = 0.9592, type = "SHIP", faction = "NEUTRAL" }, -- note: Ship from Gilneas to Bel ameth
        { from = 224, to = 18, x = 0.4223, y = 0.3253, type = "PORTAL", faction = "HORDE" }, -- note: ns.RuinsofLordaeron .. " (" .. L["Portal"] ..")"
        { from = 224, to = 50, x = 0.4207, y = 0.3378, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Gromgol .. " " .. "\n" .. "\n" .. L["Zeppelin"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. "\n" .. L["Portal"] .. "\n" .. " ==> " .. ns.RuinsofLordaeron
        { from = 224, to = 85, x = 0.4199, y = 0.3471, type = "ZEPPELIN", faction = "HORDE" }, -- note: Ship from Booty Bay to Ratchet
        { from = 224, to = 210, x = 0.3694, y = 0.7582, type = "SHIP", faction = "NEUTRAL" }, -- note: ns.Ratchet .. " (" .. L["Ship"] ..")"
        { from = 241, to = 84, x = 0.7944, y = 0.7784, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal Twilight Highlands to Stormwind
        { from = 241, to = 85, x = 0.7359, y = 0.5355, type = "PORTAL", faction = "HORDE" }, -- note: Portal Tol Orgrimmar from Twilight Highlands
        { from = 244, to = 84, x = 0.4713, y = 0.5189, type = "PORTAL", faction = "ALLIANCE" }, -- note: L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormwind
        { from = 244, to = 85, x = 0.4713, y = 0.5189, type = "PORTAL", faction = "HORDE" }, -- note: L["Portals"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " ==> " .. ns.Stormwind
        { from = 245, to = 84, x = 0.7523, y = 0.5887, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal Tol Bard to Stormwind
        { from = 245, to = 85, x = 0.5639, y = 0.7967, type = "PORTAL", faction = "HORDE" }, -- note: Portal Tol Bard to Orgimmar
        { from = 371, to = 84, x = 0.4624, y = 0.8517, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Jade Forest to ns.Stormwind
        { from = 371, to = 85, x = 0.2850, y = 0.1401, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Jade Forest to Orgrimmar
        { from = 379, to = 85, x = 0.8594, y = 0.6249, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Jade Forest to Orgrimmar
        { from = 388, to = 504, x = 0.4974, y = 0.6867, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Isle of Thunder to Shado-Pan Garrison
        { from = 388, to = 504, x = 0.5065, y = 0.7339, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Isle of Thunder to Shado-Pan Garrison
        { from = 390, to = 84, x = 0.9059, y = 0.6670, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Shrine of Seven Stars to Stormwind
        { from = 390, to = 85, x = 0.6337, y = 0.1293, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Shrine of Two Moons to Orgrimmar
        { from = 391, to = 390, x = 0.2677, y = 0.8156, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 391, to = 390, x = 0.5361, y = 0.8846, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 391, to = 390, x = 0.7747, y = 0.6963, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 391, to = 392, x = 0.2224, y = 0.5623, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: \n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Orgrimmar .. " (" .. L["Portal"] ..")
        { from = 391, to = 392, x = 0.3697, y = 0.2301, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: \n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Orgrimmar .. " (" .. L["Portal"] ..")
        { from = 391, to = 392, x = 0.5769, y = 0.1948, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: \n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Orgrimmar .. " (" .. L["Portal"] ..")
        { from = 391, to = 392, x = 0.7808, y = 0.4452, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: \n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Orgrimmar .. " (" .. L["Portal"] ..")
        { from = 392, to = 85, x = 0.7246, y = 0.4286, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Shrine of Two Moons to Orgrimmar
        { from = 392, to = 391, x = 0.2740, y = 0.7968, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"]
        { from = 392, to = 391, x = 0.3791, y = 0.3400, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"]
        { from = 392, to = 391, x = 0.5565, y = 0.3047, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"]
        { from = 392, to = 391, x = 0.7417, y = 0.6908, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Engineer"] .. "\n" .. L["Blacksmithing"]
        { from = 393, to = 390, x = 0.2426, y = 0.5267, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 393, to = 390, x = 0.3776, y = 0.2459, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 393, to = 390, x = 0.6020, y = 0.1547, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 393, to = 394, x = 0.3269, y = 0.7602, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: \n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Stormwind .. " (" .. L["Portal"] ..")
        { from = 393, to = 394, x = 0.5404, y = 0.8271, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: \n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Stormwind .. " (" .. L["Portal"] ..")
        { from = 393, to = 394, x = 0.6792, y = 0.6633, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: \n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Stormwind .. " (" .. L["Portal"] ..")
        { from = 393, to = 394, x = 0.7088, y = 0.3384, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: \n" .. BANK .. "\n" .. GUILD_BANK .. "\n" .. ns.Stormwind .. " (" .. L["Portal"] ..")
        { from = 394, to = 84, x = 0.7156, y = 0.3593, type = "PORTAL", faction = "ALLIANCE" },
        { from = 394, to = 393, x = 0.3195, y = 0.5456, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"]
        { from = 394, to = 393, x = 0.5534, y = 0.7175, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"]
        { from = 394, to = 393, x = 0.6318, y = 0.2065, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"]
        { from = 394, to = 393, x = 0.6711, y = 0.5809, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: "\n" .. BUTTON_LAG_AUCTIONHOUSE .. " " .. REQUIRES_LABEL .. " " .. L["Engineer"] .. "\n" .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. L["Blacksmithing"]
        { from = 407, to = 7, x = 0.5054, y = 0.9077, type = "PORTAL", faction = "NEUTRAL" }, -- note: FACTION_HORDE .. " ==> " .. DUNGEON_FLOOR_NIGHTMARERAID3 .. "\n" .. FACTION_ALLIANCE .. " ==> " .. POSTMASTER_LETTER_ELWYNNFOREST
        { from = 407, to = 7, x = 0.5054, y = 0.9077, type = "PORTAL", faction = "HORDE" },
        { from = 407, to = 7, x = 0.5141, y = 0.2247, type = "PORTAL", faction = "NEUTRAL" }, -- note: FACTION_HORDE .. " ==> " .. DUNGEON_FLOOR_NIGHTMARERAID3 .. "\n" .. FACTION_ALLIANCE .. " ==> " .. POSTMASTER_LETTER_ELWYNNFOREST
        { from = 407, to = 7, x = 0.5141, y = 0.2247, type = "PORTAL", faction = "HORDE" },
        { from = 407, to = 37, x = 0.5054, y = 0.9077, type = "PORTAL", faction = "NEUTRAL" }, -- note: FACTION_HORDE .. " ==> " .. DUNGEON_FLOOR_NIGHTMARERAID3 .. "\n" .. FACTION_ALLIANCE .. " ==> " .. POSTMASTER_LETTER_ELWYNNFOREST
        { from = 407, to = 37, x = 0.5054, y = 0.9077, type = "PORTAL", faction = "ALLIANCE" },
        { from = 407, to = 37, x = 0.5141, y = 0.2247, type = "PORTAL", faction = "NEUTRAL" }, -- note: FACTION_HORDE .. " ==> " .. DUNGEON_FLOOR_NIGHTMARERAID3 .. "\n" .. FACTION_ALLIANCE .. " ==> " .. POSTMASTER_LETTER_ELWYNNFOREST
        { from = 407, to = 37, x = 0.5141, y = 0.2247, type = "PORTAL", faction = "ALLIANCE" },
        { from = 418, to = 110, x = 0.1031, y = 0.5365, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Silvermoon
        { from = 424, to = 376, x = 0.4686, y = 0.7238, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53598 },
        { from = 424, to = 379, x = 0.4843, y = 0.3542, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53595 },
        { from = 463, to = 862, x = 0.7190, y = 0.3797, type = "SHIP", faction = "HORDE" }, -- note: Ship from Echo Isles to Zuldazar
        { from = 469, to = 30, x = 0.3279, y = 0.3702, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Gnomeregan
        { from = 499, to = 84, x = 0.4247, y = 0.1587, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 499, to = 87, x = 0.8987, y = 0.4349, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 499, to = 87, x = 0.8987, y = 0.6720, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 499, to = 500, x = 0.5212, y = 0.4649, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 500, to = 499, x = 0.7244, y = 0.0888, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 503, to = 85, x = 0.5743, y = 0.1229, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Portal to Shlae'gararena
        { from = 504, to = 388, x = 0.3322, y = 0.3269, type = "PORTAL", faction = "HORDE" }, -- note: ns.ShadoPanGarison .. " (" .. L["Portal"] ..")"
        { from = 504, to = 388, x = 0.6470, y = 0.7347, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.ShadoPanGarison .. " (" .. L["Portal"] ..")"
        { from = 525, to = 105, x = 0.2182, y = 0.4531, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.BladesEdgeMountains .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 525, to = 105, x = 0.3753, y = 0.6071, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.BladesEdgeMountains .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 525, to = 582, x = 0.5954, y = 0.4752, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate FrostfireRidge
        { from = 525, to = 590, x = 0.4774, y = 0.6482, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 525, to = 590, x = 0.5954, y = 0.4752, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate FrostfireRidge
        { from = 525, to = 624, x = 0.5141, y = 0.6484, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Garrison to Ashran
        { from = 534, to = 100, x = 0.4956, y = 0.5073, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.HellfirePeninsula .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 534, to = 100, x = 0.5631, y = 0.2683, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.HellfirePeninsula .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 534, to = 100, x = 0.7030, y = 0.5453, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.HellfirePeninsula .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 534, to = 622, x = 0.5742, y = 0.6032, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Lion's Watch to (Ashran Zone)
        { from = 534, to = 624, x = 0.6102, y = 0.4735, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Vol'mar to Ashran
        { from = 535, to = 102, x = 0.6842, y = 0.0932, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.TerokkarForest .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 3 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 535, to = 108, x = 0.5041, y = 0.3519, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.TerokkarForest .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 535, to = 108, x = 0.5785, y = 0.8053, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.TerokkarForest .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 535, to = 582, x = 0.5508, y = 0.4813, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate Talador
        { from = 535, to = 590, x = 0.5508, y = 0.4813, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate Talador
        { from = 539, to = 104, x = 0.3233, y = 0.2876, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.ShadowmoonValley .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 539, to = 104, x = 0.6002, y = 0.4837, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.ShadowmoonValley .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 539, to = 582, x = 0.2900, y = 0.1638, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 539, to = 582, x = 0.5046, y = 0.3566, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate Shadowmoon Valley
        { from = 539, to = 590, x = 0.5046, y = 0.3566, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate Shadowmoon Valley
        { from = 539, to = 622, x = 0.3247, y = 0.1561, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Garison to Ashran
        { from = 542, to = 108, x = 0.4740, y = 0.1245, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.TerokkarForest .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 4 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 542, to = 582, x = 0.5462, y = 0.5163, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate SpiresOfArak
        { from = 542, to = 590, x = 0.5462, y = 0.5163, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate SpiresOfArak
        { from = 543, to = 105, x = 0.4941, y = 0.7366, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.BladesEdgeMountains .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 543, to = 105, x = 0.5082, y = 0.3143, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.BladesEdgeMountains .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 543, to = 582, x = 0.5803, y = 0.3444, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate Gorgrond
        { from = 543, to = 590, x = 0.5803, y = 0.3444, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate Gorgrond
        { from = 550, to = 102, x = 0.8124, y = 0.0898, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Zangarmarsh .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 550, to = 102, x = 0.8830, y = 0.2284, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Zangarmarsh .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 550, to = 107, x = 0.5035, y = 0.5721, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 1 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 550, to = 107, x = 0.7141, y = 0.2194, type = "MIRROR", faction = "NEUTRAL", toyID = 129929 }, -- note: " ==> " .. ns.Nagrand .. " " .. L["Portal"] .. " " .. L["Number"] .. ": " .. "=> 2 <=" .. " (" .. POSTMASTER_PIPE_OUTLAND .. ")" .. "\n" .. "\n" .. LFG_LIST_REQUIRE .. " " .. TOY .. ": " .. "\n" .. " " .. L["Ever-Shifting Mirror"]
        { from = 550, to = 582, x = 0.3216, y = 0.4623, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate Nagrand
        { from = 550, to = 590, x = 0.3216, y = 0.4623, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Ogre Waygate Nagrand
        { from = 572, to = 543, x = 0.4842, y = 0.2449, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53588 },
        { from = 572, to = 550, x = 0.2932, y = 0.4349, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53590 },
        { from = 582, to = 622, x = 0.6969, y = 0.2706, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Garison to Ashran
        { from = 588, to = 84, x = 0.4384, y = 0.8830, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Ashran to Stormwind
        { from = 588, to = 85, x = 0.4500, y = 0.1476, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Garrison to Ashran (Ashran Zone)
        { from = 588, to = 534, x = 0.3832, y = 0.8897, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.LionsWatch .. " (" .. L["Portal"] ..")"
        { from = 588, to = 534, x = 0.4291, y = 0.1275, type = "PORTAL", faction = "HORDE" }, -- note: ns.Volmar .. " (" .. L["Portal"] ..")"
        { from = 590, to = 624, x = 0.7518, y = 0.4879, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Garrison to Ashran
        { from = 619, to = 646, x = 0.5800, y = 0.6767, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53589 },
        { from = 619, to = 650, x = 0.4545, y = 0.2953, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53593 },
        { from = 622, to = 84, x = 0.6081, y = 0.3785, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Ashran to Stormwind
        { from = 622, to = 534, x = 0.3623, y = 0.4113, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.LionsWatch .. " (" .. L["Portal"] ..")"
        { from = 622, to = 588, x = 0.5565, y = 0.0794, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 624, to = 85, x = 0.6082, y = 0.5159, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Ashran to Orgrimmar
        { from = 624, to = 534, x = 0.5318, y = 0.4384, type = "PORTAL", faction = "HORDE" }, -- note: Portal from Ashran to Vol'mar Captive
        { from = 624, to = 588, x = 0.5549, y = 0.8792, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 626, to = 619, x = 0.3258, y = 0.3995, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Rogue
        { from = 626, to = 627, x = 0.2957, y = 0.2185, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Rogue
        { from = 626, to = 627, x = 0.3965, y = 0.2153, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Rogue
        { from = 626, to = 627, x = 0.8539, y = 0.7396, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Rogue
        { from = 627, to = 24, x = 0.6189, y = 0.1355, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_PALADIN .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Paladin"]
        { from = 627, to = 84, x = 0.4041, y = 0.6378, type = "PORTAL", faction = "ALLIANCE" }, -- note: Dalaran to Stormwind City Portal
        { from = 627, to = 85, x = 0.5524, y = 0.2392, type = "PORTAL", faction = "HORDE" }, -- note: Dalaran to Orgrimmar Portal
        { from = 627, to = 626, x = 0.4659, y = 0.2575, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_ROGUE .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Rogue"] .. "\n\n" .. "(" .. L["talk to"] .. ": " .. ns.Mongar .. ")"
        { from = 627, to = 626, x = 0.5270, y = 0.7032, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_ROGUE .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Rogue"] .. "\n\n" .. "(" .. L["talk to"] .. ": " .. ns.JackFindel .. ")"
        { from = 627, to = 626, x = 0.5432, y = 0.3277, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_ROGUE .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Rogue"] .. "\n\n" .. "(" .. L["talk to"] .. ": " .. ns.LucianTrias .. ")"
        { from = 627, to = 628, x = 0.3466, y = 0.4554, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN2
        { from = 627, to = 628, x = 0.4834, y = 0.3243, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN2
        { from = 627, to = 628, x = 0.5971, y = 0.4771, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN2
        { from = 627, to = 629, x = 0.4932, y = 0.4758, type = "PORTAL", faction = "NEUTRAL" }, -- note: DUNGEON_FLOOR_DALARAN7012
        { from = 627, to = 695, x = 0.7497, y = 0.4754, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_WARRIOR .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Warrior"] .. "\n\n" .. ITEM_SPELL_TRIGGER_ONUSE .. " " .. ns.JumpToSkyhold .. "\n(" .. ENCOUNTER_JOURNAL_ABILITY .. ")"
        { from = 627, to = 702, x = 0.6285, y = 0.1763, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_PRIEST .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Priest"]
        { from = 627, to = 720, x = 0.9809, y = 0.6938, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_DEMONHUNTER .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. SPLASH_LEGION_BOX_FEATURE1_TITLE
        { from = 627, to = 726, x = 0.6705, y = 0.4820, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_SHAMAN .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Shaman"]
        { from = 628, to = 627, x = 0.2781, y = 0.5332, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN1
        { from = 628, to = 627, x = 0.7307, y = 0.6461, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Passage"] .. " - " .. DUNGEON_FLOOR_DALARAN1
        { from = 628, to = 717, x = 0.2757, y = 0.4455, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_WARLOCK .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Warlock"]
        { from = 629, to = 25, x = 0.2877, y = 0.7742, type = "PORTAL", faction = "NEUTRAL" },
        { from = 629, to = 42, x = 0.3194, y = 0.7153, type = "PORTAL", faction = "NEUTRAL" },
        { from = 629, to = 115, x = 0.3079, y = 0.8454, type = "PORTAL", faction = "NEUTRAL" },
        { from = 629, to = 627, x = 0.6475, y = 0.2082, type = "PORTAL", faction = "NEUTRAL" },
        { from = 629, to = 971, x = 0.3355, y = 0.7905, type = "PORTAL", faction = "HORDE" },
        { from = 630, to = 84, x = 0.4667, y = 0.4136, type = "PORTAL", faction = "ALLIANCE" }, -- note: L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind
        { from = 630, to = 85, x = 0.4667, y = 0.4136, type = "PORTAL", faction = "HORDE" }, -- note: L["Portal"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Stormwind
        { from = 641, to = 747, x = 0.4264, y = 0.2587, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_DRUID .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Druid"]
        { from = 646, to = 648, x = 0.9871, y = 0.5868, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_DEATHKNIGHT .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Death Knight"]
        { from = 647, to = 648, x = 0.3337, y = 0.3550, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DUNGEON_FLOOR_GILNEAS2
        { from = 648, to = 627, x = 0.2468, y = 0.3374, type = "PORTAL", faction = "NEUTRAL" }, -- note: Deathknight - Dalaran
        { from = 648, to = 647, x = 0.3470, y = 0.3682, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DUNGEON_FLOOR_GILNEAS3
        { from = 650, to = 739, x = 0.3517, y = 0.4553, type = "CLASS_PORTAL", faction = "NEUTRAL" }, -- note: ORDER_HALL_HUNTER .. "\n" .. L["Class Hall"] .. " " .. L["Entrance"] .. " " .. L["Hunter"]
        { from = 652, to = 85, x = 0.4617, y = 0.6383, type = "PORTAL", faction = "HORDE" }, -- note: Thundertotem to Orgrimmar
        { from = 680, to = 84, x = 0.5867, y = 0.8764, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Krokuun - Vindikaar to Stormwind
        { from = 680, to = 85, x = 0.5818, y = 0.8734, type = "PORTAL", faction = "HORDE" }, -- note: Thundertotem to Orgrimmar
        { from = 702, to = 627, x = 0.4975, y = 0.8073, type = "PORTAL", faction = "NEUTRAL" }, -- note: Priest - Dalaran
        { from = 709, to = 379, x = 0.5005, y = 0.5442, type = "PORTAL", faction = "NEUTRAL" }, -- note: Monk - Kun-Lai
        { from = 709, to = 627, x = 0.5240, y = 0.5715, type = "PORTAL", faction = "NEUTRAL" }, -- note: Monk - Dalaran
        { from = 715, to = 26, x = 0.4903, y = 0.6358, type = "PORTAL", faction = "NEUTRAL" }, -- note: Druid Emerald Dreamway - The Hinterlands
        { from = 715, to = 47, x = 0.3934, y = 0.7014, type = "PORTAL", faction = "NEUTRAL" }, -- note: Druid Emerald Dreamway - Duskwood
        { from = 715, to = 69, x = 0.2259, y = 0.3943, type = "PORTAL", faction = "NEUTRAL" }, -- note: Druid Emerald Dreamway - Feralas
        { from = 715, to = 80, x = 0.2616, y = 0.8213, type = "PORTAL", faction = "NEUTRAL" }, -- note: Druid Emerald Dreamway - Moonglade
        { from = 715, to = 116, x = 0.3161, y = 0.2524, type = "PORTAL", faction = "NEUTRAL" }, -- note: Druid Emerald Dreamway - Grizzly Hills
        { from = 715, to = 198, x = 0.5321, y = 0.5181, type = "PORTAL", faction = "NEUTRAL" }, -- note: Druid Emerald Dreamway - Hyjal
        { from = 715, to = 747, x = 0.4487, y = 0.2367, type = "PORTAL", faction = "NEUTRAL" }, -- note: Druid Emerald Dreamway
        { from = 715, to = 2239, x = 0.1923, y = 0.5918, type = "PORTAL", faction = "NEUTRAL" }, -- note: Druid Emerald Dreamway - Amirdrassil
        { from = 717, to = 627, x = 0.7579, y = 0.3679, type = "PORTAL", faction = "NEUTRAL" }, -- note: Warlock - Dalaran
        { from = 720, to = 627, x = 0.5836, y = 0.1631, type = "PORTAL", faction = "NEUTRAL" }, -- note: DH - Dalaran
        { from = 720, to = 627, x = 0.5927, y = 0.9191, type = "PORTAL", faction = "NEUTRAL" }, -- note: DH - Dalaran
        { from = 720, to = 721, x = 0.4767, y = 0.5427, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DH
        { from = 720, to = 721, x = 0.6980, y = 0.5381, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DH
        { from = 721, to = 720, x = 0.4954, y = 0.5406, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DH
        { from = 721, to = 720, x = 0.6824, y = 0.5395, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DH
        { from = 726, to = 325, x = 0.2680, y = 0.4137, type = "PORTAL", faction = "NEUTRAL" }, -- note: Shaman - Vortexgipfel - Instance
        { from = 726, to = 367, x = 0.3112, y = 0.6076, type = "PORTAL", faction = "NEUTRAL" }, -- note: Shaman - Feuerlande - Instance
        { from = 726, to = 627, x = 0.2980, y = 0.5198, type = "PORTAL", faction = "NEUTRAL" }, -- note: Shaman - Dalaran
        { from = 734, to = 627, x = 0.5734, y = 0.9054, type = "PORTAL", faction = "NEUTRAL" }, -- note: Mage - Dalaran
        { from = 734, to = 630, x = 0.5503, y = 0.3957, type = "PORTAL", faction = "NEUTRAL" }, -- note: Mage - Azsuna
        { from = 734, to = 634, x = 0.6712, y = 0.4161, type = "PORTAL", faction = "NEUTRAL" }, -- note: Mage - Stormheim
        { from = 734, to = 641, x = 0.6676, y = 0.4669, type = "PORTAL", faction = "NEUTRAL" }, -- note: Mage - Val'sharah
        { from = 734, to = 650, x = 0.5467, y = 0.4462, type = "PORTAL", faction = "NEUTRAL" }, -- note: Mage - Highmountans
        { from = 734, to = 680, x = 0.6028, y = 0.5195, type = "PORTAL", faction = "NEUTRAL" }, -- note: Mage - Suramar
        { from = 734, to = 735, x = 0.4648, y = 0.5455, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Mage
        { from = 734, to = 735, x = 0.5979, y = 0.5949, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Mage
        { from = 734, to = 735, x = 0.7333, y = 0.5924, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Mage
        { from = 735, to = 734, x = 0.4486, y = 0.7427, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Mage
        { from = 735, to = 734, x = 0.5801, y = 0.6763, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Mage
        { from = 735, to = 734, x = 0.6940, y = 0.7757, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Mage
        { from = 739, to = 627, x = 0.4862, y = 0.4354, type = "PORTAL", faction = "NEUTRAL" }, -- note: Hunter - Dalaran
        { from = 739, to = 650, x = 0.4602, y = 0.0484, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Hunter
        { from = 747, to = 627, x = 0.5666, y = 0.4308, type = "PORTAL", faction = "NEUTRAL" }, -- note: Druid
        { from = 747, to = 641, x = 0.7621, y = 0.9388, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Druid
        { from = 747, to = 715, x = 0.5554, y = 0.2115, type = "PORTAL", faction = "NEUTRAL" }, -- note: Druid
        { from = 832, to = 627, x = 0.4343, y = 0.2516, type = "PORTAL", faction = "NEUTRAL" },
        { from = 862, to = 463, x = 0.5804, y = 0.6505, type = "SHIP", faction = "HORDE" }, -- note: Ship from Zandalar to Echo Isles
        { from = 862, to = 895, x = 0.5846, y = 0.6298, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Ship from Dazar'alor to Drustvar, Tiragarde Sound or Stormsong Valley
        { from = 862, to = 896, x = 0.5846, y = 0.6298, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Ship from Dazar'alor to Drustvar, Tiragarde Sound or Stormsong Valley
        { from = 862, to = 1161, x = 0.4045, y = 0.7103, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Transport from Zuldazar to Boralus
        { from = 862, to = 1163, x = 0.5847, y = 0.4432, type = "PORTAL", faction = "HORDE" }, -- note: L["Dazar'alor"] .. " " .. L["Portalroom"] .. L["(inside building)"] .. "\n" .. " ==> " .. ns.Silvermoon .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Silithus .. "\n" .. " ==> " .. ns.Nazjatar
        { from = 862, to = 1164, x = 0.5730, y = 0.4305, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 862, to = 1165, x = 0.5926, y = 0.5920, type = "PORTAL", faction = "HORDE" }, -- note: ns.Zandalar .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"] .. "\n" .. " ==> " .. L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"]
        { from = 862, to = 1165, x = 0.6004, y = 0.3895, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal Manapuff
        { from = 862, to = 1462, x = 0.5532, y = 0.5808, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Transport from Dazar'alor to Mechagon
        { from = 862, to = 2346, x = 0.2255, y = 0.5406, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Rocket Drill from Zandalar to Undermine
        { from = 863, to = 1161, x = 0.6206, y = 0.4008, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Transport from Nazmir to Boralus
        { from = 864, to = 1161, x = 0.3669, y = 0.3428, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Transport from Vol'dun to Boralus
        { from = 875, to = 862, x = 0.4576, y = 0.7991, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80100 },
        { from = 875, to = 863, x = 0.5173, y = 0.2835, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80099 },
        { from = 876, to = 895, x = 0.6931, y = 0.7685, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80101 },
        { from = 876, to = 942, x = 0.5973, y = 0.1634, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80102 },
        { from = 895, to = 84, x = 0.7816, y = 0.2702, type = "SHIP", faction = "ALLIANCE" }, -- note: Ship from Boralus to Stormwind
        { from = 895, to = 862, x = 0.8785, y = 0.5119, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Transport from Tiragarde Sound to Zuldazar
        { from = 895, to = 1161, x = 0.6915, y = 0.3054, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal Manapuff
        { from = 895, to = 1161, x = 0.7153, y = 0.3261, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Boralus Transports
        { from = 895, to = 1161, x = 0.7407, y = 0.2427, type = "PORTAL", faction = "ALLIANCE" }, -- note: ns.Boralus .. " " .. L["Portalroom"] .. "\n" .. " " .. L["(inside building)"] .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.Silithus .. "\n" .. " ==> " .. ns.Exodar .. "\n" .. " ==> " .. ns.Ironforge .. "\n" .. " ==> " .. ns.Nazjatar
        { from = 895, to = 1161, x = 0.7511, y = 0.2192, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 896, to = 862, x = 0.2061, y = 0.4336, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Transport from Drustvar to Zuldazar
        { from = 941, to = 84, x = 0.4309, y = 0.2506, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Krokuun - Vindikaar to Stormwind
        { from = 942, to = 862, x = 0.5190, y = 0.2432, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Transport from Stormsong Valley to Zuldazar
        { from = 947, to = 17, x = 0.8985, y = 0.6822, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53594 },
        { from = 947, to = 26, x = 0.8808, y = 0.4622, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53585 },
        { from = 947, to = 27, x = 0.8628, y = 0.5685, type = "MOLE_MACHINE", faction = "NEUTRAL" },
        { from = 947, to = 35, x = 0.8679, y = 0.6183, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53587 },
        { from = 947, to = 78, x = 0.1767, y = 0.6774, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53591 },
        { from = 947, to = 84, x = 0.8451, y = 0.6347, type = "MOLE_MACHINE", faction = "NEUTRAL" },
        { from = 947, to = 115, x = 0.4890, y = 0.1689, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53596 },
        { from = 947, to = 118, x = 0.4937, y = 0.0700, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53586 },
        { from = 947, to = 198, x = 0.2018, y = 0.4585, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53601 },
        { from = 947, to = 199, x = 0.1782, y = 0.5409, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53600 },
        { from = 947, to = 376, x = 0.4717, y = 0.8564, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53598 },
        { from = 947, to = 379, x = 0.4764, y = 0.7716, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53595 },
        { from = 947, to = 646, x = 0.6130, y = 0.4608, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53589 },
        { from = 947, to = 650, x = 0.5863, y = 0.3761, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 53593 },
        { from = 947, to = 862, x = 0.5330, y = 0.6798, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80100 },
        { from = 947, to = 863, x = 0.5471, y = 0.5903, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80099 },
        { from = 947, to = 895, x = 0.7496, y = 0.5284, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80101 },
        { from = 947, to = 942, x = 0.7323, y = 0.4248, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80102 },
        { from = 947, to = 2022, x = 0.7558, y = 0.1752, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80107 },
        { from = 947, to = 2024, x = 0.8014, y = 0.2576, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80108 },
        { from = 947, to = 2133, x = 0.8440, y = 0.2766, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80109 },
        { from = 971, to = 629, x = 0.2495, y = 0.2789, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal to Dalaran
        { from = 971, to = 629, x = 0.2799, y = 0.2149, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Stormwind
        { from = 1161, to = 14, x = 0.6618, y = 0.2474, type = "PORTAL", faction = "ALLIANCE" }, -- note: L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"]
        { from = 1161, to = 62, x = 0.6621, y = 0.2442, type = "PORTAL", faction = "ALLIANCE" }, -- note: L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"]
        { from = 1161, to = 81, x = 0.6964, y = 0.1590, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portalroom from Boralus
        { from = 1161, to = 84, x = 0.7013, y = 0.1684, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portalroom from Boralus
        { from = 1161, to = 84, x = 0.7823, y = 0.2675, type = "SHIP", faction = "ALLIANCE" }, -- note: Ship from Boralus to Stormwind
        { from = 1161, to = 87, x = 0.7089, y = 0.1536, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portalroom from Boralus
        { from = 1161, to = 103, x = 0.7038, y = 0.1499, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portalroom from Boralus
        { from = 1161, to = 862, x = 0.6795, y = 0.2670, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Portal from Dazar'alor to Mechagon
        { from = 1161, to = 864, x = 0.6795, y = 0.2670, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Portal from Dazar'alor to Mechagon
        { from = 1161, to = 895, x = 0.0809, y = 0.3855, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1161, to = 895, x = 0.3776, y = 0.1547, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1161, to = 895, x = 0.4262, y = 0.1359, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1161, to = 895, x = 0.8123, y = 0.9058, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1161, to = 1355, x = 0.6987, y = 0.1531, type = "PORTAL", faction = "ALLIANCE", questID = 55175 }, -- note: Portalroom from Boralus
        { from = 1163, to = 81, x = 0.7380, y = 0.8541, type = "PORTAL", faction = "HORDE" }, -- note: Portalroom from Dazar'alor
        { from = 1163, to = 85, x = 0.7400, y = 0.6974, type = "PORTAL", faction = "HORDE" }, -- note: Portalroom from Dazar'alor
        { from = 1163, to = 88, x = 0.7402, y = 0.7739, type = "PORTAL", faction = "HORDE" }, -- note: Portalroom from Dazar'alor
        { from = 1163, to = 110, x = 0.7372, y = 0.6194, type = "PORTAL", faction = "HORDE" }, -- note: Portalroom from Dazar'alor
        { from = 1163, to = 1164, x = 0.2096, y = 0.2819, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER
        { from = 1163, to = 1164, x = 0.4152, y = 0.4702, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER
        { from = 1163, to = 1164, x = 0.4388, y = 0.8227, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER
        { from = 1163, to = 1164, x = 0.5345, y = 0.8227, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER
        { from = 1163, to = 1164, x = 0.5518, y = 0.4702, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER
        { from = 1163, to = 1164, x = 0.7653, y = 0.2819, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: PROFESSIONS_COOKING .. "\n" .. INSCRIPTION .. "\n" .. RAID_FINDER
        { from = 1163, to = 1164, x = 0.7655, y = 0.4199, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 1163, to = 1165, x = 0.4859, y = 0.1752, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1163, to = 1355, x = 0.6300, y = 0.8553, type = "PORTAL", faction = "HORDE" }, -- note: Portalroom from Dazar'alor
        { from = 1164, to = 1163, x = 0.2080, y = 0.3895, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY
        { from = 1164, to = 1163, x = 0.4090, y = 0.5331, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY
        { from = 1164, to = 1163, x = 0.4215, y = 0.8227, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY
        { from = 1164, to = 1163, x = 0.5439, y = 0.8227, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY
        { from = 1164, to = 1163, x = 0.5643, y = 0.5354, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY
        { from = 1164, to = 1163, x = 0.7668, y = 0.3848, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: L["Portals"] .. "\n" .. BANK .. " / " .. GUILD_BANK .."\n" .. MINIMAP_TRACKING_INNKEEPER .."\n" .. INSCRIPTION .."\n" .. PROFESSIONS_ARCHAEOLOGY
        { from = 1164, to = 1165, x = 0.2267, y = 0.7175, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1164, to = 1165, x = 0.7401, y = 0.7175, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1165, to = 14, x = 0.5171, y = 0.9454, type = "PORTAL", faction = "HORDE" }, -- note: L["This Arathi Highlands portal is only active if your faction is currently occupying Ar'gorok"]
        { from = 1165, to = 62, x = 0.5207, y = 0.9454, type = "PORTAL", faction = "HORDE" }, -- note: L["This Darkshore portal is only active if your faction is currently occupying Bashal'Aran"]
        { from = 1165, to = 862, x = 0.3587, y = 0.5990, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1165, to = 862, x = 0.3603, y = 0.0716, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1165, to = 862, x = 0.3723, y = 0.8159, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1165, to = 862, x = 0.5785, y = 0.1053, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1165, to = 862, x = 0.6052, y = 0.6367, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1165, to = 1163, x = 0.4880, y = 0.4311, type = "CLASS_PORTAL", faction = "NEUTRAL" },
        { from = 1165, to = 1163, x = 0.4984, y = 0.4867, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 1165, to = 1163, x = 0.4993, y = 0.4095, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 1165, to = 1163, x = 0.5142, y = 0.4583, type = "PORTAL", faction = "HORDE" }, -- note: ns.Dazaralor .. " " .. L["Portalroom"] .. "\n" .. L["(inside building)"] .. "\n" .. "\n" .. " ==> " .. ns.Silvermoon .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.ThunderBluff .. "\n" .. " ==> " .. ns.Silithus .. "\n" .. " ==> " .. ns.Nazjatar
        { from = 1165, to = 1164, x = 0.4991, y = 0.4447, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 1165, to = 1462, x = 0.4183, y = 0.8761, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Transport from Dazar'alor to Mechagon
        { from = 1355, to = 1161, x = 0.3997, y = 0.5256, type = "PORTAL", faction = "ALLIANCE", questID = 55175 }, -- note: Portalroom to Boralus from Mezzamere
        { from = 1355, to = 1163, x = 0.4727, y = 0.6279, type = "PORTAL", faction = "HORDE" }, -- note: Portalroom to Dazar'alor from NewHome
        { from = 1462, to = 862, x = 0.7552, y = 0.2266, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Transport from Mechagon to Zuldazar
        { from = 1473, to = 81, x = 0.5002, y = 0.3037, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal from Chamber of Heart to Silithus
        { from = 1530, to = 84, x = 0.9059, y = 0.6670, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal from Shrine of Seven Stars to Stormwind
        { from = 1530, to = 85, x = 0.6372, y = 0.0989, type = "PORTAL", faction = "HORDE" }, -- note: ns.Orgrimmar .. " (" .. L["Portal"] ..")\n" .. DUNGEON_FLOOR_GILNEAS3
        { from = 1530, to = 390, x = 0.8371, y = 0.2804, type = "TRANSPORT", faction = "NEUTRAL" },
        { from = 1543, to = 1670, x = 0.4242, y = 0.4210, type = "PORTAL", faction = "NEUTRAL" }, -- note: ns.Oribos .. " (" .. L["Portal"] ..")"
        { from = 1543, to = 1911, x = 0.4813, y = 0.3902, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Maw to Torghast
        { from = 1543, to = 1961, x = 0.4734, y = 0.4340, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Korthia .. " (" .. L["Transport"] ..")"
        { from = 1550, to = 1525, x = 0.1767, y = 0.5032, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80104 },
        { from = 1550, to = 1533, x = 0.7213, y = 0.4797, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80105 },
        { from = 1550, to = 1536, x = 0.6334, y = 0.2497, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80103 },
        { from = 1550, to = 1565, x = 0.5377, y = 0.8116, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80106 },
        { from = 1670, to = 84, x = 0.2065, y = 0.4625, type = "PORTAL", faction = "ALLIANCE" }, -- note: Oribos to Stormwind City Portal
        { from = 1670, to = 85, x = 0.2080, y = 0.5432, type = "PORTAL", faction = "HORDE" }, -- note: Oribos to Orgrimmar Portal
        { from = 1670, to = 1671, x = 0.4706, y = 0.5029, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DUNGEON_FLOOR_GILNEAS3 .. " (" .. L["Transport"] ..")"
        { from = 1670, to = 1671, x = 0.5208, y = 0.5793, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DUNGEON_FLOOR_GILNEAS3 .. " (" .. L["Transport"] ..")"
        { from = 1670, to = 1671, x = 0.5209, y = 0.4275, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DUNGEON_FLOOR_GILNEAS3 .. " (" .. L["Transport"] ..")"
        { from = 1670, to = 1671, x = 0.5712, y = 0.5033, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DUNGEON_FLOOR_GILNEAS3 .. " (" .. L["Transport"] ..")"
        { from = 1671, to = 1543, x = 0.4940, y = 0.5127, type = "PORTAL", faction = "NEUTRAL" }, -- note: Oribos to The Maw
        { from = 1671, to = 1670, x = 0.4341, y = 0.5157, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DUNGEON_FLOOR_GILNEAS2 .. " (" .. L["Transport"] ..")"
        { from = 1671, to = 1670, x = 0.4953, y = 0.6090, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DUNGEON_FLOOR_GILNEAS2 .. " (" .. L["Transport"] ..")"
        { from = 1671, to = 1670, x = 0.4955, y = 0.4241, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DUNGEON_FLOOR_GILNEAS2 .. " (" .. L["Transport"] ..")"
        { from = 1671, to = 1670, x = 0.5566, y = 0.5162, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: DUNGEON_FLOOR_GILNEAS2 .. " (" .. L["Transport"] ..")"
        { from = 1671, to = 1961, x = 0.3032, y = 0.2269, type = "PORTAL", faction = "NEUTRAL" }, -- note: Oribos to Korthia
        { from = 1671, to = 1970, x = 0.4953, y = 0.2566, type = "PORTAL", faction = "NEUTRAL" }, -- note: Oribos to Zereth Morthis
        { from = 1911, to = 1543, x = 0.1045, y = 0.4655, type = "PORTAL", faction = "NEUTRAL" }, -- note: Torghast to Maw
        { from = 1911, to = 1912, x = 0.1594, y = 0.6014, type = "PORTAL", faction = "NEUTRAL" }, -- note: Torghast to Maw
        { from = 1912, to = 1911, x = 0.5016, y = 0.8375, type = "PORTAL", faction = "NEUTRAL" }, -- note: Torghast to Maw
        { from = 1961, to = 1543, x = 0.6506, y = 0.2339, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.TheMaw .. " (" .. L["Transport"] ..")"
        { from = 1961, to = 1671, x = 0.6447, y = 0.2406, type = "PORTAL", faction = "NEUTRAL" }, -- note: ns.Oribos .. " (" .. L["Portal"] ..")"
        { from = 1970, to = 1671, x = 0.3295, y = 0.6973, type = "PORTAL", faction = "NEUTRAL" }, -- note: ns.Oribos .. " (" .. L["Portal"] ..")"
        { from = 1978, to = 2022, x = 0.4451, y = 0.3478, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80107 },
        { from = 1978, to = 2024, x = 0.6507, y = 0.7127, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80108 },
        { from = 1978, to = 2133, x = 0.8736, y = 0.7740, type = "MOLE_MACHINE", faction = "NEUTRAL", questID = 80109 },
        { from = 2022, to = 84, x = 0.8224, y = 0.3070, type = "SHIP", faction = "ALLIANCE" }, -- note: Ship from The Waking Shores to Stormwind
        { from = 2022, to = 85, x = 0.8163, y = 0.2788, type = "ZEPPELIN", faction = "HORDE" }, -- note: Zeppelin from The Waking Shores to Orgrimmar
        { from = 2023, to = 2200, x = 0.1829, y = 0.5226, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Portal to The Emerald Dream
        { from = 2025, to = 2112, x = 0.4051, y = 0.6283, type = "PORTAL", faction = "NEUTRAL" }, -- note: ns.Valdrakken .. " " .. L["Portals"] .. "\n" .. "\n" .. " ==> " .. ns.EmeraldDream .. "\n" .. " ==> " .. ns.Badlands .. "\n".." ==> " .. ns.Stormwind .. "\n" .. " ==> " .. ns.Orgrimmar
        { from = 2070, to = 19, x = 0.8233, y = 0.3243, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Scarlet Monastery Key for Old dungeons
        { from = 2070, to = 50, x = 0.5950, y = 0.6797, type = "PORTAL", faction = "HORDE" }, -- note: ns.Gromgol .. " (" .. L["Portal"] ..")"
        { from = 2070, to = 85, x = 0.5950, y = 0.6694, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Orgrimmar from Tirisfal
        { from = 2070, to = 110, x = 0.5940, y = 0.6743, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Silvermoon from Tirisfal
        { from = 2070, to = 117, x = 0.6012, y = 0.6689, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Howling Fjord from Tirisfal
        { from = 2112, to = 15, x = 0.2610, y = 0.4102, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal from Valdrakken to the Badlands
        { from = 2112, to = 84, x = 0.5980, y = 0.4169, type = "PORTAL", faction = "ALLIANCE" }, -- note: Valdrakken to Stormwind City Portal
        { from = 2112, to = 85, x = 0.5659, y = 0.3828, type = "PORTAL", faction = "HORDE" }, -- note: Valdrakken to Orgrimmar Portal
        { from = 2112, to = 2200, x = 0.6272, y = 0.5732, type = "PORTAL", faction = "NEUTRAL" }, -- note: Portal from Valdrakken to The Emerald Dream
        { from = 2200, to = 2023, x = 0.7306, y = 0.5245, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Portal The Emerald Dream to Ohn'ahran Plains
        { from = 2214, to = 2248, x = 0.4919, y = 0.4459, type = "TRANSPORT", faction = "NEUTRAL", questID = 82195 },
        { from = 2214, to = 2248, x = 0.6154, y = 0.7692, type = "TRANSPORT", faction = "NEUTRAL", questID = 84220 },
        { from = 2214, to = 2346, x = 0.7295, y = 0.7320, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Rocket Drill Deeps to Undermine
        { from = 2214, to = 2369, x = 0.4199, y = 0.3030, type = "MOLE_MACHINE", faction = "NEUTRAL" }, -- note: Mole Machine from Deeps to Sirene Isle
        { from = 2239, to = 84, x = 0.5546, y = 0.6365, type = "PORTAL", faction = "ALLIANCE" }, -- note: Valdrakken to Stormwind City Portal
        { from = 2239, to = 217, x = 0.4953, y = 0.0434, type = "SHIP", faction = "NEUTRAL" }, -- note: Ship from Amirdrassil to Gilneas
        { from = 2239, to = 715, x = 0.5854, y = 0.8501, type = "PORTAL", faction = "NEUTRAL" }, -- note: Bel'ameth, Amirdrassil to Druid Emerald Dreamway
        { from = 2239, to = 2200, x = 0.8964, y = 0.3770, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Bel'ameth, Amirdrassil to Emerald Dream
        { from = 2248, to = 2214, x = 0.3742, y = 0.7287, type = "TRANSPORT", faction = "NEUTRAL", questID = 84220 },
        { from = 2248, to = 2214, x = 0.6733, y = 0.3102, type = "TRANSPORT", faction = "NEUTRAL", questID = 82195 },
        { from = 2248, to = 2266, x = 0.5055, y = 0.4183, type = "WAYGATE", faction = "NEUTRAL" }, -- note: L["The Timeways"] .. " " .. L["Portals"]
        { from = 2248, to = 2339, x = 0.4691, y = 0.3872, type = "PORTAL", faction = "HORDE" }, -- note: Dornogal to Orgrimmar
        { from = 2248, to = 2339, x = 0.4704, y = 0.3781, type = "PORTAL", faction = "ALLIANCE" }, -- note: Dornogal to Stormwind
        { from = 2248, to = 2339, x = 0.5302, y = 0.4511, type = "PORTAL", faction = "NEUTRAL", achievementID = 19559 }, -- note: Portal from Dornogal to Azj-Kahet if u finished the achievement=19559
        { from = 2248, to = 2367, x = 0.4463, y = 0.4679, type = "PORTAL", faction = "NEUTRAL", achievementID = 40725 }, -- note: Chamber of Memory
        { from = 2248, to = 2369, x = 0.5545, y = 0.3363, type = "ZEPPELIN", faction = "NEUTRAL" }, -- note: Zeppelin to Siren Isle from Dornogal
        { from = 2255, to = 2339, x = 0.5734, y = 0.4184, type = "PORTAL", faction = "NEUTRAL", achievementID = 19559 }, -- note: Portal from Azj-Kahet to Dornogal if u finished the achievement=19559
        { from = 2256, to = 2339, x = 0.5734, y = 0.4184, type = "PORTAL", faction = "NEUTRAL", achievementID = 19559 }, -- note: Portal from Azj-Kahet to Dornogal if u finished the achievement=19559
        { from = 2266, to = 862, x = 0.7452, y = 0.4703, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Timeways Portal to
        { from = 2266, to = 864, x = 0.7053, y = 0.7306, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Timeways Portal to
        { from = 2266, to = 2022, x = 0.7753, y = 0.6180, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Timeways Portal to
        { from = 2266, to = 2393, x = 0.4356, y = 0.4994, type = "PORTAL", faction = "NEUTRAL" }, -- note: Timeways Portal to Silvermoon
        { from = 2322, to = 84, x = 0.0718, y = 0.4634, type = "PORTAL", faction = "ALLIANCE" }, -- note: Hall of Awakening
        { from = 2322, to = 85, x = 0.0710, y = 0.5283, type = "PORTAL", faction = "HORDE" }, -- note: Hall of Awakening
        { from = 2339, to = 84, x = 0.4116, y = 0.2271, type = "PORTAL", faction = "ALLIANCE" }, -- note: Dornogal to Stormwind
        { from = 2339, to = 85, x = 0.3819, y = 0.2724, type = "PORTAL", faction = "HORDE" }, -- note: Dornogal to Orgrimmar
        { from = 2339, to = 2214, x = 0.3587, y = 0.5875, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 2339, to = 2248, x = 0.6858, y = 0.8953, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 2339, to = 2248, x = 0.8178, y = 0.2819, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 2339, to = 2255, x = 0.6361, y = 0.5205, type = "PORTAL", faction = "NEUTRAL", achievementID = 19559 }, -- note: Portal from Dornogal to Azj-Kahet if u finished the achievement=19559
        { from = 2339, to = 2266, x = 0.5356, y = 0.3873, type = "WAYGATE", faction = "NEUTRAL" }, -- note: Portal from Dornogal to the Timeways
        { from = 2339, to = 2346, x = 0.5246, y = 0.5047, type = "PORTAL", faction = "NEUTRAL", questID = 86535 }, -- note: Portal from Dornogal to Undermine
        { from = 2339, to = 2367, x = 0.2977, y = 0.5967, type = "PORTAL", faction = "NEUTRAL", achievementID = 40725 }, -- note: Kammer der Erinnerung
        { from = 2339, to = 2369, x = 0.7354, y = 0.0516, type = "ZEPPELIN", faction = "NEUTRAL" }, -- note: Zeppelin from OG to Borean Tundra - Northrend
        { from = 2339, to = 2472, x = 0.4031, y = 0.2267, type = "PORTAL", faction = "NEUTRAL", questID = 84957 }, -- note: Portal from Dornogal to Tazavesh
        { from = 2346, to = 862, x = 0.1879, y = 0.5225, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Rocket Drill from Undermine to Zandalar
        { from = 2346, to = 2214, x = 0.1728, y = 0.5075, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Rocket Drill from Undermine to Deeps
        { from = 2346, to = 2339, x = 0.2780, y = 0.5398, type = "PORTAL", faction = "NEUTRAL", questID = 86535 }, -- note: Portal from Undermine to Dornogal
        { from = 2351, to = 85, x = 0.5392, y = 0.4938, type = "PORTAL", faction = "HORDE" }, -- note: Portal Razorwind Shores to Orgrimmar (Housing map)
        { from = 2352, to = 84, x = 0.5743, y = 0.2664, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal Founder's Point to Stormwind (Housing map)
        { from = 2367, to = 2339, x = 0.4995, y = 0.3591, type = "PORTAL", faction = "NEUTRAL", achievementID = 40725 }, -- note: Chamber of Memory
        { from = 2369, to = 2214, x = 0.6761, y = 0.3901, type = "MOLE_MACHINE", faction = "NEUTRAL" }, -- note: Mole Machine from Sirene Isle to Deeps
        { from = 2369, to = 2339, x = 0.7072, y = 0.5350, type = "ZEPPELIN", faction = "NEUTRAL" }, -- note: Zeppelin from Siren Isle to Dornogal
        { from = 2371, to = 2339, x = 0.6641, y = 0.7176, type = "PORTAL", faction = "NEUTRAL", questID = 84967 }, -- note: Portal Tazavesh to Dornogal
        { from = 2371, to = 2339, x = 0.6935, y = 0.8829, type = "PORTAL", faction = "NEUTRAL", questID = 84957 }, -- note: Portal from Tazavesh to Dornogal
        { from = 2393, to = 84, x = 0.5263, y = 0.6450, type = "PORTAL", faction = "ALLIANCE" }, -- note: Portal to Stormwind
        { from = 2393, to = 85, x = 0.5217, y = 0.6519, type = "PORTAL", faction = "HORDE" }, -- note: Portal to Orgrimmar
        { from = 2393, to = 2266, x = 0.4210, y = 0.5830, type = "WAYGATE", faction = "NEUTRAL" }, -- note: L["The Timeways"] .. " " .. L["Portals"] .. "\n" .. "\n" .. ZONE .. ": " .. ns.Voldun .. "\n" .. CALENDAR_TYPE_DUNGEON .. ": " .. ns.TempleOfSethraliss .. "\n\n" .. ZONE .. ": " .. ns.Zuldazar .. "\n" .. CALENDAR_TYPE_DUNGEON .. ": " .. ns.Kingsrush .. "\n\n" .. ZONE .. ": " .. ns.TheWakingShores .. "\n" .. CALENDAR_TYPE_DUNGEON .. ": " .. ns.RubyLifePools
        { from = 2393, to = 2395, x = 0.1787, y = 0.4455, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 2393, to = 2395, x = 0.3744, y = 0.9041, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 2393, to = 2395, x = 0.4566, y = 0.9145, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 2393, to = 2395, x = 0.6098, y = 0.9177, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 2393, to = 2405, x = 0.3528, y = 0.6607, type = "PORTAL", faction = "NEUTRAL", questID = 86549 }, -- note: Portal zum Leerensturm
        { from = 2393, to = 2413, x = 0.3674, y = 0.6821, type = "PORTAL", faction = "NEUTRAL", questID = 86898 }, -- note: Wurzelpfad nach Harandar
        { from = 2393, to = 2424, x = 0.4573, y = 0.0648, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Passage/Exit
        { from = 2393, to = 2599, x = 0.4795, y = 0.4809, type = "PORTAL", faction = "NEUTRAL" }, -- note: L["Portal"] .. " - " .. ns.Val .. " / " .. ns.Naigtal
        { from = 2393, to = 2600, x = 0.4795, y = 0.4809, type = "PORTAL", faction = "NEUTRAL" }, -- note: L["Portal"] .. " - " .. ns.Val .. " / " .. ns.Naigtal
        { from = 2395, to = 2393, x = 0.4684, y = 0.2862, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: ns.Silvermoon .. " (" .. EXPANSION_NAME11 .. ")\n\n" .. L["Portals"] .. "\n" .. " ==> " .. ns.Orgrimmar .. "\n" .. " ==> " .. ns.Harandar .. "\n" .. " ==> " .. ns.VoidTempest .. "\n" .. " ==> " .. ns.Stormwind .. "\n" .. " ==> " .. L["The Timeways"] .. "\n\n" .. CALENDAR_TYPE_DUNGEON .. "\n ==> " .. ns.MurderRow .. "\n\n" .. DELVES_LABEL .. "\n ==> " .. ns.TheDarkway .. "\n ==> " .. ns.CollegiateCalamity
        { from = 2405, to = 2393, x = 0.5163, y = 0.7026, type = "PORTAL", faction = "NEUTRAL", questID = 86510 }, -- note: L["Portals"] .. "\n " .. ns.SilvermoonMN .. "\n " .. ns.Harandar
        { from = 2405, to = 2413, x = 0.5163, y = 0.7026, type = "PORTAL", faction = "NEUTRAL", questID = 86510 }, -- note: L["Portals"] .. "\n " .. ns.SilvermoonMN .. "\n " .. ns.Harandar
        { from = 2413, to = 2576, x = 0.5354, y = 0.5571, type = "PORTAL", faction = "NEUTRAL", questID = 86883 }, -- note: L["inside the cave"] .. ":\n" .. ns.TextIconPortalOld:GetIconString() .. " " .. L["Portal"] .. " " .. ns.VoidTempest .. "\n" .. ns.TextIconPortalOld:GetIconString() .. " " .. L["Portal"] .. " " .. ns.SilvermoonMN
        { from = 2472, to = 2339, x = 0.4944, y = 0.1971, type = "PORTAL", faction = "NEUTRAL", questID = 84967 }, -- note: Portal Tazavesh to Dornogal
        { from = 2472, to = 2339, x = 0.6254, y = 0.9423, type = "PORTAL", faction = "NEUTRAL", questID = 84957 }, -- note: Portal from Tazavesh to Dornogal
        { from = 2512, to = 2509, x = 0.3020, y = 0.6475, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Altar der Fänge, Der Giftige Abgrund
        { from = 2512, to = 2509, x = 0.4437, y = 0.4421, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Altar der Fänge, Der Giftige Abgrund
        { from = 2512, to = 2509, x = 0.4686, y = 0.6487, type = "TRANSPORT", faction = "NEUTRAL" }, -- note: Altar der Fänge, Der Giftige Abgrund
        { from = 2576, to = 2393, x = 0.6468, y = 0.7098, type = "PORTAL", faction = "NEUTRAL", questID = 86883 },
        { from = 2576, to = 2405, x = 0.6178, y = 0.7348, type = "PORTAL", faction = "NEUTRAL" },
        { from = 2599, to = 2405, x = 0.6179, y = 0.1601, type = "PORTAL", faction = "NEUTRAL" },
        { from = 2600, to = 2405, x = 0.4850, y = 0.8280, type = "PORTAL", faction = "NEUTRAL" },
    },
}

-- Also exposed as a global for console debugging
PortaData = ns.PortaData
