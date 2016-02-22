GameSetup = {}
GameSetup.precache_started = false
GameSetup.votes = {}

------------------------------------------------------------------------
-- Shuffles
------------------------------------------------------------------------
local shuffleTimes = 0;
local petrCount = 2;

function GetArraySize( array )
  count = 0
  for k,v in pairs( array ) do
    count = count + 1
  end
  return count
end

function GameSetup:ShuffleSchedule( args )
  Timers:CreateTimer(args["timer"], 
    function()
      local mode = nil;
      if not GameSetup.votes['shuffle_mode'] then
        return 1.0
      end
      for k,v in pairs(GameSetup.votes['shuffle_mode']) do
        mode = v;
      end

      local petr = { };
      local kvn = { };

      GameSetup.votes['prefer_team'] = GameSetup.votes['prefer_team'] or {}
      for k,v in pairs(GameSetup.votes['prefer_team']) do
        if v == 'kvn' then
          table.insert(kvn, k)
        else
          table.insert(petr, k)
        end
      end

      -- Host shuffle list
      if mode == 'host' then
        CustomGameEventManager:Send_ServerToAllClients( "petri_set_prefer_team_list", { ["kvn"] = kvn, ["petr"] = petr } )
        CustomGameEventManager:Send_ServerToAllClients("petri_host_shuffle", { } )
      -- Random shuffle list
      else
        local petrCount = GetArraySize( petr )
        local kvnCount = GetArraySize( kvn )

        if petrCount < 2 and kvnCount > 0 then
          local num = math.floor(math.random() * (kvnCount + 1))
          -- Move one kvn in petro team
          table.insert(petr, table.remove(kvn, kvn[num]))
        else
          -- Move random petro to kvn team
          while petrCount > 2 do
            local num = math.floor(math.random() * (petrCount + 1))
            table.insert(kvn, table.remove(petr, petr[num]))

            petrCount = GetArraySize( petr )
          end
        end

        CustomGameEventManager:Send_ServerToAllClients( "petri_set_shuffled_list", { ["kvn"] = kvn, ["petr"] = petr } )
        Timers:CreateTimer(1.0, 
          function() 
            CustomGameEventManager:Send_ServerToAllClients("petri_end_shuffle", { } )
          end);        
      end

    end);
end

function GetTeamsFromEmptySelection( args )
  local petr = args["petr"];
  local kvn = args["kvn"];

  -- Get min petr in game
  local minPetrCount = 0
  if GetArraySize( GameSetup.votes['prefer_team'] ) > 6 then
    minPetrCount = 2
  end

  if minPetrCount > 0 then
    -- If empty petr team
    if GetArraySize( petr ) < minPetrCount then
      kvn = {}
      -- Try to get first two players who prefer petr team
      for k,v in pairs(GameSetup.votes['prefer_team']) do
        if v == 'petri' and GetArraySize( petr ) < minPetrCount then
          table.insert(petr, k)
        else
          table.insert(kvn, k)
        end
      end
  
      -- Set random kvn to petr team if only host prefer this team
      if GetArraySize( petr ) < minPetrCount then
        local num = math.floor(math.random() * (GetArraySize( kvn ) + 1))
        table.insert(petr, table.remove(kvn, num))     
      end
    end
  end

  return petr, kvn  
end

function GameSetup:ShuffleSetHostList( args )
  local petr, kvn = GetTeamsFromEmptySelection( args )

  CustomGameEventManager:Send_ServerToAllClients( "petri_set_shuffled_list", { ["kvn"] = kvn,  ["petr"] = petr })
  
  Timers:CreateTimer(1.0, 
    function() 
      CustomGameEventManager:Send_ServerToAllClients("petri_end_shuffle", { } )
    end);
end

------------------------------------------------------------------------
-- Votes
------------------------------------------------------------------------
-- Main vote handler
function GameSetup:Vote( args )
  local pID
  local voteName
  local value

  for k,v in pairs(args) do
    if k == "PlayerID" then
      pID = v
    else
      voteName = k
      value = v
    end
  end

  GameSetup.votes[voteName] = GameSetup.votes[voteName] or {}
  -- Unique value for each player
  GameSetup.votes[voteName][pID] = value

  --[[
  GameSetup.votes[voteName] = GameSetup.votes[voteName] or {}
  GameSetup.votes[voteName][value] = GameSetup.votes[voteName][value] or 0
  GameSetup.votes[voteName][value] = GameSetup.votes[voteName][value] + 1
  ]]
end

-- End vote handler
function GameSetup:VoteEnd( args )
  local results = {}
  
  for k,v in pairs(GameSetup.votes) do
    local votes = {}
    local lastVote = 0
    local current

    --local unique = k == "prefer_team"

    for pID,vote in pairs(v) do
      
      votes[vote] = votes[vote] or 0
      votes[vote] = votes[vote] + 1

      if votes[vote] > lastVote then
        current = vote
      end

      lastVote = votes[vote]
    end

    results[k] = current
  end

  for k,v in pairs(results) do
    if k == "bonus_item" then
      if v == "trap" then
        GameMode.KVN_BONUS_ITEM["item"] = "item_petri_trap"
        GameMode.KVN_BONUS_ITEM["count"] = 1
      end
      if v == "2_attack" then
        GameMode.KVN_BONUS_ITEM["item"] = "item_petri_attack_scroll"
        GameMode.KVN_BONUS_ITEM["count"] = 2
      end
      if v == "2_evasion" then
        GameMode.KVN_BONUS_ITEM["item"] = "item_petri_evasion_scroll"
        GameMode.KVN_BONUS_ITEM["count"] = 2
      end
      if v == "3_alcohol" then
        GameMode.KVN_BONUS_ITEM["item"] = "item_petri_alcohol"
        GameMode.KVN_BONUS_ITEM["count"] = 3
      end
    end
  end

  CustomGameEventManager:Send_ServerToAllClients("petri_vote_results", {["results"] = results} )
end

------------------------------------------------------------------------
-- Utils
------------------------------------------------------------------------
-- Send event to all clients from host
function GameSetup:ToAllClients( args )
  local eventName = args["event_name"]
  local eventArgs = {}

  for argName,argValue in pairs(args) do
    if argName ~= "event_name" then
      eventArgs[argName] = argValue
    end
  end

  CustomGameEventManager:Send_ServerToAllClients(eventName, eventArgs)
end

function GameSetup:StartPrecache()
  if GameSetup.precache_started == false then
    GameSetup.precache_started = true
    PrecacheItemByNameAsync("item_precache_item", function()
      
    end)
    for i=0,12 do
      local player = PlayerResource:GetPlayer(i)

      if player ~= nil then
        PrecacheUnitByNameAsync("npc_dota_hero_brewmaster", function ()

        end, i)
        PrecacheUnitByNameAsync("npc_dota_hero_death_prophet", function ()

        end, i)
        PrecacheUnitByNameAsync("npc_dota_hero_rattletrap", function ()

        end, i)
      end
    end
  end
end