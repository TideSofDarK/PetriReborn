function Use( event )
	local caster = event.caster
	local ability = event.ability

	local goldModifier = ability:GetLevelSpecialValueFor("gold_modifier", -1)

	caster:EmitSound("DOTA_Item.Hand_Of_Midas")

	PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), GameRules:GetDOTATime(false,false) * goldModifier  / 60, true, 0)
end