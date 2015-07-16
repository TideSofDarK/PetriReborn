function Spawn ( entityKeyValues  )
	thisEntity.foodProvided = 0
	Timers:CreateTimer(2.2,
    function()
    	thisEntity:GetPlayerOwner().maxFood = thisEntity:GetPlayerOwner().maxFood + 30
    	thisEntity.foodProvided = 30
    end)
end

function Upgrade ( event   )
	local caster = event.caster
	local ability = event.ability
	local player = caster:GetPlayerOwner()

	local tent_level = ability:GetLevel()

	if tent_level == 1 then
		caster:SetModelScale(0.4)
	elseif tent_level == 2 then 
		caster:SetModel("models/props_structures/tent_dk_med")
	elseif tent_level == 3 then
		caster:SetModel("models/props_structures/tent_dk_large.vmdl")
	end

	player.maxFood = player.maxFood + 30
	caster.foodProvided = caster.foodProvided  + 30
end