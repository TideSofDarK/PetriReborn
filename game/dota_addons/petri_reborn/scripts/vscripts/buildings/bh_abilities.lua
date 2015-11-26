function CancelBuilding(caster, ability, pID, reason)
	if reason ~= "" then Notifications:Top(caster:GetPlayerOwnerID(),{text=reason, duration=4, style={color="red"}, continue=false}) end
	return false
end

function build( keys )
	local player = keys.caster:GetPlayerOwner()
	local hero = player:GetAssignedHero()
	local pID = player:GetPlayerID()
	local caster = keys.caster

	local hero = GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]

	local ability = keys.ability
	
	local gold_cost = ability:GetGoldCost(1)
	local lumber_cost = ability:GetLevelSpecialValueFor("lumber_cost", ability:GetLevel()-1)
	local food_cost = ability:GetLevelSpecialValueFor("food_cost", ability:GetLevel()-1)

	local ability_name = ability:GetName()
	local unit_name = GameMode.AbilityKVs[ability_name]["UnitName"]

	EndCooldown(caster, ability_name)
	PlayerResource:ModifyGold(pID, gold_cost, false, 7) 

	if not CheckBuildingDependencies(pID, ability_name) then
		return false
	end

	--Build exit only after 16 min
	if ability:GetName() == "build_petri_exit" then
		if PETRI_EXIT_ALLOWED == false then
			return CancelBuilding(caster, ability, pID, "#too_early_for_exit")
		end
	end

	-- Cancel building if limit is reached
	if hero.buildingCount >= PETRI_MAX_BUILDING_COUNT_PER_PLAYER then
		return CancelBuilding(caster, ability, pID, "#building_limit_is_reached")
	end

	-- Cancel building if eye was already built
	for k,v in pairs(hero.uniqueUnitList) do
		if k == unit_name and v == true then
			return CancelBuilding(caster, ability, pID, "")
		end
	end

	player.waitingForBuildHelper = true
	
	local returnTable = BuildingHelper:AddBuilding(keys)

	keys:OnBuildingPosChosen(function(vPos)

	end)

	keys:OnPreConstruction(function ()
        if not CheckLumber(player, lumber_cost,true) or not CheckFood(player, food_cost,true) or PlayerResource:GetGold(pID) < gold_cost 
        	then
        	return false
		else
			if caster.currentArea ~= nil then
				if CheckAreaClaimers(hero, caster.currentArea.claimers) or caster.currentArea.claimers == nil then

					if caster.currentArea.claimers == nil or
						(caster.currentArea.claimers and caster.currentArea.claimers[0] and caster.currentArea.claimers[0]:IsAlive() == false
							and (not caster.currentArea.claimers[1] or caster.currentArea.claimers[1]:IsAlive() == false)) then 
						Notifications:Top(pID, {text="#area_claimed", duration=4, style={color="white"}, continue=false})
					end

					caster.currentArea.claimers = caster.currentArea.claimers or {}
					if caster.currentArea.claimers[0] ~= nil and caster.currentArea.claimers[0]:IsAlive() == false then
						if not caster.currentArea.claimers[1] or caster.currentArea.claimers[1]:IsAlive() == false then 
							caster.currentArea.claimers[0] = hero 
						end
					elseif caster.currentArea.claimers[0] == nil then 
						caster.currentArea.claimers[0] = hero 
					end

				else
					Notifications:Top(pID, {text="#you_cant_build", duration=4, style={color="white"}, continue=false})
					return false
				end
			end

			SpendLumber(player, lumber_cost)
			SpendFood(player, food_cost)

			PlayerResource:ModifyGold(pID, -1 * gold_cost, false, 7)

			StartCooldown(caster, ability_name)
		end
    end)

	keys:OnConstructionStarted(function(unit)
		hero.buildingCount = hero.buildingCount + 1

		if GameMode.UnitKVs[unit_name]["Unique"] == 1 then
			hero.uniqueUnitList[unit_name] = true
		end

		if unit:GetUnitName() == "npc_petri_exit" then
			Notifications:TopToAll({text="#exit_construction_is_started", duration=10, style={color="blue"}, continue=false})

			GameMode.EXIT_COUNT = GameMode.EXIT_COUNT + 1

			unit.childEntity = CreateUnitByName("petri_dummy_1400vision", keys.caster:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS)
			Timers:CreateTimer(GameMode.PETRI_ADDITIONAL_EXIT_GOLD_TIME, 
				function() 
					if unit:IsNull() == false and unit:IsAlive() == true and GameMode.PETRI_ADDITIONAL_EXIT_GOLD_GIVEN == false then
						GameMode.PETRI_ADDITIONAL_EXIT_GOLD_GIVEN = true
						GiveSharedGoldToHeroes(PETRI_ADDITIONAL_EXIT_GOLD, "npc_dota_hero_brewmaster")
						GiveSharedGoldToHeroes(PETRI_ADDITIONAL_EXIT_GOLD, "npc_dota_hero_death_prophet")
						Notifications:TopToAll({text="#additional_exit_gold", duration=5, style={color="white"}, continue=false})
					end
				end)
		end

		caster:EmitSound("ui.inv_pickup_wood")

		FindClearSpaceForUnit(keys.caster, keys.caster:GetAbsOrigin(), true)
		unit.foodSpent = food_cost

		local building_ability = unit:FindAbilityByName("petri_building")
		if building_ability then building_ability:SetLevel(1) end

		if caster:GetUnitName() == "npc_dota_hero_rattletrap" then
			if caster.currentMenu == 1 then
				caster:CastAbilityNoTarget(caster:FindAbilityByName("petri_close_basic_buildings_menu"), pID)
			elseif caster.currentMenu == 2 then
				caster:CastAbilityNoTarget(caster:FindAbilityByName("petri_close_advanced_buildings_menu"), pID)
			end
		end

		unit:SetMana(0)
		unit.tempManaRegen = unit:GetManaRegen()
		unit:SetBaseManaRegen(0.0)
	end)
	keys:OnConstructionCompleted(function(unit)
		InitAbilities(unit)

		AddEntryToDependenciesTable(pID, ability_name, 1)

		if unit.onBuildingCompleted then
			unit.onBuildingCompleted(unit)
		end

		unit:SetMana(unit:GetMaxMana())
		unit:SetBaseManaRegen(unit.tempManaRegen)
		unit.tempManaRegen = nil

		if unit.controllableWhenReady then
			unit:SetControllableByPlayer(keys.caster:GetPlayerOwnerID(), true)
		end
	end)

	-- These callbacks will only fire when the state between below half health/above half health changes.
	-- i.e. it won't unnecessarily fire multiple times.
	keys:OnBelowHalfHealth(function(unit)
	end)

	keys:OnAboveHalfHealth(function(unit)

	end)

	keys:OnConstructionFailed(function( building )
	end)

	keys:OnConstructionCancelled(function( building )
	end)

	-- Have a fire effect when the building goes below 50% health.
	-- It will turn off it building goes above 50% health again.
	keys:EnableFireEffect("modifier_jakiro_liquid_fire_burn")

  	if caster:GetUnitName() == "npc_dota_hero_rattletrap" then
		local basicMenu = caster:FindAbilityByName("petri_close_basic_buildings_menu")
		local advancedMenu = caster:FindAbilityByName("petri_close_advanced_buildings_menu")

		if basicMenu ~= nil then
			caster:CastAbilityNoTarget(basicMenu, pID)
		else
			caster:CastAbilityNoTarget(advancedMenu, pID)
		end
	end
end

function building_canceled( keys )
	BuildingHelper:CancelBuilding(keys)
end

function create_building_entity( keys )
	BuildingHelper:InitializeBuildingEntity(keys)
end

function builder_queue( keys )
    local ability = keys.ability
    local caster = keys.caster  
    
    if caster.ProcessingBuilding ~= nil
    and caster.lastOrder ~= DOTA_UNIT_ORDER_STOP
    and caster.lastOrder ~= DOTA_UNIT_ORDER_CAST_NO_TARGET
    and caster.lastOrder ~= DOTA_UNIT_ORDER_PICKUP_ITEM
    and caster.lastOrder ~= DOTA_UNIT_ORDER_MOVE_ITEM
     then
        -- caster is probably a builder, stop them
        player = PlayerResource:GetPlayer(caster:GetMainControllingPlayer())
        --player.activeBuilding = nil
        if player.activeBuilder and player.activeBuilder ==caster and IsValidEntity(player.activeBuilder) then
            player.activeBuilder:ClearQueue()
            player.activeBuilder:Stop()
            player.activeBuilder.ProcessingBuilding = false
        end
    end
end