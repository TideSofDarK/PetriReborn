-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
  PrecacheUnitByNameSync("npc_petri_tower_level1", context)

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