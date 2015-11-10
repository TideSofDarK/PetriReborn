GameSetup = {}
GameSetup.votes = {}

------------------------------------------------------------------------
-- Shuffles
------------------------------------------------------------------------
local shuffleTimes = 0;
local hostPlayerID = -1;
local petrCount = 2;

function GetArraySize( array )
  count = 0
  for k,v in pairs( array ) do
    count = count + 1
  end
  return count
end

function ShuffleList( count )
  local a = {}
  for i = 0, count - 1 do
    a[i] = i
  end

  for i = 0, count - 1 do
      local num = math.floor(math.random() * (i + 1));
      local d = a[num];
      a[num] = a[i];
      a[i] = d;
  end

  local petr = { };
  local kvn = { };
  for i = 0, count - 1 do
    if math.fmod(i, 2) == 0 then
      if GetArraySize( petr ) < petrCount then
        table.insert(petr, a[i])
      else
        table.insert(kvn, a[i])
      end
    else
      table.insert(kvn, a[i])
    end
  end
  
  CustomGameEventManager:Send_ServerToAllClients( "petri_set_shuffled_list", { ["kvn"] = kvn, ["petr"] = petr } );
  shuffleTimes = shuffleTimes + 1;

  if shuffleTimes == 3 then
    Timers:CreateTimer(2.0, 
      function() 
        CustomGameEventManager:Send_ServerToAllClients("petri_end_shuffle", { } )
      end);
  end
end

function GameSetup:ShuffleRandom( args )
  shuffleTimes = 0;
  hostPlayerID = args['PlayerID'];

  for i = 0, 2 do
    Timers:CreateTimer(i * 2.0, 
      function() 
        ShuffleList( args['CurrentPlayers'] ) 
      end);
  end
end

function GameSetup:ShuffleHost()
  CustomGameEventManager:Send_ServerToAllClients("petri_host_shuffle", { } )
end

function GameSetup:ShuffleSetHostList( args )
  CustomGameEventManager:Send_ServerToAllClients( "petri_set_shuffled_list", { ["kvn"] = args["kvn"],  ["petr"] = args["petr"] });
  
  Timers:CreateTimer(2.0, 
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
  GameSetup.votes[voteName][value] = GameSetup.votes[voteName][value] or 0
  GameSetup.votes[voteName][value] = GameSetup.votes[voteName][value] + 1
end

-- End vote handler
function GameSetup:VoteEnd( args )
  local results = {}
  for k,v in pairs(GameSetup.votes) do
    results[k] = 0

    local maxVotes = 0

    for option,votes in pairs(v) do
      if votes > maxVotes then 
        maxVotes = votes
        results[k] = option
      end
    end
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