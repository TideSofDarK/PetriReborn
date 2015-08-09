function Blink(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)	
end

function OnTakeDamage(keys)
	local attacker_name = keys.attacker:GetName()

    if keys.Damage > 0 and (attacker_name == "npc_dota_roshan" or keys.attacker:IsControllableByAnyPlayer()) then  --If the damage was dealt by neutrals or lane creeps, essentially.
        if keys.ability:GetCooldownTimeRemaining() < keys.BlinkDamageCooldown then
            keys.ability:StartCooldown(keys.BlinkDamageCooldown)
        end
    end
end