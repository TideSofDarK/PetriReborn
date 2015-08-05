function AddEntryToDependenciesTable(pID, building, level)
	AddKeyToNetTable(pID, "players_dependencies", building, level or 1)
end

function CheckBuildingDependencies(pID, building)
	if not GameMode.DependenciesKVs[building] then return true end
	
	for k,v in pairs(GameMode.DependenciesKVs[building]) do
		if CheckDependency(pID, k, v) == false then return false end
	end

	return true
end

function CheckUpgradeDependencies(pID, upgrade, level)
	if not GameMode.DependenciesKVs[upgrade.."_"..tostring(level)] then return true end

	for k,v in pairs(GameMode.DependenciesKVs[upgrade.."_"..tostring(level)]) do
		if CheckDependency(pID, k, v) == false then return false end
	end

	return true
end

function CheckDependency(pID, dependency, level)
	return (GetKeyInNetTable(pID, "players_dependencies", dependency) or 0) >= (level or 1)
end