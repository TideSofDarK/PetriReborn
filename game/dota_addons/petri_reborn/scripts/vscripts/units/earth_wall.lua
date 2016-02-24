function UpgradeToEarthWall( keys )
	local caster = keys.caster

	local pos = caster:GetAbsOrigin()
	local player = caster:GetPlayerOwner()

	local gridNavBlockers = caster.blockers

	UTIL_Remove(caster)

	local wall = BuildingHelper:PlaceBuilding(player, "npc_petri_earth_wall", pos, true, false, 2)
	wall.blockers = gridNavBlockers

	InitAbilities(wall)

	Timers:CreateTimer(0.03, function (  )
		wall:RemoveModifierByName("modifier_building")
	end)
end