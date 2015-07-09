function Explore(keys)
	local point = keys.target_points[1]
	local caster = keys.caster

	local ability = keys.ability

	local particleName = "particles/units/heroes/hero_rattletrap/clock_loadout_sparks.vpcf"

	local particle = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	 ParticleManager:SetParticleControl( particle, 0, point )

	point.z = point.z - 90000

	ability:CreateVisibilityNode(point, 1000, 6)
end