function Spawn( keys )
	StartAnimation(thisEntity, {duration=-1, activity=ACT_DOTA_IDLE , rate=2.5})
end

function StartUpgrading (event)
	local caster = event.caster
	local ability = event.ability

	local upgrade_level = ability:GetLevel() - 1

	local gold_cost = ability:GetGoldCost(upgrade_level)
	local lumber_cost = ability:GetLevelSpecialValueFor("lumber_cost", upgrade_level)

	if CheckLumber(caster:GetPlayerOwner(), lumber_cost,true) == false then 
		Timers:CreateTimer(0.06,
			function()
		 	    PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), gold_cost, false, 0)
				caster:InterruptChannel()
			end
		)
	else
		caster:GetPlayerOwner().lumber = caster:GetPlayerOwner().lumber - lumber_cost
		caster:SwapAbilities( "petri_upgrade_concrete", "petri_cancel_concrete_upgrading", true, false )
		ability:SetHidden(true)
	end
end

function Upgrade (event)
	local caster = event.caster
	local ability = event.ability

	ability:SetHidden(false)
	caster:SwapAbilities( "petri_upgrade_concrete", "petri_cancel_concrete_upgrading", true, false )

	local upgrade_level = ability:GetLevel()

	caster:GetAbilityByIndex(0):SetLevel(upgrade_level+1)

	if upgrade_level+1 == 10 then
		caster:RemoveAbility("petri_upgrade_concrete")
		caster:RemoveAbility("petri_cancel_concrete_upgrading")
	end
end

function StopUpgrading ( event   )
	local caster = event.caster
	local ability = event.ability

	caster:InterruptChannel()

	Timers:CreateTimer(0.06,
	function()
		caster:SwapAbilities( "petri_upgrade_concrete", "petri_cancel_concrete_upgrading", true, false )
		local original_ability = caster:FindAbilityByName("petri_upgrade_concrete")

		local gold_cost = original_ability:GetGoldCost( original_ability:GetLevel() - 1 )
		local lumber_cost = original_ability:GetLevelSpecialValueFor("food_cost", original_ability:GetLevel() - 1)

		-- Return resources
		PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), gold_cost, false, 0)
		caster:GetPlayerOwner().lumber = caster:GetPlayerOwner().lumber + lumber_cost
	end
	)
end