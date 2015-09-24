function OnGreaseHit(keys)
	keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.target, "modifier_grease_corruption", {})
end