function AddEntryToDependenciesTable(pID, entry, level)
	if (GetKeyInNetTable(pID, "players_dependencies", entry) or 0) >= level then return false end
	AddKeyToNetTable(pID, "players_dependencies", entry, level or 1)
end

function CheckBuildingDependencies(pID, building)
	if not GameMode.DependenciesKVs[building] then return true end

	local allow = true
	
	for k,v in pairs(GameMode.DependenciesKVs[building]) do
		if CheckDependency(pID, k, v) == false then
			if allow == true then Notifications:Top(pID,{text="#depedency_is_needed", duration=1, style={color="red"}, continue=false}) end
			Notifications:Top(pID,{text="#DOTA_Tooltip_ability_"..k, duration=1, style={color="red"}, continue=false})
			Notifications:Top(pID,{text=" ("..tostring(v)..")", duration=1, style={color="red"}, continue=true})
			allow = false
		end
	end

	return allow
end

function CheckUpgradeDependencies(pID, upgrade, level)
	if not GameMode.DependenciesKVs[upgrade.."_"..tostring(level)] then return true end

	local allow = true

	for k,v in pairs(GameMode.DependenciesKVs[upgrade.."_"..tostring(level)]) do
		if CheckDependency(pID, k, v) == false then
			if allow == true then Notifications:Top(pID,{text="#depedency_is_needed", duration=4, style={color="red"}, continue=false}) end
			Notifications:Top(pID,{text="#DOTA_Tooltip_ability_"..k, duration=4, style={color="red"}, continue=false})
			Notifications:Top(pID,{text=" ("..tostring(v)..")", duration=4, style={color="red"}, continue=true})
			allow = false
		end
	end

	return allow
end

function CheckDependency(pID, dependency, level)
	return (GetKeyInNetTable(pID, "players_dependencies", dependency) or 0) >= (level or 1)
end