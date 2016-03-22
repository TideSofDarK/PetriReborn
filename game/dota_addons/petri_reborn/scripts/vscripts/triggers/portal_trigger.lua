PORTAL_LEVELS = {}
PORTAL_LEVELS[1] = 1
PORTAL_LEVELS[2] = 5
PORTAL_LEVELS[3] = 20
PORTAL_LEVELS[4] = 25
PORTAL_LEVELS[5] = 40
PORTAL_LEVELS[6] = 60
PORTAL_LEVELS[7] = 80

function CheckFarmPlaces(trigger, activator)
	local triggerName = trigger:GetName ()
	if activator:GetUnitName() == "npc_dota_hero_storm_spirit" and string.match(triggerName, "portal_trigger_creep0") == false then 
		return false 
	elseif activator:GetUnitName() == "npc_dota_hero_storm_spirit" and string.match(triggerName, "portal_trigger_creep0") == true then
		return true 
	end
	if string.match(triggerName, "portal_trigger_creep") or string.match(triggerName, "portal_trigger_kivin_input") then
		
		local heroLevel = activator:GetLevel()
		local portalLevel = PORTAL_LEVELS[GetPortalNumber( triggerName )]
		local portalNumber = GetPortalNumber( triggerName )

		if GameRules:IsDaytime() == false and portalNumber ~= 7 then 
			return true 
		else
			if heroLevel < portalLevel then
				return true
			end
			-- if string.match(triggerName, "portal_trigger_creep3") then
			-- 	if GameMode.PETRI_TRUE_TIME < 384 then
			-- 		return true 
			-- 	end
			-- end
		end
	end
	if string.match(triggerName, "portal_trigger_boss_b") then
		if GameMode.PETRI_TRUE_TIME > 1200 
			or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 30000 then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_2_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
	if string.match(triggerName, "portal_trigger_boss_c") then
		if GameMode.PETRI_TRUE_TIME > 1680 
			or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 90000 then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_3_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
end

function OnStartTouch(trigger)
	if trigger.activator:GetTeam() == DOTA_TEAM_BADGUYS then
		if CheckFarmPlaces(trigger.caller, trigger.activator) == true then return end

		if trigger.activator.teleportationState == nil or trigger.activator.teleportationState == 0 
			or trigger.activator.teleportationState == 3 then
			trigger.activator.teleportationState = 1

			local newPosition = thisEntity:GetAbsOrigin()

			if string.match(trigger.caller:GetName (), "portal_trigger_creep") or string.match(trigger.caller:GetName (), "portal_trigger_boss") then
				trigger.activator.teleportationState = 0
			end

			trigger.activator.currentArea = trigger.caller
	    	FindClearSpaceForUnit(trigger.activator,newPosition,true)

	    	trigger.activator:Stop()

	    	if trigger.activator:IsHero() then MoveCamera(trigger.activator:GetPlayerOwnerID(), trigger.activator) end

	    	local particleName = "particles/econ/events/nexon_hero_compendium_2014/teleport_end_ground_flash_nexon_hero_cp_2014.vpcf"
			local particle = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
		 	ParticleManager:SetParticleControl( particle, 0, trigger.activator:GetAbsOrigin() )
		end
	end
end
 
function OnEndTouch(trigger)
	if trigger.activator:GetTeam() == DOTA_TEAM_BADGUYS then
		if CheckFarmPlaces(trigger.caller,trigger.activator) == true then return end
		
		trigger.activator.teleportationState = trigger.activator.teleportationState + 1
		PlayerResource:SetCameraTarget(trigger.activator:GetPlayerOwnerID(), nil)
	end
end

function Activate(keys)
	print("Portal activated")

	local name = thisEntity:GetName()

	if IsCreepPortal( name ) == true then
		Timers:CreateTimer(20, function (  )
			local number = GetPortalNumber( name )

			local unit = CreateUnitByName("npc_dummy_unit", thisEntity:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS)

			local oldPos = unit:GetAbsOrigin()
			oldPos.z = oldPos.z + 250
			unit:SetAbsOrigin(oldPos)

			unit:AddAbility("petri_dummy_static_popup")
			InitAbilities(unit)

			Timers:CreateTimer(10, function (  )
				PopupStaticParticle(PORTAL_LEVELS[number], Vector(255,255,255), unit)
			end)
		end)
	end
end

function IsCreepPortal( name )
	if string.match(name, "portal_trigger_creep") and string.match(name, "input") then return true end
	if string.match(name, "portal_trigger_kivin_input") then return true end
	return false
end

function GetPortalNumber( name )
	if string.match(name, "portal_trigger_kivin_input") then return 7 end

	local numberString = string.gsub(string.gsub(name, "portal_trigger_creep", ""), "_input", "")
	local number = tonumber(numberString) or 1

	return number
end