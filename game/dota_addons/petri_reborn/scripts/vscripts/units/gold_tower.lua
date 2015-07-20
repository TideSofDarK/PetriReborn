function GetGoldAutocast( event )
	local caster = event.caster
	local target = event.target
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
		caster:SetModelScale(0.45)
	elseif tower_level == 2 then 
		caster:SetModelScale(0.5)
	elseif tower_level == 3 then
		caster:SetModelScale(0.55)
	elseif tower_level == 4 then
		caster:SetModelScale(0.6)
	elseif tower_level == 5 then
		caster:SetModelScale(0.65)
	elseif tower_level == 6 then
		caster:SetModelScale(0.7)
	elseif tower_level == 7 then
		caster:SetModelScale(0.75)
	elseif tower_level == 8 then
		caster:SetModelScale(0.80)
	end

	caster:GetAbilityByIndex(0):SetLevel(tower_level+1)
end