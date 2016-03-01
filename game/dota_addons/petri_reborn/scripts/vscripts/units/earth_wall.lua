function UpgradeToEarthWall( keys )
	local caster = keys.caster

	local pos = caster:GetAbsOrigin()
	local pID = caster:GetPlayerOwnerID()

	local gridNavBlockers = caster.blockers
	local remove = caster.RemoveFromGNV

	caster.RemoveFromGNV()

	UTIL_Remove(caster)

	local wall = BuildingHelper:PlaceBuilding(GameMode.assignedPlayerHeroes[pID], "npc_petri_earth_wall", pos, true, false, 2)
	wall.blockers = gridNavBlockers

	InitAbilities(wall)

	Timers:CreateTimer(0.03, function (  )
		wall:RemoveModifierByName("modifier_building")
	end)
end