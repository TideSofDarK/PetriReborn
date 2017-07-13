TOWER_BASIC = 0
TOWER_ELEMENTS = 1
TOWER_FIRE = 2
TOWER_ICE = 3
TOWER_DEATH = 4

function UpgradeDeath (event)
	local caster = event.caster
	local ability = event.ability

	local tower_level = ability:GetLevel()
	
	UpdateModel(caster, GetModelNameForTower(TOWER_DEATH), 0.58 + (tower_level/30))
	SetCustomBuildingModel(caster, PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID()), "death_"..tostring(tower_level))
	
	caster:RemoveAbility("petri_upgrade_ice_tower")
	caster:RemoveAbility("petri_upgrade_fire_tower")
	caster:RemoveAbility("petri_upgrade_to_earth_wall")

	caster:AddAbility("petri_animated_tower")
	caster:FindAbilityByName("petri_animated_tower"):UpgradeAbility(false)

	caster:RemoveModifierByName("modifier_building")

	UpdateAttributes(TOWER_DEATH, ability)
end

function UpgradeIce (event)
	local caster = event.caster
	local ability = event.ability

	local tower_level = ability:GetLevel()

	UpdateModel(caster, GetModelNameForTower(TOWER_ICE), 0.70 + (tower_level/30))
	SetCustomBuildingModel(caster, PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID()), "cold_"..tostring(tower_level))

	caster:RemoveAbility("petri_upgrade_death_tower")
	caster:RemoveAbility("petri_upgrade_fire_tower")
	caster:RemoveAbility("petri_upgrade_to_earth_wall")

	caster:AddAbility("petri_animated_tower")
	caster:FindAbilityByName("petri_animated_tower"):UpgradeAbility(false)

	caster:RemoveModifierByName("modifier_building")

	UpdateAttributes(TOWER_ICE, ability)
end

function UpgradeFire (event)
	local caster = event.caster
	local ability = event.ability

	local tower_level = ability:GetLevel()

	UpdateModel(caster, GetModelNameForTower(TOWER_FIRE), 0.78 + (tower_level/30))
	SetCustomBuildingModel(caster, PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID()), "fire_"..tostring(tower_level))

	caster:RemoveAbility("petri_upgrade_death_tower")
	caster:RemoveAbility("petri_upgrade_ice_tower")
	caster:RemoveAbility("petri_upgrade_to_earth_wall")

	caster:AddAbility("petri_animated_tower")
	caster:FindAbilityByName("petri_animated_tower"):UpgradeAbility(false)

	caster:RemoveModifierByName("modifier_building")

	UpdateAttributes(TOWER_FIRE, ability)
end

function UpgradeElements (event)
	local caster = event.caster
	local ability = event.ability

	local tower_level = ability:GetLevel()

	UpdateModel(caster, GetModelNameForTower(TOWER_ELEMENTS), 0.58)

	caster:RemoveAbility("petri_upgrade_basic_tower")

	caster:AddAbility("petri_upgrade_fire_tower")
	caster:AddAbility("petri_upgrade_death_tower")
	caster:AddAbility("petri_upgrade_ice_tower")
	caster:AddAbility("petri_upgrade_to_earth_wall")

	caster:SwapAbilities("petri_upgrade_fire_tower", "petri_empty1", true, false)
	caster:SwapAbilities("petri_upgrade_death_tower", "petri_empty2", true, false)
	caster:SwapAbilities("petri_upgrade_ice_tower", "petri_empty3", true, false)

	InitAbilities(caster)

	UpdateAttributes(TOWER_ELEMENTS, ability)

	StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.0})
end

function UpgradeBasic (event)
	local caster = event.caster
	local ability = event.ability

	local tower_level = ability:GetLevel()

	caster:SetModelScale(0.35 + (tower_level/30))

	caster:RemoveAbility("petri_upgrade_elements_tower")

	UpdateAttributes(TOWER_BASIC, ability)
end

function GetModelNameForTower(tower)
	if tower == TOWER_ELEMENTS then 
		return "models/props_structures/tower_good.vmdl"
	elseif tower == TOWER_FIRE then 
		return "models/items/invoker/forge_spirit/arsenal_magus_forged_spirit/arsenal_magus_forged_spirit.vmdl"
	elseif tower == TOWER_ICE then 
		return "models/heroes/ancient_apparition/ancient_apparition.vmdl"
	elseif tower == TOWER_DEATH then 
		return "models/heroes/undying/undying_tower.vmdl"
	end
end

function UpdateAttributes(tower, ability)
	local tower_level = ability:GetLevel() - 1

	local attack = ability:GetLevelSpecialValueFor("attack", tower_level)
	local attack_rate = ability:GetLevelSpecialValueFor("attack_rate", tower_level)

	local caster = ability:GetCaster()

	local oldAngles = caster:GetAngles()
	oldAngles[2] = math.random(0, 360)
	caster:SetAngles(oldAngles[1], oldAngles[2], oldAngles[3])

	caster:SetBaseDamageMax(attack)
	caster:SetBaseDamageMin(attack)

	if tower == TOWER_BASIC then
	elseif tower == TOWER_ELEMENTS then 
	elseif tower == TOWER_FIRE then
		caster:RemoveModifierByName("modifier_attack_speed")
		ability:ApplyDataDrivenModifier(ability:GetCaster(), caster, "modifier_crits", {})
	elseif tower == TOWER_ICE then
		caster:RemoveModifierByName("modifier_attack_speed")
		ability:ApplyDataDrivenModifier(ability:GetCaster(), caster, "modifier_skadi", {})
	elseif tower == TOWER_DEATH then 
		caster:RemoveModifierByName("modifier_attack_speed")
		ability:ApplyDataDrivenModifier(ability:GetCaster(), caster, "modifier_death_tower", {})
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_attack_speed", {})
end

-- Misc
function IceTowerOnOrbImpact(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not target:IsMagicImmune() then
		local modifierName = "modifier_skadi_cold_attack"
		local maxStacks = ability:GetLevelSpecialValueFor("slow_stacks", ability:GetLevel()-1)

		
		for i=1,maxStacks do
			AddStackableModifierWithDuration(target, target, ability, modifierName, keys.ColdDuration, maxStacks)
		end
	end
end

function DeathTowerOnOrbImpact(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not target:IsMagicImmune() then
		local modifierName = "modifier_death_tower_corruption"
		local maxStacks = ability:GetLevelSpecialValueFor("armor_reduction_stacks", ability:GetLevel()-1)

		AddStackableModifierWithDuration(target, target, ability, modifierName, 1, maxStacks)
	end
end