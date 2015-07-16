function Upgrade ( event   )
	local caster = event.caster
	local ability = event.ability

	local tower_level = ability:GetLevel()

	if tower_level == 1 then
		UpdateModel(caster, "models/items/undying/idol_of_ruination/idol_tower.vmdl", 0.65)
	elseif tower_level == 2 then 
		caster:SetModelScale(0.7)
	elseif tower_level == 3 then
		UpdateModel(caster, "models/items/undying/idol_of_ruination/idol_tower_gold.vmdl", 0.75)
	elseif tower_level == 4 then
		caster:SetModelScale(0.8)
	end

	local attack = ability:GetLevelSpecialValueFor("attack", tower_level)
	local attack_rate = ability:GetLevelSpecialValueFor("attack_rate", tower_level)

	ability:GetCaster():SetBaseDamageMax(attack)
	ability:GetCaster():SetBaseDamageMin(attack)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_attack_speed", {})
end