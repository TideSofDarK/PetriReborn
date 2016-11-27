PORTALS_LEVELS = {}
PORTALS_LEVELS["40portal_brewmaster_in_portalarena5"] 		= true
PORTALS_LEVELS["25portal_brewmaster_in_portalarena4"] 		= true
PORTALS_LEVELS["60portal_brewmaster_in_portalarena6"] 		= true
PORTALS_LEVELS["40portal_death_prophet_in_portalarena5"] 	= true
PORTALS_LEVELS["25portal_death_prophet_in_portalarena4"] 	= true
PORTALS_LEVELS["60portal_death_prophet_in_portalarena6"] 	= true

PORTAL_LEVELS = {}
PORTAL_LEVELS["1portal_brewmaster_in_portalarena1"] = 1
PORTAL_LEVELS["3portal_brewmaster_in_portalarena2"] = 3
PORTAL_LEVELS["10portal_brewmaster_in_portalarena3"] = 10
PORTAL_LEVELS["20portal_brewmaster_in_portalarena4"] = 20
PORTAL_LEVELS["30portal_brewmaster_in_portalarena5"] = 30
PORTAL_LEVELS["40portal_brewmaster_in_portalarena6"] = 40
PORTAL_LEVELS["50portal_brewmaster_in_portalarena7"] = 50
PORTAL_LEVELS["60portal_brewmaster_in_portalarena8"] = 60
PORTAL_LEVELS["70portal_brewmaster_in_portalarena9"] = 70
PORTAL_LEVELS["80portal_brewmaster_in_portalarena10"] = 80
PORTAL_LEVELS["1portal_brewmaster_in_portalarena11"] = 777

function OnStartTouch(trigger)
	if string.match(trigger.caller:GetName(), string.gsub(trigger.activator:GetUnitName(), "npc_dota_hero_", "")) and (string.match(trigger.caller:GetName(),"%d+") == nil or trigger.activator:GetLevel() >= tonumber(string.match(trigger.caller:GetName(),"%d+"))) then
		if PORTALS_LEVELS[trigger.caller:GetName()] == true then
			if GameRules:IsDaytime() == false then 
				return false 
			end
		end

		local newPosition = thisEntity:GetAbsOrigin()

		trigger.activator.currentArea = trigger.caller
		FindClearSpaceForUnit(trigger.activator,newPosition,true)

		trigger.activator:Stop()

		if trigger.activator:IsHero() then MoveCamera(trigger.activator:GetPlayerOwnerID(), trigger.activator) end

		local particleName = "particles/econ/events/nexon_hero_compendium_2014/teleport_end_ground_flash_nexon_hero_cp_2014.vpcf"
		local particle = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	 	ParticleManager:SetParticleControl( particle, 0, trigger.activator:GetAbsOrigin() )
	end
end

function Activate(keys)
	print("Portal activated")

	local name = thisEntity:GetName()

	if PORTAL_LEVELS[name] then
		Timers:CreateTimer(20, function (  )
			local number = PORTAL_LEVELS[name]
			print("Asdasdasdasdsdas", number)
			local unit = CreateUnitByName("npc_dummy_unit", thisEntity:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS)

			local oldPos = unit:GetAbsOrigin()
			oldPos.z = oldPos.z + 250
			unit:SetAbsOrigin(oldPos)

			unit:AddAbility("petri_dummy_static_popup")
			InitAbilities(unit)

			Timers:CreateTimer(10, function (  )
				PopupStaticParticle(number, Vector(255,255,255), unit)
			end)
		end)
	end
end

function CheckBoss(trigger, activator)
	local triggerName = trigger:GetName ()
		if string.match(triggerName, "2portal_brewmaster_in_portalboss1") or string.match(triggerName, "2portal_death_prophet_in_portalboss1") or string.match(triggerName, "2portal_storm_spirit_in_portalboss1") then
		if GameMode.PETRI_TRUE_TIME > 1200 
			or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 9000000000 then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_3_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
	local triggerName = trigger:GetName ()
		if string.match(triggerName, "2portal_brewmaster_in_portalboss2") or string.match(triggerName, "2portal_death_prophet_in_portalboss2") or string.match(triggerName, "2portal_storm_spirit_in_portalboss2") then
		if GameMode.PETRI_TRUE_TIME > 1200 
			or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 900000000000 then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_3_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
			if string.match(triggerName, "2portal_brewmaster_in_portalboss3") or string.match(triggerName, "2portal_death_prophet_in_portalboss3") or string.match(triggerName, "2portal_storm_spirit_in_portalboss3") then
		if GameMode.PETRI_TRUE_TIME > 1680 
			or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 9000000000 then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_3_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
			if string.match(triggerName, "2portal_brewmaster_in_portalboss4") or string.match(triggerName, "2portal_death_prophet_in_portalboss4") or string.match(triggerName, "2portal_storm_spirit_in_portalboss4") then
		if GameMode.PETRI_TRUE_TIME > 2160 
			or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 900000000 then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_3_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
			if string.match(triggerName, "2portal_brewmaster_in_portalboss5") or string.match(triggerName, "2portal_death_prophet_in_portalboss5") or string.match(triggerName, "2portal_storm_spirit_in_portalboss5") then
		if GameMode.PETRI_TRUE_TIME > 2640 
			or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 90000000000 then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_3_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
end