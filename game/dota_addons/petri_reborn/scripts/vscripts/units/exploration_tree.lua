function Upgrade( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster.childEntity = CreateUnitByName("npc_dummy_upgraded_eye_vision", caster:GetAbsOrigin(), false, caster:GetOwnerEntity(), caster:GetOwnerEntity(), DOTA_TEAM_GOODGUYS)

	caster:RemoveAbility("petri_upgrade_eye")
end