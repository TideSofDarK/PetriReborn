GameSetup = {}

local shuffleTimes = 0;
local hostPlayerID = -1;
local petrCount = 2;

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
  for i = 0, petrCount - 1 do
    petr[i] = a[i];
  end

  local kvn = {};
  for i = petrCount, count - petrCount - 1 do
    kvn[i - petrCount] = a[i];
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