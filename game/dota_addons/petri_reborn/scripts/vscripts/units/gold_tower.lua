function GetGoldAutocast( event )
	local caster = event.caster
	local target = event.target -- victim of the attack
	local ability = event.ability

	caster:CastAbilityNoTarget(ability, caster:GetPlayerOwnerID())
end

function Spawn ( entityKeyValues  )
	Timers:CreateTimer(3.65,
    function()
    	thisEntity:GetAbilityByIndex(0):ToggleAutoCast()
    end)
end 

function GetGold( event )
	local caster = event.caster
	local ability = event.ability

	local pID = caster:GetPlayerOwnerID()
	PlayerResource:SetGold(pID, PlayerResource:GetUnreliableGold(pID) + tonumber(event["gold"]), false)
end

function StartUpgrading ( event   )
	local caster = event.caster
	local ability = event.ability

	local gold_cost = ability:GetGoldCost( ability:GetLevel() - 1 )

	if SpendFood(caster:GetPlayerOwner(), tonumber(event.food))== false then 
		
		Timers:CreateTimer(0.06,
			function()
		 	    	PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), gold_cost, false, 0)
		caster:InterruptChannel()
		Notifications:Bottom(PlayerResource:GetPlayer(0), {text="#need_more_food", duration=2, style={color="red", ["font-size"]="35px"}})
			end
		)
	else
		caster:SwapAbilities( "petri_upgrade_gold_tower", "petri_upgrade_gold_tower_cancel", false, true )
	end
end

function StopUpgrading ( event   )
	local caster = event.caster
	local ability = event.ability

	caster:InterruptChannel()

	Timers:CreateTimer(0.06,
	function()
		caster:SwapAbilities( "petri_upgrade_gold_tower", "petri_upgrade_gold_tower_cancel", true, false )
		local original_ability = caster:FindAbilityByName("petri_upgrade_gold_tower")

		local gold_cost = original_ability:GetGoldCost( original_ability:GetLevel() - 1 )
		local food_cost = original_ability:GetLevelSpecialValueFor("food_cost", original_ability:GetLevel() - 1)

		PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), gold_cost, false, 0)
		caster:GetPlayerOwner().food = caster:GetPlayerOwner().food - food_cost
	end
	)
end

function Upgrade ( event   )
	local caster = event.caster
	local ability = event.ability

	caster:SwapAbilities( "petri_upgrade_gold_tower", "petri_upgrade_gold_tower_cancel", true, false )

	local tower_level = ability:GetLevel()

	if tower_level == 1 then
		caster:SetModelScale(0.4)
	elseif tower_level == 2 then 
		caster:SetModelScale(0.5)
	elseif tower_level == 3 then
		caster:SetModelScale(0.6)
	elseif tower_level == 4 then
		caster:SetModelScale(0.7)
	elseif tower_level == 5 then
		caster:SetModelScale(0.8)
	elseif tower_level == 6 then
		caster:SetModelScale(0.9)
	elseif tower_level == 7 then
		caster:SetModelScale(1.0)
	elseif tower_level == 8 then
		caster:SetModelScale(1.1)
	end

	caster:GetAbilityByIndex(0):SetLevel(tower_level+1)
	caster:GetAbilityByIndex(1):SetLevel(tower_level+1)

	if tower_level+1 == 8 then
		caster:RemoveAbility("petri_upgrade_gold_tower")
	end
end