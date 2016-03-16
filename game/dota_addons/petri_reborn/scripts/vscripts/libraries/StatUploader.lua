local statSettings = LoadKeyValues('scripts/kv/StatUploaderSettings.kv')

SU = {}

function SU:Init() 
  ListenToGameEvent('game_rules_state_change', 
    function(keys)
      local state = GameRules:State_Get()

      if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        SU:AddPlayers()
      elseif state == DOTA_GAMERULES_STATE_POST_GAME then
        SU:SavePlayersStats()
      end
    end, nil)
end

-- Request function
function SU:SendRequest( requestParams, successCallback )
  -- Adding auth key
  requestParams.AuthKey = statSettings.AuthKey
  -- DeepPrintTable(requestParams)

  -- Create the request
  local request = CreateHTTPRequest('POST', statSettings.Host)
  request:SetHTTPRequestGetOrPostParameter('CommandParams', json.encode(requestParams))

  -- Send the request
  request:Send(function(res)
    if res.StatusCode ~= 200 or not res.Body then
        print("Request error. See info below: ")
        DeepPrintTable(res)
        return
    end

    -- Try to decode the result
    local obj, pos, err = json.decode(res.Body, 1, nil)
    
    -- if not a JSON send full body
    if obj == nil then
      obj = res.Body
    end
    
    -- Feed the result into our callback
    successCallback(obj)
  end)
end

function SU:AddPlayers()
  local requestParams = {
    Command = "AddPlayers",
    SteamIDs = SU:BuildSteamIDArray()
  }
    
  SU:SendRequest( requestParams, function(obj)
      print("Adding players: ", obj)
      SU:LoadPlayersStats()
  end)
end

function SU:LoadPlayersStats()
  local requestParams = {
    Command = "LoadPlayersStats",
    SteamIDs = SU:BuildSteamIDArray()
  }
    
  SU:SendRequest( requestParams, function(obj)
      SU.LoadedStats = obj
      CustomGameEventManager:Send_ServerToAllClients( "su_send_mmr", SU.LoadedStats )
      
      print("Loaded players: ")
      PrintTable(SU.LoadedStats)      
  end)
end

function SU:SavePlayersStats()
  local requestParams = {
    Command = "SavePlayersStats",
    PlayersStats = SU:BuildMMRArray()
  }
    
  SU:SendRequest( requestParams, function(obj)
    PrintTable("Saved MMR: ", obj)
  end)
end

function SU:BuildSteamIDArray()
    local players = {}
    for playerID = 0, DOTA_MAX_PLAYERS do
      if PlayerResource:IsValidPlayerID(playerID) then
        if not PlayerResource:IsBroadcaster(playerID) then
          table.insert(players, PlayerResource:GetSteamAccountID(playerID))
        end
      end
    end

    print("dick")
    PrintTable(players)

    return players
end

function SU:GetPlayerMMR( steamID, team )
  for k,v in pairs(SU.LoadedStats) do
    print("-----")
    print(v.SteamID)
    print("equals")
    print(steamID)
    print("-----")
    if v.SteamID == steamID then
      if team == DOTA_TEAM_BADGUYS then
        return v.PetriRating or 3000
      else
        return v.KVNRating or 3000
      end
    end
  end
end

function SU:GetGameCount( steamID, team )
  for k,v in pairs(SU.LoadedStats) do
    if v.SteamID == steamID then
      if team == DOTA_TEAM_BADGUYS then
        return v.PetriGames or 0 
      else
        return v.KVNGames or 0
      end
    end
  end
end

function SU:GetWonGameCount( steamID, team )
  for k,v in pairs(SU.LoadedStats) do
    if v.SteamID == steamID then
      if team == DOTA_TEAM_BADGUYS then
        return v.PetriWins or 0
      else
        return v.KVNWins or 0
      end
    end
  end
end

function SU:GetTop3MMRKVN()
    local mmr = {}
    for playerID = 0, DOTA_MAX_PLAYERS do
      if PlayerResource:IsValidPlayerID(playerID) then
        if not PlayerResource:IsBroadcaster(playerID) then
          if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
            local hero = GameMode.assignedPlayerHeroes[playerID] or PlayerResource:GetSelectedHeroEntity(playerID)

            if hero and hero:GetUnitName() ~= "npc_dota_hero_name" then
              table.insert(mmr, SU:GetPlayerMMR(PlayerResource:GetSteamAccountID(playerID), DOTA_TEAM_GOODGUYS) or 3000)
            end
          end
        end
      end
    end

    DeepPrintTable(mmr)

    table.sort(mmr)

    DeepPrintTable(mmr)

    DeepPrintTable(ReverseTable(mmr))

    return ReverseTable(mmr)
end

function SU:GetPetriMMR()
    local mmr = 0
    for playerID = 0, DOTA_MAX_PLAYERS do
      if PlayerResource:IsValidPlayerID(playerID) then
        if not PlayerResource:IsBroadcaster(playerID) then
          if PlayerResource:GetTeam(playerID) == DOTA_TEAM_BADGUYS then
            local hero = GameMode.assignedPlayerHeroes[playerID] or PlayerResource:GetSelectedHeroEntity(playerID)

            if hero and hero:GetUnitName() ~= "npc_dota_hero_name" and hero:GetUnitName() ~= "npc_dota_hero_storm_spirit" then
              mmr = mmr + SU:GetPlayerMMR(PlayerResource:GetSteamAccountID(playerID), DOTA_TEAM_BADGUYS) or 3000
            end
          end
        end
      end
    end

    return mmr
end

function SU:BuildMMRArray()

    local top_kvn_mmr = SU:GetTop3MMRKVN()

    local kvn_mmr = top_kvn_mmr[1] + top_kvn_mmr[2] + top_kvn_mmr[3]
    local petri_mmr = SU:GetPetriMMR()

    local players = {}

    for playerID = 0, DOTA_MAX_PLAYERS do
      if PlayerResource:IsValidPlayerID(playerID) then
        if not PlayerResource:IsBroadcaster(playerID) then
          local hero = GameMode.assignedPlayerHeroes[playerID] or PlayerResource:GetSelectedHeroEntity(playerID)
          local team = hero:GetTeamNumber()

          local steam_id = PlayerResource:GetSteamAccountID(playerID)

          local player_petr_mmr = SU:GetPlayerMMR( steam_id, DOTA_TEAM_BADGUYS )
          local player_kvn_mmr = SU:GetPlayerMMR( steam_id, DOTA_TEAM_GOODGUYS )

          local petri_games = SU:GetGameCount( steam_id, DOTA_TEAM_BADGUYS )
          local kvn_games = SU:GetGameCount( steam_id, DOTA_TEAM_GOODGUYS )

          local won_petri_games = SU:GetWonGameCount( steam_id, DOTA_TEAM_BADGUYS )
          local won_kvn_games = SU:GetWonGameCount( steam_id, DOTA_TEAM_GOODGUYS )

          if hero and hero:GetUnitName() ~= "npc_dota_hero_name" then
            if team == DOTA_TEAM_GOODGUYS then
              if team == GameRules.Winner then
                player_kvn_mmr = player_kvn_mmr + clamp(50-((kvn_mmr/3)-(petri_mmr/2))/50, 5, 100)
                kvn_games = kvn_games + 1
                won_kvn_games = won_kvn_games + 1
              end
            else
              if hero:GetUnitName() ~= "npc_dota_hero_storm_spirit" then
                if team == GameRules.Winner then
                  player_petr_mmr = player_petr_mmr + clamp(50-((petri_mmr/2)-(kvn_mmr/3))/50, 5, 100)
                  won_petri_games = won_petri_games + 1
                else
                  player_petr_mmr = player_petr_mmr + clamp(-50-((petri_mmr/2)-(kvn_mmr/3))/50, -100, -5)
                  won = false
                end
                petri_games = petri_games + 1
              else
                if hero:GetKills() >= 1 or (PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED and (hero.hooked or hero:GetLevel() == 80)) then
                  player_kvn_mmr = player_kvn_mmr
                else
                  player_kvn_mmr = player_kvn_mmr + clamp(-50-((kvn_mmr/3)-(petri_mmr/2))/50, -100, -5)
                end
                kvn_games = kvn_games + 1
              end
            end
          end

          -- Date parsing
          local month, day, year = string.match(GetSystemDate(), '(%d+)[/](%d+)[/](%d+)')
        
          table.insert(players, {
            SteamID = steam_id, 
            KVNGames = kvn_games, 
            KVNWins = won_kvn_games, 
            PetriGames = petri_games, 
            PetriWins = won_petri_games, 
            KVNRating = player_kvn_mmr, 
            PetriRating = player_petr_mmr, 
            LastGameDate = string.format("20%s%s%s", year, month, day)
            })
        end
      end
    end

    DeepPrintTable(players)

    return players
end

-- Testing event
CustomGameEventManager:RegisterListener( "su_test_request", Dynamic_Wrap(SU, 'Test'))

-- tools
function clamp( _in, low, high )
  if (_in < low ) then return low end
  if (_in > high ) then return high end
  return _in
end

function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end