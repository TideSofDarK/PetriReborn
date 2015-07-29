function ApplyBonusArmor( event )
	local caster = event.caster
	local ability = event.ability

	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
	
	for k,v in pairs(units) do
		if v:GetPlayerOwnerID() == caster:GetPlayerOwnerID() and
			v:HasAbility("petri_building") then
			ability:ApplyDataDrivenModifier(caster, v, "modifier_item_petri_defence_scroll_active", {duration = ability:GetSpecialValueFor("duration")})
		end
	end
end