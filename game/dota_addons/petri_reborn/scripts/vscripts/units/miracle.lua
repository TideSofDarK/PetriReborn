function MiracleHeal(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	if target:GetUnitName() == "npc_petri_exit" or target:GetUnitName() == "npc_petri_miracle1" or target:GetUnitName() == "npc_petri_miracle2" or target:GetUnitName() == "npc_petri_miracle3" then  ability:EndCooldown() ability:StartCooldown(5.0) return end

	if target:HasAbility("petri_building") ~= true then
		Notifications:Bottom(caster:GetPlayerOwnerID(), {text="#repair_target_is_not_a_building", duration=1, style={color="red", ["font-size"]="45px"}}) ability:EndCooldown() ability:StartCooldown(5.0)
		return
	end
	if target:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then

			local healAmount = (target:GetMaxHealth() * 0.3)
			target:Heal(healAmount, caster)
	else
		ability:EndCooldown() ability:StartCooldown(5.0)
		Notifications:Bottom(caster:GetPlayerOwnerID(), {text="#heal_target_is_not_yours", duration=1, style={color="red", ["font-size"]="45px"}})
	end
end

function SpellDamage(keys)
	local u_caster = keys.caster
	local u_target
	if keys.Target == "CASTER" then
		u_target = keys.caster
	elseif keys.Target == "TARGET" then
		u_target = keys.target
	elseif keys.Target == "UNIT" then
		u_target = keys.unit
	elseif keys.Target == "ATTACKER" then
		u_target = keys.attacker
	else
		u_target = keys.caster
	end
	if u_caster and u_target then
		DamageManager:SpellDamage(u_caster,u_target,keys.Damage)
	end
end