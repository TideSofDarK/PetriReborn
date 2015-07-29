BAREBONES_DEBUG_SPEW = false

-- Settings time

PETRI_TIME_LIMIT = 96
PETRI_EXIT_MARK = 24
PETIR_EXIT_ALLOWED = false
PETRI_EXIT_WARNING = PETRI_TIME_LIMIT - 12

START_KVN_GOLD = 10
START_KVN_LUMBER = 150

START_PETROSYANS_GOLD = 32
START_MINI_ACTORS_GOLD = 15

PETRI_MAX_BUILDING_COUNT_PER_PLAYER = 27

local FRIENDS_KVN = {}
FRIENDS_KVN["50163929"] = "models/heroes/terrorblade/terrorblade_arcana.vmdl"

local FRIENDS_PETRI = {}
FRIENDS_KVN["96571761"] = "models/heroes/doom/doom.vmdl"
FRIENDS_KVN["63399181"] = "models/heroes/doom/doom.vmdl"

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

require('filters')
require('commands')
require('internal/gamemode')

function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  
end

function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end

function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  hero:SetGold(0, false)

  GameMode.assignedPlayerHeroes = GameMode.assignedPlayerHeroes or {}

  if hero:GetClassname() == "npc_dota_hero_viper" then
    local team = hero:GetTeamNumber()
    local player = hero:GetPlayerOwner()
    local pID = player:GetPlayerID()

    InitAbilities(hero)
    DestroyEntityBasedOnHealth(hero,hero)

    local newHero

    MoveCamera(pID, hero)

    UTIL_Remove( hero )

     -- Init kvn fan
    if team == 2 then
      PrecacheUnitByNameAsync("npc_dota_hero_rattletrap",
       function() 
          Notifications:Top(pID, {text="#start_game", duration=5, style={color="white", ["font-size"]="45px"}})

          newHero = CreateHeroForPlayer("npc_dota_hero_rattletrap", player)

          InitAbilities(newHero)

          newHero:SetAbilityPoints(0)

          newHero:AddItemByName("item_petri_kvn_fan_blink")
          newHero:AddItemByName("item_petri_give_permission_to_build")
          newHero:AddItemByName("item_petri_gold_bag")
          newHero:AddItemByName("item_petri_trap")

          newHero.spawnPosition = newHero:GetAbsOrigin()

          newHero:SetGold(START_KVN_GOLD, false)
          newHero.lumber = START_KVN_LUMBER
          newHero.bonusLumber = 0
          newHero.food = 0
          newHero.maxFood = 10

          newHero.buildingCount = 0

          SetupUI(newHero)
          SetupUpgrades(newHero)

          GameMode.assignedPlayerHeroes[pID] = newHero

          PlayerResource:SetCustomPlayerColor(pID,PLAYER_COLORS[pID][1], 
          PLAYER_COLORS[pID][2],
          PLAYER_COLORS[pID][3])

          for k,v in pairs(FRIENDS_KVN) do
            local id = tonumber(k)

            if PlayerResource:GetSteamAccountID(pID) == id then
              UpdateModel(newHero, v, 1)
            end
          end
       end, pID)
    end

    local petrosyanHeroName = "npc_dota_hero_brewmaster"
    if pID == PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, 2) then
      petrosyanHeroName = "npc_dota_hero_death_prophet"
    end

     -- Init petrosyan
    if team == 3 then
      PrecacheUnitByNameAsync(petrosyanHeroName,
       function() 
          newHero = CreateHeroForPlayer(petrosyanHeroName, player)

          -- It's dangerous to go alone, take this
          newHero:SetAbilityPoints(3)
          newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_return"))
          newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_dummy_sleep"))

          newHero.spawnPosition = newHero:GetAbsOrigin()

          newHero:SetGold(START_PETROSYANS_GOLD, false)
          newHero.lumber = 0
          newHero.food = 0
          newHero.maxFood = 0
          SetupUI(newHero)

          GameMode.assignedPlayerHeroes[pID] = newHero

          PlayerResource:SetCustomPlayerColor(pID,PLAYER_COLORS[pID][1], 
          PLAYER_COLORS[pID][2],
          PLAYER_COLORS[pID][3])

          for k,v in pairs(FRIENDS_PETRI) do
            local id = tonumber(k)

            if PlayerResource:GetSteamAccountID(pID) == id then
              UpdateModel(newHero, v, 1)
            end
          end

          if GameRules.explorationTowerCreated == nil then
            GameRules.explorationTowerCreated = true
            Timers:CreateTimer(0.2,
            function()
              CreateUnitByName( "npc_petri_exploration_tower" , Vector(784,1164,129) , true, nil, nil, DOTA_TEAM_BADGUYS )
              end)
          end
       end, pID)
    end
    --print("Player with ID: ")
    --print(PlayerResource:GetSteamAccountID(pID))
  end
end

function SetupUpgrades(newHero)
  local player = newHero:GetPlayerOwner()
  local pID = player:GetPlayerID()

  local upgradeAbilities = {}

  for ability_name,ability_info in pairs(GameMode.AbilityKVs) do
    if type(ability_info) == "table" then
      if string.match(ability_name, "petri_upgrade") then 
         upgradeAbilities[ability_name] = 0
      end  
    end
  end

  CustomNetTables:SetTableValue( "players_upgrades", tostring(pID), { upgradeAbilities } );

  --PrintTable(CustomNetTables:GetTableValue("players_upgrades", tostring(pID)))
end

function SetupUI(newHero)
  local player = newHero:GetPlayerOwner()
  local pID = player:GetPlayerID()

  --Send lumber and food info to users
  CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_ability_layouts", GameMode.abilityLayouts )

  --Send gold costs
  CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_gold_costs", GameMode.abilityGoldCosts )

  --Update player's UI
  Timers:CreateTimer(0.03,
  function()
    local event_data =
    {
        gold = GameMode.assignedPlayerHeroes[pID]:GetGold(),
        lumber = newHero.lumber,
        food = newHero.food,
        maxFood = newHero.maxFood
    }
    CustomGameEventManager:Send_ServerToPlayer( player, "receive_resources_info", event_data )
    if PlayerResource:GetConnectionState(pID) == DOTA_CONNECTION_STATE_CONNECTED then return 0.35 end
  end)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")
  
  Timers:CreateTimer((PETRI_EXIT_MARK * 60),
    function()
      PETIR_EXIT_ALLOWED = true
      Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#exit_notification", duration=4, style={color="white", ["font-size"]="45px"}})
    end)

  Timers:CreateTimer((PETRI_EXIT_WARNING * 60),
    function()
      Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#exit_warning", duration=4, style={color="red", ["font-size"]="45px"}})
    end)

  Timers:CreateTimer((PETRI_TIME_LIMIT * 60),
    function()
      PetrosyanWin()
    end)
end

function GameMode:InitGameMode()
  GameMode = self

  GameMode:_InitGameMode()
  SendToServerConsole( "dota_combine_models 0" )

  GameMode.ShopKVs = LoadKeyValues("scripts/shops/petri_alpha_shops.txt")

  GameMode.UnitKVs = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  GameMode.HeroKVs = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  GameMode.AbilityKVs = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  GameMode.ItemKVs = LoadKeyValues("scripts/npc/npc_items_custom.txt")

  GameMode.abilityLayouts = {}
  GameMode.abilityGoldCosts = {}

  for i=1,2 do
    local t = GameMode.UnitKVs
    if i == 2 then
      t = GameMode.HeroKVs
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

  for ability_name,ability_info in pairs(GameMode.AbilityKVs) do
    if type(ability_info) == "table" then
      if ability_info["AbilityGoldCost"] ~= nil then
        GameMode.abilityGoldCosts[ability_name] = Split(ability_info["AbilityGoldCost"], " ")
        -- local i = 0
        -- for c in string.gmatch(ability_info["AbilityGoldCost"], "[^%s]+") do
        --   GameMode.abilityGoldCosts[i] = c
        -- end
      end  
    end
  end

  -- Some way to prevent controlling of disconnected players
  GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( GameMode, "FilterExecuteOrder" ), self )

  -- Fix hero bounties
  GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, "ModifyGoldFilter"), GameMode)

  -- Fix hero bounties
  GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(GameMode, "ModifyExperienceFilter"), GameMode)

  -- Commands
  Convars:RegisterCommand( "lumber", Dynamic_Wrap(GameMode, 'LumberCommand'), "Gives you lumber", FCVAR_CHEAT )
  Convars:RegisterCommand( "lag", Dynamic_Wrap(GameMode, 'LumberAndGoldCommand'), "Gives you lumber and gold", FCVAR_CHEAT )
  --Convars:RegisterCommand( "dota_sf_hud_force_captainsmode", Dynamic_Wrap(GameMode, 'LumberCommand'), "Gives you lumber", FCVAR_CHEAT )

  BuildingHelper:Init()
end

function GameMode:ReplaceWithMiniActor(player)
  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)-1)
  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)+1)

  PrecacheUnitByNameAsync("npc_dota_hero_storm_spirit",
    function() 
      player:SetTeam(DOTA_TEAM_BADGUYS)

      local newHero = PlayerResource:ReplaceHeroWith(player:GetPlayerID(), "npc_dota_hero_storm_spirit", START_MINI_ACTORS_GOLD, 0)
      GameMode.assignedPlayerHeroes[player:GetPlayerID()] = newHero

      newHero:SetTeam(DOTA_TEAM_BADGUYS)

      newHero:RespawnHero(false, false, false)

      newHero:SetAbilityPoints(3)
      newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_flat_joke"))
      newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_return"))

      Timers:CreateTimer(0.03, function ()
        newHero.spawnPosition = newHero:GetAbsOrigin()
      end)
    end
    , 
  player:GetPlayerID())
end

function KVNWin(keys)
  local caster = keys.caster

  Notifications:TopToAll({text="#kvn_win", duration=100, style={color="green"}, continue=false})

  for i=1,10 do
    PlayerResource:SetCameraTarget(i-1, caster)
  end

  Timers:CreateTimer(5.0,
    function()
      GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS) 
    end)
end

function PetrosyanWin()
  Notifications:TopToAll({text="#petrosyan_limit", duration=100, style={color="red"}, continue=false})

  Timers:CreateTimer(5.0,
    function()
      GameRules:SetGameWinner(DOTA_TEAM_BADGUYS) 
    end)
end