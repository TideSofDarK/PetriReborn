function ApplyBonusDamage( event )
	local caster = event.caster
	local ability = event.ability

	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)

	caster:EmitSound("Hero_LegionCommander.Duel.Cast")

	for k,v in pairs(units) do
		if v:GetPlayerOwnerID() == caster:GetPlayerOwnerID() and v:HasAttackCapability() and
			v:HasAbility("petri_building") then
			ability:ApplyDataDrivenModifier(caster, v, "modifier_item_petri_attack_scroll_active", {duration = ability:GetSpecialValueFor("duration")})
		
			local fxIndex = ParticleManager:CreateParticle( "particles/items_fx/aegis_timer_i.vpcf", PATTACH_ABSORIGIN, v)
			ParticleManager:SetParticleControl( fxIndex, 0, v:GetAbsOrigin() )
		end
	end
end