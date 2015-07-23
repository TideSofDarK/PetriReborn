function Explore(keys)
	local target = keys.target_points[1]
	local caster = keys.caster

	local ability = keys.ability

	local allHeroes = HeroList:GetAllHeroes()
	local particleName = "particles/items_fx/dust_of_appearance.vpcf"

	-- Particle for team
	for _, v in pairs( allHeroes ) do
		if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
			local fxIndex = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_WORLDORIGIN, v, PlayerResource:GetPlayer( v:GetPlayerID() ) )
			ParticleManager:SetParticleControl( fxIndex, 0, target )
			ParticleManager:SetParticleControl( fxIndex, 1, Vector(1400,0,1400) )
		end
	end

	local dummy = CreateUnitByName("petri_dummy_1400vision", target, false, caster, caster, caster:GetTeamNumber())
	InitAbilities(dummy)
	Timers:CreateTimer(5, function() dummy:RemoveSelf() end)
end