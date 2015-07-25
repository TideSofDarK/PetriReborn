function Spawn( keys )
	StartAnimation(thisEntity, {duration=-1, activity=ACT_DOTA_IDLE , rate=2.5})

	Timers:CreateTimer(5.1, function()
		local pID = thisEntity:GetPlayerOwnerID()
		if pID ~= -1 then
			local level = GetUpgradeLevelForPlayer("petri_upgrade_concrete", pID)
			thisEntity:FindAbilityByName("petri_upgrade_concrete"):SetLevel(level+1)
			HideIfMaxLevel(thisEntity:FindAbilityByName("petri_upgrade_concrete"))

			level = GetUpgradeLevelForPlayer("petri_upgrade_tower_damage", pID)
			thisEntity:FindAbilityByName("petri_upgrade_tower_damage"):SetLevel(level+1)
			HideIfMaxLevel(thisEntity:FindAbilityByName("petri_upgrade_tower_damage"))

			level = GetUpgradeLevelForPlayer("petri_upgrade_lumber", pID)
			thisEntity:FindAbilityByName("petri_upgrade_lumber"):SetLevel(level+1)
			HideIfMaxLevel(thisEntity:FindAbilityByName("petri_upgrade_lumber"))
		end
	end)
end

function LumberUpgrade(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	local hero = GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]

	local bonus = ability:GetLevelSpecialValueFor("bonus_lumber", ability:GetLevel() - 1)

	if bonus > hero.bonusLumber then 
		local level = GetUpgradeLevelForPlayer("petri_upgrade_lumber", caster:GetPlayerOwnerID())

		hero.bonusLumber = bonus
	end
end

function ApplyDamageAura(event)
	local caster = event.caster
	local ability = event.ability

	local newDamage = ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel() - 2) 
	local newRange = ability:GetLevelSpecialValueFor("bonus_range", ability:GetLevel() - 2) 

	local radius = ability:GetLevelSpecialValueFor("aura_range", ability:GetLevel()-1)

	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
	
	for k,v in pairs(units) do
		if v:GetPlayerOwnerID() == caster:GetPlayerOwnerID() and
			v:HasAbility("petri_building") then

			ability:ApplyDataDrivenModifier(caster, v, "modifier_damage", {})

			if (v:FindModifierByName("modifier_damage") ~= nil and v:GetModifierStackCount("modifier_damage", v) < newDamage) 
				or (v:FindModifierByName("modifier_damage") == nil) then
				v:RemoveModifierByName("modifier_damage")
				ability:ApplyDataDrivenModifier(v, v, "modifier_damage", { })
				v:SetModifierStackCount("modifier_damage", v, newDamage)
			end

			if (v:FindModifierByName("modifier_range") ~= nil and v:GetModifierStackCount("modifier_range", v) < newRange) 
				or (v:FindModifierByName("modifier_range") == nil) then
				v:RemoveModifierByName("modifier_range")
				ability:ApplyDataDrivenModifier(v, v, "modifier_range", { })
				v:SetModifierStackCount("modifier_range", v, newRange)
			end
		end
	end
end

function ApplyArmorAura(event)
	local caster = event.caster
	local ability = event.ability

	local newArmor = ability:GetLevelSpecialValueFor("bonus_armor", ability:GetLevel() - 2) 

	local radius = ability:GetLevelSpecialValueFor("aura_range", ability:GetLevel()-1)

	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
	
	for k,v in pairs(units) do
		if v:GetPlayerOwnerID() == caster:GetPlayerOwnerID() and
			v:HasAbility("petri_building") then

			if (v:FindModifierByName("modifier_concrete") ~= nil and v:GetModifierStackCount("modifier_concrete", v) < newArmor) 
				or (v:FindModifierByName("modifier_concrete") == nil) then
				v:RemoveModifierByName("modifier_concrete")
				ability:ApplyDataDrivenModifier(v, v, "modifier_concrete", { })
				v:SetModifierStackCount("modifier_concrete", v, newArmor)
			end
		end
	end
end