POPUP_SYMBOL_PRE_PLUS = 0
POPUP_SYMBOL_PRE_MINUS = 1
POPUP_SYMBOL_PRE_SADFACE = 2
POPUP_SYMBOL_PRE_BROKENARROW = 3
POPUP_SYMBOL_PRE_SHADES = 4
POPUP_SYMBOL_PRE_MISS = 5
POPUP_SYMBOL_PRE_EVADE = 6
POPUP_SYMBOL_PRE_DENY = 7
POPUP_SYMBOL_PRE_ARROW = 8

POPUP_SYMBOL_POST_EXCLAMATION = 0
POPUP_SYMBOL_POST_POINTZERO = 1
POPUP_SYMBOL_POST_MEDAL = 2
POPUP_SYMBOL_POST_DROP = 3
POPUP_SYMBOL_POST_LIGHTNING = 4
POPUP_SYMBOL_POST_SKULL = 5
POPUP_SYMBOL_POST_EYE = 6
POPUP_SYMBOL_POST_SHIELD = 7
POPUP_SYMBOL_POST_POINTFIVE = 8

function GetExpTickModifier()
  local time = math.floor(GameMode.PETRI_TRUE_TIME/60)
  
  if time >= 40 then
    return 0.0
  elseif time >= 33 and time < 40 then
    return 10.0
  elseif time >= 32 and time < 33 then
    return 0.0
  elseif time >= 28 and time < 32 then
    return 8.0
  elseif time >= 24 and time < 28 then
    return 0.0
  elseif time >= 20 and time < 24 then
    return 6.0
  elseif time >= 16 and time < 20 then
    return 0.0
  elseif time >= 12 and time < 16 then
    return 50.0
  elseif time >= 8 and time < 12 then
    return 0.0
  elseif time >= 6 and time < 8 then
    return 1.0
  elseif time >= 5 and time < 6 then
    return 2.0
  elseif time >= 4 and time < 5 then
    return 3.0
  elseif time >= 2 and time < 4 then
    return 0.0
  elseif time < 2 then
    return 0.0 
  end
  return 1.0
end

function GetGoldTickModifier()
  local time = math.floor(GameMode.PETRI_TRUE_TIME/60)
  
  if time >= 40 then
    return 0.0
  elseif time >= 33 and time < 40 then
    return 50.0
  elseif time >= 32 and time < 33 then
    return 0.0
  elseif time >= 28 and time < 32 then
    return 25.0
  elseif time >= 24 and time < 28 then
    return 0.0
  elseif time >= 20 and time < 24 then
    return 10.0
  elseif time >= 16 and time < 20 then
    return 0.0
  elseif time >= 12 and time < 16 then
    return 4.0
  elseif time >= 8 and time < 12 then
    return 0.0
  elseif time >= 6 and time < 8 then
    return 1.0
  elseif time >= 4 and time < 6 then
    return 0.0
  elseif time >= 2 and time < 4 then
    return 0.0
  elseif time < 2 then
    return 0.0 
  end
  return 1.0
end

function GetGoldModifier()
  local time = math.floor(GameMode.PETRI_TRUE_TIME/60)

  if time > 40 then
    return 10.0
  elseif time > 36 and time <= 40 then
    return 8.0
  elseif time > 32 and time <= 36 then
    return 5.0
  elseif time > 28 and time <= 32 then
    return 4.0
  elseif time > 24 and time <= 28 then
    return 3.0
  elseif time > 20 and time <= 24 then
    return 2.0
  elseif time > 16 and time <= 20 then
    return 1.5
  elseif time > 12 and time <= 16 then
    return 0.7
  elseif time > 8 and time <= 12 then
    return 0.5
  elseif time > 4 and time <= 8 then
    return 0.3
  elseif time >= 2 and time <= 4 then
    return 0.28
  elseif time < 2 then
    return 0.0 
  end
  return 1.0
end

function GetAbilityGoldCost( ability )
  if ability and GameMode.AbilityKVs[ability:GetName()] then
    local costString = GameMode.AbilityKVs[ability:GetName()].AbilityGoldCost
    if string.match(costString, " ") then
      local prices = Split(costString, " ")

      local value, stuff = string.gsub(prices[ability:GetLevel()], '%%', '')
      return tonumber(value)
    else
      local value, stuff = string.gsub(costString, '%%', '')
      return tonumber(value)
    end
  end
  return 0
end

function PrintDebugMessageToClientConsole( message )
  CustomGameEventManager:Send_ServerToAllClients( "petri_debug_client_message", message )
end

function IsBuilding( target )

  return IsValidEntity(target) and target:HasAbility("petri_building") == true or target:HasAbility("petri_tower") == true
end

function IsInsideEntityBounds(ent, position)
  local origin = entity:GetAbsOrigin()
  local bounds = entity:GetBounds()
  local min = bounds.Mins
  local max = bounds.Maxs
  local X = location.x
  local Y = location.y
  local minX = min.x + origin.x
  local minY = min.y + origin.y
  local maxX = max.x + origin.x
  local maxY = max.y + origin.y
  local betweenX = X >= minX and X <= maxX
  local betweenY = Y >= minY and Y <= maxY

  return betweenX and betweenY
end

function GetMoveToTreePosition( unit, target )
  local origin = unit:GetAbsOrigin()
  local building_pos = target:GetAbsOrigin()
  local distance = 120
  return building_pos + (origin - building_pos):Normalized() * distance
end

function GetMoveToBuildingPosition( unit, target )
  local origin = unit:GetAbsOrigin()
  local building_pos = target:GetAbsOrigin()
  local distance = target:GetHullRadius()
  return building_pos + (origin - building_pos):Normalized() * distance
end

function PayGoldCost(ability)
  local cost = GetAbilityGoldCost( ability )
  if PlayerResource:GetGold(ability:GetOwnerEntity():GetPlayerOwnerID()) >= cost then
    ability:PayGoldCost()
    return true
  else
    return false
  end
end

function FakeStopOrder( target )
  local newOrder = {
    UnitIndex       = target:entindex(),
    OrderType       = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    Position        = target:GetAbsOrigin(), 
    Queue           = 0
  }
  ExecuteOrderFromTable(newOrder)
end

function UnitCanAttackTarget( unit, target )
  if not unit:HasAttackCapability() 
    or (target.IsInvulnerable and target:IsInvulnerable()) 
    or (target.IsAttackImmune and target:IsAttackImmune()) 
    or not unit:CanEntityBeSeenByMyTeam(target) 
    or unit:GetTeamNumber() == target:GetTeamNumber() then
    return false
  end

  return true
end

function IsMultiOrderAbility( ability )
  if IsValidEntity(ability) then
    if not ability.GetAbilityName then return false end
    local ability_name = ability:GetAbilityName()
    local ability_table = GameMode.AbilityKVs[ability_name]

    if not ability_table then
      ability_table = GameMode.ItemKVs[ability_name]
    end

    if ability_table then
      local AbilityMultiOrder = ability_table["AbilityMultiOrder"]
      if AbilityMultiOrder and AbilityMultiOrder == 1 then
        return true
      end
    else
      print("Cant find ability table for "..ability_name)
    end
  end
  return false
end

-- MODIFIERS
function RemoveInvuModifiers(target)
  target:RemoveModifierByName("modifier_item_petri_cola_active")
  target:RemoveModifierByName("modifier_item_petri_uber_mask_of_laugh_active")
  target:RemoveModifierByName("modifier_item_petri_magic_shield_active")
end

function RemoveGatheringAndRepairingModifiers(target)
  if target:HasModifier("modifier_returning_resources")
    or target:HasModifier("modifier_chopping_wood")
    or target:HasModifier("modifier_gathering_lumber")
    or target:HasModifier("modifier_chopping_wood_animation")
    or target:HasModifier("modifier_chopping_building_animation")
    or target:HasModifier("modifier_chopping_building")
    or target:HasModifier("modifier_repairing")
    or target:HasModifier("modifier_returning_resources_on_order_cancel") then

    ToggleAbilityOff(target:FindAbilityByName("return_resources"))
    ToggleAbilityOff(target:FindAbilityByName("gather_lumber"))
    ToggleAbilityOff(target:FindAbilityByName("petri_repair"))

    --cmdPlayer.activeBuilder:RemoveModifierByName("modifier_returning_resources")
    target:RemoveModifierByName("modifier_chopping_wood")
    target:RemoveModifierByName("modifier_gathering_lumber")
    target:RemoveModifierByName("modifier_chopping_wood_animation")

    target:RemoveModifierByName("modifier_returning_resources_on_order_cancel")

    target:RemoveModifierByName("modifier_repairing")
    target:RemoveModifierByName("modifier_chopping_building")
    target:RemoveModifierByName("modifier_chopping_building_animation")
  end
end

function GetModifierCountByName(caster, target, modifierBuffName)
  local modifierCount = target:GetModifierCount()
  local modifierName
  local currentStack = 0

  for i = 0, modifierCount do
    modifierName = target:GetModifierNameByIndex(i)

    if modifierName == modifierBuffName then
      currentStack = currentStack + 1
    end
  end

  return currentStack
end

function AddStackableModifierWithDuration(caster, target, ability, modifierName, time, maxStacks)
  local modifier = target:FindModifierByName(modifierName)
  if modifier then
    local stackCount = target:GetModifierStackCount(modifierName, caster)

    target:RemoveModifierByName(modifierName)
    ability:ApplyDataDrivenModifier(caster, target, modifierName, {duration=time})

    if (stackCount + 1) <= maxStacks then
      target:SetModifierStackCount(modifierName, caster, stackCount + 1)
    else
      target:SetModifierStackCount(modifierName, caster, stackCount)
    end
  else
    ability:ApplyDataDrivenModifier(caster, target, modifierName, {duration=time})
    target:SetModifierStackCount(modifierName, caster, 1)
  end
end
-- MODIFIERS

function PopupParticle(number, color, duration, caster, preSymbol, postSymbol)
  if number < 1 then
    return false
  end
  local pfxPath = string.format("particles/msg_fx/msg_gold.vpcf", pfx)

  local pidx

  if caster:GetPlayerOwner() == nil then
    pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, caster)
  else
    pidx = ParticleManager:CreateParticleForPlayer(pfxPath, PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetPlayerOwner())
  end

  local color = color
  local lifetime = duration
  local digits = #tostring(number) + 1

  local digits = 0
  if number ~= nil then
      digits = #tostring(number)
  end
  if preSymbol ~= nil then
      digits = digits + 1
  end
  if postSymbol ~= nil then
      digits = digits + 1
  end

  ParticleManager:SetParticleControl(pidx, 1, Vector( preSymbol, number, postSymbol ) )
  ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
  ParticleManager:SetParticleControl(pidx, 3, color)
end

function PopupStaticParticle(number, color, caster)
  if number < 1 then
    return false
  end
  local pfxPath = string.format("particles/portal_level_msg.vpcf", pfx)

  local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN, caster)

  local digits = 0
  if number ~= nil then
      digits = #tostring(number)
  end
  digits = digits + 1

  ParticleManager:SetParticleControl(pidx, 2, Vector(1, 0, 0))
  ParticleManager:SetParticleControl(pidx, 3, Vector(9, number, 2))
  ParticleManager:SetParticleControl(pidx, 4, Vector(1, digits, 0))
end

-- NETTABLES
function GetKeyInNetTable(pID, nettable, k)
  local tempTable = CustomNetTables:GetTableValue(nettable, tostring(pID))

  return tempTable[k]
end

function AddKeyToNetTable(pID, nettable, k, v)
  local tempTable = CustomNetTables:GetTableValue(nettable, tostring(pID)) or {}

  tempTable[k] = v

  CustomNetTables:SetTableValue(nettable, tostring(pID), tempTable);
end
-- NETTABLES

-- ITEMS
function GetItemByID(id)
  for k,v in pairs(GameMode.ItemKVs) do
    if tonumber(v["ID"]) == id then 
      v["name"] = k
      return v 
    end
  end
end

function CheckShopType(item, itemType)
  for k,v in pairs(GameMode.ItemKVs) do
    if k == item then 
      if itemType == "SecretShop" then 
        if not v["SideShop"] then
          return true
        end
      end
      if v[itemType] or v["ItemShareability"] == "ITEM_FULLY_SHAREABLE" then return true end
    end
  end
  return false
end
-- ITEMS

function ToggleAbilityAutocastOff(ability)
  if ability:GetAutoCastState() == true then 
      ability:ToggleAutoCast()
  end
end

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
  if GameMode.PETRI_NO_END == true then return false end

  for playerID = 0, DOTA_MAX_PLAYERS do
    if PlayerResource:IsValidPlayerID(playerID) then
      if not PlayerResource:IsBroadcaster(playerID) then
        if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS and PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
          local hero = GameMode.assignedPlayerHeroes[playerID] or PlayerResource:GetPlayer(playerID):GetAssignedHero()

          if IsValidEntity(hero) then 
            if hero:IsAlive() == true and hero:GetUnitName() == "npc_dota_hero_rattletrap" and hero:GetPlayerOwner() then
              return false
            end
          end
        end
      end
    end
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
  return CustomNetTables:GetTableValue("players_upgrades", tostring(pID))[upgrade]
end

function StartUpgrading (event)
  local caster = event.caster
  local ability = event.ability

  local hero = GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]
  local pID = hero:GetPlayerOwnerID()

  local level = ability:GetLevel() - 1

  local gold_cost = GetAbilityGoldCost( ability )
  local lumber_cost = ability:GetLevelSpecialValueFor("lumber_cost", level) or 0
  local food_cost = ability:GetLevelSpecialValueFor("food_cost", level) or 0

  if CheckLumber(caster:GetPlayerOwner(), lumber_cost,true) == false
    or CheckFood(caster:GetPlayerOwner(), food_cost,true) == false
    or CheckUpgradeDependencies(pID, ability:GetName(), ability:GetLevel()) == false 
    or GetCustomGold( pID ) < gold_cost then
    Timers:CreateTimer(0.06,
      function()
          caster:InterruptChannel()
      end
    )
  else
    hero.lumber = hero.lumber - lumber_cost
    hero.food = hero.food + food_cost

    caster.lastSpentLumber = lumber_cost
    caster.lastSpentGold = gold_cost
    caster.lastSpentFood = food_cost

    caster.foodSpent = caster.foodSpent or 0
    caster.foodSpent = caster.foodSpent + food_cost

    SpendCustomGold( pID, gold_cost )
    
    if not event["Permanent"] then
      ability:SetActivated(false)
    else 
      local all = FindAllByUnitName(caster:GetUnitName(), caster:GetPlayerOwnerID())
      local abilityName = ability:GetName()

      for k,v in pairs(all) do
        if v:HasAbility(abilityName) then
          local a = v:FindAbilityByName(abilityName)
          a:SetActivated(false)
        end
      end
    end
  end
end

function StopUpgrading(event)
  local caster = event.caster
  local ability = event.ability

  local hero = GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]

  caster.lastSpentLumber = caster.lastSpentLumber or 0
  caster.lastSpentGold = caster.lastSpentGold or 0
  caster.lastSpentFood = caster.lastSpentFood or 0

  if caster:IsAlive() then
    hero.lumber = hero.lumber + caster.lastSpentLumber
    hero.food = hero.food - caster.lastSpentFood
    caster.foodSpent = caster.foodSpent - caster.lastSpentFood
    AddCustomGold( caster:GetPlayerOwnerID(), caster.lastSpentGold )
  end

  caster.lastSpentLumber = 0
  caster.lastSpentGold = 0
  caster.lastSpentFood = 0

  if not event["Permanent"] then
    ability:SetActivated(true)
  else 
    local all = FindAllByUnitName(caster:GetUnitName(), caster:GetPlayerOwnerID())
    local abilityName = ability:GetName()

    for k,v in pairs(all) do
      if v:HasAbility(abilityName) then
        local a = v:FindAbilityByName(abilityName)
        a:SetActivated(true)
      end
    end
  end
end

function OnUpgradeSucceeded(event)
  local caster = event.caster
  local ability = event.ability

  local hero = GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]
  local pID = caster:GetPlayerOwnerID()

  local level = ability:GetLevel()

  ability:SetLevel(level+1)

  caster.lastSpentLumber = 0
  caster.lastSpentGold = 0
  caster.lastSpentFood = 0

  if caster:HasAbility("petri_upgrade") == false then
    caster:AddAbility("petri_upgrade")
    caster:FindAbilityByName("petri_upgrade"):ApplyDataDrivenModifier(caster, caster, "modifier_upgrade", {})
    caster:SetModifierStackCount("modifier_upgrade", caster, 1)
  end
  
  caster:SetModifierStackCount("modifier_upgrade", caster, caster:GetModifierStackCount("modifier_upgrade", caster) + 1)

  AddEntryToDependenciesTable(pID, ability:GetName(), ability:GetLevel())

  if event["Permanent"] then
    local tempTable = CustomNetTables:GetTableValue("players_upgrades", tostring(pID))
    tempTable[ability:GetName()] = tempTable[ability:GetName()] + 1
    CustomNetTables:SetTableValue( "players_upgrades", tostring(pID), tempTable );

    local all = FindAllByUnitName(caster:GetUnitName(), caster:GetPlayerOwnerID())
    local abilityName = ability:GetName()

    for k,v in pairs(all) do
      if v:HasAbility(abilityName) then
        local a = v:FindAbilityByName(abilityName)
        a:SetLevel(level+1)

        if level+1 == a:GetMaxLevel() then
          a:SetHidden(true)
        else 
          a:SetActivated(true)
        end
      end
    end
  else 
    if level+1 == ability:GetMaxLevel() then
      ability:SetHidden(true)
    else 
      ability:SetActivated(true)
    end
  end
end

function UpdateModel(target, model, scale)
  target:SetOriginalModel(model)
  target:SetModel(model)
  target:SetModelScale(scale)
end

-- End of upgrades

function AddLumber( player, amount )
  local playerID = player:GetPlayerID() 
  local hero = player:GetAssignedHero() 

  hero.lumber = hero.lumber + amount
  hero.allGatheredLumber = hero.allGatheredLumber + amount
end

function ReturnGold(player)
  local playerID = player:GetPlayerID() 
  local hero = player:GetAssignedHero() 
  if hero.lastSpentGold ~= nil then
    AddCustomGold( playerID, hero.lastSpentGold )
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
    if hero.food == 250 then
      Notifications:Bottom(player:GetPlayerID(), {text="#food_limit_is_reached", duration=2, style={color="red", ["font-size"]="35px"}})
    else 
      Notifications:Bottom(player:GetPlayerID(), {text="#need_more_food", duration=2, style={color="red", ["font-size"]="35px"}})
    end
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
      elseif abil:GetLevel() < 1 then
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

function RandomChange (percent)
  assert(percent >= 0 and percent <= 100) 
  return percent >= math.random(1, 100)
end

function GetTableLength( t )
  local length = 0

  for k,v in pairs(t) do
    length = length + 1
  end

  return length
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

function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end