-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode


-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

require('libraries/timers')
require('libraries/physics')
require('libraries/projectiles')
require('libraries/notifications')
require('libraries/animations')

require('libraries/FlashUtil')
require('libraries/buildinghelper')
require('buildings/bh_abilities')

require('settings')
require('internal/events')
require('events')

require('internal/gamemode')

function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")

  
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  hero:SetGold(0, false)

  if hero:GetClassname() == "npc_dota_hero_viper" then
    local team = hero:GetTeamNumber()
    local player = hero:GetPlayerOwner()

    local newHero

    UTIL_Remove( hero )

     -- Init kvn fan
    if team == 2 then
      PrecacheUnitByNameAsync("npc_dota_hero_rattletrap",
        function() 
          newHero = CreateHeroForPlayer("npc_dota_hero_rattletrap", player)

        InitAbilities(newHero)

        newHero:SetAbilityPoints(0)

        newHero:SetGold(1000, false)

        newHero:AddItemByName("item_petri_kvn_fan_blink")
        newHero:AddItemByName("item_petri_give_permission_to_build")
        newHero:AddItemByName("item_petri_gold_bag")
        end, player:GetPlayerID())
    end

     -- Init petrosyan
    if team == 3 then
      PrecacheUnitByNameAsync("npc_dota_hero_brewmaster",
        function() 
          newHero = CreateHeroForPlayer("npc_dota_hero_brewmaster", player)

          -- It's dangerous to go alone, take this
          newHero:SetAbilityPoints(3)
          newHero:UpgradeAbility(newHero:GetAbilityByIndex(0))
          newHero:UpgradeAbility(newHero:GetAbilityByIndex(5))

          -- Wait a bit and spawn tower
          Timers:CreateTimer(0.03,
            function()
              CreateUnitByName( "npc_petri_exploration_tower" , Vector(784,1164,129) , true, nil, nil, DOTA_TEAM_BADGUYS )
              
              newHero.spawnPosition = newHero:GetAbsOrigin()
              end)
        end, player:GetPlayerID())
    end

    -- We don't need 'undefined' variables
    player.lumber = 500000
    player.food = 0
    player.maxFood = 10
 
    --Send lumber and food info to users
    CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_ability_layouts", GameMode.abilityLayouts )

    --Update player's UI
    Timers:CreateTimer(0.03,
    function()
      local event_data =
      {
          gold = PlayerResource:GetGold(player:GetPlayerID()),
          lumber = player.lumber,
          food = player.food,
          maxFood = player.maxFood
      }
      CustomGameEventManager:Send_ServerToPlayer( player, "receive_resources_info", event_data )
      return 0.15
    end)
  end
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds 
    end)
end

function GameMode:OnUnitSelected(args)
end

function GameMode:InitGameMode()
  GameMode = self

  GameMode:_InitGameMode()
  SendToServerConsole( "dota_combine_models 0" )

   -- Find all ability layouts to send them to clients later
  local UnitKVs = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  local HeroKVs = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")

  GameMode.abilityLayouts = {}

  for i=1,2 do
    local t = UnitKVs
    if i == 2 then
      t = HeroKVs
    end
    for unit_name,unit_info in pairs(t) do
      if type(unit_info) == "table" then
        if i == 2 then
          GameMode.abilityLayouts[unit_info["override_hero"]] = unit_info["AbilityLayout"]
        else
          GameMode.abilityLayouts[unit_name] = unit_info["AbilityLayout"]
        end
      end
    end
  end

  --GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( GameMode, "FilterExecuteOrder" ), self )

  -- Some creepy shit for hiding rally point
  -- Timers:CreateTimer(1, function()
  --   CustomGameEventManager:RegisterListener( "custom_dota_player_update_selected_unit", Dynamic_Wrap(GameMode, 'OnUnitSelected') )
  -- end)

  BuildingHelper:Init()
end