function AddEntryToDependenciesTable(pID, entry, level)
	if (GetKeyInNetTable(pID, "players_dependencies", entry) or 0) >= level then return false end
	AddKeyToNetTable(pID, "players_dependencies", entry, level or 1)
end

function CheckBuildingDependencies(pID, building)
	if not GameMode.DependenciesKVs[building] then return true end

	local allow = true
	
	for k,v in pairs(GameMode.DependenciesKVs[building]) do
		if CheckDependency(pID, k, v) == false then
			allow = false
		end
	end

	if allow == false and GameMode.DependenciesKVs[building.."_alt"] then
		allow = true
		for k,v in pairs(GameMode.DependenciesKVs[building.."_alt"]) do
			if CheckDependency(pID, k, v) == false then
				allow = false
			end
		end
	end

	if allow == false then
		local allow = true
		for k,v in pairs(GameMode.DependenciesKVs[building]) do
			if CheckDependency(pID, k, v) == false then
				if allow == true then Notifications:Top(pID,{text="#depedency_is_needed", duration=1, style={color="red"}, continue=false}) end
				Notifications:Top(pID,{text="#DOTA_Tooltip_ability_"..k, duration=1, style={color="red"}, continue=false})
				Notifications:Top(pID,{text=" ("..tostring(v)..")", duration=1, style={color="red"}, continue=true})
				allow = false
			end
		end

		if allow == false then return false end

		if allow == false and GameMode.DependenciesKVs[building.."_alt"] then
			allow = true
			for k,v in pairs(GameMode.DependenciesKVs[building.."_alt"]) do
				if CheckDependency(pID, k, v) == false then
					if allow == true then Notifications:Top(pID,{text="#depedency_is_needed", duration=1, style={color="red"}, continue=false}) end
					Notifications:Top(pID,{text="#DOTA_Tooltip_ability_"..k, duration=1, style={color="red"}, continue=false})
					Notifications:Top(pID,{text=" ("..tostring(v)..")", duration=1, style={color="red"}, continue=true})
					allow = false
				end
			end
		end
	end

	return allow
end

function CheckUpgradeDependencies(pID, upgrade, level)
	if not GameMode.DependenciesKVs[upgrade.."_"..tostring(level)] then return true end

	local allow = true

	if GameMode.DependenciesKVs[upgrade.."_"..level] then
		for k,v in pairs(GameMode.DependenciesKVs[upgrade.."_"..level]) do
			if CheckDependency(pID, k, v) == false then
				allow = false
			end
		end
	end

	if allow == false and GameMode.DependenciesKVs[upgrade.."_"..level.."_alt"] then
		allow = true
		for k,v in pairs(GameMode.DependenciesKVs[upgrade.."_"..level.."_alt"]) do
			if CheckDependency(pID, k, v) == false then
				allow = false
			end
		end
	end

	if allow == false then
		allow = true
		if GameMode.DependenciesKVs[upgrade.."_"..level] then
			for k,v in pairs(GameMode.DependenciesKVs[upgrade.."_"..level]) do
				if CheckDependency(pID, k, v) == false then
					if allow == true then Notifications:Top(pID,{text="#depedency_is_needed", duration=4, style={color="red"}, continue=false}) end
					Notifications:Top(pID,{text="#DOTA_Tooltip_ability_"..k, duration=4, style={color="red"}, continue=false})
					Notifications:Top(pID,{text=" ("..tostring(v)..")", duration=4, style={color="red"}, continue=true})
					allow = false
				end
			end
		end

		if allow == false then return false end

		if GameMode.DependenciesKVs[upgrade.."_"..level.."_alt"] then
			for k,v in pairs(GameMode.DependenciesKVs[upgrade.."_"..level.."_alt"]) do
				if CheckDependency(pID, k, v) == false then
					if allow == true then Notifications:Top(pID,{text="#depedency_is_needed", duration=4, style={color="red"}, continue=false}) end
					Notifications:Top(pID,{text="#DOTA_Tooltip_ability_"..k, duration=4, style={color="red"}, continue=false})
					Notifications:Top(pID,{text=" ("..tostring(v)..")", duration=4, style={color="red"}, continue=true})
					allow = false
				end
			end
		end
	end

	return allow
end

function CheckDependency(pID, dependency, level)
	return (GetKeyInNetTable(pID, "players_dependencies", dependency) or 0) >= (level or 1)
end