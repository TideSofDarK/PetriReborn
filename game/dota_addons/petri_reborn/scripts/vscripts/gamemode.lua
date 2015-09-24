BAREBONES_DEBUG_SPEW = false

-- Settings time

PETRI_GAME_HAS_STARTED = false
PETRI_GAME_HAS_ENDED = false

PETRI_TIME_LIMIT = 96
PETRI_EXIT_MARK = 28
PETRI_EXIT_ALLOWED = false
PETRI_EXIT_WARNING = PETRI_TIME_LIMIT - 12

START_KVN_GOLD = 10
START_KVN_LUMBER = 150

START_PETROSYANS_GOLD = 32
START_MINI_ACTORS_GOLD = 15

PETRI_MAX_BUILDING_COUNT_PER_PLAYER = 27

PETRI_MAX_WORKERS = 15

DEFENCE_SCROLL_CHANCE = 98
ATTACK_SCROLL_CHANCE = 94
GOLD_COIN_CHANCE = 71
WOOD_CHANCE = 53

local FRIENDS_KVN = {}
FRIENDS_KVN["96571761"] = "models/heroes/doom/doom.vmdl"
FRIENDS_KVN["50163929"] = "models/heroes/terrorblade/terrorblade_arcana.vmdl"
FRIENDS_KVN["41110316"] = "models/heroes/doom/doom.vmdl"

local FRIENDS_PETRI = {}
FRIENDS_KVN["96571761"] = "models/heroes/doom/doom.vmdl"
FRIENDS_KVN["63399181"] = "models/heroes/doom/doom.vmdl"
FRIENDS_KVN["151765071"] = "models/heroes/terrorblade/terrorblade_arcana.vmdl"

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

GameMode.PETRI_NAME_LIST = {}

require('libraries/timers')
require('libraries/physics')
require('libraries/projectiles')
require('libraries/notifications')
require('libraries/animations')
require('libraries/GameSetup')

require('libraries/buildinghelper')
require('libraries/dependencies')
require('buildings/bh_abilities')

require('settings')
require('internal/events')
require('events')

require('lottery')

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

  local team = hero:GetTeamNumber()
  local player = hero:GetPlayerOwner()
  local pID = player:GetPlayerID()

  if hero:GetClassname() == "npc_dota_hero_rattletrap" and not GameMode.assignedPlayerHeroes[pID] then

    hero.spawnPosition = hero:GetAbsOrigin()

    local newHero

    MoveCamera(pID, hero)

     -- Init kvn fan
    if team == 2 then
      PrecacheUnitByNameAsync("npc_dota_hero_rattletrap",
        function() 
          Notifications:Top(pID, {text="#start_game", duration=5, style={color="white", ["font-size"]="45px"}})

          newHero = hero

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
          newHero.numberOfUnits = 0

          newHero.buildingCount = 0

          SetupUI(newHero)
          SetupUpgrades(newHero)
          SetupDependencies(newHero)

          GameMode.assignedPlayerHeroes[pID] = newHero

          PlayerResource:SetCustomPlayerColor(pID,PLAYER_COLORS[pID][1], 
          PLAYER_COLORS[pID][2],
          PLAYER_COLORS[pID][3])

          GameMode.SELECTED_UNITS[pID] = {}
          GameMode.SELECTED_UNITS[pID]["0"] = newHero:entindex()

          for k,v in pairs(FRIENDS_KVN) do
            local id = tonumber(k)

            if PlayerResource:GetSteamAccountID(pID) == id then
              UpdateModel(newHero, v, 1)

              for k,v in pairs(newHero:GetChildren()) do
                if v:GetClassname() == "dota_item_wearable" then
                  v:AddEffects(EF_NODRAW) 
                end
              end
            end
          end
        end, 
      pID)
    end

    local petrosyanHeroName = "npc_dota_hero_brewmaster"
    if pID == PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, 2) then
      petrosyanHeroName = "npc_dota_hero_death_prophet"
    end

     -- Init petrosyan
    if team == 3 then
      UTIL_Remove(hero) 
      PrecacheUnitByNameAsync(petrosyanHeroName,
       function() 
          newHero = CreateHeroForPlayer(petrosyanHeroName, player)

          -- It's dangerous to go alone, take this
          newHero:SetAbilityPoints(4)
          newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_return"))
          newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_dummy_sleep"))
          newHero:UpgradeAbility(newHero:FindAbilityByName("petri_exploration_tower_explore_world"))

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

          GameMode.SELECTED_UNITS[pID] = {} 
          GameMode.SELECTED_UNITS[pID]["0"] = newHero:entindex()

          for k,v in pairs(FRIENDS_PETRI) do
            local id = tonumber(k)

            if PlayerResource:GetSteamAccountID(pID) == id then
              UpdateModel(newHero, v, 1)

              for k,v in pairs(newHero:GetChildren()) do
                if v:GetClassname() == "dota_item_wearable" then
                  v:AddEffects(EF_NODRAW) 
                end
              end
            end
          end

          if GameRules.explorationTowerCreated == nil then
            GameRules.explorationTowerCreated = true
            Timers:CreateTimer(0.2,
            function()
              GameMode.explorationTower = CreateUnitByName( "npc_petri_exploration_tower" , Vector(784,1164,129) , true, newHero, nil, DOTA_TEAM_BADGUYS )
              end)
          end
       end, pID)
    end
    --print("Player with ID: ")
    --print(PlayerResource:GetSteamAccountID(pID))
  end
end

function SetupDependencies(newHero)
  local player = newHero:GetPlayerOwner()
  local pID = player:GetPlayerID()

  CustomNetTables:SetTableValue( "players_dependencies", tostring(pID), {} );
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

  CustomNetTables:SetTableValue( "players_upgrades", tostring(pID), upgradeAbilities );

  --PrintTable(CustomNetTables:GetTableValue("players_upgrades", tostring(pID)))
end

function SetupUI(newHero)
  local player = newHero:GetPlayerOwner()
  local pID = player:GetPlayerID()

  --Send lumber and food info to users
  CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_ability_layouts", GameMode.abilityLayouts )

  --Send gold costs
  CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_gold_costs", GameMode.abilityGoldCosts )

  --Send xp table
  CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_xp_table", XP_PER_LEVEL_TABLE )

  --Send dependencies
  CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_dependencies_table", GameMode.DependenciesKVs )

  --Send special values
  CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_special_values_table", GameMode.specialValues )

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

  PETRI_GAME_HAS_STARTED = true

  Timers:CreateTimer((PETRI_FIRST_LOTTERY_TIME * 60),
    function()
      InitLottery()

      Timers:CreateTimer((PETRI_LOTTERY_TIME * 60),
      function()
        InitLottery()

        return (PETRI_LOTTERY_TIME * 60)
      end)
    end)
  
  Timers:CreateTimer((PETRI_EXIT_MARK * 60),
    function()
      PETRI_EXIT_ALLOWED = true
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

  -- Tips
  Timers:CreateTimer(((PETRI_FIRST_LOTTERY_TIME - 2) * 60),
    function()
      Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#lottery_notification", duration=4, style={color="white", ["font-size"]="45px"}})
    end)
end

function GameMode:InitGameMode()
  GameMode = self

  GameMode:_InitGameMode()

  GameMode.DependenciesKVs = LoadKeyValues("scripts/kv/dependencies.kv")

  GameMode.BuildingMenusKVs = LoadKeyValues("scripts/kv/building_menus.kv")

  GameMode.ShopKVs = LoadKeyValues("scripts/shops/petri_alpha_shops.txt")

  GameMode.UnitKVs = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  GameMode.HeroKVs = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  GameMode.AbilityKVs = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  GameMode.ItemKVs = LoadKeyValues("scripts/npc/npc_items_custom.txt")

  GameMode.abilityLayouts = {}
  GameMode.abilityGoldCosts = {}
  GameMode.specialValues = {}
  GameMode.buildingMenus = {}

  GameMode.SELECTED_UNITS = {}

  -- KVN Building menus
  for k,menu in pairs(GameMode.BuildingMenusKVs) do
    if type(menu) == "table" then
      GameMode.buildingMenus[k] = {}
      local i = 1
      for k1,v1 in pairs(menu) do
        GameMode.buildingMenus[k][i] = menu[tostring(i)]
        i = i + 1
      end
    end
  end

  -- Ability layouts
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

  -- Gold costs
  for ability_name,ability_info in pairs(GameMode.AbilityKVs) do
    if type(ability_info) == "table" then
      if ability_info["AbilityGoldCost"] ~= nil then
        GameMode.abilityGoldCosts[ability_name] = Split(ability_info["AbilityGoldCost"], " ")
      end  
    end
  end

  -- Special values
  for ability_name,ability_info in pairs(GameMode.AbilityKVs) do
    if type(ability_info) == "table" then
      if ability_info["AbilitySpecial"] ~= nil then
        GameMode.specialValues[ability_name] = {}
        for k,v in pairs(ability_info["AbilitySpecial"]) do
          for k1,v1 in pairs(v) do
            if k1 ~= "var_type" and k1 ~= "lumber_cost" and k1 ~= "food_cost" then
              table.insert(GameMode.specialValues[ability_name], k1)
            end
          end
        end
      end  
    end
  end

  -- Filter orders
  GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( GameMode, "FilterExecuteOrder" ), self )

  -- Fix hero bounties
  GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, "ModifyGoldFilter"), GameMode)

  -- Fix hero xp bounties
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

      newHero:SetAbilityPoints(5)
      newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_flat_joke"))
      newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_return"))
      newHero:UpgradeAbility(newHero:FindAbilityByName("petri_exploration_tower_explore_world"))
      newHero:UpgradeAbility(newHero:FindAbilityByName("petri_mini_actor_phase"))

      Timers:CreateTimer(0.03, function ()
        newHero.spawnPosition = newHero:GetAbsOrigin()
      end)
    end
    , 
  player:GetPlayerID())
end

function KVNWin(keys)
  local caster = keys.caster

  if PETRI_GAME_HAS_ENDED == false then
    PETRI_GAME_HAS_ENDED = true

    Notifications:TopToAll({text="#kvn_win", duration=100, style={color="green"}, continue=false})

    for i=1,14 do
      PlayerResource:SetCameraTarget(i-1, caster)
    end

    Timers:CreateTimer(5.0,
      function()
        GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS) 
      end)
  end
end

function PetrosyanWin()
  Notifications:TopToAll({text="#petrosyan_limit", duration=100, style={color="red"}, continue=false})

  Timers:CreateTimer(5.0,
    function()
      GameRules:SetGameWinner(DOTA_TEAM_BADGUYS) 
    end)
end