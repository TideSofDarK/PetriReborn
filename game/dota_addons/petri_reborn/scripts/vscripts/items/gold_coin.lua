function Use( event )
	local caster = event.caster
	local ability = event.ability

	local goldModifier = ability:GetLevelSpecialValueFor("gold_modifier", -1)

	caster:EmitSound("DOTA_Item.Hand_Of_Midas")
	
	local amount = math.floor(GameRules:GetDOTATime(false,false) * goldModifier  / 60)

	PopupParticle(amount, Vector(244,201,23), 1.0, caster)

	AddCustomGold( caster:GetPlayerOwnerID(), amount )
end