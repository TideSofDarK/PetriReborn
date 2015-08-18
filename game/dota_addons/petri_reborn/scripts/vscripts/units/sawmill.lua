function Upgrade (event)
	local caster = event.caster
	local ability = event.ability

	local sawmill_level = ability:GetLevel()

	if sawmill_level == 1 then
		caster:SetOriginalModel(GetModelNameForLevel(sawmill_level))
		caster:SetModel(GetModelNameForLevel(sawmill_level))
		caster:SetModelScale(0.7)

		caster:AddAbility("train_petri_peasant")

		caster:GetPlayerOwner().sawmill_2 = true
	elseif sawmill_level == 2 then 
		caster:SetOriginalModel(GetModelNameForLevel(sawmill_level))
		caster:SetModel(GetModelNameForLevel(sawmill_level))
		caster:SetModelScale(0.5)

		caster:GetPlayerOwner().sawmill_3 = true

		caster:RemoveAbility(ability:GetName())

		caster:AddAbility("train_petri_super_peasant")
		caster:AddAbility("petri_make_a_bet")
	end

	InitAbilities(caster)
end

function GetModelNameForLevel(level)
	if level == 1 then
		return "models/props_structures/good_barracks_ranged002_lvl2.vmdl"
	elseif level == 2 then 
		return "models/props_structures/good_ancient001.vmdl"
	end
end

function BuyLumber(keys)
	local caster = keys.caster
	local ability = keys.ability

	local lumber = ability:GetSpecialValueFor("lumber")

	GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()].lumber = GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()].lumber + lumber
end

function MakeABet( keys )
	local caster = keys.caster
	local ability = keys.ability

	if GameMode.LOTTERY_STATE == 0 then
		GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]:ModifyGold(ability:GetGoldCost(-1), false, 0)
		return false
	end

	GameMode.CURRENT_BANK = GameMode.CURRENT_BANK + ability:GetGoldCost(-1)
	table.insert(GameMode.CURRENT_LOTTERY_PLAYERS, caster:GetPlayerOwnerID())
end