function OnStartTouch(trigger)
 	local unitName = trigger.activator:GetUnitName()
 	if trigger.activator:GetTeam() == DOTA_TEAM_GOODGUYS then
 		if trigger.activator.spawnPosition ~= nil then
 			FindClearSpaceForUnit(trigger.activator, trigger.activator.spawnPosition + Vector(-70,-70,0), false)
	 		Timers:CreateTimer(0.03, function()
	 			MoveCamera(trigger.activator:GetPlayerOwnerID(),trigger.activator)
	 			trigger.activator:Stop()
	 		end)
	 		

	 		Notifications:Bottom(trigger.activator:GetPlayerOwnerID(), {text="#you_cant_be_here", duration=2, style={color="red", ["font-size"]="45px"}})
 		end
 	end
end