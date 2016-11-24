function UpgradeGoldBagTo( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	local pID = caster:GetPlayerOwnerID()

	event.caster = GameMode.assignedPlayerHeroes[pID]
	event.pos = caster:GetAbsOrigin()

	local newBag = SpawnGoldBag( event )

	caster:AddNoDraw()
	caster:Kill(ability,caster)

	PlayerResource:SetOverrideSelectionEntity(pID, newBag)
	Timers:CreateTimer(0.03, function ()
		PlayerResource:SetOverrideSelectionEntity(pID, nil)
	end)
end

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
	
	if caster:IsSilenced() == false then
		AddCustomGold( pID, gold )
	end
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

	if ability:GetAutoCastState() == false then
		return false
	end

	local goldModifier = caster:GetModifierStackCount("modifier_gold_bag", caster)
	local gold = PlayerResource:GetGold(pID)

	local upgradeRate = ability:GetSpecialValueFor("upgrade_rate")
	local upgradeLimit = ability:GetSpecialValueFor("upgrade_limit")

	if gold >= upgradeRate then
		local count = math.floor(gold / upgradeRate)
		local actualCount = count
		if goldModifier+count > upgradeLimit then actualCount = upgradeLimit - goldModifier end
		local cost = actualCount*upgradeRate

		if GetCustomGold( pID ) < cost then
			return
		end

		SpendCustomGold( pID, cost )

		GameMode.assignedPlayerHeroes[pID].goldBagStacks = goldModifier+actualCount

		caster:SetModifierStackCount("modifier_gold_bag", caster, GameMode.assignedPlayerHeroes[pID].goldBagStacks)

		CheckLimit( caster, ability, upgradeLimit, GameMode.assignedPlayerHeroes[pID] )
	end
end

function UpgradeOnce( event )
	local caster = event.caster
	local ability = event.ability
	local pID = caster:GetPlayerOwnerID()

	local goldModifier = caster:GetModifierStackCount("modifier_gold_bag", caster)
	local gold = PlayerResource:GetGold(pID)

	if GetCustomGold( pID ) < upgradeRate then
		return
	end

	local upgradeRate = ability:GetSpecialValueFor("upgrade_rate")
	local upgradeLimit = ability:GetSpecialValueFor("upgrade_limit")

	if gold >= upgradeRate then
		SpendCustomGold( pID, upgradeRate )

		GameMode.assignedPlayerHeroes[pID].goldBagStacks = goldModifier+1

		caster:SetModifierStackCount("modifier_gold_bag", caster, GameMode.assignedPlayerHeroes[pID].goldBagStacks)

		CheckLimit( caster, ability, upgradeLimit, GameMode.assignedPlayerHeroes[pID] )
	end
end

function CheckLimit( caster, ability, upgradeLimit, hero )
	if caster:GetModifierStackCount("modifier_gold_bag", caster) >= upgradeLimit then
		caster:SetModifierStackCount("modifier_gold_bag", caster,upgradeLimit)

		caster:RemoveModifierByName("modifier_gold_bag_upgrading_autocast")
		ability:ToggleAbility()

		caster:SwapAbilities("petri_upgrade_gold_bag", "petri_empty2", false, true)
		caster:SwapAbilities("petri_upgrade_gold_bag2", "petri_empty2", false, true)
		caster:SwapAbilities("petri_upgrade_gold_bag3", "petri_empty2", false, true)
		caster:SwapAbilities("petri_upgrade_gold_bag4", "petri_empty2", false, true)

		GameMode.FIRST_BAG = GameMode.FIRST_BAG or math.floor(GameMode.PETRI_TRUE_TIME)

		if not hero.bagRecord then
			local time = GameMode.PETRI_TRUE_TIME
			hero.bagRecord = string.format("%.2d:%.2d", time/60%60, time%60)
		end

		if not string.match(ability:GetName(), "3") then 
			if string.match(ability:GetName(), "2") then
				caster:AddAbility("petri_upgrade_gold_bag_to_3")
				caster:SwapAbilities("petri_upgrade_gold_bag_to_3","petri_empty1",true,false)
			else
				caster:AddAbility("petri_upgrade_gold_bag_to_2")
				caster:SwapAbilities("petri_upgrade_gold_bag_to_2","petri_empty1",true,false)
			end
		elseif not string.match(ability:GetName(), "4") then 
			caster:AddAbility("petri_upgrade_gold_bag_to_4")
			caster:SwapAbilities("petri_upgrade_gold_bag_to_4","petri_empty1",true,false)
		end
		InitAbilities(caster)
	end
end