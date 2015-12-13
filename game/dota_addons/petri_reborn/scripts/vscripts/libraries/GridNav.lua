local GNV_PRINT = false

GNV = {}

GNV.Encoded = "" -- String containing the base terrain, networked to clients
GNV.XSize = 0  -- Number of X grid points
GNV.YSize = 0  -- Number of Y grid points

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

ListenToGameEvent('game_rules_state_change', function()
    local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        -- The base terrain GridNav is obtained directly from the vmap
        GNV:Init()
    elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
        Timers:CreateTimer(1, function()
            GNV:Send()
        end)
    end
end, nil)

function GNV:print( ... )
    if GNV_PRINT then
        print('[GNV] '.. ...)
    end
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

function GNV:Init()
  local worldMin = Vector(GetWorldMinX(), GetWorldMinY(), 0)
  local worldMax = Vector(GetWorldMaxX(), GetWorldMaxY(), 0)

  local boundX1 = GridNav:WorldToGridPosX(worldMin.x)
  local boundX2 = GridNav:WorldToGridPosX(worldMax.x)
  local boundY1 = GridNav:WorldToGridPosY(worldMin.y)
  local boundY2 = GridNav:WorldToGridPosY(worldMax.y)
 
  GNV:print("Max World Bounds: ")
  GNV:print(GetWorldMaxX()..' '..GetWorldMaxY()..' '..GetWorldMaxX()..' '..GetWorldMaxY())

  local blockedCount = 0
  local unblockedCount = 0

  local binaryStr = ""
  local totalCount = 1;
  
  local gnv = {}

  for x=boundX1,boundX2 do
    local curRow = ""
    for y=boundY1,boundY2 do
      local gridX = GridNav:GridPosToWorldCenterX(x)
      local gridY = GridNav:GridPosToWorldCenterY(y)
      local position = Vector(gridX, gridY, 0)
      local blocked = not GridNav:IsTraversable(position) or GridNav:IsBlocked(position)

      curRow = curRow .. tostring(blocked and 1 or 0)

      binaryStr = binaryStr .. tostring(blocked and 1 or 0)
      if binaryStr:len() == 8 then
        gnv[totalCount] = string.format("%02s", IntToHex(BinToInt(binaryStr)) )
        totalCount = totalCount + 1
        binaryStr = ""
      end
      
      if blocked then
          blockedCount = blockedCount+1
      else
          unblockedCount = unblockedCount+1
      end
    end
    
    --print(curRow)
  end
 
  local gnv_string = table.concat( PackGNVTable(gnv, totalCount), '')

  GNV:print(boundX1..' '..boundX2..' '..boundY1..' '..boundY2)
  local squareX = math.abs(boundX1) + math.abs(boundX2)+1
  local squareY = math.abs(boundY1) + math.abs(boundY2)+1
  print("Free: "..unblockedCount.." Blocked: "..blockedCount)

  GNV.Encoded = gnv_string
  GNV.XMin = boundX1
  GNV.XMax = boundX2
  GNV.YMin = boundY1
  GNV.YMax = boundY2
end
    
function GNV:Send()
    CustomGameEventManager:Send_ServerToAllClients("gnv", { gnv = GNV.Encoded, XMin = GNV.XMin, XMax = GNV.XMax, YMin = GNV.YMin, YMax = GNV.YMax })
end    
    