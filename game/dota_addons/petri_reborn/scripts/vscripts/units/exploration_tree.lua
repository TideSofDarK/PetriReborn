function Explore(keys)
	local target = keys.target_points[1]
	local caster = keys.caster

	local ability = keys.ability

	local dummy = CreateUnitByName("petri_dummy_1400vision", target, false, caster, caster, caster:GetTeamNumber())
	Timers:CreateTimer(5, function() dummy:RemoveSelf() end)
end