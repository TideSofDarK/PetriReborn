GameSetup = {}

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
function GameSetup:VoteFreeze()
  CustomGameEventManager:Send_ServerToAllClients( "petri_vote_freeze", { });
end

function GameSetup:VoteUnfreeze()
  CustomGameEventManager:Send_ServerToAllClients( "petri_vote_unfreeze", { });
end

-- Main vote handler
function GameSetup:Vote( args )
end