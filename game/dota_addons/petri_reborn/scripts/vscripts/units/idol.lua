function Spawn( keys )
	StartAnimation(thisEntity, {duration=-1, activity=ACT_DOTA_IDLE , rate=2.5})
	thisEntity:SetAngles(0, -90, 0)

	Timers:CreateTimer(tonumber(GameMode.AbilityKVs["build_petri_idol"]["BuildTime"]) + 0.1, function()
		-- local hSpawnTable = {
		-- 	name = "team_"..DOTA_TEAM_GOODGUYS.."_idol_target",
		-- 	origin = thisEntity:GetAbsOrigin()
		-- }

		-- SpawnEntityFromTableSynchronous( "info_target", hSpawnTable )

		--SpawnEntityFromTableSynchronous( "trigger_shop", hSpawnTable )
	end)
end