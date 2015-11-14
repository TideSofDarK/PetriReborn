function SetCustomBuildingModel(building, steamID, level)
	ParseCustomBuldingKVs("default", building, steamID, level)

	if not GameMode.CustomBuildingsKVs[tostring(steamID)] then return nil end

	return ParseCustomBuldingKVs(tostring(steamID), building, steamID, level)
end

function ParseCustomBuldingKVs(key, building, steamID, level)
	for k,v in pairs(GameMode.CustomBuildingsKVs[key]) do
		local name = building:GetUnitName()
		if level then name = name.."_"..level end

		if k == name then
			if type(v)=="table" then
				local scale = building:GetModelScale()

				local yaw = building:GetAngles()[2]

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
			        end
			    end

			    for k2,v2 in pairs(v) do
			        if v2 ~= "model" then
			        	Attachments:AttachProp(building, v2, k2, nil)
			        end
			    end

			    building:SetAngles(building:GetAngles()[1], yaw, building:GetAngles()[3])

			    return scale
			else 
				UpdateModel(building, v, building:GetModelScale())

				return building:GetModelScale()
			end
			break
		end
	end
end