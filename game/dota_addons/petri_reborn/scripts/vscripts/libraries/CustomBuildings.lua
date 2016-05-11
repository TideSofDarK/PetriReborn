function SetCustomBuildingModel(building, steamID, level)
	local key = tostring(steamID)
	local name = building:GetUnitName()
	if level then name = name.."_"..level end

	local defaultScale = ParseCustomBuldingKVs(GameMode.CustomBuildingsKVs["default"][name], building, level)

	if not GameMode.CustomBuildingsKVs[key] or not GameMode.CustomBuildingsKVs[key][name] then return defaultScale end

	return ParseCustomBuldingKVs(GameMode.CustomBuildingsKVs[key][name], building, level)
end

function ParseCustomBuldingKVs(entry, building, level)
	local scale = building:GetModelScale()
	
	local yaw = building:GetAngles()[2]

	local attack_speed = building:GetBaseAttackTime()

	local v = entry
	if not v then return scale end

	if type(v)=="table" then
		for k2,v2 in pairs(v) do
	        if v2 == "attack_speed" then
	        	attack_speed = tonumber(k2)
	        end
	    end

		for k2,v2 in pairs(v) do
	        if v2 == "scale" then
	        	scale = tonumber(k2)
	        end
	    end

	    for k2,v2 in pairs(v) do
	        if v2 == "yaw" then
	        	yaw = tonumber(k2)
	        end
	    end

	    if building.attachedModels then
	    	for i2,v2 in ipairs(building.attachedModels) do
	    		if v2:IsNull() == false then v2:RemoveSelf() end
			end
	    end

		for k2,v2 in pairs(v) do
	        if v2 == "model" then
	        	UpdateModel(building, k2, scale)
	        	PrecacheResource("model", k2, GameRules.pc)
	        end
	    end

	    for k2,v2 in pairs(v) do
	        if v2 ~= "model" then
	        	Attachments:AttachProp(building, v2, k2, nil)
	        end
	    end

	    building:SetBaseAttackTime(attack_speed)

	    building:SetAngles(building:GetAngles()[1], yaw, building:GetAngles()[3])
	else 
		UpdateModel(building, v, building:GetModelScale())
	end

	return scale
end