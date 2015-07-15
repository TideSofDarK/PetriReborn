function StartUpgrading (event)
	local caster = event.caster
	local ability = event.ability

	local sawmill_level = ability:GetLevel() - 1

	local gold_cost = ability:GetGoldCost(sawmill_level)
	local lumber_cost = ability:GetLevelSpecialValueFor("lumber_cost", sawmill_level)

	if CheckLumber(caster:GetPlayerOwner(), lumber_cost,true) == false then 
		Timers:CreateTimer(0.06,
			function()
		 	    PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), gold_cost, false, 0)
				caster:InterruptChannel()
			end
		)
	else
		SpendLumber(caster:GetPlayerOwner(), lumber_cost)
		ability:SetHidden(true)
	end
end

function Upgrade (event)
	local caster = event.caster
	local ability = event.ability

	ability:SetHidden(false)

	local sawmill_level = ability:GetLevel()

	if sawmill_level == 1 then
		caster:SetOriginalModel(GetModelNameForLevel(sawmill_level))
		caster:SetModel(GetModelNameForLevel(sawmill_level))
		caster:SetModelScale(0.7)

		caster:SwapAbilities("train_petri_peasant", "petri_empty1", true, false)

		caster:GetPlayerOwner().sawmill_2 = true
	elseif sawmill_level == 2 then 
		caster:SetOriginalModel(GetModelNameForLevel(sawmill_level))
		caster:SetModel(GetModelNameForLevel(sawmill_level))
		caster:SetModelScale(0.5)

		caster:GetPlayerOwner().sawmill_3 = true

		caster:SwapAbilities("train_petri_super_peasant", "petri_empty2", true, false)
	end

	ability:SetLevel(sawmill_level+1)

	if sawmill_level+1 == 3 then
		caster:RemoveAbility("petri_upgrade_sawmill")
	end
end

function GetModelNameForLevel(level)
	if level == 1 then
		return "models/props_structures/good_barracks_ranged002_lvl2.vmdl"
	elseif level == 2 then 
		return "models/props_structures/good_ancient001.vmdl"
	end
end