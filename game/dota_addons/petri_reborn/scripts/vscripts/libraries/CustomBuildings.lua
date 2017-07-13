function SetCustomBuildingModel(building, steamID, level)
	if IsInToolsMode() then
		GameMode.CustomSkinsKVs = LoadKeyValues("scripts/kv/custom_buildings.kv")
	end

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

	PrintTable(v)

	if type(v)=="table" then
		if building.building_particles then
	    	for k3,v3 in pairs(building.building_particles) do
	    		ParticleManager:DestroyParticle(v3,true)
	    	end
		end

      for k1,v1 in pairs(building:GetChildren()) do
        if v1:GetClassname() == "dota_item_wearable" then
          v1:AddEffects(EF_NODRAW) 
        end
      end

		Wearables:Remove(building)

		for k2,v2 in pairs(v) do
	        if v2 == "attack_speed" then
	        	attack_speed = tonumber(k2)
	        end
	    end

		for k2,v2 in pairs(v) do
	        if v2 == "scale" then
	        	print(tonumber(k2))
	        	scale = tonumber(k2)
	        end
	    end

	    for k2,v2 in pairs(v) do
	        if v2 == "yaw" then
	        	yaw = tonumber(k2)
	        end
	    end

	    for k2,v2 in pairs(v) do
	        if string.match(k2, "particle") and type(v2) == 'table' then
	        	building.building_particles = building.building_particles or {}
	        	-- print(PATTACH_CUSTOMORIGIN)
	        	local attach = _G[v2.attach] or PATTACH_ABSORIGIN
		          if v2.attach == -1 then
		            attach = -1
		          end
	        	local p = ParticleManager:CreateParticle(v2.particle, attach, building)
	        	if v2.attach == "attach_fx" then
	                ParticleManager:SetParticleControlEnt(p, 0, building, PATTACH_POINT_FOLLOW, "attach_fx", building:GetAbsOrigin(), true)
	                if not v2.only0 then
		                ParticleManager:SetParticleControlEnt(p, 1, building, PATTACH_POINT_FOLLOW, "attach_fx", building:GetAbsOrigin(), true)
		                ParticleManager:SetParticleControlEnt(p, 2, building, PATTACH_POINT_FOLLOW, "attach_fx", building:GetAbsOrigin(), true)
		            end
	        	end
	        	table.insert(building.building_particles, p)
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
	        	-- if not v["animation"] then
	        	-- 	StartAnimation(building, {duration=-1, activity=ACT_DOTA_IDLE, rate=1})
	        	-- end
	        end
	    end

	    for k2,v2 in pairs(v) do
	        if v2 == "wearable" and not string.match(k2, "particle") then
	        	-- Attachments:AttachProp(building, v2, k2, nil)
	        	Wearables:AttachWearable(building, k2)
	        end
	    end

		for k2,v2 in pairs(v) do
	        if k2 == "animation" then
	        	local data = Split(v2, "+")
	        	local act = _G[data[1]]
	        	local translate = data[2]
	        	print(act, data[1], translate)
	        	-- EndAnimation(building)
	        	StartAnimation(building, {duration=-1, activity=act, rate=1, translate = tranlate})
	        end
	    end

	    building:SetBaseAttackTime(attack_speed)

	    building:SetAngles(building:GetAngles()[1], yaw, building:GetAngles()[3])
	else 
		UpdateModel(building, v, building:GetModelScale())
	end

	return scale
end