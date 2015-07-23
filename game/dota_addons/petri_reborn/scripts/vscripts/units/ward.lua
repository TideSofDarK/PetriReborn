function Spawn( keys )
	InitAbilities(thisEntity)
    thisEntity:AddNewModifier(thisEntity, nil, "modifier_kill", {duration = 50})

    StartAnimation(thisEntity, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})
end