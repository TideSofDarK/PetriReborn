function Spawn ( entityKeyValues  )
	thisEntity.foodProvided = 0
	Timers:CreateTimer(2.2,
    function()
    	thisEntity:GetPlayerOwner().maxFood = thisEntity:GetPlayerOwner().maxFood + 30
    	thisEntity.foodProvided = 30
    end)
end

function Upgrade ( event   )
	local caster = event.caster
	local ability = event.ability
	local player = caster:GetPlayerOwner()

	local tent_level = ability:GetLevel()

	if tent_level == 1 then
		caster:SetModelScale(0.4)
	elseif tent_level == 2 then 
		caster:SetModel("models/props_structures/tent_dk_med")
	elseif tent_level == 3 then
		caster:SetModel("models/props_structures/tent_dk_large.vmdl")
	end

	ability:SetLevel(tent_level+1)

	if tent_level+1 == 4 then
		caster:RemoveAbility("petri_upgrade_tent")
	else
		ability:SetHidden(false)
	end

	player.maxFood = player.maxFood + 30
	caster.foodProvided = caster.foodProvided  + 30
end

function StartUpgrading(event)
	local caster = event.caster
	local ability = event.ability
	local player = caster:GetPlayerOwner()

	local tent_level = ability:GetLevel()
	local lumber_cost = ability:GetLevelSpecialValueFor("lumber_cost", tent_level-1)

	ability:SetHidden(true)

	Timers:CreateTimer(0.06,
	function()
		if CheckLumber(player, lumber_cost,true) == true then
			SpendLumber(player, lumber_cost)
		else
			caster:InterruptChannel()

			ability:SetHidden(false)
		end
	end)
end