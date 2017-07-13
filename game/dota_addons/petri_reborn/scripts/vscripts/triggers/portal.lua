PORTALS_LEVELS = {}
PORTALS_LEVELS["1portal_brewmaster_in_portalarena1"] = true
PORTALS_LEVELS["3portal_brewmaster_in_portalarena2"] = true
PORTALS_LEVELS["10portal_brewmaster_in_portalarena3"] = true
PORTALS_LEVELS["20portal_brewmaster_in_portalarena4"] = true
PORTALS_LEVELS["30portal_brewmaster_in_portalarena5"] = true
PORTALS_LEVELS["40portal_brewmaster_in_portalarena6"] = true
PORTALS_LEVELS["50portal_brewmaster_in_portalarena7"] = true
PORTALS_LEVELS["60portal_brewmaster_in_portalarena8"] = true
PORTALS_LEVELS["70portal_brewmaster_in_portalarena9"] = true
PORTALS_LEVELS["1portal_brewmaster_in_portalarena11"] = true
PORTALS_LEVELS["1portal_death_prophet_in_portalarena1"] = true
PORTALS_LEVELS["3portal_death_prophet_in_portalarena2"] = true
PORTALS_LEVELS["10portal_death_prophet_in_portalarena3"] = true
PORTALS_LEVELS["20portal_death_prophet_in_portalarena4"] = true
PORTALS_LEVELS["30portal_death_prophet_in_portalarena5"] = true
PORTALS_LEVELS["40portal_death_prophet_in_portalarena6"] = true
PORTALS_LEVELS["50portal_death_prophet_in_portalarena7"] = true
PORTALS_LEVELS["60portal_death_prophet_in_portalarena8"] = true
PORTALS_LEVELS["70portal_death_prophet_in_portalarena9"] = true
PORTALS_LEVELS["1portal_death_prophet_in_portalarena11"] = true
PORTALS_LEVELS["1portal_storm_spirit_in_portalarena1"] = true
PORTALS_LEVELS["3portal_storm_spirit_in_portalarena2"] = true
PORTALS_LEVELS["10portal_storm_spirit_in_portalarena3"] = true
PORTALS_LEVELS["20portal_storm_spirit_in_portalarena4"] = true
PORTALS_LEVELS["30portal_storm_spirit_in_portalarena5"] = true
PORTALS_LEVELS["40portal_storm_spirit_in_portalarena6"] = true
PORTALS_LEVELS["50portal_storm_spirit_in_portalarena7"] = true
PORTALS_LEVELS["60portal_storm_spirit_in_portalarena8"] = true
PORTALS_LEVELS["70portal_storm_spirit_in_portalarena9"] = true
PORTALS_LEVELS["1portal_storm_spirit_in_portalarena11"] = true

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
PORTAL_LEVELS["2portal_brewmaster_in_portalboss1"] = 1
PORTAL_LEVELS["2portal_brewmaster_in_portalboss2"] = 2
PORTAL_LEVELS["2portal_brewmaster_in_portalboss3"] = 3
PORTAL_LEVELS["2portal_brewmaster_in_portalboss4"] = 4
PORTAL_LEVELS["2portal_brewmaster_in_portalboss5"] = 5

function OnStartTouch(trigger)
	if string.match(trigger.caller:GetName(), string.gsub(trigger.activator:GetUnitName(), "npc_dota_hero_", "")) and (string.match(trigger.caller:GetName(),"%d+") == nil or trigger.activator:GetLevel() >= tonumber(string.match(trigger.caller:GetName(),"%d+"))) then
		if PORTALS_LEVELS[trigger.caller:GetName()] == true then
			if GameRules:IsDaytime() == false then 
				return false 
			end
		end

		if CheckBoss(trigger.caller, trigger.activator) then
			return false
		end

		local newPosition = thisEntity:GetAbsOrigin()

		if trigger.activator:GetTeam() == 3 or trigger.activator:GetTeam() == 2 then
			local units = FindUnitsInRadius(trigger.activator:GetTeam(),newPosition,nil,275,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)
			for k,v in pairs(units) do
				if (v:HasModifier("modifier_building") or v:HasModifier("modifier_animated_tower") or v:GetUnitName() == "npc_petri_tent") and not string.match(v:GetUnitName(),"npc_petri_gold_bag") then
					v:Kill(nil, trigger.activator)
				end
			end
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

function Activate(keys)
	print("Portal activated")

	local name = thisEntity:GetName()

	if PORTAL_LEVELS[name] then
		Timers:CreateTimer(20, function (  )
			local number = PORTAL_LEVELS[name]
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
	print(triggerName)
	if string.match(triggerName, "2portal_brewmaster_in_portalboss1") or string.match(triggerName, "2portal_death_prophet_in_portalboss1") or string.match(triggerName, "2portal_storm_spirit_in_portalboss1") then
		if activator:GetLevel() >= 20 and (GameMode.PETRI_TRUE_TIME > 480 or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 900000000000) then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_1_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
	if string.match(triggerName, "2portal_brewmaster_in_portalboss2") or string.match(triggerName, "2portal_death_prophet_in_portalboss2") or string.match(triggerName, "2portal_storm_spirit_in_portalboss2") then
		if activator:GetLevel() >= 30 and (GameMode.PETRI_TRUE_TIME > 1200 or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 900000000000) then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_2_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
	if string.match(triggerName, "2portal_brewmaster_in_portalboss3") or string.match(triggerName, "2portal_death_prophet_in_portalboss3") or string.match(triggerName, "2portal_storm_spirit_in_portalboss3") then
		if activator:GetLevel() >= 30 and (GameMode.PETRI_TRUE_TIME > 1680 or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 9000000000) then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_3_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
	if string.match(triggerName, "2portal_brewmaster_in_portalboss4") or string.match(triggerName, "2portal_death_prophet_in_portalboss4") or string.match(triggerName, "2portal_storm_spirit_in_portalboss4") then
		if activator:GetLevel() >= 30 and (GameMode.PETRI_TRUE_TIME > 2160 or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 900000000) then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_4_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
	if string.match(triggerName, "2portal_brewmaster_in_portalboss5") or string.match(triggerName, "2portal_death_prophet_in_portalboss5") or string.match(triggerName, "2portal_storm_spirit_in_portalboss5") then
		if activator:GetLevel() >= 30 and (GameMode.PETRI_TRUE_TIME > 2640 or GameMode.assignedPlayerHeroes[activator:GetPlayerOwnerID()].allEarnedGold > 90000000000) then 
			return false 
		else 
			Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text="#boss_5_notification", duration=4, style={color="white", ["font-size"]="45px"}})
			return true 
		end
	end
	return false
end