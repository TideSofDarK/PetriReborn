UPGRADE_RATE = 70
UPGRADE_LIMIT = 275

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

	local gold = caster:GetModifierStackCount("modifier_gold_bag", caster)
	
	PlayerResource:SetGold(pID, PlayerResource:GetUnreliableGold(pID) + gold, false)
end

function ToggleUpgrading ( event   )
	local caster = event.caster
	local ability = event.ability

	if ability:GetToggleState() == true then
		caster:RemoveModifierByName("modifier_gold_bag_upgrading_autocast")
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_gold_bag_upgrading_autocast", {})
	end

	ability:ToggleAbility()
end


function Upgrade( event )
	local caster = event.caster
	local ability = event.ability
	local pID = caster:GetPlayerOwnerID()

	local goldModifier = caster:GetModifierStackCount("modifier_gold_bag", caster)
	local gold = PlayerResource:GetGold(pID)

	if gold >= UPGRADE_RATE then
		local count = math.floor(gold / UPGRADE_RATE)
		local actualCount = count
		if goldModifier+count > UPGRADE_LIMIT then actualCount = UPGRADE_LIMIT - goldModifier end
		local cost = actualCount*UPGRADE_RATE
		PlayerResource:SpendGold(pID, cost, 0)

		caster:SetModifierStackCount("modifier_gold_bag", caster,goldModifier+actualCount)

		if caster:GetModifierStackCount("modifier_gold_bag", caster) >= UPGRADE_LIMIT then
			caster:SetModifierStackCount("modifier_gold_bag", caster,UPGRADE_LIMIT)

			caster:RemoveModifierByName("modifier_gold_bag_upgrading_autocast")
			ability:ToggleAbility()

			caster:SwapAbilities("petri_upgrade_gold_bag", "petri_empty2", false, true)
		end
	end
end