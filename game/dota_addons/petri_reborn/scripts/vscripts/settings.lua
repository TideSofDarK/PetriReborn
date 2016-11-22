-- In this file you can set up all the properties and settings for your game mode.


ENABLE_HERO_RESPAWN = false              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 0.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 0.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 10.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 0                     -- How much gold should players get per tick?
GOLD_TICK_TIME = 0                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommened builds for heroes
CAMERA_DISTANCE_OVERRIDE = 1134.0       -- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 0.9                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                   -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false      -- Should we disable fog of war entirely for both teams?
USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 8         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 80                        -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
XP_PER_LEVEL_TABLE[1] = 0 
XP_PER_LEVEL_TABLE[2] = 30
XP_PER_LEVEL_TABLE[3] = 60
XP_PER_LEVEL_TABLE[4] = 50
XP_PER_LEVEL_TABLE[5] = 50
XP_PER_LEVEL_TABLE[6] = 50
XP_PER_LEVEL_TABLE[7] = 50
XP_PER_LEVEL_TABLE[8] = 50 
XP_PER_LEVEL_TABLE[9] = 50 
XP_PER_LEVEL_TABLE[10] = 250000 
XP_PER_LEVEL_TABLE[11] = 180 
XP_PER_LEVEL_TABLE[12] = 200 
XP_PER_LEVEL_TABLE[13] = 250 
XP_PER_LEVEL_TABLE[14] = 350
XP_PER_LEVEL_TABLE[15] = 400
XP_PER_LEVEL_TABLE[16] = 420 
XP_PER_LEVEL_TABLE[17] = 440
XP_PER_LEVEL_TABLE[18] = 460
XP_PER_LEVEL_TABLE[19] = 480 
XP_PER_LEVEL_TABLE[20] = 500
XP_PER_LEVEL_TABLE[21] = 575
XP_PER_LEVEL_TABLE[22] = 580
XP_PER_LEVEL_TABLE[23] = 585
XP_PER_LEVEL_TABLE[24] = 590
XP_PER_LEVEL_TABLE[25] = 595
XP_PER_LEVEL_TABLE[26] = 600
XP_PER_LEVEL_TABLE[27] = 625
XP_PER_LEVEL_TABLE[28] = 650
XP_PER_LEVEL_TABLE[29] = 675
XP_PER_LEVEL_TABLE[30] = 700
XP_PER_LEVEL_TABLE[31] = 750
XP_PER_LEVEL_TABLE[32] = 800
XP_PER_LEVEL_TABLE[33] = 825
XP_PER_LEVEL_TABLE[34] = 850
XP_PER_LEVEL_TABLE[35] = 875
XP_PER_LEVEL_TABLE[36] = 900
XP_PER_LEVEL_TABLE[37] = 925
XP_PER_LEVEL_TABLE[38] = 950
XP_PER_LEVEL_TABLE[39] = 975
XP_PER_LEVEL_TABLE[40] = 1000
XP_PER_LEVEL_TABLE[41] = 1500
XP_PER_LEVEL_TABLE[42] = 1600
XP_PER_LEVEL_TABLE[43] = 1700
XP_PER_LEVEL_TABLE[44] = 1800
XP_PER_LEVEL_TABLE[45] = 1900
XP_PER_LEVEL_TABLE[46] = 2000
XP_PER_LEVEL_TABLE[47] = 2100
XP_PER_LEVEL_TABLE[48] = 2200
XP_PER_LEVEL_TABLE[49] = 2300
XP_PER_LEVEL_TABLE[50] = 2400
XP_PER_LEVEL_TABLE[51] = 2500
XP_PER_LEVEL_TABLE[52] = 2600
XP_PER_LEVEL_TABLE[53] = 2700
XP_PER_LEVEL_TABLE[54] = 2800
XP_PER_LEVEL_TABLE[55] = 2900
XP_PER_LEVEL_TABLE[56] = 3000
XP_PER_LEVEL_TABLE[57] = 3100
XP_PER_LEVEL_TABLE[58] = 3200
XP_PER_LEVEL_TABLE[59] = 3300
XP_PER_LEVEL_TABLE[60] = 3400
XP_PER_LEVEL_TABLE[61] = 3500
XP_PER_LEVEL_TABLE[62] = 3750
XP_PER_LEVEL_TABLE[63] = 4000
XP_PER_LEVEL_TABLE[64] = 4250
XP_PER_LEVEL_TABLE[65] = 4500
XP_PER_LEVEL_TABLE[66] = 4750 
XP_PER_LEVEL_TABLE[67] = 5000 
XP_PER_LEVEL_TABLE[68] = 5250 
XP_PER_LEVEL_TABLE[69] = 5500 
XP_PER_LEVEL_TABLE[70] = 5750 
XP_PER_LEVEL_TABLE[71] = 6000 
XP_PER_LEVEL_TABLE[72] = 6250 
XP_PER_LEVEL_TABLE[73] = 6500 
XP_PER_LEVEL_TABLE[74] = 6750 
XP_PER_LEVEL_TABLE[75] = 7000 
XP_PER_LEVEL_TABLE[76] = 7250 
XP_PER_LEVEL_TABLE[77] = 7500 
XP_PER_LEVEL_TABLE[78] = 7750 
XP_PER_LEVEL_TABLE[79] = 8000 
XP_PER_LEVEL_TABLE[80] = 8250
for i=1,MAX_LEVEL do
	local originalValue = XP_PER_LEVEL_TABLE[i]
	if i > 2 then
		XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i] + XP_PER_LEVEL_TABLE[i-1]
	end
end 

ENABLE_FIRST_BLOOD = false               -- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = true               -- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = false               -- Should we have players lose the normal amount of dota gold on death?
SHOW_ONLY_PLAYER_INVENTORY = false      -- Should we only allow players to see their own inventory even when selecting other units?
DISABLE_STASH_PURCHASING = false        -- Should we prevent players from being able to buy items into their stash when not at a shop?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?

FORCE_PICKED_HERO = nil				-- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

FIXED_RESPAWN_TIME = 20                 -- What time should we use for a fixed respawn timer?  Use -1 to keep the default dota behavior.
FOUNTAIN_CONSTANT_MANA_REGEN = -1       -- What should we use for the constant fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_MANA_REGEN = -1     -- What should we use for the percentage fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_HEALTH_REGEN = 10   -- What should we use for the percentage fountain health regen?  Use -1 to keep the default dota behavior.
MAXIMUM_ATTACK_SPEED = 1000000              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 20               -- What should we use for the minimum attack speed?


-- NOTE: You always need at least 2 non-bounty (non-regen while broken) type runes to be able to spawn or your game will crash!
ENABLED_RUNES = {}                      -- Which runes should be enabled to spawn in our game mode?
ENABLED_RUNES[DOTA_RUNE_DOUBLEDAMAGE] = true
ENABLED_RUNES[DOTA_RUNE_HASTE] = true
ENABLED_RUNES[DOTA_RUNE_ILLUSION] = true
ENABLED_RUNES[DOTA_RUNE_INVISIBILITY] = true
ENABLED_RUNES[DOTA_RUNE_REGENERATION] = true -- Regen runes are currently not spawning as of the writing of this comment
ENABLED_RUNES[DOTA_RUNE_BOUNTY] = true


MAX_NUMBER_OF_TEAMS = 2                -- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = true          -- Should we use custom team colors?

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 } 
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }

USE_CUSTOM_COLORS_FOR_PLAYERS = true

PLAYER_COLORS = {}
PLAYER_COLORS[0] = { 100 * 2.55, 0, 0 }
PLAYER_COLORS[1]  = { 0, 25.88 * 2.55, 100 }
PLAYER_COLORS[2]  = { 9.8 * 2.55, 90.2  * 2.55, 72.55  * 2.55}
PLAYER_COLORS[3]  = { 32.94 * 2.55, 0, 50.59 * 2.55}
PLAYER_COLORS[4]  = { 100 * 2.55, 98.82 * 2.55, 0 }
PLAYER_COLORS[5]  = { 99.61 * 2.55, 72.94 * 2.55, 5.49 * 2.55}
PLAYER_COLORS[6]  = { 12.55 * 2.55, 75.3 * 2.55, 0 }
PLAYER_COLORS[7]  = { 89.8  * 2.55, 35.69 * 2.55, 69.02 * 2.55 }
PLAYER_COLORS[8]  = { 58.43 * 2.55, 58.82 * 2.55, 59.21 * 2.55 }
PLAYER_COLORS[9]  = { 49.41 * 2.55, 74.90 * 2.55, 94.51 * 2.55 }
PLAYER_COLORS[10]  = { 29.41 * 2.55, 74.90 * 2.55, 54.51 * 2.55 }
PLAYER_COLORS[11]  = { 89.41 * 2.55, 4.90 * 2.55, 34.51 * 2.55 }
PLAYER_COLORS[12]  = { 40.41 * 2.55, 40.90 * 2.55, 1.51 * 2.55 }
PLAYER_COLORS[13]  = { 9.41 * 2.55, 4.90 * 2.55, 85.51 * 2.55 }

USE_AUTOMATIC_PLAYERS_PER_TEAM = false   -- Should we set the number of players to 10 / MAX_NUMBER_OF_TEAMS?

CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 12
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 2