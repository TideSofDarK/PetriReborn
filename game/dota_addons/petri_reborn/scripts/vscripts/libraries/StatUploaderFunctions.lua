require('libraries/StatUploader')
local isTest = false
GameMode.steamIDs = {}

ListenToGameEvent('game_rules_state_change', 
  function(keys)
    local state = GameRules:State_Get()

    if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
      SU:Init()
    end
  end, nil)

SU.LoadedKVNMMR = {}

function SU:Init()
  GameMode.steamIDs = SU:BuildSteamIDArray()
  if SU.StatSettings ~= nil then
    if true then
      ListenToGameEvent('game_rules_state_change', 
        function(keys)
          local state = GameRules:State_Get()

          if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
            -- Timers:CreateTimer(0.03, function (  )
              SU:LoadPlayersStats()
            -- end)
          elseif state == DOTA_GAMERULES_STATE_POST_GAME then
            SU:SavePlayersStats()
          elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
            Timers:CreateTimer(1.0, function (  )
              SU.LoadedKVNMMR = SU:GetTop3MMRKVN()
              if GetTableLength(GameMode.steamIDs) == 0 then
                GameMode.steamIDs = SU:BuildSteamIDArray()
              end
            end)
          end
        end, nil)
    else
      print("Bad stat recording conditions.")
    end    
  else
    print("StatUploader settings file not found.")
  end
end

function SU:LoadPlayersStats()
  local requestParams = {
    Command = "LoadPlayersStats",
    SteamIDs = GameMode.steamIDs
  }
    
  SU:SendRequest( requestParams, function(obj)
      -- print(obj)
      SU.LoadedStats = obj
      CustomGameEventManager:Send_ServerToAllClients( "su_send_mmr", obj )
      
      print("Loaded players: ")
      -- PrintTable(SU.LoadedStats)   
  end)
end

function SU:SavePlayersStats()
  local time = math.ceil(GameMode.PETRI_TRUE_TIME / 60)
  if time < 9 or time > 50  then --or not GameMode.villians["npc_dota_hero_death_prophet"]
    print("sdasdasdsassssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss")
    -- return
  end
  print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
  local requestParams = {
    Command = "SavePlayersStats",
    PlayersStats = SU:BuildMMRArray()
  }
    
  SU:SendRequest( requestParams, function(obj)
    -- PrintTable("Saved MMR: ", obj)
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

    return players
end

function SU:GetStatValue( steamID, team, statName )
  for k,v in pairs(SU.LoadedStats) do
    if v.SteamID == tostring(steamID) then
      
      if statName == "mmr" then
        return ((team == DOTA_TEAM_BADGUYS and v.PetriRating) or v.KVNRating) or 3000
      elseif statName == 'games' then
        return ((team == DOTA_TEAM_BADGUYS and v.PetriGames) or v.KVNGames) or 0
      elseif statName == 'wins' then
        return ((team == DOTA_TEAM_BADGUYS and v.PetriWins) or v.KVNWins) or 0
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
              table.insert(mmr, SU:GetStatValue(PlayerResource:GetSteamAccountID(playerID), DOTA_TEAM_GOODGUYS, "mmr") or 3000)
            end
          end
        end
      end
    end

    -- DeepPrintTable(mmr)

    table.sort(mmr)

    -- DeepPrintTable(mmr)

    -- DeepPrintTable(ReverseTable(mmr))

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
              mmr = mmr + (SU:GetStatValue(PlayerResource:GetSteamAccountID(playerID), DOTA_TEAM_BADGUYS, 'mmr') or 3000)
            end
          end
        end
      end
    end

    return mmr
end

function SU:BuildMMRArray()
    local top_kvn_mmr = SU.LoadedKVNMMR or SU:GetTop3MMRKVN()

    local kvn_mmr = (top_kvn_mmr[1] or 3000) + (top_kvn_mmr[2] or 3000) + (top_kvn_mmr[3] or 3000)
    local petri_mmr = SU:GetPetriMMR()

    local players = {}

    if not SU.LoadedStats then return players end

    for playerID = 0, DOTA_MAX_PLAYERS do
      if PlayerResource:IsValidPlayerID(playerID) then
        if not PlayerResource:IsBroadcaster(playerID) then
          local steam_id = PlayerResource:GetSteamAccountID(playerID)
          
          if steam_id ~= 0 then
            local hero = GameMode.assignedPlayerHeroes[playerID] or PlayerResource:GetSelectedHeroEntity(playerID)
            local team = hero:GetTeamNumber()

            local player_petr_mmr = SU:GetStatValue( steam_id, DOTA_TEAM_BADGUYS, 'mmr' )
            local player_kvn_mmr = SU:GetStatValue( steam_id, DOTA_TEAM_GOODGUYS, 'mmr' )
            
            local petri_games = SU:GetStatValue( steam_id, DOTA_TEAM_BADGUYS, 'games' )
            local kvn_games = SU:GetStatValue( steam_id, DOTA_TEAM_GOODGUYS, 'games' )

            local won_petri_games = SU:GetStatValue( steam_id, DOTA_TEAM_BADGUYS, 'wins' )
            local won_kvn_games = SU:GetStatValue( steam_id, DOTA_TEAM_GOODGUYS, 'wins' )

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
    end

    -- DeepPrintTable(players)

    return players
end

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