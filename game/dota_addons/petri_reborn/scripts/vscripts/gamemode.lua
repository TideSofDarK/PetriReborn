BAREBONES_DEBUG_SPEW = false

PETRI_TIME_LIMIT = 55
PETRI_EXIT_MARK = 20

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

          newHero.spawnPosition = newHero:GetAbsOrigin()

          newHero:SetGold(10, false)
          newHero.lumber = 150
          newHero.bonusLumber = 0
          newHero.food = 0
          newHero.maxFood = 10
          SetupUI(newHero)

          GameMode.assignedPlayerHeroes[pID] = newHero
        end, pID)
    end

     -- Init petrosyan
    if team == 3 then
      PrecacheUnitByNameAsync("npc_dota_hero_brewmaster",
        function() 
          newHero = CreateHeroForPlayer("npc_dota_hero_brewmaster", player)

          -- It's dangerous to go alone, take this
          newHero:SetAbilityPoints(4)
          newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_flat_joke"))
          newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_return"))
          newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_dummy_sleep"))

          newHero.spawnPosition = newHero:GetAbsOrigin()

          newHero:SetGold(32, false)
          newHero.lumber = 0
          newHero.food = 0
          newHero.maxFood = 0
          SetupUI(newHero)

          GameMode.assignedPlayerHeroes[pID] = newHero

          if GameRules.explorationTowerCreated == nil then
            GameRules.explorationTowerCreated = true
            Timers:CreateTimer(0.2,
            function()
              CreateUnitByName( "npc_petri_exploration_tower" , Vector(784,1164,129) , true, nil, nil, DOTA_TEAM_BADGUYS )
              end)
          end
        end, pID)
    end
  end
end

function SetupUI(newHero)
  local player = newHero:GetPlayerOwner()

  --Send lumber and food info to users
  CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_ability_layouts", GameMode.abilityLayouts )

  --Update player's UI
  Timers:CreateTimer(0.03,
  function()
    local event_data =
    {
        gold = PlayerResource:GetGold(newHero:GetPlayerOwnerID()),
        lumber = newHero.lumber,
        food = newHero.food,
        maxFood = newHero.maxFood
    }
    CustomGameEventManager:Send_ServerToPlayer( player, "receive_resources_info", event_data )
    if PlayerResource:GetConnectionState(player:GetPlayerID()) == DOTA_CONNECTION_STATE_CONNECTED then return 0.35 end
  end)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  Timers:CreateTimer(PETRI_EXIT_MARK * 60,
    function()
      Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#exit_notification", duration=4, style={color="white", ["font-size"]="45px"}})
    end)

  Timers:CreateTimer((PETRI_TIME_LIMIT - 9 - 2) * 60,
    function()
      Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#exit_warning", duration=4, style={color="red", ["font-size"]="45px"}})
    end)

  Timers:CreateTimer(PETRI_TIME_LIMIT * 60,
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
  if event.reason_const == DOTA_ModifyGold_HeroKill then
    PlayerResource:ModifyGold(event.player_id_const, 100,false,DOTA_ModifyGold_HeroKill )
    return false
  end
  return true
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

  -- Some way to prevent controlling of disconnected players
  GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( GameMode, "FilterExecuteOrder" ), self )

  -- Fix hero bounties
  GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, "ModifyGoldFilter"), GameMode)

  BuildingHelper:Init()
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