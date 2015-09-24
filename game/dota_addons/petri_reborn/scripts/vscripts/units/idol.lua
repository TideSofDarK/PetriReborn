function Spawn( keys )
	StartAnimation(thisEntity, {duration=-1, activity=ACT_DOTA_IDLE , rate=2.5})
	thisEntity:SetAngles(0, -90, 0)
end