function Sleep(keys)
	local caster = keys.caster
	local target = keys.target

	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local dur = ability:GetLevelSpecialValueFor("sleep_modifier", ability_level)

	ability:ApplyDataDrivenModifier( caster, target, "sleep_modifier", dur)
end