function UpgradeToEarthWall( keys )
	local caster = keys.caster

	local pos = caster:GetAbsOrigin()
	local player = caster:GetPlayerOwner()

	caster:RemoveBuilding( true )
	UTIL_Remove(caster)

	local wall = BuildingHelper:PlaceBuilding(player, "npc_petri_earth_wall", pos, true, true, 2)

	--UpdateModel(wall, "models/items/earth_spirit/demon_stone_summon/demon_stone_summon.vmdl", 0.8)
	InitAbilities(wall)

	Timers:CreateTimer(0.03, function (  )
		wall:RemoveModifierByName("modifier_building")
	end)
end