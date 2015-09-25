-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.
-- Do not remove the GameMode:_Function calls in these events as it will mess with the internal barebones systems.

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
  DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  PrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid
  
  -- GameRules.deadKvnFansNumber = GameRules.deadKvnFansNumber or 0
  -- GameRules.deadKvnFansNumber = GameRules.deadKvnFansNumber + 1
end
-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  DebugPrint("[BAREBONES] GameRules State Changed")
  DebugPrintTable(keys)

  -- This internal handling is used to set up main barebones functions
  GameMode:_OnGameRulesStateChange(keys)
end

function GameMode:OnPause(data)
  PrintTable(data)
  PauseGame(false) 
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
  DebugPrint("[BAREBONES] NPC Spawned")
  DebugPrintTable(keys)

  -- This internal handling is used to set up main barebones functions
  GameMode:_OnNPCSpawned(keys)

  local npc = EntIndexToHScript(keys.entindex)
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
  --DebugPrint("[BAREBONES] Entity Hurt")
  --DebugPrintTable(keys)

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
    local entCause = EntIndexToHScript(keys.entindex_attacker)
    local entVictim = EntIndexToHScript(keys.entindex_killed)
  end
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
  DebugPrint( '[BAREBONES] OnItemPickedUp' )
  DebugPrintTable(keys)

  local itemname = keys.itemname
  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)

  if keys.HeroEntityIndex then
    local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
    local player = PlayerResource:GetPlayer(keys.PlayerID)

    if player:GetTeam() == DOTA_TEAM_GOODGUYS then 
      if CheckShopType(itemname) ~= 1 then
        heroEntity:DropItemAtPositionImmediate(itemEntity, heroEntity:GetAbsOrigin())
      end
    end
    if player:GetTeam() == DOTA_TEAM_BADGUYS then 
      if CheckShopType(itemname) == 1 then
        heroEntity:DropItemAtPositionImmediate(itemEntity, heroEntity:GetAbsOrigin())
      end
    end
  end
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
  DebugPrint( '[BAREBONES] OnPlayerReconnect' )
  --PrintTable(keys) 

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local hero = GameMode.assignedPlayerHeroes[keys.PlayerID]

  Timers:CreateTimer(0, function()
    if PlayerResource:GetConnectionState(keys.PlayerID) == DOTA_CONNECTION_STATE_CONNECTED then
      Timers:CreateTimer(1.25,
      function()
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

        --Set correct team
        if hero:GetTeam() == DOTA_TEAM_BADGUYS then
          player:SetTeam(DOTA_TEAM_BADGUYS)
        end
      end)

      Timers:CreateTimer(0.03,
      function()
        local event_data =
        {
            gold = GameMode.assignedPlayerHeroes[keys.PlayerID]:GetGold(),
            lumber = hero.lumber,
            food = hero.food,
            maxFood = hero.maxFood
        }
        CustomGameEventManager:Send_ServerToPlayer( player, "receive_resources_info", event_data )
        if PlayerResource:GetConnectionState(keys.PlayerID) == DOTA_CONNECTION_STATE_CONNECTED then return 0.03 end
      end)
    else
      return 0.03
    end
  end)
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
  DebugPrint( '[BAREBONES] OnItemPurchased' )
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
  DebugPrint('[BAREBONES] AbilityUsed')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityname = keys.abilityname

  if player.cursorStream ~= nil then
    if not (string.len(abilityname) > 14 and string.sub(abilityname,1,14) == "move_to_point_") then
      if not DontCancelBuildingGhostAbils[abilityname] then
        player:CancelGhost()
      else
        print(abilityname .. " did not cancel building ghost.")
      end
    end
  end
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
  DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
  DebugPrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
  DebugPrint('[BAREBONES] OnPlayerChangedName')
  DebugPrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
  DebugPrint('[BAREBONES] OnAbilityChannelFinished')
  DebugPrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
  DebugPrint('[BAREBONES] OnPlayerLevelUp')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
  DebugPrint('[BAREBONES] OnLastHit')
  DebugPrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
  DebugPrint('[BAREBONES] OnTreeCut')
  DebugPrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
  DebugPrint('[BAREBONES] OnRuneActivated')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_BOUNTY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
  DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  DebugPrint('[BAREBONES] OnPlayerPickHero')
  DebugPrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
  DebugPrint('[BAREBONES] OnTeamKillCredit')
  DebugPrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died
function GameMode:OnEntityKilled( keys )
  DebugPrint( '[BAREBONES] OnEntityKilled Called' )

  GameMode:_OnEntityKilled( keys )
  
  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless

  if killedUnit.hasNumber == true then
    local hero = GameMode.assignedPlayerHeroes[killedUnit:GetPlayerOwnerID()]
    hero.numberOfUnits = hero.numberOfUnits - 1
  end

  -- KVN fan is killed
  if killedUnit:GetUnitName() == "npc_dota_hero_rattletrap" then
    --Notifications:TopToAll({text=PlayerResource:GetPlayerName(killedUnit:GetPlayerOwnerID()) .." ".."#kvn_fan_is_dead", duration=4, style={color="red"}, continue=false})
    GameRules.deadKvnFansNumber = GameRules.deadKvnFansNumber or 0
    GameRules.deadKvnFansNumber = GameRules.deadKvnFansNumber + 1

    local allBuildings = Entities:FindAllByClassname("npc_dota_base_additive")
    local allCreeps = Entities:FindAllByClassname("npc_dota_creature")

    for k,v in pairs(allBuildings) do
      if v:GetPlayerOwnerID() == killedUnit:GetPlayerOwnerID() then
        DestroyEntityBasedOnHealth(killerEntity, v)
      end
    end

    for k,v in pairs(allCreeps) do
      if v:GetPlayerOwnerID() == killedUnit:GetPlayerOwnerID() then
        DestroyEntityBasedOnHealth(killerEntity, v)
      end
    end

    if PlayerResource:GetConnectionState(killedUnit:GetPlayerOwnerID()) ~= DOTA_CONNECTION_STATE_ABANDONED then
      GameMode:ReplaceWithMiniActor(killedUnit:GetPlayerOwner(), killedUnit:GetGold())
    end

    Timers:CreateTimer(1.0,
    function()
      if CheckKVN() then
        Notifications:TopToAll({text="#petrosyan_win", duration=10, style={color="RED"}, continue=false})

        for i=1,10 do
          PlayerResource:SetCameraTarget(i-1, killerEntity)
        end

        Timers:CreateTimer(2.0,
          function()
            GameRules:SetGameWinner(DOTA_TEAM_BADGUYS) 
          end)
      end
    end)
  end

  -- Idol is killed
  if killedUnit:GetUnitName() == "npc_petri_idol" then
    if killedUnit.newShopTarget then UTIL_Remove(killedUnit.newShopTarget) end
    if killedUnit.newShop then UTIL_Remove(killedUnit.newShop) end
  end

  -- Remove building
  if killedUnit:HasAbility("petri_building") then
    if killedUnit.RemoveBuilding ~= nil then killedUnit:RemoveBuilding(true) end
    local hero = GameMode.assignedPlayerHeroes[killedUnit:GetPlayerOwnerID()]
    if hero then
      hero.buildingCount = hero.buildingCount - 1
    end

    local chance = math.random(1, 100)
    if killerEntity:GetTeam() ~= killedUnit:GetTeam() then
      if chance > DEFENCE_SCROLL_CHANCE then
        CreateItemOnPositionSync(killedUnit:GetAbsOrigin(), CreateItem("item_petri_defence_scroll", nil, nil)) 
      elseif chance > ATTACK_SCROLL_CHANCE then
        CreateItemOnPositionSync(killedUnit:GetAbsOrigin(), CreateItem("item_petri_attack_scroll", nil, nil)) 
      elseif chance > GOLD_COIN_CHANCE then
        CreateItemOnPositionSync(killedUnit:GetAbsOrigin(), CreateItem("item_petri_gold_coin", nil, nil)) 
      elseif chance > WOOD_CHANCE then
        CreateItemOnPositionSync(killedUnit:GetAbsOrigin(), CreateItem("item_petri_pile_of_wood", nil, nil)) 
      end
    end
  end

  if killedUnit.childEntity then
    UTIL_Remove(killedUnit.childEntity)
  end
  
  -- Petrosyn is killed
  if killedUnit:GetUnitName() == "npc_dota_hero_brewmaster" or
  killedUnit:GetUnitName() == "npc_dota_hero_death_prophet" or
  killedUnit:GetUnitName() == "npc_dota_hero_storm_spirit"  then
    -- if killerEntity:GetPlayerOwnerID() ~= nil then
    --   Notifications:TopToAll({text="#petrosyan_is_killed" .. PlayerResource:GetPlayerName(killerEntity:GetPlayerOwnerID()), duration=4, style={color="yellow"}, continue=false})
    -- end
    killedUnit.teleportationState = 0
    killedUnit:SetTimeUntilRespawn(30.0)
    Timers:CreateTimer(30.0,
    function()
      killedUnit:RespawnHero(false, false, false)
    end)
  end

  if killedUnit.foodProvided ~= nil then
    local hero = GameMode.assignedPlayerHeroes[killedUnit:GetPlayerOwnerID()]

    hero.maxFood = hero.maxFood - killedUnit.foodProvided
  end

  if killedUnit.foodSpent ~= nil then
    local hero = GameMode.assignedPlayerHeroes[killedUnit:GetPlayerOwnerID()]

    hero.food = hero.food - killedUnit.foodSpent
  end

  if string.match(killedUnit:GetUnitName (), "cop") then
    GameMode.assignedPlayerHeroes[killedUnit:GetPlayerOwnerID()].copIsPresent = false
  end

  if string.match(killedUnit:GetUnitName (), "peasant") then
    killedUnit:RemoveModifierByName("modifier_chopping_wood")
    killedUnit:RemoveModifierByName("modifier_gathering_lumber")
    killedUnit:RemoveModifierByName("modifier_chopping_wood_animation")

    killedUnit:RemoveModifierByName("modifier_repairing")
    killedUnit:RemoveModifierByName("modifier_chopping_building")
    killedUnit:RemoveModifierByName("modifier_chopping_building_animation")
  end

  -- Respawn creep
  if string.match(killedUnit:GetUnitName (), "npc_petri_creep_") then
    if GameRules:IsDaytime() == false then

      killerEntity:CastAbilityNoTarget(killerEntity:FindAbilityByName("petri_petrosyan_return"), killerEntity:GetPlayerOwnerID())
      Notifications:Bottom(killerEntity:GetPlayerOwnerID(), {text="#no_farm_tonight", duration=5, style={color="red", ["font-size"]="45px"}})
      
      Timers:CreateTimer(0.04,
      function()
        MoveCamera(killerEntity:GetPlayerOwnerID(), killerEntity)
      end)
      
    end
    Timers:CreateTimer(0.5,
    function()
      CreateUnitByName(killedUnit:GetUnitName(), killedUnit:GetAbsOrigin(),true, nil,nil,DOTA_TEAM_NEUTRALS)
    end)
  end
end

-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
  DebugPrint('[BAREBONES] PlayerConnect')
  DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
  DebugPrint('[BAREBONES] OnConnectFull')

  GameMode:_OnConnectFull(keys)
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)

  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
  DebugPrint('[BAREBONES] OnIllusionsCreated')
  DebugPrintTable(keys)

  local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
  DebugPrint('[BAREBONES] OnItemCombined')
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end
  local player = PlayerResource:GetPlayer(plyID)

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
  DebugPrint('[BAREBONES] OnAbilityCastBegins')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
  DebugPrint('[BAREBONES] OnTowerKill')
  DebugPrintTable(keys)

  local gold = keys.gold
  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
  DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.player_id)
  local success = (keys.success == 1)
  local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
  DebugPrint('[BAREBONES] OnNPCGoalReached')
  DebugPrintTable(keys)

  local goalEntity = EntIndexToHScript(keys.goal_entindex)
  local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
  local npc = EntIndexToHScript(keys.npc_entindex)
end

function GameMode:OnPlayerSelectedEntities( event )
  local pID = event.pID

  GameMode.SELECTED_UNITS[pID] = event.selected_entities
end

function GameMode:OnPlayerSendName( event )
  local pID = event.pID
  local name = event.name

  GameMode.PETRI_NAME_LIST[pID] = name
end

function GameMode:OnPlayerMakeBet( event )
  local pID = event.pID
  local bet = event.bet
  local option = event.option

  if GameMode.LOTTERY_STATE == 0 then
    return false
  end

  GameMode.CURRENT_BANK = GameMode.CURRENT_BANK + bet

  if not GameMode.CURRENT_LOTTERY_PLAYERS[tostring(pID)] then 
    GameMode.CURRENT_LOTTERY_PLAYERS[tostring(pID)]           = {}
    GameMode.CURRENT_LOTTERY_PLAYERS[tostring(pID)]["option"] = option
    GameMode.CURRENT_LOTTERY_PLAYERS[tostring(pID)]["bet"]    = bet
  end

  GameMode.assignedPlayerHeroes[pID]:ModifyGold(bet * -1, false, 0)

  CustomGameEventManager:Send_ServerToAllClients("petri_bank_updated", {["bank"] = GameMode.CURRENT_BANK} )
end

function GameMode:OnPlayerSay( event )
  local pID = event.userid
  local text = event.text

  if text == "-disablehints" then
    table.insert(DISABLED_HINTS_PLAYERS, pID-1)
  end
end