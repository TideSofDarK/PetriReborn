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

	UpdateAttributes(caster, wall_level, ability)

	if wall_level == 1 then
		caster:SetModel("models/items/rattletrap/forge_warrior_rocket_cannon/forge_warrior_rocket_cannon.vmdl")
		caster:SetModelScale(3.35)
	elseif wall_level == 2 then 
		caster:SetModel("models/props_rock/riveredge_rock008a.vmdl")
		caster:SetModelScale(0.8)
	elseif wall_level == 3 then
		caster:SetModel("models/props_magic/bad_crystals002.vmdl")
		caster:SetModelScale(2.4)
	elseif wall_level == 4 then
		caster:SetModel("models/heroes/oracle/crystal_ball.vmdl")
		caster:SetModelScale(4.3)
	elseif wall_level == 5 then
		caster:SetModel("models/props_items/bloodstone.vmdl")
		caster:SetModelScale(3.0)
	elseif wall_level == 6 then
		caster:SetModel("models/creeps/neutral_creeps/n_creep_golem_a/neutral_creep_golem_a.vmdl")
		caster:SetModelScale(1.2)
	elseif wall_level == 7 then
		caster:SetModel("models/heroes/undying/undying_flesh_golem.vmdl")
		caster:SetModelScale(1.3)
	elseif wall_level == 8 then
		caster:SetModel("models/items/warlock/golem/obsidian_golem/obsidian_golem.vmdl")
		caster:SetModelScale(1.5)
	elseif wall_level == 9 then
		caster:SetModel("models/items/terrorblade/dotapit_s3_fallen_light_metamorphosis/dotapit_s3_fallen_light_metamorphosis.vmdl")
		caster:SetModelScale(1.6)
	end

	caster:GetAbilityByIndex(0):SetLevel(wall_level+1)

	if wall_level+1 == 10 then
		caster:RemoveAbility("petri_upgrade_wall")
	end
end

function UpdateAttributes(wall, level, ability)
	local newHealth = ability:GetLevelSpecialValueFor("health_points", level - 1)
	local newArmor = ability:GetLevelSpecialValueFor("armor", level - 1)

	local fullHP = wall:GetHealth() == wall:GetMaxHealth()

	wall:SetBaseMaxHealth(newHealth)

	if fullHP then
		wall:SetHealth(newHealth)
	end

	ability:ApplyDataDrivenModifier(wall, wall, "modifier_armor", {})
end