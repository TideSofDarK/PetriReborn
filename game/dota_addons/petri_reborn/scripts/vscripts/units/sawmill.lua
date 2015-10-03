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
		caster:AddAbility("petri_upgrade_exchange")
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

function UpgradeExchange( keys )
	local caster = keys.caster
	local ability = keys.ability

	local time = math.floor((PETRI_LOTTERY_DURATION * 60) - (GameRules:GetDOTATime(false, false) - LOTTERY_START_TIME))
	print(time)
	if time >= 10 then
		CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "petri_force_start_exchange", {["exchange_time"] = time } )
	end
end