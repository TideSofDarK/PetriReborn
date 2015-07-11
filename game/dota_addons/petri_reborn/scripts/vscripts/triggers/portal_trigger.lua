function OnStartTouch(trigger)
	print(trigger.activator:GetUnitName ())
	if trigger.activator:GetUnitName () == "npc_dota_hero_brewmaster" then
		if trigger.activator.teleportationState == nil or trigger.activator.teleportationState == 0 
			or trigger.activator.teleportationState == 3 then
			trigger.activator.teleportationState = 1

			trigger.activator.currentArea = trigger.caller
	    	FindClearSpaceForUnit(trigger.activator,thisEntity:GetAbsOrigin(),true)

	    	trigger.activator:Stop()
	    	PlayerResource:SetCameraTarget(trigger.activator:GetPlayerOwnerID(), trigger.activator)

	    	local particleName = "particles/econ/events/nexon_hero_compendium_2014/teleport_end_ground_flash_nexon_hero_cp_2014.vpcf"
			local particle = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
		 	ParticleManager:SetParticleControl( particle, 0, trigger.activator:GetAbsOrigin() )
		end
	end
	
end
 
function OnEndTouch(trigger)
	if trigger.activator:GetUnitName () == "npc_dota_hero_brewmaster" then
		trigger.activator.teleportationState = trigger.activator.teleportationState + 1
		PlayerResource:SetCameraTarget(trigger.activator:GetPlayerOwnerID(), nil)
	end
end

function Activate(keys)
	print("Portal activated")
end