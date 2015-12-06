function Upgrade( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster.childEntity = CreateUnitByName("petri_dummy_1800vision", caster:GetAbsOrigin(), false, caster:GetOwnerEntity(), caster:GetOwnerEntity(), DOTA_TEAM_GOODGUYS)
	caster:RemoveAbility("petri_upgrade_eye")
end