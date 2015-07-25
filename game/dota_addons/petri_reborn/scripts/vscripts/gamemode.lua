BAREBONES_DEBUG_SPEW = false

PETRI_TIME_LIMIT = 96
PETRI_EXIT_MARK = 24
PETRI_EXIT_WARNING = PETRI_TIME_LIMIT - 11

START_KVN_GOLD = 10
START_KVN_LUMBER = 150

START_PETROSYANS_GOLD = 32
START_MINI_ACTORS_GOLD = 15

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
          SetupUI(newHero)
          SetupUpgrades(newHero)

          GameMode.assignedPlayerHeroes[pID] = newHero

          PlayerResource:SetCustomPlayerColor(pID,PLAYER_COLORS[pID][1], 
          PLAYER_COLORS[pID][2],
          PLAYER_COLORS[pID][3])
        end, pID)
    end

    local friends = {}
    friends[0] = 96571761
    friends[1] = 63399181

     -- Init petrosyan
    if team == 3 then
      PrecacheUnitByNameAsync("npc_dota_hero_brewmaster",
        function() 
          newHero = CreateHeroForPlayer("npc_dota_hero_brewmaster", player)

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

          if PlayerResource:GetSteamAccountID(pID) == friends[0] or PlayerResource:GetSteamAccountID(pID) == friends[1] then 
            UpdateModel(newHero, "models/heroes/doom/doom.vmdl", 1.1)
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

function GameMode:FilterExecuteOrder( filterTable )
    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]

    if order_type == 19 then 
      if filterTable["entindex_target"] >= 6 or
        PlayerResource:GetTeam(issuer) == DOTA_TEAM_GOODGUYS then
        return false
      else
        local ent = EntIndexToHScript(filterTable["units"]["0"])

        if Entities:FindByName(nil,"PetrosyanShopTrigger"):IsTouching(ent) then
          local stashSlot = 6
          for i=6,11 do
            if ent:GetItemInSlot(i) == EntIndexToHScript(filterTable["entindex_ability"]) then
              stashSlot = i
              break
            end
          end

          ent:SwapItems(filterTable["entindex_target"], stashSlot)
        end
      end
    end

    for n,unit_index in pairs(units) do
        local unit = EntIndexToHScript(unit_index)
        local ownerID = unit:GetPlayerOwnerID()

        if PlayerResource:GetConnectionState(ownerID) == 3 or
          PlayerResource:GetConnectionState(ownerID) == 4
          then
          return false
        end
    end

    return true
end

function GameMode:ModifyGoldFilter(event)
  event["reliable"] = 0
  if event.reason_const == DOTA_ModifyGold_HeroKill then
    event["gold"] = 17 * (PlayerResource:GetKills(event.player_id_const) + 1)
  end
  return true
end

function GameMode:InitGameMode()
  GameMode = self

  GameMode:_InitGameMode()
  SendToServerConsole( "dota_combine_models 0" )

   -- Find all ability layouts to send them to clients later
  GameMode.UnitKVs = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  GameMode.HeroKVs = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  GameMode.AbilityKVs = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

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

  -- Commands
  Convars:RegisterCommand( "lumber", Dynamic_Wrap(GameMode, 'LumberCommand'), "Gives you lumber", FCVAR_CHEAT )

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

function GameMode:LumberCommand()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      GameMode.assignedPlayerHeroes[playerID].lumber = GameMode.assignedPlayerHeroes[playerID].lumber + 15000000
    end
  end
end