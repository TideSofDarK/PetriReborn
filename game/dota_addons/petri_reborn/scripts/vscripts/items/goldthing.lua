function Use(keys)
	local caster = keys.caster
	local gold = keys.ability:GetSpecialValueFor("gold")

	AddCustomGold( caster:GetPlayerOwnerID(), gold )
end