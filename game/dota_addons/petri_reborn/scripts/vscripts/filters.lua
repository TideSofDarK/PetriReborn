function GameMode:FilterExecuteOrder( filterTable )
    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]

    local abilityIndex = filterTable["entindex_ability"]
    local targetIndex = filterTable["entindex_target"]
    local x = tonumber(filterTable["position_x"])
    local y = tonumber(filterTable["position_y"])
    local z = tonumber(filterTable["position_z"])
    local point = Vector(x,y,z)

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
      if filterTable["entindex_target"] >= 6 then
        return false
      elseif PlayerResource:GetTeam(issuer) == DOTA_TEAM_BADGUYS then
        local hero = EntIndexToHScript(filterTable["units"]["0"])
        local ent = EntIndexToHScript(filterTable["units"]["0"])

        if ent:GetUnitName() == "npc_petri_janitor" then
          filterTable["units"]["0"] = hero:GetOwnerEntity():entindex()
          hero = ent:GetOwnerEntity()
        end

        if EntIndexToHScript(filterTable["entindex_ability"]):GetPurchaser() ~= hero then
          return false
        end

        if Entities:FindByName(nil,"PetrosyanShopTrigger"):IsTouching(ent) then
          local stashSlot = 6

          for i=6,11 do
            if hero:GetItemInSlot(i) == EntIndexToHScript(filterTable["entindex_ability"]) then
              stashSlot = i
              break
            end
          end

          local itemName = hero:GetItemInSlot(stashSlot):GetName()
          local charges = hero:GetItemInSlot(stashSlot):GetCurrentCharges()

          local newItem = CreateItem(itemName, ent, hero)
          newItem:SetCurrentCharges(charges)

          hero:RemoveItem(hero:GetItemInSlot(stashSlot))
          ent:AddItem(newItem)
        end
      end
    elseif order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
      local item = EntIndexToHScript(filterTable["entindex_target"]):GetContainedItem()

      local purchaser = EntIndexToHScript(units["0"])

      if item:IsCastOnPickup() == true then
        if EntIndexToHScript(units["0"]):GetUnitName() == "npc_petri_cop" then
          return true
        else 
          return false
        end
      end

      if purchaser:GetTeam() == DOTA_TEAM_GOODGUYS then 
        if CheckShopType(item:GetName()) ~= 1 then
          return false
        end
      end
      if purchaser:GetTeam() == DOTA_TEAM_BADGUYS then 
        if CheckShopType(item:GetName()) == 1 then
          return false
        end
      end
    elseif order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
      local purchaser = EntIndexToHScript(units["0"])

      if purchaser:GetUnitName() == "npc_petri_janitor" then
        filterTable["units"]["0"] = purchaser:GetOwnerEntity():entindex()
      end

      local item = GetItemByID(filterTable["entindex_ability"])

      if OnEnemyShop(purchaser) then
        Notifications:Bottom(issuer, {text="#cant_buy_pudge", duration=2, style={color="red", ["font-size"]="35px"}})
        return false
      elseif PlayerResource:GetTeam(issuer) == DOTA_TEAM_GOODGUYS then
        if not item["SideShop"] or OnKVNSideShop( purchaser ) == false then return false end
      elseif PlayerResource:GetTeam(issuer) == DOTA_TEAM_BADGUYS then
        if item["SideShop"] then return false end
      end
    elseif order_type == DOTA_UNIT_ORDER_SELL_ITEM then
      local purchaser = EntIndexToHScript(units["0"])

      if OnEnemyShop(purchaser) then
        return false
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
    end

    return true
end

function GameMode:ModifyGoldFilter(event)
  event["reliable"] = 0

  if GameMode.assignedPlayerHeroes[event.player_id_const] then
    GameMode.assignedPlayerHeroes[event.player_id_const].allEarnedGold = GameMode.assignedPlayerHeroes[event.player_id_const].allEarnedGold or 0
    GameMode.assignedPlayerHeroes[event.player_id_const].allEarnedGold = GameMode.assignedPlayerHeroes[event.player_id_const].allEarnedGold + event["gold"]
  end

  if event.reason_const == DOTA_ModifyGold_HeroKill then
    if GameRules:GetDOTATime(false, false) < 120 then return false end

    if event.player_id_const and PlayerResource:GetTeam(event.player_id_const) == DOTA_TEAM_BADGUYS then
      GiveSharedGoldToTeam(90 * GetGoldModifier(), DOTA_TEAM_BADGUYS)
    end

    return false
  elseif event.reason_const == DOTA_ModifyGold_Unspecified then
    if event.player_id_const and PlayerResource:GetTeam(event.player_id_const) == DOTA_TEAM_BADGUYS then
      if GameRules:GetDOTATime(false, false) < 120 then return false end
      print(GetGoldModifier())
      GiveSharedGoldToTeam(event["gold"] * GetGoldModifier(), DOTA_TEAM_BADGUYS)

      return false
    end
  elseif event.reason_const == DOTA_ModifyGold_CreepKill then
    
    if PlayerResource:GetTeam(event["player_id_const"]) == DOTA_TEAM_BADGUYS and
      event["gold"] >= 5000 then -- boss

      Notifications:TopToAll({text="#boss_is_killed_1", duration=4, style={color="red"}, continue=false})
      Notifications:TopToAll({text=tostring(event["gold"]/2).." ", duration=4, style={color="red"}, continue=true})
      Notifications:TopToAll({text="#boss_is_killed_2", duration=4, style={color="red"}, continue=true})

      if event["gold"] >= 10000 then
       CreateItemOnPositionSync(GameMode.assignedPlayerHeroes[event.player_id_const]:GetAbsOrigin(), CreateItem("item_petri_grease", nil, nil)) 
       Notifications:TopToAll({text="#grease_has_been_dropped", duration=4, style={color="red"}, continue=false})
      end

      for i=1,PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) do
        local hero = GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, i)] 
        if hero then
          PlayerResource:ModifyGold(hero:GetPlayerOwnerID(), event["gold"]/2, false, DOTA_ModifyGold_SharedGold)

          PlusParticle(event["gold"]/2, Vector(244,201,23), 3.0, hero)
        end
      end
      return false
    end
  end
  return true
end

function GameMode:ModifyExperienceFilter(filterTable)
  if not filterTable["player_id_const"] then return false end
  if PlayerResource:GetPlayer(filterTable["player_id_const"]):GetTeam() == DOTA_TEAM_GOODGUYS then return false end 
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