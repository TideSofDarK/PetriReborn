-- The overall game state has changed
function GameMode:_OnGameRulesStateChange(keys)
  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
    GameMode:OnAllPlayersLoaded()
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    GameMode:PostLoadPrecache()
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    GameMode:OnGameInProgress()

    self.spawnQueueID = -1

    self.spawnDelay = 2.25

    EasyTimers:CreateTimer(function()
      if not self.heroesSpawned then
        PauseGame(true)
        return 0.03
      else
        PauseGame(false)
      end
    end, 'auto_pause', 0.03)

    EasyTimers:CreateTimer(function()
      PauseGame(true)
      self.playerQueue = function ()
          self.spawnQueueID = self.spawnQueueID + 1

          -- Update queue info
          CustomGameEventManager:Send_ServerToAllClients("petri_spawning_queue", {queue = self.spawnQueueID})

          -- End pause if every player is checked
          if self.spawnQueueID > 24 then
              self.spawnQueueID = nil
              self.heroesSpawned = true
              return
          end

          if PlayerResource:GetConnectionState(self.spawnQueueID) < 1 then
            self.playerQueue()
            return
          end

          -- Keep spawning
          EasyTimers:CreateTimer(function()
            -- Skip disconnected players
            if PlayerResource:GetConnectionState(self.spawnQueueID) < 1 then
                self.playerQueue()
                return
            else
                local color = PLAYER_COLORS[self.spawnQueueID]
                if color then
                  PlayerResource:SetCustomPlayerColor(self.spawnQueueID, color[1], color[2], color[3])
                end
                GameMode:CreateHero(self.spawnQueueID, self.playerQueue)
                return
            end
          end, DoUniqueString('spawning'), self.spawnDelay)
      end

      self.playerQueue()
    end, 'spawning_start', 1.0)
  end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:_OnNPCSpawned(keys)
  local npc = EntIndexToHScript(keys.entindex)

  if npc:IsRealHero() and npc.bFirstSpawned == nil then
    npc.bFirstSpawned = true
    -- GameMode.spawnedArray = GameMode.spawnedArray or {}

    -- if not GameMode.spawnedArray[npc:GetPlayerID()] then
    --   GameMode:OnHeroInGame(npc:GetPlayerID(), npc:GetTeamNumber(), npc)
    --   GameMode.spawnedArray[npc:GetPlayerID()] = true
    -- end
  end
end

-- An entity died
function GameMode:_OnEntityKilled( keys )
  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  if killedUnit:IsRealHero() then
    DebugPrint("KILLED, KILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
    if END_GAME_ON_KILLS and GetTeamHeroKills(killerEntity:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
      GameRules:SetSafeToLeave( true )
      GameRules:SetGameWinner( killerEntity:GetTeam() )
    end

    --PlayerResource:GetTeamKills
    if SHOW_KILLS_ON_TOPBAR then
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS) )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS) )
    end
  end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:_OnConnectFull(keys)
  GameMode:_CaptureGameMode()

  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)

  local userID = keys.userid

  self.vUserIds = self.vUserIds or {}
  self.vUserIds[userID] = ply
end
