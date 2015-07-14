function StartUpgrading (event)
	local caster = event.caster
	local ability = event.ability

	local wall_level = ability:GetLevel() - 1

	local gold_cost = ability:GetGoldCost(wall_level)
	local lumber_cost = ability:GetLevelSpecialValueFor("lumber_cost", wall_level)

	if CheckLumber(caster:GetPlayerOwner(), lumber_cost,true) == false then 
		Timers:CreateTimer(0.06,
			function()
		 	    PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), gold_cost, false, 0)
				caster:InterruptChannel()
			end
		)
	else
		SpendLumber(caster:GetPlayerOwner(), lumber_cost)
		caster:SwapAbilities("petri_upgrade_wall", "petri_empty4", false, true)
		ability:SetHidden(true)
	end
end

function Upgrade (event)
	local caster = event.caster
	local ability = event.ability

	ability:SetHidden(false)
	caster:SwapAbilities("petri_upgrade_wall", "petri_empty4", true, false)

	local wall_level = ability:GetLevel()

	if wall_level == 1 then
		--caster:SetModelScale(0.4)
	elseif wall_level == 2 then 
		--caster:SetModelScale(0.5)
	elseif wall_level == 3 then
		--caster:SetModelScale(0.6)
	elseif wall_level == 4 then
		--caster:SetModelScale(0.7)
	elseif wall_level == 5 then
		--caster:SetModelScale(0.8)
	elseif wall_level == 6 then
		--caster:SetModelScale(0.9)
	elseif wall_level == 7 then
		--caster:SetModelScale(1.0)
	elseif wall_level == 8 then
		--caster:SetModelScale(1.1)
	elseif wall_level == 9 then
		--caster:SetModelScale(1.1)
	end

	UpdateAttributes(caster, wall_level, ability)

	caster:GetAbilityByIndex(0):SetLevel(wall_level+1)

	if wall_level+1 == 10 then
		caster:RemoveAbility("petri_upgrade_wall")
	end
end

function UpdateAttributes(wall, level, ability)
	local newHealth = ability:GetLevelSpecialValueFor("health_points", level - 1)
	local newArmor = ability:GetLevelSpecialValueFor("armor", level - 1)

	local fullHP = wall:GetHealth() == wall:GetMaxHealth()

	wall:SetMaxHealth(newHealth)

	if fullHP then
		wall:SetHealth(newHealth)
	end

	wall:SetPhysicalArmorBaseValue(newArmor)
end