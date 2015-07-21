function Spawn( keys )
	StartAnimation(thisEntity, {duration=-1, activity=ACT_DOTA_IDLE , rate=2.5})
end

function Upgrade (event)
	local caster = event.caster
	local ability = event.ability
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	local upgrade_level = ability:GetLevel()

	if hero:HasAbility("petri_upgrade_concrete") == false then
		hero:AddAbility("petri_upgrade_concrete")
	end

	local hero_ability = hero:FindAbilityByName("petri_upgrade_concrete")
	hero_ability:SetHidden(true)

	hero_ability:SetLevel(upgrade_level+1)
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