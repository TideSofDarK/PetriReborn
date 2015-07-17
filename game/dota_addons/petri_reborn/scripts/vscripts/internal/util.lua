-- Upgrades

function StartUpgrading (event)
  local caster = event.caster
  local ability = event.ability

  local level = ability:GetLevel() - 1

  local gold_cost = ability:GetGoldCost(level) or 0
  local lumber_cost = ability:GetLevelSpecialValueFor("lumber_cost", level) or 0
  local food_cost = ability:GetLevelSpecialValueFor("food_cost", level) or 0

  if CheckLumber(caster:GetPlayerOwner(), lumber_cost,true) == false
    or CheckFood(caster:GetPlayerOwner(), food_cost,true) == false then 
    Timers:CreateTimer(0.06,
      function()
          PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), gold_cost, false, 0)
          caster:InterruptChannel()
      end
    )
  else
    caster:GetPlayerOwner().lumber = caster:GetPlayerOwner().lumber - lumber_cost
    caster:GetPlayerOwner().food = caster:GetPlayerOwner().food + food_cost

    caster.lastSpentLumber = lumber_cost
    caster.lastSpentGold = gold_cost
    caster.lastSpentFood = food_cost

    caster.foodSpent = caster.foodSpent + food_cost

    ability:SetHidden(true)
  end
end

function StopUpgrading(event)
  local caster = event.caster
  local ability = event.ability

  caster.lastSpentLumber = caster.lastSpentLumber or 0
  caster.lastSpentGold = caster.lastSpentGold or 0
  caster.lastSpentFood = caster.lastSpentFood or 0

  caster:GetPlayerOwner().lumber = caster:GetPlayerOwner().lumber + caster.lastSpentLumber
  caster:GetPlayerOwner().food = caster:GetPlayerOwner().food - caster.lastSpentFood
  PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), caster.lastSpentGold, false, 0)

  caster.lastSpentLumber = 0
  caster.lastSpentGold = 0
  caster.lastSpentFood = 0

  ability:SetHidden(false)
end

function OnUpgradeSucceeded(event)
  local caster = event.caster
  local ability = event.ability

  local level = ability:GetLevel()

  ability:SetLevel(level+1)

  caster.lastSpentLumber = 0
  caster.lastSpentGold = 0
  caster.lastSpentFood = 0

  if level+1 == ability:GetMaxLevel() then
    caster:RemoveAbility(ability:GetAbilityName())
  else 
    ability:SetHidden(false)
  end
end

function UpdateModel(tower, model, scale)
  tower:SetOriginalModel(model)
  tower:SetModel(model)
  tower:SetModelScale(scale)
end

-- End of upgrades

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
    Notifications:Bottom(player:GetPlayerID(), {text="#gather_more_lumber", duration=1, style={color="red", ["font-size"]="45px"}})
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
    Notifications:Bottom(player:GetPlayerID(), {text="#need_more_food", duration=2, style={color="red", ["font-size"]="35px"}})
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