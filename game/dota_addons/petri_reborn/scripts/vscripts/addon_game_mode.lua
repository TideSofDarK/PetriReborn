-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
  
  PrecacheResource("model", "models/props_structures/radiant_tower001.vmdl", context)

  PrecacheResource("model", "models/aow/aow.vmdl", context)
  
  PrecacheResource("model", "models/props_structures/tent_dk_small.vmdl", context)
  PrecacheResource("model", "models/props_structures/tent_dk_med.vmdl", context)
  PrecacheResource("model", "models/props_structures/tent_dk_large.vmdl", context)
  
  PrecacheResource("model", "models/particle/legion_duel_banner.vmdl", context)
  PrecacheResource("particle_folder", "particles/buildinghelper", context)

  PrecacheItemByNameSync("item_petri_builder_blink", context)
  PrecacheItemByNameSync("item_petri_give_permission_to_build", context)

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