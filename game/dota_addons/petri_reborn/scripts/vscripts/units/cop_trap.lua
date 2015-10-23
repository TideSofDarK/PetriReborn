function OnAttacked( keys )
	local attacker = keys.attacker
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(attacker, attacker, "modifier_poison", {})
end

function Upgrade( keys )
	local caster = keys.caster
	local ability = keys.ability

	local passive = caster:FindAbilityByName("petri_cop_trap")
	if passive then
		passive:UpgradeAbility(false)
		
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_upgraded", {})

		ability:SetHidden(true)

		caster:SetModelScale(2.1)
		caster:CreatureLevelUp(1) 

		caster:SetBaseMaxHealth(350)
		caster:SetHealth(350)

		caster:RemoveAbility("petri_upgrade_cop_trap")
	end
end