BAREBONES_DEBUG_SPEW = false

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

GameMode.DISABLED_HINTS_PLAYERS = {}

GameMode.PETRI_GAME_HAS_STARTED = false
GameMode.PETRI_GAME_HAS_ENDED = false

GameMode.PETRI_NO_END = false

GameMode.PETRI_NAME_LIST = {}
GameMode.PETRI_LANG_LIST = {}

GameMode.KVN_BONUS_ITEM = {}
for i=0,DOTA_MAX_PLAYERS do
  GameMode.KVN_BONUS_ITEM[i] = {}
  table.insert(GameMode.KVN_BONUS_ITEM[i], {item = "item_petri_kvn_bag_1", count = 1})
  table.insert(GameMode.KVN_BONUS_ITEM[i], {item = "item_petri_kvn_bag_2", count = 1})
  table.insert(GameMode.KVN_BONUS_ITEM[i], {item = "item_petri_kvn_bag_3", count = 1})
  table.insert(GameMode.KVN_BONUS_ITEM[i], {item = "item_petri_kvn_bag_4", count = 1})
end

GameMode.EXIT_COUNT = 0

GameMode.PETRI_ADDITIONAL_EXIT_GOLD_GIVEN = false
GameMode.PETRI_ADDITIONAL_EXIT_GOLD_TIME = 300
GameMode.PETRI_ADDITIONAL_EXIT_GOLD = 10000

GameMode.villians = {}
GameMode.kvns = {}

FUCKSCALEFORM = false

GameRules.Winner = GameRules.Winner or DOTA_TEAM_BADGUYS

check1 = (function(name) 
            for i=1,7 do
              if GameRules.PETRI_LOCK_ITEMS[i] == name then
                return true
              end
            end
            return false
          end)

check2 = (function(purchaser) 
            for i=0,5 do
              if purchaser:GetItemInSlot(i) and check1(purchaser:GetItemInSlot(i):GetName()) then
                return true
              end
            end
            return false
          end)

require('libraries/physics')
require('libraries/projectiles')
require('libraries/notifications')
require('libraries/attachments')
require('libraries/animations')
require('libraries/GameSetup')
require('libraries/KickSystem')
require('libraries/CustomBuildings')
require('libraries/StatUploaderFunctions')

require('libraries/buildinghelper')
require('libraries/dependencies')

require('units/kvn_fan')

require('buildings/bh_abilities')

require('balance')

require('settings')
require('internal/events')
require('events')

require('lottery')
require('scores')
require('autogold')
require('shop')

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

  -- for pID = 0, DOTA_MAX_PLAYERS do
  --   if IsValidPlayerID(pID) then
  --     PrecacheUnitByNameAsync("npc_dota_hero_death_prophet",
  --     function()
  --       for pID = 0, DOTA_MAX_PLAYERS do
  --         if IsValidPlayerID(pID) then
  --           PrecacheUnitByNameAsync("npc_dota_hero_rattletrap",
  --           function()
  --             for pID = 0, DOTA_MAX_PLAYERS do
  --               if IsValidPlayerID(pID) then
  --                 PrecacheUnitByNameAsync("npc_dota_hero_brewmaster",
  --                 function()

  --                 end, pID)
  --               end
  --             end
  --           end, pID)
  --         end
  --       end
  --     end, pID)
  --   end
  -- end
end

function GameMode:CreateHero(pID)
  GameMode.assignedPlayerHeroes = GameMode.assignedPlayerHeroes or {}
  
  local player = PlayerResource:GetPlayer(pID)
  local team = player:GetTeamNumber()

  local newHero

   -- Init kvn fan
  if team == 2 then
    -- UTIL_Remove(hero) 
    -- PrecacheUnitByNameAsync("npc_dota_hero_rattletrap",
    --   function() 
        Notifications:Top(pID, {text="#start_game", duration=5, style={color="white", ["font-size"]="45px"}})

        newHero = CreateHeroForPlayer("npc_dota_hero_rattletrap",player)

        InitAbilities(newHero)

        newHero:SetAbilityPoints(0)


        PrintTable(GameMode.KVN_BONUS_ITEM[pID])

        if GameMode.KVN_BONUS_ITEM[pID] then
          for k,v in pairs(GameMode.KVN_BONUS_ITEM[pID]) do
            for i=1,tonumber(v["count"]) do
              newHero:AddItemByName(v["item"])
            end  
          end
        end

        newHero.spawnPosition = newHero:GetAbsOrigin()
        
        InitHeroValues(newHero, pID)
        newHero.lumber = GameRules.START_KVN_LUMBER

        newHero.uniqueUnitList = {}

        SetupUI(newHero)
        SetupUpgrades(newHero)
        SetupDependencies(newHero)

        GameMode.assignedPlayerHeroes[pID] = newHero

        SetCustomGold( pID, GameRules.START_KVN_GOLD )

        newHero.kvnScore = 0

        Timers:CreateTimer(function (  )
          GameMode:SetupCustomSkin(newHero, PlayerResource:GetSteamAccountID(pID), "kvn")
          SetupVIPItems(newHero, PlayerResource:GetSteamAccountID(pID))
        end)

        table.insert(GameMode.kvns, newHero)
    --   end, 
    -- pID)
  end

  local petrosyanHeroName = "npc_dota_hero_brewmaster"
  if pID == PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, 2) then
    petrosyanHeroName = "npc_dota_hero_death_prophet"
  end

   -- Init petrosyan
  if team == 3 then
    -- UTIL_Remove(hero) 
    -- PrecacheUnitByNameAsync(petrosyanHeroName,
     -- function() 
        newHero = CreateHeroForPlayer(petrosyanHeroName,player)

        -- It's dangerous to go alone, take this
        newHero:SetAbilityPoints(4)
        newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_return"))
        newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_passive"))
        newHero:UpgradeAbility(newHero:FindAbilityByName("petri_exploration_tower_explore_world"))
        newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_flat_joke"))

        newHero:FindAbilityByName("petri_petrosyan_passive"):ApplyDataDrivenModifier(newHero, newHero, "dummy_sleep_modifier", {})

        newHero.spawnPosition = newHero:GetAbsOrigin()

        InitHeroValues(newHero, pID)

        SetupUI(newHero)

        GameMode.assignedPlayerHeroes[pID] = newHero

        SetCustomGold( pID, GameRules.START_PETROSYANS_GOLD )

        newHero.petrosyanScore = 0

        GameMode.villians[petrosyanHeroName] = newHero

        Timers:CreateTimer(function (  )
          if petrosyanHeroName ~= "npc_dota_hero_death_prophet" then
            GameMode:SetupCustomSkin(newHero, PlayerResource:GetSteamAccountID(pID), "petrosyan")
          else
            GameMode:SetupCustomSkin(newHero, PlayerResource:GetSteamAccountID(pID), "elena")
          end
        end)

        if GameRules.explorationTowerCreated == nil then
          GameRules.explorationTowerCreated = true
          Timers:CreateTimer(0.2,
          function()
            GameMode.explorationTower = CreateUnitByName( "npc_petri_exploration_tower" , Entities:FindAllByName("exploration_tower_position")[1]:GetAbsOrigin() , true, newHero, nil, DOTA_TEAM_BADGUYS )
            end)
        end
     -- end, pID)
  end

  for steamid,t in pairs(GameMode.StartItemsKVs) do
    if tonumber(steamid) == PlayerResource:GetSteamAccountID(pID) then
      for k,v in pairs(t) do
        if k == newHero:GetUnitName() then
          for k1,v1 in pairs(v) do
            newHero:AddItemByName(v1)
          end
          break
        end
      end
    end
  end
end

function InitHeroValues(hero, pID)
  hero.lumber = 0
  hero.bonusLumber = 0
  hero.food = 0
  hero.maxFood = 10
  hero.allEarnedGold = 0
  hero.allGatheredLumber = 0
  hero.numberOfUnits = 0
  hero.numberOfMegaWorkers = 0
  hero.buildingCount = 0

  GameMode.SELECTED_UNITS[pID] = {}
  GameMode.SELECTED_UNITS[pID]["0"] = hero:entindex()
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
  CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_builds", GameMode.ItemBuilds )

  --Send lumber and food info to users
  CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_items", GameMode.ItemKVs )

  --Send lumber and food info to users
  CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_shops", GameMode.shopsKVs )

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
end

function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  Shop:Init()
  
  GameMode.PETRI_GAME_HAS_STARTED = true

  -- PauseGame(true)

  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, DOTA_MAX_PLAYERS)

  GameMode:TimingScores( )
  GameMode:RegisterAutoGold( )

  local creepID = 1
  Timers:CreateTimer(6 * 60,
    function()
      if creepID == 8 then
        return
      end

      local ents = Entities:FindAllByName("npc_dota_creature")

      for k,v in pairs(ents) do
        if v.GetUnitName and v:GetUnitName() == "npc_petri_creep_special"..tostring(creepID) then
          local pos = v:GetAbsOrigin()

          UTIL_Remove(v)

          local unit = CreateUnitByName("npc_petri_creep_special"..tostring(creepID  + 1),pos,true,nil,nil,DOTA_TEAM_NEUTRALS)
        end
      end

      creepID = creepID + 1

      return 8.0 * 60
    end)

  Timers:CreateTimer(1.0,
    function()
      GameMode.PETRI_TRUE_TIME = GameMode.PETRI_TRUE_TIME + 1
      return 1.0
    end)

  Timers:CreateTimer((PETRI_FIRST_LOTTERY_TIME * 60),
    function()
      InitLottery()

      Timers:CreateTimer((PETRI_LOTTERY_TIME * 60),
      function()
        InitLottery()

        return (PETRI_LOTTERY_TIME * 60)
      end)
    end)
  
  Timers:CreateTimer((GameRules.PETRI_EXIT_MARK * 60),
    function()
      GameRules.PETRI_EXIT_ALLOWED = true
      Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#exit_notification", duration=4, style={color="white", ["font-size"]="45px"}})
    end)

  Timers:CreateTimer((GameRules.PETRI_EXIT_WARNING * 60),
    function()
      Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#exit_warning", duration=4, style={color="red", ["font-size"]="45px"}})
    end)

  Timers:CreateTimer((GameRules.PETRI_TIME_LIMIT * 60),
    function()
      PetrosyanWin()
    end)

  -- Tips
  Timers:CreateTimer(((PETRI_FIRST_LOTTERY_TIME - 2) * 60),
    function()
      Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#lottery_notification", duration=4, style={color="white", ["font-size"]="45px"}})
    end)

  -- Petrosyan tutorial
  tutorial_time = 0
  Timers:CreateTimer(
    function()
      Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {disabled_players = GameMode.DISABLED_HINTS_PLAYERS, loc_check = true, text="#petrosyans_tip_"..tostring(tutorial_time), duration=10, style={color="white", ["font-size"]="45px"}})

      tutorial_time = tutorial_time + 5
      return 5
    end)
end

function GameMode:InitGameMode()
  GameMode = self

  GameMode:_InitGameMode()

  GameMode.DependenciesKVs = LoadKeyValues("scripts/kv/dependencies.kv")

  GameMode.BuildingMenusKVs = LoadKeyValues("scripts/kv/building_menus.kv")

  GameMode.WallsKVs = LoadKeyValues("scripts/kv/walls.kv")

  GameMode.CustomSkinsKVs = LoadKeyValues("scripts/kv/custom_skins.kv")
  GameMode.CustomBuildingsKVs = LoadKeyValues("scripts/kv/custom_buildings.kv")
  GameMode.VIPItemsKVs = LoadKeyValues("scripts/kv/vip_items.kv")

  GameMode.ShopKVs = LoadKeyValues("scripts/shops/petri_1_radiant_shops.txt")

  GameMode.UnitKVs = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  GameMode.HeroKVs = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  GameMode.AbilityKVs = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  GameMode.ItemKVs = LoadKeyValues("scripts/npc/npc_items_custom.txt")

  GameMode.StartItemsKVs = LoadKeyValues("scripts/kv/start_items.kv")

  GameMode.shopsKVs = LoadKeyValues("scripts/shops/petri_1_radiant_shops.txt")

  GameMode.ItemBuilds = {}
  GameMode.ItemBuilds["npc_dota_hero_brewmaster"] = LoadKeyValues("itembuilds/default_brewmaster.txt")
  GameMode.ItemBuilds["npc_dota_hero_death_prophet"] = LoadKeyValues("itembuilds/default_death_prophet.txt")
  GameMode.ItemBuilds["npc_dota_hero_rattletrap"] = LoadKeyValues("itembuilds/default_rattletrap.txt")

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

  -- Fix gold bounties
  GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, "ModifyGoldFilter"), GameMode)

  -- Fix xp bounties
  GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(GameMode, "ModifyExperienceFilter"), GameMode)

  -- Commands
  Convars:RegisterCommand( "lumber", Dynamic_Wrap(GameMode, 'LumberCommand'), "Gives you lumber", FCVAR_CHEAT )
  Convars:RegisterCommand( "lag", Dynamic_Wrap(GameMode, 'LumberAndGoldCommand'), "Gives you lumber and gold", FCVAR_CHEAT )
  Convars:RegisterCommand( "taeg", Dynamic_Wrap(GameMode, 'TestAdditionalExitGold'), "Test for additional exit gold", FCVAR_CHEAT )
  Convars:RegisterCommand( "tspu", Dynamic_Wrap(GameMode, 'TestStaticPopup'), "Test static popup", FCVAR_CHEAT )
  Convars:RegisterCommand( "deg", Dynamic_Wrap(GameMode, 'DontEndGame'), "Dont end game", FCVAR_CHEAT )
  Convars:RegisterCommand( "getgold", Dynamic_Wrap(GameMode, 'GetGold'), "Get all gold", FCVAR_CHEAT )

  BuildingHelper:Init()

  --Update player's UI
  Timers:CreateTimer(0.03,
  function()
    
    if GameMode.assignedPlayerHeroes then
      for k,v in pairs(GameMode.assignedPlayerHeroes) do
        if GameMode.assignedPlayerHeroes[k] then
          AddKeyToNetTable(k, "players_resources", "lumber", v.lumber)
          AddKeyToNetTable(k, "players_resources", "food", v.food)
          AddKeyToNetTable(k, "players_resources", "maxFood", v.maxFood)
          AddKeyToNetTable(k, "players_resources", "gold", GetCustomGold( v:GetPlayerOwnerID() ))
        end
      end
    end

    return 0.03
  end)
end

function GameMode:ReplaceWithMiniActor(player, gold)
  PrecacheUnitByNameAsync("npc_dota_hero_storm_spirit",
    function() 
      -- GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)-1)

      player:SetTeam(DOTA_TEAM_BADGUYS)

      local newHero = PlayerResource:ReplaceHeroWith(player:GetPlayerID(), "npc_dota_hero_storm_spirit", GameRules.START_MINI_ACTORS_GOLD + gold, 0)

      newHero.spawnPosition = newHero:GetAbsOrigin()

      GameMode.assignedPlayerHeroes[player:GetPlayerID()] = newHero
      
      newHero:SetTeam(DOTA_TEAM_BADGUYS)

      newHero:RespawnHero(false, false, false)

      newHero:AddAbility("petri_petrosyan_flat_joke")

      newHero:SetAbilityPoints(4)
      newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_return"))
      newHero:UpgradeAbility(newHero:FindAbilityByName("petri_mini_actor_phase"))
      newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_passive"))
      newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_flat_joke"))

      GameMode:SetupCustomSkin(newHero, PlayerResource:GetSteamAccountID(player:GetPlayerID()), "miniactors")

      for k,v in pairs(newHero:GetChildren()) do
        if v:GetClassname() == "dota_item_wearable" then
          v:AddEffects(EF_NODRAW) 
        end
      end

      Timers:CreateTimer(0.03, function ()
        newHero.spawnPosition = newHero:GetAbsOrigin()
      end)
    end
    , 
  player:GetPlayerID())
end

function GameMode:SetupCustomSkin(hero, steamID, key)
  for k,v in pairs(GameMode.CustomSkinsKVs[key]) do
    local id = tonumber(k)

    if steamID == id then
      for k2,v2 in pairs(v) do
        if v2 == "model" then
          UpdateModel(hero, k2, 1)
        end
      end

      for k2,v2 in pairs(v) do
        if v2 == "scale" then
          hero:SetModelScale(tonumber(k2))
        end
      end

      for k2,v2 in pairs(v) do
        if v2 ~= "model" then
          Attachments:AttachProp(hero, v2, k2, nil)
        end
      end

      for k1,v1 in pairs(hero:GetChildren()) do
        if v1:GetClassname() == "dota_item_wearable" then
          v1:AddEffects(EF_NODRAW) 
        end
      end

      return true
    end
  end
  local localization = GameMode.PETRI_LANG_LIST[hero:GetPlayerID()]

  if localization and GameMode.CustomSkinsKVs[key][localization] then
    for k2,v2 in pairs(GameMode.CustomSkinsKVs[key][localization]) do
      if v2 == "model" then
        UpdateModel(hero, k2, 1)
      end
    end

    for k2,v2 in pairs(GameMode.CustomSkinsKVs[key][localization]) do
      if v2 ~= "model" then
        Attachments:AttachProp(hero, v2, k2, nil)
      end
    end

    for k2,v2 in pairs(hero:GetChildren()) do
      if v2:GetClassname() == "dota_item_wearable" then
        v2:AddEffects(EF_NODRAW) 
      end
    end

    if hero:GetUnitName() == "npc_dota_hero_brewmaster" then
      Wearables:AttachWearable(hero, "models/items/brewmaster/reddragon_arms/reddragon_arms.vmdl")
      Wearables:AttachWearable(hero, "models/items/brewmaster/reddragon_back/reddragon_back.vmdl")
      Wearables:AttachWearable(hero, "models/items/brewmaster/reddragon_offhand/reddragon_offhand.vmdl")
      Wearables:AttachWearable(hero, "models/items/brewmaster/reddragon_shoulder/reddragon_shoulder.vmdl")
      Wearables:AttachWearable(hero, "models/items/brewmaster/reddragon_weapon/reddragon_weapon.vmdl")
    elseif hero:GetUnitName() == "npc_dota_hero_death_prophet" then
      Wearables:AttachWearable(hero, "models/items/death_prophet/fatal_blossom_nails/fatal_blossom_nails.vmdl")
      Wearables:AttachWearable(hero, "models/items/death_prophet/burial_robes_armor/burial_robes_armor.vmdl")
      Wearables:AttachWearable(hero, "models/items/death_prophet/burial_robes_belt/burial_robes_belt.vmdl")
      Wearables:AttachWearable(hero, "models/items/death_prophet/burial_robes_legs/burial_robes_legs.vmdl")
      Wearables:AttachWearable(hero, "models/items/death_prophet/burial_robes_head/burial_robes_head.vmdl")
      Wearables:AttachWearable(hero, "models/items/death_prophet/burial_robes_vortex/burial_robes_vortex.vmdl")
    elseif hero:GetUnitName() == "npc_dota_hero_rattletrap" then
      Wearables:AttachWearable(hero, "models/items/rattletrap/forge_warrior_helm/forge_warrior_helm.vmdl")
      Wearables:AttachWearable(hero, "models/items/rattletrap/forge_warrior_claw/forge_warrior_claw.vmdl")
      Wearables:AttachWearable(hero, "models/items/rattletrap/forge_warrior_rocket_cannon/forge_warrior_rocket_cannon.vmdl")
      Wearables:AttachWearable(hero, "models/items/rattletrap/forge_warrior_steam_exoskeleton/forge_warrior_steam_exoskeleton.vmdl")
      Wearables:AttachWearable(hero, "particles/econ/items/clockwerk/clockwerk_mortar_forge/clockwerk_mortar_ambient.vpcf")
    elseif hero:GetUnitName() == "npc_dota_hero_storm_spirit" then
      Wearables:AttachWearable(hero, "models/items/storm_spirit/raikage_ares_armor/raikage_ares_armor.vmdl")
      Wearables:AttachWearable(hero, "models/items/storm_spirit/raikage_ares_arms/raikage_ares_arms.vmdl")
      Wearables:AttachWearable(hero, "models/items/storm_spirit/raikage_ares_head/raikage_ares_head.vmdl")
    end
  end
end

function SetupVIPItems(hero, steamID)
  for k,v in pairs(GameMode.VIPItemsKVs) do
    if k == tostring(steamID) then
      for item,count in pairs(v) do
        hero:AddItemByName(item)
      end
    end
  end
end

function KVNWin(keys)
  local caster = keys.caster

  if GameMode.PETRI_NO_END == false then
    if GameMode.PETRI_GAME_HAS_ENDED == false then
      GameMode.PETRI_GAME_HAS_ENDED = true

      Notifications:TopToAll({text="#kvn_win", duration=100, style={color="green"}, continue=false})

      for i=1,12 do
        PlayerResource:SetCameraTarget(i-1, caster)
      end

      Timers:CreateTimer(5.0,
        function()
          GameRules.Winner = DOTA_TEAM_GOODGUYS
          GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS) 
        end)
    end
  end
end

function PetrosyanWin()
  if GameMode.PETRI_NO_END == false then
    if GameMode.PETRI_GAME_HAS_ENDED == false then
      GameMode.PETRI_GAME_HAS_ENDED = true

      Notifications:TopToAll({text="#petrosyan_limit", duration=100, style={color="red"}, continue=false})
      Timers:CreateTimer(5.0,
        function()
          GameRules.Winner = DOTA_TEAM_BADGUYS
          GameRules:SetGameWinner(DOTA_TEAM_BADGUYS) 
        end)
    end
  end
end

if Wearables == nil then
    _G.Wearables = class({})
end

function Wearables:AttachWearable(unit, modelPath)
    local wearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelPath, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})

    wearable:FollowEntity(unit, true)

    unit.wearables = unit.wearables or {}
    table.insert(unit.wearables, wearable)

    return wearable
end

function Wearables:Remove(unit)
    if not unit.wearables or #unit.wearables == 0 then
        return
    end

    for _, part in pairs(unit.wearables) do
        part:RemoveSelf()
    end

    unit.wearables = {}
end

if LOADED then
  return
end
LOADED = true

GameMode.PETRI_TRUE_TIME = 0