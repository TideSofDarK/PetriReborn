TOWER_BASIC = 0
TOWER_ELEMENTS = 1
TOWER_FIRE = 2
TOWER_ICE = 3
TOWER_DEATH = 4

function UpgradeBasic (event)
	local caster = event.caster
	local ability = event.ability

	ability:SetHidden(false)

	local tower_level = ability:GetLevel()

	--caster:SetOriginalModel(GetModelNameForLevel(TOWER_BASIC))
	--caster:SetModel(GetModelNameForLevel(TOWER_BASIC))

	caster:SetModelScale(0.4 + (tower_level/20))

	UpdateAttributes(TOWER_BASIC, ability)
end

function GetModelNameForTower(tower)
	if tower == TOWER_ELEMENTS then 
		return "models/props_structures/good_ancient001.vmdl"
	elseif tower == TOWER_FIRE then 
		return "models/props_structures/good_ancient001.vmdl"
	elseif tower == TOWER_ICE then 
		return "models/props_structures/good_ancient001.vmdl"
	elseif tower == TOWER_DEATH then 
		return "models/props_structures/good_ancient001.vmdl"
	end
end

function UpdateAttributes(tower, ability)
	local tower_level = ability:GetLevel() - 1

	local attack = ability:GetLevelSpecialValueFor("attack", tower_level)
	local attack_rate = ability:GetLevelSpecialValueFor("attack_rate", tower_level)

	ability:GetCaster():SetBaseDamageMax(attack)
	ability:GetCaster():SetBaseDamageMin(attack)
	--ability:GetCaster():SetBaseAttackTime(attack_rate)

	ability:ApplyDataDrivenModifier(ability:GetCaster(), ability:GetCaster(), "modifier_attack_speed", {})

	if tower == TOWER_BASIC then
		
	elseif tower == TOWER_ELEMENTS then 
	elseif tower == TOWER_FIRE then 
	elseif tower == TOWER_ICE then 
	elseif tower == TOWER_DEATH then 
	end
end

function SetAttributes()
	-- body
end