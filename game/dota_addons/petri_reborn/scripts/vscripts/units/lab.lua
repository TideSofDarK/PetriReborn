function Spawn( keys )
	StartAnimation(thisEntity, {duration=-1, activity=ACT_DOTA_IDLE , rate=2.5})
end

function LumberUpgrade(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	local hero = GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]

	local bonus = ability:GetLevelSpecialValueFor("bonus_lumber", ability:GetLevel() - 1)

	if bonus > hero.bonusLumber then hero.bonusLumber = bonus end
end

function ApplyDamageAura(event)
	local caster = event.caster
	local ability = event.ability

	local radius = ability:GetLevelSpecialValueFor("aura_range", ability:GetLevel()-1)

	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
	
	for k,v in pairs(units) do
		if v:GetPlayerOwnerID() == caster:GetPlayerOwnerID() and
			v:HasAbility("petri_building") then

			ability:ApplyDataDrivenModifier(caster, v, "modifier_damage", {})
		end
	end
end

function ApplyArmorAura(event)
	local caster = event.caster
	local ability = event.ability

	local radius = ability:GetLevelSpecialValueFor("aura_range", ability:GetLevel()-1)

	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
	
	for k,v in pairs(units) do
		if v:GetPlayerOwnerID() == caster:GetPlayerOwnerID() and
			v:HasAbility("petri_building") then
			
			ability:ApplyDataDrivenModifier(caster, v, "modifier_concrete", {})
		end
	end
end