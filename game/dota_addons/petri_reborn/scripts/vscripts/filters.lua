function GameMode:FilterExecuteOrder( filterTable )
    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]

    local issuerUnit
    if units["0"] then
      issuerUnit = EntIndexToHScript(units["0"])
      if issuerUnit then issuerUnit.lastOrder = order_type end
    end

    if order_type == DOTA_UNIT_ORDER_MOVE_ITEM then 
      if filterTable["entindex_target"] >= 6 then
        return false
      elseif PlayerResource:GetTeam(issuer) == DOTA_TEAM_BADGUYS then
        local ent = EntIndexToHScript(filterTable["units"]["0"])

        if Entities:FindByName(nil,"PetrosyanShopTrigger"):IsTouching(ent) then
          local stashSlot = 6
          for i=6,11 do
            if ent:GetItemInSlot(i) == EntIndexToHScript(filterTable["entindex_ability"]) then
              stashSlot = i
              break
            end
          end
          ent:SwapItems(filterTable["entindex_target"], stashSlot)
        end
      end
    elseif order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
      local purchaser = EntIndexToHScript(units["0"])
      local item = GetItemByID(filterTable["entindex_ability"])

      if OnEnemyShop(purchaser) then
        Notifications:Bottom(issuer, {text="#cant_buy_pudge", duration=2, style={color="red", ["font-size"]="35px"}})
        return false
      elseif PlayerResource:GetTeam(issuer) == DOTA_TEAM_GOODGUYS then
        if not item["SideShop"] then return false end
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

    return true
end

function GameMode:ModifyGoldFilter(event)
  event["reliable"] = 0
  if event.reason_const == DOTA_ModifyGold_HeroKill then
    event["gold"] = 17 * (PlayerResource:GetKills(event.player_id_const) + 1)
  elseif event.reason_const == DOTA_ModifyGold_CreepKill then
    PrintTable(event)
    if PlayerResource:GetTeam(event["player_id_const"]) == DOTA_TEAM_BADGUYS and
      event["gold"] >= 5000 then -- boss
      Notifications:TopToAll({text="#boss_is_killed_1", duration=4, style={color="red"}, continue=false})
      Notifications:TopToAll({text=tostring(event["gold"]/2).." ", duration=4, style={color="red"}, continue=true})
      Notifications:TopToAll({text="#boss_is_killed_2", duration=4, style={color="red"}, continue=true})
      for i=1,PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) do
        local hero = GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, i)] 
        if hero then
          PlayerResource:ModifyGold(hero:GetPlayerOwnerID(), event["gold"]/2, false, DOTA_ModifyGold_SharedGold)

          POPUP_SYMBOL_PRE_PLUS = 0 -- This makes the + on the message particle
          local pfxPath = string.format("particles/msg_fx/msg_damage.vpcf", pfx)
          local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, hero)
          local color = Vector(244,201,23)
          local lifetime = 3.0
          local digits = #tostring(event["gold"]/2) + 1
          
          ParticleManager:SetParticleControl(pidx, 1, Vector( POPUP_SYMBOL_PRE_PLUS, event["gold"]/2, 0 ) )
          ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
          ParticleManager:SetParticleControl(pidx, 3, color)
        end
      end
      return false
    end
  end
  return true
end

function GameMode:ModifyExperienceFilter(filterTable)
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