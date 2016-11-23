function GameMode:FilterExecuteOrder( filterTable )

    if GameMode.PETRI_GAME_HAS_ENDED == true then return false end

    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]

    local abilityIndex = filterTable["entindex_ability"]
    local targetIndex = filterTable["entindex_target"]
    local x = tonumber(filterTable["position_x"])
    local y = tonumber(filterTable["position_y"])
    local z = tonumber(filterTable["position_z"])
    local point = Vector(x,y,z)
    PrintTable(filterTable)
    local issuerUnit
    if units["0"] then
      issuerUnit = EntIndexToHScript(units["0"])
      if issuerUnit then issuerUnit.lastOrder = order_type end
    end

    if issuerUnit and issuerUnit.skip then
      issuerUnit.skip = false
      return true
    end

    for n,unit_index in pairs(units) do
      local unit = EntIndexToHScript(unit_index)
      local ownerID = unit:GetPlayerOwnerID()

      if PlayerResource:GetConnectionState(ownerID) == 3 or
        PlayerResource:GetConnectionState(ownerID) == 4
        then
        return false
      end
    end

    if PlayerResource:GetTeam(issuer) == DOTA_TEAM_GOODGUYS then
      if abilityIndex and IsMultiOrderAbility(EntIndexToHScript(abilityIndex)) then
        local ability = EntIndexToHScript(abilityIndex) 
        local abilityName = ability:GetAbilityName()

        if not GameMode.SELECTED_UNITS[issuerUnit:GetPlayerOwnerID()] then return false end

        local entityList = GameMode.SELECTED_UNITS[issuerUnit:GetPlayerOwnerID()]
        
        for _,entityIndex in pairs(entityList) do
          local caster = EntIndexToHScript(entityIndex)
          if caster and caster:HasAbility(abilityName) then
            local abil = caster:FindAbilityByName(abilityName)
            if abil and abil:IsFullyCastable() then

              if issuerUnit ~= caster then caster.skip = true end

              if order_type == DOTA_UNIT_ORDER_CAST_POSITION then
                ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, Position = point, AbilityIndex = abil:GetEntityIndex(), Queue = queue})
              elseif order_type == DOTA_UNIT_ORDER_CAST_TARGET or order_type == DOTA_UNIT_ORDER_CAST_TARGET_TREE then
                FakeStopOrder(caster)
                ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, TargetIndex = targetIndex, AbilityIndex = abil:GetEntityIndex(), Queue = queue})
              else --order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET or order_type == DOTA_UNIT_ORDER_CAST_TOGGLE or order_type == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO
                if order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET then 
                  Timers:CreateTimer(function() 
                    caster:CastAbilityNoTarget(abil, caster:GetPlayerOwnerID())
                  end) 
                else 
                  ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, AbilityIndex = abil:GetEntityIndex(), Queue = queue})
                end
              end
            end
          end
        end
        return false
      end
    end

    if order_type == DOTA_UNIT_ORDER_MOVE_ITEM then 

      if filterTable["entindex_target"] >= 6 and PlayerResource:GetTeam(issuer) ~= DOTA_TEAM_BADGUYS then
        return false
      elseif filterTable["entindex_target"] >= 6 and PlayerResource:GetTeam(issuer) == DOTA_TEAM_BADGUYS then
        local hero = EntIndexToHScript(filterTable["units"]["0"])

        local targetSlot = filterTable["entindex_target"]
        local heroSlot = 0

        if not Entities:FindByName(nil,"PetrosyanShopTrigger"):IsTouching(hero) then
          return false
        end

        for i=0,11 do
          if hero:GetItemInSlot(i) == EntIndexToHScript(filterTable["entindex_ability"]) then
            heroSlot = i
            break
          end
        end

        hero:SwapItems(heroSlot, targetSlot)
        return false
      elseif PlayerResource:GetTeam(issuer) == DOTA_TEAM_BADGUYS then
        local hero = EntIndexToHScript(filterTable["units"]["0"])
        local ent = hero

        -- if EntIndexToHScript(filterTable["entindex_ability"]):GetPurchaser() ~= hero then
        --   return false
        -- end

        if Entities:FindByName(nil,"PetrosyanShopTrigger"):IsTouching(hero) then

          local stashSlot = 6

          for i=0,11 do
            if hero:GetItemInSlot(i) == EntIndexToHScript(filterTable["entindex_ability"]) then
              stashSlot = i
              break
            end
          end

          if hero:GetItemInSlot(stashSlot) and hero:GetItemInSlot(stashSlot):GetPurchaser() ~= hero then
            return false
          elseif not hero:GetItemInSlot(stashSlot) then
            return false
          end

          local oldItem = hero:GetItemInSlot(stashSlot)

          
          ent:DropItemAtPositionImmediate(oldItem, Vector(10000,10000,10000))

          ent:AddItem(oldItem)

          UTIL_Remove(oldItem:GetContainer())
        end
      end
    elseif order_type == DOTA_UNIT_ORDER_GIVE_ITEM then
      local item = EntIndexToHScript(filterTable["entindex_ability"])

      local purchaser = EntIndexToHScript(filterTable["entindex_target"])

      if check2(purchaser) and check1(item:GetName()) then
        return false
      end

      if purchaser:GetUnitName() ~= "npc_dota_courier" and purchaser ~= item:GetPurchaser() and purchaser:GetTeamNumber() == DOTA_TEAM_BADGUYS and item:GetName() ~= "item_petri_grease" then
        return false
      end

      if issuerUnit:GetUnitName() == "npc_dota_courier" and purchaser:IsHero() == true 
        and (issuerUnit:GetAbsOrigin() - purchaser:GetAbsOrigin()):Length() < 400 then

        local hasSpace = false
        for i=0,5 do
          if purchaser:GetItemInSlot(i) == nil then 
            hasSpace = true
            break
          end
        end

        if hasSpace == false then
          local oldItem = purchaser:GetItemInSlot(0)

          purchaser:DropItemAtPositionImmediate(oldItem, purchaser:GetAbsOrigin())

          issuerUnit:DropItemAtPositionImmediate(item, issuerUnit:GetAbsOrigin())

          purchaser:AddItem(item)

          issuerUnit:AddItem(oldItem)

          UTIL_Remove(item:GetContainer())
          UTIL_Remove(oldItem:GetContainer())
        end
      end
    elseif order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
      if not EntIndexToHScript(filterTable["entindex_target"]) then return false end

      local item = EntIndexToHScript(filterTable["entindex_target"]):GetContainedItem()

      local purchaser = EntIndexToHScript(units["0"])
      if item:GetName() == "item_petri_candy" then return true end
      if check2(purchaser) and check1(item:GetName()) then
        return false
      end

      if purchaser:GetUnitName() ~= "npc_dota_courier" and purchaser ~= item:GetPurchaser() and purchaser:GetTeamNumber() == DOTA_TEAM_BADGUYS and item:GetName() ~= "item_petri_grease" then
        return false
      end

      if item:IsCastOnPickup() == true then
        if EntIndexToHScript(units["0"]):GetUnitName() == "npc_petri_cop" then
          return true
        else 
          return false
        end
      end

      if purchaser:GetTeam() == DOTA_TEAM_GOODGUYS then 
        if CheckShopType(item:GetName(), "SideShop") == false then
          return false
        end
      end
      if purchaser:GetTeam() == DOTA_TEAM_BADGUYS then 
        if CheckShopType(item:GetName(), "SecretShop") == false then
          return false
        end
      end
    elseif order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
      local purchaser = EntIndexToHScript(units["0"])

      if purchaser:GetUnitName() == "npc_petri_janitor" then
        filterTable["units"]["0"] = purchaser:GetOwnerEntity():entindex()
      end

      local item = GetItemByID(filterTable["entindex_ability"])

      if item and check2(purchaser) and check1(item["name"]) then
        return false
      end

      if PlayerResource:GetTeam(issuer) == DOTA_TEAM_GOODGUYS and (filterTable["entindex_ability"] == 45 or filterTable["entindex_ability"] == 84) then return false end

      if item then
        if purchaser:GetUnitName() == "npc_dota_hero_storm_spirit" and item["SideShop"] then
          return false
        end
        if OnEnemyShop(purchaser) then
          Notifications:Bottom(issuer, {text="#cant_buy_pudge", duration=2, style={color="red", ["font-size"]="35px"}})
          return false
        elseif PlayerResource:GetTeam(issuer) == DOTA_TEAM_GOODGUYS then
          if item["SideShop"] ~= 1 or OnKVNSideShop( purchaser ) == false then return false end
        elseif PlayerResource:GetTeam(issuer) == DOTA_TEAM_BADGUYS then
          if item["SideShop"] then return false end
        end
      end
    elseif order_type == DOTA_UNIT_ORDER_SELL_ITEM then
      local purchaser = EntIndexToHScript(units["0"])

      if OnEnemyShop(purchaser) then
        return false
      end

      local item = EntIndexToHScript(filterTable.entindex_ability) 

      if item and item.purchaseTime and GameMode.ItemKVs[item:GetName()].ItemSellable ~= "0" then
        if item.purchaseTime + 10 > GameMode.PETRI_TRUE_TIME or GameMode.ItemKVs[item:GetName()].ItemSellFullPrice == "1" then
          AddCustomGold( issuer, math.floor(GameMode.ItemKVs[item:GetName()].ItemCost) )
        else
          AddCustomGold( issuer, math.floor(GameMode.ItemKVs[item:GetName()].ItemCost / 2))
        end

        EmitSoundOnClient("Quickbuy.Confirmation", PlayerResource:GetPlayer(issuer))
      end
    elseif order_type == DOTA_UNIT_ORDER_GLYPH then
      return false
    elseif order_type == DOTA_UNIT_ORDER_CAST_TARGET_TREE then
      local ability = EntIndexToHScript(abilityIndex)
      if ability and ability.GetAbilityName then
        local abilityName = ability:GetAbilityName()

        if abilityName == "gather_lumber" then
          if issuerUnit:FindModifierByName("modifier_returning_resources") then
            issuerUnit:RemoveModifierByName("modifier_chopping_wood")
          
            issuerUnit:CastAbilityNoTarget(issuerUnit:FindAbilityByName("return_resources"), issuer)

            return false
          end
          return true
        end
      end
    elseif order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET then
      local ability = EntIndexToHScript(abilityIndex)
      if ability and ability.GetAbilityName then
        local abilityName = ability:GetAbilityName()

        if abilityName == "petri_open_basic_buildings_menu" or abilityName == "petri_open_advanced_buildings_menu"
          or abilityName == "petri_close_basic_buildings_menu" or abilityName == "petri_close_advanced_buildings_menu" then
          issuerUnit.lastOrder = DOTA_UNIT_ORDER_MOVE_ITEM 
        end
      else return false end
    elseif order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
      local target = EntIndexToHScript(targetIndex)
      for n, unit_index in pairs(units) do 
        local unit = EntIndexToHScript(unit_index)
        if UnitCanAttackTarget(unit, target) then
          unit.skip = true
          ExecuteOrderFromTable({ UnitIndex = unit_index, OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, TargetIndex = targetIndex, Queue = queue})
        end
      end
      return false
    elseif order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then 
      local target = EntIndexToHScript(targetIndex)
      
      if target:HasAbility("petri_building") == true then
        issuerUnit:MoveToPosition(GetMoveToBuildingPosition(issuerUnit,target))

        return false
      end
    end

    return true
end

function GameMode:ModifyGoldFilter(event)
  return false
  -- event["reliable"] = 0

  -- local hero = GameMode.assignedPlayerHeroes[event.player_id_const]

  -- if event.reason_const == DOTA_ModifyGold_SellItem then

  --   AddCustomGold( event.player_id_const, event["gold"] )
    
  --   return false
  -- end

  -- return false
end

function GameMode:ModifyExperienceFilter(filterTable)
  if not filterTable["player_id_const"] or not PlayerResource:GetPlayer(filterTable["player_id_const"]) then return false end
  if PlayerResource:GetPlayer(filterTable["player_id_const"]):GetTeam() == DOTA_TEAM_GOODGUYS 
    or PlayerResource:GetPlayer(filterTable["player_id_const"]):GetTeam() == DOTA_TEAM_BADGUYS 
    then return false end 
  return true
end

function OnEnemyShop( unit )
  local teamID = unit:GetTeamNumber()
  local position = unit:GetAbsOrigin()
  local own_base_name = "team_"..teamID
  local nearby_entities = Entities:FindAllByNameWithin("team_*", position, 300)

  if (#nearby_entities > 0) then
    for k,ent in pairs(nearby_entities) do
      if not string.match(ent:GetName(), own_base_name) then
        return true
      end
    end
  end
  return false
end

function OnKVNSideShop( unit )
  local teamID = unit:GetTeamNumber()
  local position = unit:GetAbsOrigin()
  local own_base_name = "team_"..teamID
  local nearby_entities = Entities:FindAllByNameWithin("team_*", position, 300)

  if (#nearby_entities > 0) then
    for k,ent in pairs(nearby_entities) do
      if string.match(ent:GetName(), own_base_name) then
        return true
      end
    end
  end
  return false
end