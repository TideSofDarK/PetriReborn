function Upgrade (event)
	local caster = event.caster
	local ability = event.ability

	local sawmill_level = ability:GetLevel()

	if sawmill_level == 1 then
		caster:AddAbility("train_petri_peasant")

	elseif sawmill_level == 2 then 
		caster:AddAbility("train_petri_super_peasant")
		caster:AddAbility("petri_upgrade_exchange")
		-- caster:SwapAbilities("train_petri_super_peasant","petri_upgrade_exchange",false,true)
		-- caster:SwapAbilities("train_petri_super_peasant","petri_upgrade_exchange",false,true)
	elseif sawmill_level == 3 then 
		caster:AddAbility("train_petri_mega_peasant")
		caster:SwapAbilities("petri_upgrade_sawmill", "train_petri_mega_peasant", false, true)
		caster:RemoveAbility(ability:GetName())
	end

	SetCustomBuildingModel(caster, PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID()), sawmill_level+1)

	InitAbilities(caster)
end

function BuyLumber(keys)
	local caster = keys.caster
	local ability = keys.ability

	local lumber = ability:GetSpecialValueFor("lumber")

	caster:EmitSound("ui.inv_pickup_wood")
	PopupParticle(lumber, Vector(10, 200, 90), 3.0, caster)

	AddLumber( caster:GetPlayerOwner(), lumber )
end

function BuyGold(keys)
	local caster = keys.caster
	local ability = keys.ability

	if CheckLumber(caster:GetPlayerOwner(), ability:GetSpecialValueFor("lumber_cost"), false) then
		SpendLumber(caster:GetPlayerOwner(), ability:GetSpecialValueFor("lumber_cost"))

		caster:EmitSound("ui.inv_pickup_wood")
		PopupParticle(ability:GetSpecialValueFor("gold"), Vector(244,201,23), 3.0, caster)

		AddCustomGold( caster:GetPlayerOwnerID(), ability:GetSpecialValueFor("gold") )
	end
end

function UpgradeExchange( keys )
	local caster = keys.caster
	local ability = keys.ability

	if GameMode.LOTTERY_STATE == 1 then
		local time = math.floor((PETRI_LOTTERY_DURATION * 60) - (GameMode.PETRI_TRUE_TIME - LOTTERY_START_TIME))
		if time >= 10 then
			CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "petri_force_start_exchange", {["exchange_time"] = time } )
		end
	end
end