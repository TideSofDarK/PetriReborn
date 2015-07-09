-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
  
  PrecacheResource("model", "models/props_structures/tower_good_sfm.vmdl", context)
  
  PrecacheResource("model", "models/props_structures/tent_dk_small.vmdl", context)
  PrecacheResource("model", "models/props_structures/tent_dk_med.vmdl", context)
  PrecacheResource("model", "models/props_structures/tent_dk_large.vmdl", context)
  
  PrecacheResource("model", "models/particle/legion_duel_banner.vmdl", context)
  PrecacheResource("particle_folder", "particles/buildinghelper", context)

  PrecacheItemByNameSync("item_petri_builder_blink", context)
  PrecacheItemByNameSync("item_petri_give_permission_to_build", context)

  PrecacheUnitByNameSync("npc_petri_tower_level1", context)

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