function CheckFarmPlaces(trigger)
	local triggerName = trigger:GetName ()
	if 	string.match(triggerName, "portal_trigger_creep")  then
		if GameRules:IsDaytime() ~= true then return true end
	end
end

function OnStartTouch(trigger)
	if trigger.activator:GetTeam() == DOTA_TEAM_BADGUYS then
		if CheckFarmPlaces(trigger.caller) == true then return end

		if trigger.activator.teleportationState == nil or trigger.activator.teleportationState == 0 
			or trigger.activator.teleportationState == 3 then
			trigger.activator.teleportationState = 1

			local newPosition = thisEntity:GetAbsOrigin()

			if string.match(trigger.caller:GetName (), "portal_trigger_creep") then
				trigger.activator.teleportationState = 0
			end

			trigger.activator.currentArea = trigger.caller
	    	FindClearSpaceForUnit(trigger.activator,newPosition,true)

	    	trigger.activator:Stop()
	    	MoveCamera(trigger.activator:GetPlayerOwnerID(), trigger.activator)

	    	local particleName = "particles/econ/events/nexon_hero_compendium_2014/teleport_end_ground_flash_nexon_hero_cp_2014.vpcf"
			local particle = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
		 	ParticleManager:SetParticleControl( particle, 0, trigger.activator:GetAbsOrigin() )
		end
	end
	
end
 
function OnEndTouch(trigger)
	if trigger.activator:GetTeam() == DOTA_TEAM_BADGUYS then
		if CheckFarmPlaces(trigger.caller) == true then return end
		
		trigger.activator.teleportationState = trigger.activator.teleportationState + 1
		PlayerResource:SetCameraTarget(trigger.activator:GetPlayerOwnerID(), nil)
	end
end

function Activate(keys)
	print("Portal activated")
end