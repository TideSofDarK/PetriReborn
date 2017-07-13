function OnAttacked( keys )
	local attacker = keys.attacker
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(attacker, attacker, "modifier_poison", {})
end

function Upgrade( keys )
	local caster = keys.caster
	local ability = keys.ability

	local passive = caster:FindAbilityByName("petri_cop_trap")
	if passive and SpendCustomGold( caster:GetPlayerOwnerID(), GetAbilityGoldCost( ability ) ) then
		passive:UpgradeAbility(false)
		LinkLuaModifier("modifier_bonus_life", "internal/modifier_bonus_life.lua", LUA_MODIFIER_MOTION_NONE)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_upgraded", {})
		caster:AddNewModifier(caster,ability,"modifier_bonus_life",{}).health = 290
		print(caster:HasModifier("modifier_bonus_life"))

		ability:SetHidden(true)

		caster:SetModelScale(2.1)
		caster:CreatureLevelUp(1) 

		caster:RemoveAbility("petri_upgrade_cop_trap")
	end
end