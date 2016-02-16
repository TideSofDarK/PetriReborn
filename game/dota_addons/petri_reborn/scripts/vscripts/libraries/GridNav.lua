local GNV_PRINT = true
-- Time to clear nettable value
local netTableClearTimer = 15.0

GNV = {}
GNV.XMin = 0
GNV.XMax = 0
GNV.YMin = 0
GNV.YMax = 0

-- User config for GridNav
GNV.Config = {}

-- LayerManager namespace
GNV.LayerManager = {}
GNV.LayerManager.QueueNumber = 0

-- Layers container
GNV.Layers = {}

-- Callbacks table
-- Uses default table "Init" in init function, possible other uses
GNV.Callbacks = {}

-------------------------------------------------------------------------------
--                          GNV options
-------------------------------------------------------------------------------
function GNV:LoadConfig()
  local config = LoadKeyValues("scripts/kv/GridNavConfig.kv")
  
  -- Parse colors
  if config['Colors'] ~= nil then
    for k, v in pairs(config['Colors']) do
      config['Colors'][k] = GetMatches(v, "[0-9]+")
    end
  end
  
  GNV.Config["Default"] = config
  
  -- Make config for every player
  for i = 0, PlayerResource:GetPlayerCount() - 1 do
    GNV.Config[i] = config
  end
end

function GNV:SendConfig( args )
  local playerID = args.PlayerID
  local player = PlayerResource:GetPlayer(playerID)
  
  GNV:print("Sending GNV config to player "..playerID)
  CustomGameEventManager:Send_ServerToPlayer(player, "gnv_config", { config = GNV.Config[playerID] })  
end

function GNV:SendDefaultConfig( args )
  local playerID = args.PlayerID
  local player = PlayerResource:GetPlayer(playerID)
  
  CustomGameEventManager:Send_ServerToPlayer(player, "gnv_config", { config = GNV.Config["Default"] })  
end

function GNV:UpdateConfig( args )
  local playerID = args.PlayerID
  
  if args["config"] ~= nil then
    GNV.Config[playerID] = args["config"]
  end
end

-------------------------------------------------------------------------------
--                          Layer manager
-------------------------------------------------------------------------------
function GNV.LayerManager:Create( layerName )
  if GNV.Layers[layerName] == nil then
    GNV.Layers[layerName] = {}
    
    -- Init fullsize grid with default values
    for y = GNV.YMin, GNV.YMax do
      GNV.Layers[layerName][y] = {}
      for x = GNV.XMin, GNV.XMax do
        GNV.Layers[layerName][y][x] = 0
      end
    end
    
  end
end

function GNV.LayerManager:Delete( layerName )
  if GNV.Layers[layerName] ~= nil then
    GNV.Layers[layerName] = {}
  end
end

-- Write to layer
-- Args:
--  - LayerName
--  - X, Y - top left corner
--  - Width
--  - Height
--  - Mapping - mapping with size X * Y
function GNV.LayerManager:Write( args )
  local layerName = args['LayerName']
  local location = GetGridPosition( { x = args["X"], y = args["Y"] })
  -- Write in nettable grid coords
  args["X"] = location.x
  args["Y"] = location.y
  local width = args["Width"]
  local height = args["Height"]
  
  GNV:print("Writing to layer '" .. layerName .. "'")

  -- Skip bad location
  if location.x < GNV.XMin or location.y < GNV.YMin or 
     location.x + width > GNV.XMax or location.y + height > GNV.YMax then
    return
  end
  
  -- Write to new layer
  GNV.LayerManager:Create( layerName )
  
  -- Update layer
  for y = 1, height do
    for x = 1, width do
      GNV.Layers[layerName][location.y + y - 1][location.x + x - 1] = args['Mapping'][y][x]
    end
  end
  
  local curQueueNumber = GNV.LayerManager.QueueNumber
  -- Update queue for clients  
  CustomNetTables:SetTableValue("LayersQueue", tostring( curQueueNumber ), args)
  Timers:CreateTimer(netTableClearTimer, 
		function() 
		  CustomNetTables:SetTableValue("LayersQueue", tostring( curQueueNumber ), {})
		end)
  
  GNV.LayerManager.QueueNumber = GNV.LayerManager.QueueNumber + 1
end

-- Generate terrain grid and get map sizes
function GNV.LayerManager:Generate()
  GNV.LayerManager:Create( 'Terrain' )
  
  local worldMin = Vector(GetWorldMinX(), GetWorldMinY(), 0)
  local worldMax = Vector(GetWorldMaxX(), GetWorldMaxY(), 0)

  GNV.XMin = GridNav:WorldToGridPosX(worldMin.x)
  GNV.XMax = GridNav:WorldToGridPosX(worldMax.x)
  GNV.YMin = GridNav:WorldToGridPosY(worldMin.y)
  GNV.YMax = GridNav:WorldToGridPosY(worldMax.y)
 
  GNV:print("Max World Bounds: ")
  GNV:print(GetWorldMinX()..' '..GetWorldMinY()..' '..GetWorldMaxX()..' '..GetWorldMaxY())
  GNV:print(GNV.XMin..' '..GNV.YMin..' '..GNV.XMax..' '..GNV.YMax)

  local blockedCount = 0
  local unblockedCount = 0

  for y = GNV.YMin, GNV.YMax do
    GNV.Layers['Terrain'][y] = {}
    for x = GNV.XMin, GNV.XMax do
      local gridX = GridNav:GridPosToWorldCenterX(x)
      local gridY = GridNav:GridPosToWorldCenterY(y)
      local position = Vector(gridX, gridY, 0)  
      local blocked = not GridNav:IsTraversable(position) or GridNav:IsBlocked(position)
      
      GNV.Layers['Terrain'][y][x] = tostring(blocked and 1 or 0)

      if blocked then
          blockedCount = blockedCount + 1
      else
          unblockedCount = unblockedCount + 1
      end
    end
  end
end

-------------------------------------------------------------------------------
--                          GNV commons
-------------------------------------------------------------------------------
ListenToGameEvent('game_rules_state_change', function()
    local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        -- The base terrain GridNav is obtained directly from the vmap
        GNV:Init()
    end
end, nil)

function GNV:print( ... )
    if GNV_PRINT then
        print("[GNV] ".. ...)
    end
end

function GNV:RegisterListeners()
  -- Config
  CustomGameEventManager:RegisterListener( "gnv_config_request", Dynamic_Wrap(GNV, 'SendConfig'))
  CustomGameEventManager:RegisterListener( "gnv_default_config_request", Dynamic_Wrap(GNV, 'SendDefaultConfig'))
  CustomGameEventManager:RegisterListener( "gnv_config_update", Dynamic_Wrap(GNV, 'UpdateConfig'))
  
  -- Grid
  CustomGameEventManager:RegisterListener( "gnv_request", Dynamic_Wrap(GNV, 'Send'))
end

-- Main function
function GNV:Init()
  -- Register listeners for GNV events
  GNV:RegisterListeners()
  
  -- Load server config
  GNV:LoadConfig();
  
  GNV.LayerManager:Generate()
  -- Exec default callbacks for init function
  GNV:ExecCallbacks( 'Init' )
end

-- Send layers
function GNV:Send( args )
  local playerID = args.PlayerID
  local player = PlayerResource:GetPlayer(playerID)
  
  local layers = { 'Terrain' }
  for _, v in pairs(args['Layers']) do
    table.insert(layers, v)   
  end
  
  for _, v in pairs(layers) do
    GNV:print("Sending layer '" .. v .. "' to player "..playerID)
    CustomGameEventManager:Send_ServerToPlayer(player, "gnv", { gnv = Pack( v ), LayerName = v, XMin = GNV.XMin, XMax = GNV.XMax, YMin = GNV.YMin, YMax = GNV.YMax })
  end    
end

-- Add callbacks
function GNV:AddCallbacks( tableName, callback)
  if GNV.Callbacks[tableName] == nil then
    GNV.Callbacks[tableName] = {}
  end
  
  table.insert(GNV.Callbacks[tableName], callback)
end

-- Exec callbacks
function GNV:ExecCallbacks( tableName )
  if GNV.Callbacks[tableName] ~= nil then
    for _, func in pairs(GNV.Callbacks[tableName]) do
      func()
    end
  end
end

-- Clear callbacks
function GNV.ClearCallbacks( tableName )
  -- Clear full table
  if tableName == '' then
    for k, _ in pairs(GNV.Callbacks) do
      GNV.Callbacks[k] = {}
    end
  
    return
  end

  if GNV.Callbacks[tableName] ~= nil then
    GNV.Callbacks[tableName] = {}
  end
end

-------------------------------------------------------------------------------
--                          Utility functions
-------------------------------------------------------------------------------
function GetGridPosition( location )
  return { x = GridNav:WorldToGridPosX(location.x), y = GridNav:WorldToGridPosX(location.y) }
end

function BinToInt( str )
  local value = 0
  for i = 1,8 do
    value = value + str:sub(i,i) * math.pow(2, 8 - i)
  end
  return value
end

function IntToHex( num )
    local hexstr = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = math.fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
    if s == '' then s = '0' end
    return s
end

function GetMatches( str, pattern )
  local m = {}
  for i in string.gmatch(str, pattern) do 
    table.insert(m, i)
  end
  return m
end
-------------------------------------------------------------------------------
--                          Packing
-------------------------------------------------------------------------------
-- Pack layer
function Pack( layerName )
  GNV:print("Packing layer '" .. layerName .."'")
  
  local binaryStr = ""
  local totalCount = 1;
  
  local gnv = {}

  if GNV.Layers[layerName] == nil then
    GNV:print("Unknown layer. Unable to pack.")
    return ''
  end

  for y = GNV.YMin, GNV.YMax do
    local curRow = ""    
    for x = GNV.XMin, GNV.XMax do
      curRow = curRow .. GNV.Layers[layerName][y][x]
      binaryStr = binaryStr .. GNV.Layers[layerName][y][x]
      if binaryStr:len() == 8 then
        gnv[totalCount] = string.format("%02s", IntToHex(BinToInt(binaryStr)) )
        totalCount = totalCount + 1
        binaryStr = ""
      end
    end
  end

  return table.concat( PackGNVTable(gnv, totalCount), '')
end

function PackGNVTable( gnvTable, length )
  local packedTable = {}
  local prevChar = gnvTable[1]
  local curChar = ""
  
  local count = 1
  
  for i = 2, length do
    curChar = gnvTable[i]
    
    if prevChar ~= curChar then     
      local strLen = "(" .. count .. ")"
      
      if string.rep(prevChar, count):len() > strLen:len() then
        table.insert(packedTable, prevChar)
        table.insert(packedTable, strLen)
      else
        table.insert(packedTable, string.rep(prevChar, count))
      end
      
      count = 0
    end
  
    count = count + 1
    prevChar = curChar
  end

  return packedTable
end