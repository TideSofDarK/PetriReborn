function BonusGoldFromWall(keys)
	local caster = keys.caster
	local target = keys.target

	if target:GetUnitName() == "npc_petri_wall" then
		PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), 1, false, DOTA_ModifyGold_SharedGold)

		PlusParticle(1, Vector(244,201,23), 3.0, caster)
	end

	if target:HasAbility("petri_creep_pendant") == true 
	and caster:GetAverageTrueAttackDamage() >= target:FindAbilityByName("petri_creep_pendant"):GetLevelSpecialValueFor( "damage", -1 ) then
		if caster:HasModifier("modifier_bonus_damage") then
			caster:RemoveModifierByName("modifier_bonus_damage")
		end

		GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]:ModifyGold(110, false, DOTA_ModifyGold_CreepKill )
		caster.allEarnedGold = caster.allEarnedGold + 110
		PlusParticle(110, Vector(244,201,23), 1.0, caster)
	end
end

function ModifierSuperLifesteal(keys)
	if keys.target:HasAbility("petri_cop_trap") == false then
		if keys.target:HasAbility("petri_building") then
			keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_petri_uber_mask_of_laugh_datadriven_lifesteal_building", {duration = 0.03})
		else
			keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_petri_uber_mask_of_laugh_datadriven_lifesteal", {duration = 0.03})
		end
	end
end

function ModifierLifesteal(keys)
	if keys.target:HasAbility("petri_cop_trap") == false then
		if keys.target:HasAbility("petri_building") then
			keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_petri_mask_of_laugh_datadriven_lifesteal_building", {duration = 0.03})
		else
			keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_petri_mask_of_laugh_datadriven_lifesteal", {duration = 0.03})
		end
	end
end

--[[
	Author: Noya
	Date: 17.01.2015.
	Gives vision over an area and shows a particle to the team
]]
function FarSight( event )
	local caster = event.caster
	local ability = event.ability
	local level = ability:GetLevel()
	local reveal_radius = ability:GetLevelSpecialValueFor( "reveal_radius", level - 1 )
	local duration = ability:GetLevelSpecialValueFor( "duration", level - 1 )

	local allHeroes = HeroList:GetAllHeroes()
	local particleName = "particles/items_fx/dust_of_appearance.vpcf"
	local target = event.target_points[1]

	-- Particle for team
	for _, v in pairs( allHeroes ) do
		if v:GetPlayerID() then
			local fxIndex = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_WORLDORIGIN, v, PlayerResource:GetPlayer( v:GetPlayerID() ) )
			ParticleManager:SetParticleControl( fxIndex, 0, target )
			ParticleManager:SetParticleControl( fxIndex, 1, Vector(reveal_radius,0,reveal_radius) )
		end
	end

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, reveal_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER,false)

	for i,v in ipairs(units) do
		if v:HasAbility("petri_building") == true then
			if not v.minimapIcon then
				v.minimapIcon = CreateUnitByName("npc_dummy_enemy_building_icon", v:GetAbsOrigin(), false, v, v, DOTA_TEAM_GOODGUYS)
			end
		end
	end

	-- Vision
	if level == 1 then
		local dummy = CreateUnitByName("petri_dummy_600vision", target, false, caster, caster, caster:GetTeamNumber())
		Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)

	elseif level == 2 then
		local dummy = CreateUnitByName("petri_dummy_1000vision", target, false, caster, caster, caster:GetTeamNumber())
		Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
	elseif level == 3 then
		local dummy = CreateUnitByName("petri_dummy_1400vision", target, false, caster, caster, caster:GetTeamNumber())
		Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
    elseif level == 4 then
		-- Central dummy
		local dummy = CreateUnitByName("petri_dummy_1800vision", target, false, caster, caster, caster:GetTeamNumber())

		-- We need to create many 1800vision dummies to make a bigger circle
		local fv = caster:GetForwardVector()
    	local distance = 1800

    	-- Front and Back
    	local front_position = target + fv * distance
    	local back_position = target - fv * distance

		-- Left and Right
    	ang_left = QAngle(0, 90, 0)
    	ang_right = QAngle(1, -90, 0)
		
		local left_position = RotatePosition(target, ang_left, front_position)
    	local right_position = RotatePosition(target, ang_right, front_position)

    	-- Create the 4 auxiliar units
    	local dummy_front = CreateUnitByName("dummy_1800vision", front_position, false, caster, caster, caster:GetTeamNumber())
    	local dummy_back = CreateUnitByName("dummy_1800vision", back_position, false, caster, caster, caster:GetTeamNumber())
    	local dummy_left = CreateUnitByName("dummy_1800vision", left_position, false, caster, caster, caster:GetTeamNumber())
    	local dummy_right = CreateUnitByName("dummy_1800vision", right_position, false, caster, caster, caster:GetTeamNumber())

    	-- Destroy after the duration
    	Timers:CreateTimer(duration, function() 
    		if not dummy:IsNull() then dummy:RemoveSelf() end
    		if not dummy_front:IsNull() then dummy_front:RemoveSelf() end
    		if not dummy_back:IsNull() then dummy_back:RemoveSelf() end
    		if not dummy_left:IsNull() then dummy_left:RemoveSelf() end
    		if not dummy_right:IsNull() then dummy_right:RemoveSelf() end
    	end)
    end

end

function Sleep(keys)
	local caster = keys.caster
	local target = keys.target

	RemoveGatheringAndRepairingModifiers(target)

	for i=0,target:GetAbilityCount()-1 do
		if target:GetAbilityByIndex(i) ~= nil and target:GetAbilityByIndex(i):GetToggleState() then
			target:GetAbilityByIndex(i):ToggleAbility()
		end
	end

	-- for i=0,target:GetModifierCount() do
	-- 	local modifierName = target:GetModifierNameByIndex(i)
	-- 	target:RemoveModifierByName(modifierName)
	-- end
end

function Return( keys )
	local caster = keys.caster

	caster.teleportationState = 0

	caster:Stop()
    PlayerResource:SetCameraTarget(caster:GetPlayerOwnerID(), caster)

	Timers:CreateTimer(0.1,
    function()
    	local particleName = "particles/econ/events/nexon_hero_compendium_2014/teleport_end_ground_flash_nexon_hero_cp_2014.vpcf"
		local particle = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( particle, 0, caster.spawnPosition )

		PlayerResource:SetCameraTarget(caster:GetPlayerOwnerID(), nil)
    end)

	FindClearSpaceForUnit(caster,caster.spawnPosition,true)

	caster:Stop()
	local newOrder = {
        UnitIndex       = caster:entindex(),
        OrderType       = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position        = caster:GetAbsOrigin(), 
        Queue           = 0
    }

  	ExecuteOrderFromTable(newOrder)
end

function SpawnWard(keys)
	local point = keys.target_points[1]
	local caster = keys.caster

	local ward = CreateUnitByName("npc_petri_ward", point,  true, nil, caster, DOTA_TEAM_BADGUYS)

	keys.ability:ApplyDataDrivenModifier(caster, ward, "modifier_ward_invisibility", {})

	InitAbilities(ward)
	StartAnimation(ward, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})
end

function SpawnJanitor( keys )
	local caster = keys.caster

	local janitor = CreateUnitByName("npc_petri_janitor", caster:GetAbsOrigin(), true, nil, caster, DOTA_TEAM_BADGUYS)
	janitor:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
	janitor:SetOwner(caster)

	-- UpdateModel(janitor, "models/heroes/death_prophet/death_prophet_ghost.vmdl", 1.0)
	-- for i=0,15 do
	-- 	if janitor:GetAbilityByIndex(i) ~= nil then janitor:RemoveAbility(janitor:GetAbilityByIndex(i):GetName())  end
	-- end

	--janitor:AddAbility("courier_transfer_items")

	--InitAbilities(janitor)

	janitor:SetHasInventory(true)
	janitor:SetMoveCapability(2)
	janitor.spawnPosition = caster.spawnPosition
end

function ReadBookOfLaugh( keys )
	local caster = keys.caster
	caster:HeroLevelUp(false)
	caster:HeroLevelUp(false)
	caster:HeroLevelUp(false)
	caster:HeroLevelUp(false)
	caster:HeroLevelUp(true)
end

function ReadComedyStory( keys )
	local caster = keys.caster

	caster:SetBaseDamageMin(caster:GetBaseDamageMin() + 17000)
	caster:SetBaseDamageMax(caster:GetBaseDamageMax() + 17000)

	caster:CalculateStatBonus()
end

function ReadComedyBook( keys )
	local caster = keys.caster
	
	caster:SetBaseStrength(caster:GetBaseStrength() + 25)

	caster:CalculateStatBonus()
end

function BuySnares( keys )
	local caster = keys.caster
	local player = keys.caster:GetPlayerOwner()
	local pID = player:GetPlayerID()
	local ability = keys.ability
	
	local sleep_ability = caster:FindAbilityByName("petri_petrosyan_sleep")
	if sleep_ability then
		caster:AddAbility("petri_petrosyan_snare_1")
		caster:FindAbilityByName("petri_petrosyan_snare_1"):UpgradeAbility(false)
		caster:SwapAbilities("petri_petrosyan_sleep", "petri_petrosyan_snare_1", false, true)
		caster:RemoveAbility("petri_petrosyan_sleep")
	else
		PlayerResource:ModifyGold(pID, keys.ItemCost, false, 7)
	end
end

function BuyUpgradedSnares( keys )
	local caster = keys.caster
	local player = keys.caster:GetPlayerOwner()
	local pID = player:GetPlayerID()
	local ability = keys.ability
	
	local snare_ability = caster:FindAbilityByName("petri_petrosyan_snare_1")
	if snare_ability then
		caster:AddAbility("petri_petrosyan_snare_2")
		caster:FindAbilityByName("petri_petrosyan_snare_2"):UpgradeAbility(false)
		caster:SwapAbilities("petri_petrosyan_snare_1", "petri_petrosyan_snare_2", false, true)
		caster:RemoveAbility("petri_petrosyan_snare_1")
	else
		PlayerResource:ModifyGold(pID, keys.ItemCost, false, 7)
	end
end

function OnAwake( keys )
	local caster = keys.caster
	Notifications:Bottom(caster:GetPlayerOwnerID(), {text="#petri_start", duration=5, style={color="white", ["font-size"]="45px"}})
	if GameRules.firstPetrosyanIsAwake == nil then
		GameRules.firstPetrosyanIsAwake = true
		Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#petrosyan_is_awake", duration=4, style={color="red", ["font-size"]="45px"}})
		print("First petrosyan is awake")
	end
end