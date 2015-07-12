-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
  PrecacheResource("model", "models/heroes/death_prophet/death_prophet_ghost.vmdl", context)

  PrecacheResource("model", "models/items/dragon_knight/dragon_immortal_1/dragon_immortal_1.vmdl", context)
  PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ogre_lrg/n_creep_ogre_lrg.vmdl", context)
  PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_mega.vmdl", context)
  PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_melee_diretide/creep_bad_melee_diretide.vmdl", context)
  PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_kobold/kobold_a/n_creep_kobold_a.vmdl", context)
  PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee.vmdl", context)
  PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee.vmdl", context)

  PrecacheResource("model", "models/props_structures/radiant_tower001.vmdl", context)

  PrecacheResource("model", "models/aow/aow.vmdl", context)
  
  PrecacheResource("model", "models/props_structures/tent_dk_small.vmdl", context)
  PrecacheResource("model", "models/props_structures/tent_dk_med.vmdl", context)
  PrecacheResource("model", "models/props_structures/tent_dk_large.vmdl", context)
  
  PrecacheResource("model", "models/particle/legion_duel_banner.vmdl", context)
  PrecacheResource("particle_folder", "particles/buildinghelper", context)

  PrecacheResource("particle", "particles/econ/events/nexon_hero_compendium_2014/teleport_end_ground_flash_nexon_hero_cp_2014.vpcf", context)

  PrecacheUnitByNameSync("npc_petri_svetlakov", context)
  PrecacheUnitByNameSync("npc_petri_maslyakov", context)
  PrecacheUnitByNameSync("npc_petri_gusman", context)

  PrecacheItemByNameSync("item_petri_hook", context)

  PrecacheUnitByNameSync("npc_petri_tower_basic", context)
  PrecacheUnitByNameSync("npc_petri_exploration_tower", context)

  PrecacheUnitByNameSync("npc_petri_sawmill", context)
  PrecacheUnitByNameSync("npc_peasant", context)

  PrecacheUnitByNameSync("npc_dota_hero_rattletrap", context)
  PrecacheUnitByNameSync("npc_dota_hero_petri_builder", context)
  PrecacheUnitByNameSync("npc_dota_hero_brewmaster", context)
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:InitGameMode()
  -- GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 8)
  -- GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 2)
end