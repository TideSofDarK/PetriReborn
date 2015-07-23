function BonusGoldFromWall(keys)
	if keys.target:GetUnitName() == "npc_petri_wall" then
		PlayerResource:ModifyGold(keys.caster:GetPlayerOwnerID(), 1, false, 0)

		POPUP_SYMBOL_PRE_PLUS = 0 -- This makes the + on the message particle
		local pfxPath = string.format("particles/msg_fx/msg_damage.vpcf", pfx)
		local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, keys.caster)
		local color = Vector(244,201,23)
		local lifetime = 3.0
	    local digits = #tostring(1) + 1
	    
	    ParticleManager:SetParticleControl(pidx, 1, Vector( POPUP_SYMBOL_PRE_PLUS, 1, 0 ) )
	    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
	    ParticleManager:SetParticleControl(pidx, 3, color)
	end
end

function ModifierSuperLifesteal(keys)
	if keys.target:HasAbility("petri_building") then
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_petri_uber_mask_of_laugh_datadriven_lifesteal_building", {duration = 0.03})
	else
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_petri_uber_mask_of_laugh_datadriven_lifesteal", {duration = 0.03})
	end
end

function ModifierLifesteal(keys)
	if keys.target:HasAbility("petri_building") then
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_petri_mask_of_laugh_datadriven_lifesteal_building", {duration = 0.03})
	else
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_petri_mask_of_laugh_datadriven_lifesteal", {duration = 0.03})
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
		if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
			local fxIndex = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_WORLDORIGIN, v, PlayerResource:GetPlayer( v:GetPlayerID() ) )
			ParticleManager:SetParticleControl( fxIndex, 0, target )
			ParticleManager:SetParticleControl( fxIndex, 1, Vector(reveal_radius,0,reveal_radius) )
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
    		dummy:RemoveSelf()
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

	target:RemoveModifierByName("modifier_repairing")
	target:RemoveModifierByName("modifier_chopping_building")
	target:RemoveModifierByName("modifier_chopping_building_animation")
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
end

function SpawnWard(keys)
	local point = keys.target_points[1]
	local caster = keys.caster

	local ward = CreateUnitByName("npc_petri_ward", point,  true, nil, caster, DOTA_TEAM_BADGUYS)

	InitAbilities(ward)
	StartAnimation(ward, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})
end

function SpawnJanitor( keys )
	local caster = keys.caster

	local janitor = CreateUnitByName("npc_dota_courier", caster:GetAbsOrigin(), true, nil, caster, DOTA_TEAM_BADGUYS)
	janitor:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)

	UpdateModel(janitor, "models/heroes/death_prophet/death_prophet_ghost.vmdl", 1.0)
	for i=0,15 do
		if janitor:GetAbilityByIndex(i) ~= nil then janitor:RemoveAbility(janitor:GetAbilityByIndex(i):GetName())  end
	end

	janitor:AddAbility("courier_transfer_items")
	janitor:AddAbility("petri_janitor_truesight")
	
	InitAbilities(janitor)

	janitor:SetMoveCapability(2)

	janitor.spawnPosition = caster:GetAbsOrigin()
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

	caster:SetBaseDamageMin(caster:GetBaseDamageMin() + 575)
	caster:SetBaseDamageMax(caster:GetBaseDamageMax() + 575)

	caster:CalculateStatBonus()
end

function ReadComedyBook( keys )
	local caster = keys.caster
	
	caster:SetBaseStrength(caster:GetBaseStrength() + 40)

	caster:CalculateStatBonus()
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