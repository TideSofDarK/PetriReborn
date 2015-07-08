-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode


-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')

require('FlashUtil')
require('buildinghelper')
require('buildings/bh_abilities')
require('buildings/rally_point')

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
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

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  hero:SetGold(0, false)

  if hero:GetClassname() == "npc_dota_hero_viper" then
    local team = hero:GetTeamNumber()
    local player = hero:GetPlayerOwner()

    local newHero

    if team == 2 then
      UTIL_Remove( hero )
      newHero = CreateHeroForPlayer("npc_dota_hero_rattletrap", player)

      InitAbilities(newHero)

      newHero:SetAbilityPoints(0)

      newHero:SetGold(1000, false)
    end

    if team == 3 then

      UTIL_Remove( hero )
      newHero = CreateHeroForPlayer("npc_dota_hero_brewmaster", player)
    end

    -- We don't need 'undefined' variables
    player.lumber = 0
    player.food = 0
    player.maxFood = 25

    --Update player's UI
    Timers:CreateTimer(0.03,
    function()
      local event_data =
      {
          gold = newHero:GetGold(),
          lumber = player.lumber,
          food = player.food,
          maxFood = player.maxFood
      }
      CustomGameEventManager:Send_ServerToPlayer( player, "receive_resources_info", event_data )
      return 0.35
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

function GameMode:FilterExecuteOrder( filterTable )
    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]

    for n,unit_index in pairs(units) do
        local unit = EntIndexToHScript(unit_index)
        local ownerID = unit:GetPlayerOwnerID()

        if unit:GetUnitLabel() == "building" then
          if order_type == 1 then
            return false
          end
        end
    end

    return true
end

function GameMode:OnUnitSelected(args)
  local unit = EntIndexToHScript(tonumber(args["main_unit"]))

  if unit ~= nil then
    if unit:GetPlayerOwner().selection == nil then 
      unit:GetPlayerOwner().selection = {}
    end

    if unit:GetPlayerOwner().selection.flag ~= nil then
      unit:GetPlayerOwner().selection.flag:SetModelScale(0)
    end

    if unit:GetUnitLabel() == "building" then
      if unit:HasAbility("building_queue") then
        if unit.flag ~= nil then
          unit.flag:SetModelScale(0.5)
        end 
      end
    end

    unit:GetPlayerOwner().selection = unit
  end
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self

  GameMode:_InitGameMode()
  SendToServerConsole( "dota_combine_models 0" )

  GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( GameMode, "FilterExecuteOrder" ), self )

  -- Some creepy shit for hiding rally point
  Timers:CreateTimer(1, function()
    CustomGameEventManager:RegisterListener( "custom_dota_player_update_selected_unit", Dynamic_Wrap(GameMode, 'OnUnitSelected') )
  end)

  BuildingHelper:Init()
end