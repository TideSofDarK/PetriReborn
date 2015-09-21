function Use( event )
	local caster = event.caster
	local ability = event.ability

	local woodModifier = ability:GetLevelSpecialValueFor("wood_modifier", -1)

	caster:EmitSound("ui.inv_pickup_wood")

	local hero = GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]

	hero.lumber = hero.lumber + math.floor(GameRules:GetDOTATime(false,false) * woodModifier / 60)
end