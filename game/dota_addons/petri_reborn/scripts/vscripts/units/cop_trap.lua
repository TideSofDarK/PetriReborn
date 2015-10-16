function OnAttacked( keys )
	local attacker = keys.attacker
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(attacker, attacker, "modifier_poison", {})
end