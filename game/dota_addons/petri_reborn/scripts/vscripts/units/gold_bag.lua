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

	local upgradeRate = ability:GetSpecialValueFor("upgrade_rate")
	local upgradeLimit = ability:GetSpecialValueFor("upgrade_limit")

	if gold >= upgradeRate then
		local count = math.floor(gold / upgradeRate)
		local actualCount = count
		if goldModifier+count > upgradeLimit then actualCount = upgradeLimit - goldModifier end
		local cost = actualCount*upgradeRate
		PlayerResource:SpendGold(pID, cost, 0)

		GameMode.assignedPlayerHeroes[pID].goldBagStacks = goldModifier+actualCount

		caster:SetModifierStackCount("modifier_gold_bag", caster, GameMode.assignedPlayerHeroes[pID].goldBagStacks)

		if caster:GetModifierStackCount("modifier_gold_bag", caster) >= upgradeLimit then
			caster:SetModifierStackCount("modifier_gold_bag", caster,upgradeLimit)

			caster:RemoveModifierByName("modifier_gold_bag_upgrading_autocast")
			ability:ToggleAbility()

			caster:SwapAbilities("petri_upgrade_gold_bag", "petri_empty2", false, true)
		end
	end
end