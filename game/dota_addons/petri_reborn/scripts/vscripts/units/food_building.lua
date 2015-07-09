function Spawn ( entityKeyValues  )
	thisEntity.foodProvided = 0
	Timers:CreateTimer(2.1,
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

		ability:SetLevel(tent_level+1)

		if tent_level+1 == 4 then
			caster:RemoveAbility("petri_upgrade_tent")
		end

		player.maxFood = player.maxFood + 30
		caster.foodProvided = caster.foodProvided  + 30

	
end

function CheckLumber(event)
	local caster = event.caster
	local ability = event.ability

	local player = caster:GetPlayerOwner()

	local tent_level = ability:GetLevel()

	local lumber_cost = ability:GetLevelSpecialValueFor("lumber_cost", tent_level-1)

	if player.lumber >= lumber_cost then
		player.lumber = player.lumber - lumber_cost
	else 
		Timers:CreateTimer(0.06,
	    function()
	    	caster:InterruptChannel()
	    	Notifications:Bottom(PlayerResource:GetPlayer(0), {text="#gather_more_lumber", duration=1, style={color="red", ["font-size"]="45px"}})
	    end)
	end
end