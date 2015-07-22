Debug_Peasant = false

-- Lumber gathering

function Gather( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local target_class = target:GetClassname()

	-- Initialize variable to keep track of how much resource is the unit carrying
	if not caster.lumber_gathered then
		caster.lumber_gathered = 0
	end

	-- Intialize the variable to stop the return (workaround for ExecuteFromOrder being good and MoveToNPC now working after a Stop)
	caster.manual_order = false

	if target_class == "ent_dota_tree" then
		caster:MoveToTargetToAttack(target)
		if Debug_Peasant then
			print("Moving to ", target_class)
		end
		caster.target_tree = target


	end

	caster:RemoveModifierByName("modifier_gathering_lumber")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gathering_lumber", {})

	-- Visual fake toggle
	if ability:GetToggleState() == false then
		ability:ToggleAbility()
	end

	-- Hide Return
	--local return_ability = caster:FindAbilityByName("return_resources")
	--return_ability:SetHidden(true)
	--ability:SetHidden(false)

	--caster:SwapAbilities("gather_lumber", "return_resources" , true, false)

	if Debug_Peasant then
		print("Gather ON, Return OFF")
	end
end

-- Toggles Off Gather
function ToggleOffGather( event )
	local caster = event.caster
	local gather_ability = caster:FindAbilityByName("gather_lumber")
	
	caster.target_tree.worker = nil

	if gather_ability:GetToggleState() == true then
		gather_ability:ToggleAbility()

		if Debug_Peasant then
			print("Toggled Off Gather")
		end
	end
end

-- Toggles Off Return because of an order (e.g. Stop)
function ToggleOffReturn( event )
	local caster = event.caster
	local return_ability = caster:FindAbilityByName("return_resources")

	if return_ability:GetToggleState() == true then 
		return_ability:ToggleAbility()
		if Debug_Peasant then
			print("Toggled Off Return")
		end
	end
	caster.skip_order = false
end

function CheckTreePosition( event )

	local caster = event.caster
	local target = caster.target_tree -- Index tree so we know which target to start with
	local ability = event.ability
	local target_class = target:GetClassname()

	if target_class == "ent_dota_tree" then
		caster:MoveToTargetToAttack(target)
		--print("Moving to "..target_class)
	end

	local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length()
	local collision = distance < 160
	if not collision then
	--print("Moving to tree, distance: ",distance)
	elseif not caster:HasModifier("modifier_chopping_wood") then
		caster:RemoveModifierByName("modifier_gathering_lumber")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_chopping_wood", {})
		if Debug_Peasant then
			print("Reached tree")
		end
	end
end

function Gather100Lumber( event )
	
	local caster = event.caster
	local ability = event.ability

	local hero = caster:GetPlayerOwner():GetAssignedHero()

	local max_lumber_carried = 200
	local single_chop = 100

	if caster:GetUnitName() == "npc_petri_super_peasant" then 
		max_lumber_carried = 400
		single_chop = 200
	end

	max_lumber_carried = max_lumber_carried + (hero.bonusLumber * 2)
	single_chop = single_chop + hero.bonusLumber 

	local return_ability = caster:FindAbilityByName("return_resources")

	caster.lumber_gathered = caster.lumber_gathered + single_chop
	if Debug_Peasant then
		print("Gathered "..caster.lumber_gathered)
	end

	-- Show the stack of resources that the unit is carrying
	if not caster:HasModifier("modifier_returning_resources") then
        return_ability:ApplyDataDrivenModifier( caster, caster, "modifier_returning_resources", nil)
    end
    caster:SetModifierStackCount("modifier_returning_resources", caster, caster.lumber_gathered)
 
	-- Increase up to the max, or cancel
	if caster.lumber_gathered < max_lumber_carried then

		-- Fake Toggle the Return ability
		if return_ability:GetToggleState() == false or return_ability:IsHidden() then
			if Debug_Peasant then
				print("Gather OFF, Return ON")
			end
			--return_ability:SetHidden(false)
			if return_ability:GetToggleState() == false then
				return_ability:ToggleAbility()
			end
			--ability:SetHidden(true)

			caster:SwapAbilities("gather_lumber", "return_resources", false, true)
		end
	else
		local player = caster:GetPlayerOwner():GetPlayerID()

		caster:RemoveModifierByName("modifier_chopping_wood")

		-- Return Ability On		
		caster:CastAbilityNoTarget(return_ability, player)
		return_ability:ToggleAbility()

		
	end
end


function ReturnResources( event )

	local caster = event.caster
	local ability = event.ability

	if caster.lumber_gathered and caster.lumber_gathered > 0 then
		-- Find where to return the resources
		local building = FindClosestResourceDeposit( caster )
		if building == nil then return end
		if Debug_Peasant then
			print("Returning "..caster.lumber_gathered.." Lumber back to "..building:GetUnitName())
		end

		-- Set On, Wait one frame, as OnOrder gets executed before this is applied.
		Timers:CreateTimer(0.03, function() 
			if ability:GetToggleState() == false then
				ability:ToggleAbility()
				if Debug_Peasant then
					print("Return Ability Toggled On")
				end
			end
		end)

		local dist = (caster:GetAbsOrigin()-building:GetAbsOrigin()):Length() - 300
		local fixed_position = (building:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * dist

		ExecuteOrderFromTable({ UnitIndex = caster:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, TargetIndex = building:GetEntityIndex(), Position = fixed_position, Queue = false}) 
		caster.skip_order = true
		caster.target_building = building
	end
end

function CheckBuildingPosition( event )

	local caster = event.caster
	local target = caster.target_building -- Index building so we know which target to start with
	local ability = event.ability

	if not target or not caster then
		-- caster:RemoveModifierByName("modifier_chopping_wood")
		-- caster:RemoveModifierByName("modifier_gathering_lumber")
		-- caster:RemoveModifierByName("modifier_chopping_wood_animation")
		return
	end

	local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length()
	local collision = distance <= (caster.target_building:GetHullRadius()+100)
	if not collision then
		--print("Moving to building, distance: ",distance)
	else
		local hero = caster:GetOwner()
		local pID = hero:GetPlayerID()
		caster:RemoveModifierByName("modifier_returning_resources")
		if Debug_Peasant then
			print("Removed modifier_returning_resources")
		end

		if caster.lumber_gathered > 0 then
			if Debug_Peasant then
				print("Reached building, give resources")
			end

			local hero = caster:GetPlayerOwner():GetAssignedHero()
 
			local lumber_gathered = caster.lumber_gathered
			caster.lumber_gathered = 0

			-- Green Particle Lumber Popup
			POPUP_SYMBOL_PRE_PLUS = 0 -- This makes the + on the message particle
			local pfxPath = string.format("particles/msg_fx/msg_damage.vpcf", pfx)
			local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, caster)
			local color = Vector(10, 200, 90)
			local lifetime = 3.0
		    local digits = #tostring(lumber_gathered) + 1
		    
		    ParticleManager:SetParticleControl(pidx, 1, Vector( POPUP_SYMBOL_PRE_PLUS, lumber_gathered, 0 ) )
		    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
		    ParticleManager:SetParticleControl(pidx, 3, color)

		   
			hero.lumber = hero.lumber + lumber_gathered 
    		--print("Lumber Gained. " .. hero:GetUnitName() .. " is currently at " .. hero.lumber)
    		--FireGameEvent('cgm_player_lumber_changed', { player_ID = pID, lumber = hero.lumber })

    		caster:SwapAbilities("gather_lumber", "return_resources", true, false)
		end

		-- Return Ability Off
		if ability:ToggleAbility() == true then
			ability:ToggleAbility()
			if Debug_Peasant then
				print("Return Ability Toggled Off")
			end
		end

		-- Gather Ability
		local gather_ability = caster:FindAbilityByName("gather_lumber")
		if gather_ability:ToggleAbility() == false then
			-- Fake toggle On
			gather_ability:ToggleAbility() 
			if Debug_Peasant then
				print("Gather Ability Toggled On")
			end
		end
		caster:CastAbilityOnTarget(caster.target_tree, gather_ability, pID)
		if Debug_Peasant then
			print("Casting ability to target tree")
		end
	end
end

function FindClosestResourceDeposit( caster )
	local position = caster:GetAbsOrigin()

	local buildings = Entities:FindAllByClassname("npc_dota_base_additive*") 
	local sawmills = {}
	for _,building in pairs(buildings) do
		if building:GetUnitName() == "npc_petri_sawmill" then
			table.insert(sawmills, building)
		end
	end

	local distance = 9999
	local closest_building = nil

	if sawmills then
		-- print(table.getn(sawmills))
		if Debug_Peasant then
			print("barrack found")
		end
		for _,building in pairs(sawmills) do
			if building:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
				local this_distance = (position - building:GetAbsOrigin()):Length()
				if this_distance < distance then
					distance = this_distance
					closest_building = building
				end
			end
		end
		return closest_building

	end

end

function ReleaseTree( event )
	local caster = event.caster
	if caster.target_tree.worker ~= nil then
		caster.target_tree.worker = nil
	end
end

-- Repairing

function StartRepairing(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	if target:GetUnitName() == "npc_petri_exit" then return end

	if target:GetHealthPercent() == 100 then
		Notifications:Bottom(caster:GetPlayerOwnerID(), {text="#repair_target_is_full", duration=1, style={color="red", ["font-size"]="45px"}})
		return
	end

	if target:HasAbility("petri_building") ~= true then
		Notifications:Bottom(caster:GetPlayerOwnerID(), {text="#repair_target_is_not_a_building", duration=1, style={color="red", ["font-size"]="45px"}})
		return
	end
	
	if target:GetHealthPercent() < 100 and target:HasAbility("petri_building") then
		caster:MoveToNPC(target)
		caster.repairingTarget = target

		caster:RemoveModifierByName("modifier_repairing")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_repairing", {})

		-- Visual fake toggle
		if ability:GetToggleState() == false then
			ability:ToggleAbility()
		end
	end
end

function CheckRepairingTargetPosition( event )
	local caster = event.caster
	local target = caster.repairingTarget
	local ability = event.ability

	local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length()
	local collision = distance < 210
	if not collision then

	elseif not caster:HasModifier("modifier_chopping_building") then
		caster:RemoveModifierByName("modifier_repairing")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_chopping_building", {})
	end
end

function ToggleOffRepairing( event )
	local caster = event.caster
	local repair_ability = caster:FindAbilityByName("petri_repair")

	if repair_ability:GetToggleState() == true then
		repair_ability:ToggleAbility()
		if Debug_Peasant then
			print("Toggled Off Repairing")
		end
	end
end

function RepairBy1Percent( event )
	local caster = event.caster
	local ability = event.ability
	local target = caster.repairingTarget

	local health = target:GetHealth()
	local maxHealth = target:GetMaxHealth()

	if health < maxHealth then

		target:SetHealth(health + 25)
	else
		local player = caster:GetPlayerOwner():GetPlayerID()

		ability:ToggleAbility()

		caster:RemoveModifierByName("modifier_chopping_building")
		caster:RemoveModifierByName("modifier_repairing")
		caster:RemoveModifierByName("modifier_chopping_building_animation")
	end
end

-- Misc

function Spawn( t )
	local pID = thisEntity:GetPlayerOwnerID()
	local ability = thisEntity:FindAbilityByName("gather_lumber")

	InitAbilities(thisEntity)

	thisEntity.spawnPosition = thisEntity:GetAbsOrigin()

	Timers:CreateTimer(0.2, function()
		local trees = GridNav:GetAllTreesAroundPoint(thisEntity:GetAbsOrigin(), 750, true)

		local distance = 9999
		local closest_tree = nil
		local position = thisEntity:GetAbsOrigin()

		if trees then
			for k, v in pairs(trees) do
				local this_distance = (position - v:GetAbsOrigin()):Length()

				if this_distance < distance then
					distance = this_distance
					--if v.worker == nil then
						closest_tree = v
					--end
				end
			end

			if closest_tree ~= nil then closest_tree.worker = thisEntity end
			thisEntity:CastAbilityOnTarget(closest_tree, ability,pID)
		end
	end)
end

function Suicide( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:Kill(ability, caster)
end