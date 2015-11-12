function SetCustomBuildingModel(building, steamID, level)
	if not GameMode.CustomBuildingsKVs[tostring(steamID)] then return nil end
	for k,v in pairs(GameMode.CustomBuildingsKVs[tostring(steamID)]) do
		local name = building:GetUnitName()
		if level then name = name.."_"..level end

		if k == name then
			if type(v)=="table" then
				local scale = building:GetModelScale()
				for k2,v2 in pairs(v) do
			        if v2 == "scale" then
			        	scale = tonumber(k2)
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

			    return scale
			else 
				UpdateModel(building, v, 1)

				return 1
			end
			break
		end
	end
	return 0
end