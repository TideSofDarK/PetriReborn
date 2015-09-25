function Spawn( keys )
	thisEntity:AddAbility("petri_invulnerable_creep")
	InitAbilities(thisEntity)
	thisEntity:SetAttackCapability(0)
end

function ApplyDamageReduction( keys )
	local caster = keys.caster
	local ability = keys.ability

	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", -1) - 1

    local average_damage = (caster:GetBaseDamageMax() + caster:GetBaseDamageMin()) / 2

	local damage = (average_damage) - math.floor( (average_damage) / max_stacks )

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_damage_reduction", {})
	caster:SetModifierStackCount("modifier_damage_reduction", caster, damage)
end

function Attack( keys )
	local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local modifierName = "modifier_creep_swipes_target"
    local damageType = ability:GetAbilityDamageType()

    local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", -1) 

    local average_damage = (caster:GetBaseDamageMax() + caster:GetBaseDamageMin()) / 2

    duration = ability:GetLevelSpecialValueFor( "reset_time", ability:GetLevel() - 1 )

	if target:HasModifier( modifierName ) == true then
        local current_stack = target:GetModifierStackCount( modifierName, target )
        if current_stack > max_stacks then
        	current_stack = max_stacks
        end

        local damage_table = {
            victim = target,
            attacker = caster,
            damage = average_damage * current_stack,
            damage_type = damageType
        }
        ApplyDamage( damage_table )
        
        PlusParticle(average_damage * current_stack, Vector(255,255,0), 1.0, attacker)
        
        ability:ApplyDataDrivenModifier( target, target, modifierName, { Duration = duration } )
        target:SetModifierStackCount( modifierName, target, current_stack + 1 )
    else
        ability:ApplyDataDrivenModifier( target, target, modifierName, { Duration = duration } )
        target:SetModifierStackCount( modifierName, target, 1 )
    end
end