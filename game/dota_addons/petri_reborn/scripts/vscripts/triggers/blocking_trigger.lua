function OnStartTouch(trigger)
 	trigger.activator.currentArea = trigger.caller
 	local unitName = trigger.activator:GetUnitName()
 	if unitName == "npc_dota_hero_rattletrap" or unitName == "npc_petri_peasant" or unitName == "npc_petri_super_peasant" then
 		FindClearSpaceForUnit(trigger.activator, trigger.activator.spawnPosition, false)
 		Timers:CreateTimer(0.03, function()
 			MoveCamera(trigger.activator:GetPlayerOwnerID(),trigger.activator)
 		end)
 		

 		Notifications:Bottom(trigger.activator:GetPlayerOwnerID(), {text="#you_cant_be_here", duration=2, style={color="red", ["font-size"]="45px"}})
 	end
end