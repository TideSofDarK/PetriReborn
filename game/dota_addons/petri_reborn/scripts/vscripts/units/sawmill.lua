function Upgrade (event)
	local caster = event.caster
	local ability = event.ability

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
end

function GetModelNameForLevel(level)
	if level == 1 then
		return "models/props_structures/good_barracks_ranged002_lvl2.vmdl"
	elseif level == 2 then 
		return "models/props_structures/good_ancient001.vmdl"
	end
end