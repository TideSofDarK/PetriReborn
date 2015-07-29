-- ITEMS
function GetItemByID(id)
  for k,v in pairs(GameMode.ItemKVs) do
    if tonumber(v["ID"]) == id then return v end
  end
end

function CheckShopType(item)
  for k,v in pairs(GameMode.ItemKVs) do
    if k == item then 
      if v["SideShop"] then return 1
      elseif v["SecretShop"] then return 2
      else return 0 end
    end
  end
end
-- ITEMS

function ToggleAbilityOff(ability)
  if ability:GetToggleState() == true then 
      ability:ToggleAbility()  
  end
end

function GetPresentAbilities(unit, layout)
  local abilities = {}
  for i=0, unit:GetAbilityCount()-1 do
    if unit:GetAbilityByIndex(i) then
      if not unit:GetAbilityByIndex(i):IsHidden() then
        abilities[(#abilities + 1)] = unit:GetAbilityByIndex(i):GetName()
        if #abilities == layout then break end
      end
    end 
  end
  return abilities
end

function IsHiddenBehavior(ability)
  local behavior = GameMode.AbilityKVs[ability]["AbilityBehavior"]
  print(behavior)
  return string.match(behavior, "DOTA_ABILITY_BEHAVIOR_HIDDEN")
end

function HideIfMaxLevel(ability)
  if ability:GetMaxLevel() == ability:GetLevel() then
    ability:SetHidden(true)
  end
end

function FindAllByUnitName(name, pID, ignore)
  local entities = {}
  for k,v in pairs(Entities:FindAllByClassname("npc_dota_base_additive")) do
    if v:GetUnitName() == name and v:GetPlayerOwnerID() == pID and v ~= ignore then entities[k] = v end
  end
  return entities
end

function Split(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function CheckKVN()
  local kvns = Entities:FindAllByName("npc_dota_hero_rattletrap")
  for k,v in pairs(kvns) do
    if v:IsAlive() then return false end
  end
  return true
end

-- Cooldowns
function StartCooldown(caster, ability_name)
  if caster:FindAbilityByName(ability_name) ~= nil then
    caster:FindAbilityByName(ability_name):StartCooldown(caster:FindAbilityByName(ability_name):GetCooldown(0))
  else
    caster:AddAbility(ability_name)
    if caster:FindAbilityByName(ability_name) ~= nil then
      caster:FindAbilityByName(ability_name):StartCooldown(caster:FindAbilityByName(ability_name):GetCooldown(0))
      caster:RemoveAbility(ability_name)
    end
  end
end

function EndCooldown(caster, ability_name)
  if caster:FindAbilityByName(ability_name) ~= nil then
    caster:FindAbilityByName(ability_name):EndCooldown()
  else
    caster:AddAbility(ability_name)
    if caster:FindAbilityByName(ability_name) ~= nil then
      caster:FindAbilityByName(ability_name):EndCooldown()
      caster:RemoveAbility(ability_name)
    end
  end
end
-- Cooldowns

function DestroyEntityBasedOnHealth(killer, target)
  local damageTable = {
    victim = target,
    attacker = killer,
    damage = target:GetMaxHealth(),
    damage_type = DAMAGE_TYPE_PURE,
  }
  ApplyDamage(damageTable)
end

function CheckAreaClaimers(target, claimers)
  if claimers == nil or target == nil then return false end
  for i=0,#claimers,1 do
    if claimers[i] == target then return true end
  end
  return false
end

function MoveCamera(pID, target)
  PlayerResource:SetCameraTarget(pID, target)
  Timers:CreateTimer(0.03,
      function()
          PlayerResource:SetCameraTarget(pID, nil)
      end
    )
end

-- Upgrades

function GetUpgradeLevelForPlayer(upgrade, pID)
  return CustomNetTables:GetTableValue("players_upgrades", tostring(pID))["1"][upgrade]
end

function StartUpgrading (event)
  local caster = event.caster
  local ability = event.ability

  local hero = caster:GetPlayerOwner():GetAssignedHero() 

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
    hero.lumber = hero.lumber - lumber_cost
    hero.food = hero.food + food_cost

    caster.lastSpentLumber = lumber_cost
    caster.lastSpentGold = gold_cost
    caster.lastSpentFood = food_cost

    caster.foodSpent = caster.foodSpent + food_cost

    if not event["Permanent"] then
      ability:SetHidden(true)
    else 
      local all = FindAllByUnitName(caster:GetUnitName(), caster:GetPlayerOwnerID())
      local abilityName = ability:GetName()

      for k,v in pairs(all) do
        if v:HasAbility(abilityName) then
          local a = v:FindAbilityByName(abilityName)
          a:SetHidden(true)
        end
      end
    end
  end
end

function StopUpgrading(event)
  local caster = event.caster
  local ability = event.ability

  local hero = caster:GetPlayerOwner():GetAssignedHero() 

  caster.lastSpentLumber = caster.lastSpentLumber or 0
  caster.lastSpentGold = caster.lastSpentGold or 0
  caster.lastSpentFood = caster.lastSpentFood or 0

  hero.lumber = hero.lumber + caster.lastSpentLumber
  hero.food = hero.food - caster.lastSpentFood
  PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), caster.lastSpentGold, false, 0)

  caster.lastSpentLumber = 0
  caster.lastSpentGold = 0
  caster.lastSpentFood = 0

  if not event["Permanent"] then
    ability:SetHidden(false)
  else 
    local all = FindAllByUnitName(caster:GetUnitName(), caster:GetPlayerOwnerID())
    local abilityName = ability:GetName()

    for k,v in pairs(all) do
      if v:HasAbility(abilityName) then
        local a = v:FindAbilityByName(abilityName)
        a:SetHidden(false)
      end
    end
  end
end

function OnUpgradeSucceeded(event)
  local caster = event.caster
  local ability = event.ability

  local hero = caster:GetPlayerOwner():GetAssignedHero() 
  local pID = caster:GetPlayerOwnerID()

  local level = ability:GetLevel()

  ability:SetLevel(level+1)

  caster.lastSpentLumber = 0
  caster.lastSpentGold = 0
  caster.lastSpentFood = 0

  if event["Permanent"] then
    local tempTable = CustomNetTables:GetTableValue("players_upgrades", tostring(pID))
    tempTable["1"][ability:GetName()] = tempTable["1"][ability:GetName()] + 1
    CustomNetTables:SetTableValue( "players_upgrades", tostring(pID), { tempTable["1"] } );

    local all = FindAllByUnitName(caster:GetUnitName(), caster:GetPlayerOwnerID())
    local abilityName = ability:GetName()

    for k,v in pairs(all) do
      if v:HasAbility(abilityName) then
        local a = v:FindAbilityByName(abilityName)
        a:SetLevel(level+1)

        if level+1 == a:GetMaxLevel() then
          a:SetHidden(true)
        else 
          a:SetHidden(false)
        end
      end
    end
  else 
    if level+1 == ability:GetMaxLevel() then
      ability:SetHidden(true)
    else 
      ability:SetHidden(false)
    end
  end
end

function UpdateModel(target, model, scale)
  target:SetOriginalModel(model)
  target:SetModel(model)
  target:SetModelScale(scale)
end

-- End of upgrades

function ReturnGold(player)
  local playerID = player:GetPlayerID() 
  local hero = player:GetAssignedHero() 
  if hero.lastSpentGold ~= nil then
    PlayerResource:ModifyGold(playerID, hero.lastSpentGold,false,0)
    hero.lastSpentGold = nil
  end
end

function ReturnLumber(player)
  local hero = player:GetAssignedHero() 
  if hero.lumber ~= nil and hero.lastSpentLumber ~= nil then
    hero.lumber = hero.lumber + hero.lastSpentLumber
    hero.lastSpentLumber = nil
  end
end

function CheckLumber(player, lumber_amount, notification)
  local hero = player:GetAssignedHero() 
  local enough = hero.lumber >= lumber_amount
  if enough ~= true and notification == true then 
    Notifications:Bottom(player:GetPlayerID(), {text="#gather_more_lumber", duration=1, style={color="red", ["font-size"]="45px"}})
  end
  return enough
end

function SpendLumber(player, lumber_amount)
  local hero = player:GetAssignedHero() 
  hero.lumber = hero.lumber - lumber_amount
  hero.lastSpentLumber = lumber_amount
end

function CheckFood( player, food_amount, notification)
  local hero = player:GetAssignedHero() 
  if food_amount == 0 then return true end
  local enough = hero.food + food_amount <= Clamp(hero.maxFood,10,250)
  if enough ~= true and notification == true then 
    Notifications:Bottom(player:GetPlayerID(), {text="#need_more_food", duration=2, style={color="red", ["font-size"]="35px"}})
  end
  return enough
end

function SpendFood( player, food_amount )
  local hero = player:GetAssignedHero() 
  hero.food = hero.food + food_amount
  hero.lastSpentFood = food_amount
end

function ReturnFood( player )
  local hero = player:GetAssignedHero() 
  if hero.food ~= nil and hero.lastSpentFood ~= nil then
    hero.food = hero.food - hero.lastSpentFood
    hero.lastSpentFood = nil
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