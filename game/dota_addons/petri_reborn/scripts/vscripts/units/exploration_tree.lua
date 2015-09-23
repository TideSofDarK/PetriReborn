function Explore(keys)
	local target = keys.target_points[1]
	local caster = keys.caster

	local ability = keys.ability

	local allHeroes = HeroList:GetAllHeroes()
	local particleName = "particles/items_fx/dust_of_appearance.vpcf"

	-- Particle for team
	local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()])
	ParticleManager:SetParticleControl( fxIndex, 0, target )
	ParticleManager:SetParticleControl( fxIndex, 1, Vector(1400,0,1400) )

	local dummy = CreateUnitByName("petri_dummy_1400vision", target, false, caster, caster, caster:GetTeamNumber())
	InitAbilities(dummy)
	Timers:CreateTimer(5, function() dummy:RemoveSelf() end)
end

function Upgrade( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster.childEntity = CreateUnitByName("petri_dummy_1800vision", caster:GetAbsOrigin(), false, caster:GetOwnerEntity(), caster:GetOwnerEntity(), DOTA_TEAM_GOODGUYS)
	caster:RemoveAbility("petri_upgrade_eye")
end