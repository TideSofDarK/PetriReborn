function GetGoldAutocast( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	caster:CastAbilityNoTarget(ability, caster:GetPlayerOwnerID())
end

function Spawn ( entityKeyValues  )
	Timers:CreateTimer(3.65,
    function()
    	if thisEntity:IsNull() == false and thisEntity:GetPlayerOwner() ~= nil then
    		thisEntity:GetAbilityByIndex(0):ToggleAutoCast()
    	end
    end)
end 

function GetGold( event )
	local caster = event.caster
	local ability = event.ability

	local pID = caster:GetPlayerOwnerID()
	if caster:IsSilenced() == false then
		AddCustomGold( pID, tonumber(event["gold"]) )
	end
end

function Upgrade ( event   )
	local caster = event.caster
	local ability = event.ability

	local tower_level = ability:GetLevel()

	SetCustomBuildingModel(caster, PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID()), tower_level+1)

	caster:GetAbilityByIndex(0):SetLevel(tower_level+1)
end