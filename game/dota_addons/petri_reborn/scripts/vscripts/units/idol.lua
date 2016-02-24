function Spawn( keys )
	StartAnimation(thisEntity, {duration=-1, activity=ACT_DOTA_IDLE , rate=2.5})
	thisEntity:SetAngles(0, -90, 0)

	thisEntity.onBuildingCompleted = OnBuildingCompleted
end

function OnBuildingCompleted( thisEntity )
	local shopEnt = Entities:FindByName(nil, "petri_idol") -- entity name in hammer
	thisEntity.newShopTarget = SpawnEntityFromTableSynchronous('info_target', {targetname = "team_"..tostring(DOTA_TEAM_GOODGUYS).."_idol", origin = thisEntity:GetAbsOrigin()})
	thisEntity.newShop = SpawnEntityFromTableSynchronous('trigger_shop', {targetname = "team_"..tostring(DOTA_TEAM_GOODGUYS).."_idol",origin = thisEntity:GetAbsOrigin(), shoptype = 1, model=shopEnt:GetModelName()})
end