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

  -- local newState = GameRules:State_Get()

  -- if GameRules:State_Get() == 2 then
  --   local players = {}
  --   for i=1,10 do
  --     local pID = i-1
  --     local player = PlayerResource:GetPlayer(pID)
  --     local team = PlayerResource:GetTeam(pID)

  --     if player == nil then
  --       goto continue
  --     end

  --     if team == DOTA_TEAM_GOODGUYS then
  --       PrecacheUnitByNameAsync("npc_dota_hero_rattletrap",
  --       function() 
  --         Notifications:Top(pID, {text="#start_game", duration=5, style={color="white", ["font-size"]="45px"}})

  --         newHero = CreateHeroForPlayer("npc_dota_hero_rattletrap", player)

  --         InitAbilities(newHero)

  --         newHero:SetAbilityPoints(0)

  --         newHero:AddItemByName("item_petri_kvn_fan_blink")
  --         newHero:AddItemByName("item_petri_give_permission_to_build")
  --         newHero:AddItemByName("item_petri_gold_bag")

  --         newHero.spawnPosition = newHero:GetAbsOrigin()

  --         newHero:SetGold(10, false)

  --         player.lumber = 150
  --       end, pID)
  --     elseif team == DOTA_TEAM_BADGUYS then
  --       PrecacheUnitByNameAsync("npc_dota_hero_brewmaster",
  --       function() 
  --         newHero = CreateHeroForPlayer("npc_dota_hero_brewmaster", player)
  --         newHero:SetControllableByPlayer(pID, true)
  --         newHero:SetPlayerID(pID)

  --         -- It's dangerous to go alone, take this
  --         newHero:SetAbilityPoints(4)
  --         newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_flat_joke"))
  --         newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_return"))
  --         newHero:UpgradeAbility(newHero:FindAbilityByName("petri_petrosyan_dummy_sleep"))

  --         newHero:SetGold(32, false)

  --         newHero.spawnPosition = newHero:GetAbsOrigin()

  --         if GameRules.explorationTowerCreated == nil then
  --           GameRules.explorationTowerCreated = true
  --           Timers:CreateTimer(0.2,
  --           function()
  --             CreateUnitByName( "npc_petri_exploration_tower" , Vector(784,1164,129) , true, nil, nil, DOTA_TEAM_BADGUYS )
  --             end)
  --         end
  --       end, pID)
  --     end

  --     -- We don't need 'undefined' variables
  --     player.food = 0
  --     player.maxFood = 10
  --     player.lumber = player.lumber or 0

  --     --Send lumber and food info to users
  --     CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_ability_layouts", GameMode.abilityLayouts )

  --     --Update player's UI
  --     Timers:CreateTimer(0.03,
  --     function()
  --       local event_data =
  --       {
  --           gold = PlayerResource:GetGold(player:GetPlayerID()),
  --           lumber = player.lumber,
  --           food = player.food,
  --           maxFood = player.maxFood
  --       }
  --       CustomGameEventManager:Send_ServerToPlayer( player, "receive_resources_info", event_data )
  --       return 0.35
  --     end)

  --     ::continue::
  --   end
  -- end
end

function GameMode:CreateHeroes()
  --print("Game State Changed: " .. GameRules:State_Get())
  --print("Hero Selection State: " .. DOTA_GAMERULES_STATE_HERO_SELECTION)
  
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

  local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname

  if player:GetTeam() == DOTA_TEAM_GOODGUYS then 
    heroEntity:DropItemAtPositionImmediate(itemEntity, heroEntity:GetAbsOrigin())
  end
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
  DebugPrint( '[BAREBONES] OnPlayerReconnect' )
  --PrintTable(keys) 

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local hero = player:GetAssignedHero()

  Timers:CreateTimer(0, function()
    if PlayerResource:GetConnectionState(keys.PlayerID) == DOTA_CONNECTION_STATE_CONNECTED then
      Timers:CreateTimer(1,
      function()
        CustomGameEventManager:Send_ServerToPlayer( player, "petri_set_ability_layouts", GameMode.abilityLayouts )
      end)

      Timers:CreateTimer(0.03,
      function()
        local event_data =
        {
            gold = PlayerResource:GetGold(player:GetPlayerID()),
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

  -- KVN fan is killed
  if killedUnit:GetUnitName() == "npc_dota_hero_rattletrap" then
    --Notifications:TopToAll({text=PlayerResource:GetPlayerName(killedUnit:GetPlayerOwnerID()) .." ".."#kvn_fan_is_dead", duration=4, style={color="red"}, continue=false})
    
    GameRules.deadKvnFansNumber = GameRules.deadKvnFansNumber or 0
    GameRules.deadKvnFansNumber = GameRules.deadKvnFansNumber + 1

    if GameRules.deadKvnFansNumber == PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) then
      Notifications:TopToAll({text="#petrosyan_win", duration=10, style={color="RED"}, continue=false})

      for i=1,10 do
        PlayerResource:SetCameraTarget(i-1, killerEntity)
      end

      Timers:CreateTimer(2.0,
        function()
          GameRules:SetGameWinner(DOTA_TEAM_BADGUYS) 
        end)
    end
  end

  -- Petrosyn is killed
  if killedUnit:GetUnitName() == "npc_dota_hero_brewmaster" then
    -- if killerEntity:GetPlayerOwnerID() ~= nil then
    --   Notifications:TopToAll({text="#petrosyan_is_killed" .. PlayerResource:GetPlayerName(killerEntity:GetPlayerOwnerID()), duration=4, style={color="yellow"}, continue=false})
    -- end
    killedUnit:SetTimeUntilRespawn(30.0)
    Timers:CreateTimer(30.0,
    function()
      killedUnit:RespawnHero(false, false, false)
    end)
  end

  -- Remove building
  if killedUnit:HasAbility("petri_building") and killedUnit.RemoveBuilding ~= nil then
    killedUnit:RemoveBuilding(true)
  end

  if killedUnit.foodProvided ~= nil then
    local hero = GameMode.assignedPlayerHeroes[killedUnit:GetPlayerOwnerID()]

    hero.maxFood = hero.maxFood - killedUnit.foodProvided
  end

  if killedUnit.foodSpent ~= nil then
    local hero = GameMode.assignedPlayerHeroes[killedUnit:GetPlayerOwnerID()]

    hero.food = hero.food - killedUnit.foodSpent
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
    Timers:CreateTimer(0.73,
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
  DebugPrintTable(keys)

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