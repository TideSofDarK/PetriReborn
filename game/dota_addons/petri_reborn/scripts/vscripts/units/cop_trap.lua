function OnAttacked( keys )
	local attacker = keys.attacker

	local damageTable = {
	    victim = attacker,
	    attacker = keys.caster,
	    damage = keys.damage,
	    damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
end