function ReturnGold(player)
  local playerID = player:GetPlayerID() 
  if player.lastSpentGold ~= nil then
    PlayerResource:ModifyGold(playerID, player.lastSpentGold,false,0)
    player.lastSpentGold = nil
  end
end

function ReturnLumber(player)
  if player.lumber ~= nil and player.lastSpentLumber ~= nil then
    player.lumber = player.lumber + player.lastSpentLumber
    player.lastSpentLumber = nil
  end
end

function CheckLumber(player, lumber_amount, notification)
  local enough = player.lumber >= lumber_amount
  if enough ~= true and notification == true then 
    Notifications:Bottom(PlayerResource:GetPlayer(0), {text="#gather_more_lumber", duration=1, style={color="red", ["font-size"]="45px"}})
  end
  return enough
end

function SpendLumber(player, lumber_amount)
  player.lumber = player.lumber - lumber_amount
  player.lastSpentLumber = lumber_amount
end

function CheckFood( player, food_amount, notification)
  local enough = player.food + food_amount <= Clamp(player.maxFood,10,250)
  if enough ~= true and notification == true then 
    Notifications:Bottom(PlayerResource:GetPlayer(0), {text="#need_more_food", duration=2, style={color="red", ["font-size"]="35px"}})
  end
  return enough
end

function SpendFood( player, food_amount )
  player.food = player.food + food_amount
  player.lastSpentFood = food_amount
end

function ReturnFood( player )
  if player.food ~= nil and player.lastSpentFood ~= nil then
    player.food = player.food - player.lastSpentFood
    player.lastSpentFood = nil
  end
end

function Clamp( _in, low, high )
  if (_in < low ) then return low end
  if (_in > high ) then return high end
  return _in
end

function InitAbilities( hero )
  for i=0, hero:GetAbilityCount()-1 do
    local abil = hero:GetAbilityByIndex(i)
    if abil ~= nil then
      if hero:IsHero() and hero:GetAbilityPoints() > 0 then
        hero:UpgradeAbility(abil)
      else
        abil:SetLevel(1)
      end
    end
  end
end

function DebugPrint(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    print(...)
  end
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    PrintTable(...)
  end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'