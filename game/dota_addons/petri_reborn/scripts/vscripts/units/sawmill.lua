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
    local id = keys.PlayerID

	if GameMode.LOTTERY_STATE == 0 then
		GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]:ModifyGold(ability:GetGoldCost(-1), false, 0)
		return false
	end

    
    if caster:GetPlayerOwnerID() == 0 then GameMode.PlAYER_0_BET = GameMode.PlAYER_0_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 1 then GameMode.PlAYER_1_BET = GameMode.PlAYER_1_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 2 then GameMode.PlAYER_2_BET = GameMode.PlAYER_2_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 3 then GameMode.PlAYER_3_BET = GameMode.PlAYER_3_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 4 then GameMode.PlAYER_4_BET = GameMode.PlAYER_4_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 5 then GameMode.PlAYER_5_BET = GameMode.PlAYER_5_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 6 then GameMode.PlAYER_6_BET = GameMode.PlAYER_6_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 7 then GameMode.PlAYER_7_BET = GameMode.PlAYER_7_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 8 then GameMode.PlAYER_8_BET = GameMode.PlAYER_8_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 9 then GameMode.PlAYER_9_BET = GameMode.PlAYER_9_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 10 then GameMode.PlAYER_10_BET = GameMode.PlAYER_10_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 11 then GameMode.PlAYER_11_BET = GameMode.PlAYER_11_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 12 then GameMode.PlAYER_12_BET = GameMode.PlAYER_12_BET + ability:GetGoldCost(-1) end 
    if caster:GetPlayerOwnerID() == 13 then GameMode.PlAYER_13_BET = GameMode.PlAYER_13_BET + ability:GetGoldCost(-1) end 

	if not GameMode.CURRENT_LOTTERY_PLAYERS[tostring(caster:GetPlayerOwnerID())] then 
		GameMode.CURRENT_LOTTERY_PLAYERS[tostring(caster:GetPlayerOwnerID())] = caster:GetPlayerOwnerID()
	end
end