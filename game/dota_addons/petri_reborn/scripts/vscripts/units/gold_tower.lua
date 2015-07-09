function GetGoldAutocast( event )
	local caster = event.caster
	local target = event.target -- victim of the attack
	local ability = event.ability

	caster:CastAbilityNoTarget(ability, caster:GetPlayerOwnerID())
end

function Spawn ( entityKeyValues  )
	Timers:CreateTimer(3.65,
    function()
    	thisEntity:GetAbilityByIndex(0):ToggleAutoCast()
    end)
end 

function GetGold( event )
	local caster = event.caster
	local ability = event.ability

	local pID = caster:GetPlayerOwnerID()
	PlayerResource:SetGold(pID, PlayerResource:GetUnreliableGold(pID) + tonumber(event["gold"]), false)
end

function Upgrade ( event   )
	local caster = event.caster
	local ability = event.ability

	local tower_level = ability:GetLevel()

	if tower_level == 1 then
		caster:SetModelScale(0.4)
	elseif tower_level == 2 then 
		caster:SetModelScale(0.5)
		--caster:SetModel("models/props_structures/tent_dk_med")
	elseif tower_level == 3 then
		caster:SetModelScale(0.6)
		--caster:SetModel("models/props_structures/tent_dk_large.vmdl")
	elseif tower_level == 4 then
		caster:SetModelScale(0.7)
		--caster:SetModel("models/props_structures/tent_dk_large.vmdl")
	elseif tower_level == 5 then
		caster:SetModelScale(0.8)
		--caster:SetModel("models/props_structures/tent_dk_large.vmdl")
	elseif tower_level == 6 then
		caster:SetModelScale(0.9)
		--caster:SetModel("models/props_structures/tent_dk_large.vmdl")
	elseif tower_level == 7 then
		caster:SetModelScale(1.0)
		--caster:SetModel("models/props_structures/tent_dk_large.vmdl")
	elseif tower_level == 8 then
		caster:SetModelScale(1.1)
		--caster:SetModel("models/props_structures/tent_dk_large.vmdl")
	end

	caster:GetAbilityByIndex(0):SetLevel(tower_level+1)
	caster:GetAbilityByIndex(1):SetLevel(tower_level+1)

	if tower_level+1 == 8 then
		caster:RemoveAbility("petri_upgrade_gold_tower")
	end
end