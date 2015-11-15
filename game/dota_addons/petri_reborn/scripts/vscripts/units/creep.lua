function Spawn( keys )
    print("asdsa")
    if thisEntity:GetTeamNumber() == DOTA_TEAM_BADGUYS then -- Guys in cells
        thisEntity:AddAbility("petri_invulnerable_creep")
        InitAbilities(thisEntity)
        thisEntity:SetAttackCapability(0)
    else 
        FindClearSpaceForUnit(thisEntity, thisEntity:GetAbsOrigin(),true)
        print("asdsa")
        Timers:CreateTimer(0.03, function (  )
            thisEntity.spawnPosition = thisEntity:GetAbsOrigin()
        end)
    end
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

function SplitShot( keys )
    local caster = keys.caster
    local caster_location = caster:GetAbsOrigin()
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    -- Targeting variables
    local target_type = ability:GetAbilityTargetType()
    local target_team = ability:GetAbilityTargetTeam()
    local target_flags = ability:GetAbilityTargetFlags()
    local attack_target = caster:GetAttackTarget()

    -- Ability variables
    local radius = 200
    local max_targets = 10
    local projectile_speed = 1400
    local split_shot_projectile = keys.projectile

    local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), caster_location, nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)

    -- Create projectiles for units that are not the casters current attack target
    for _,v in pairs(split_shot_targets) do
        if v ~= attack_target then
            local projectile_info = 
            {
                EffectName = split_shot_projectile,
                Ability = ability,
                vSpawnOrigin = caster_location,
                Target = v,
                Source = caster,
                bHasFrontalCone = false,
                iMoveSpeed = projectile_speed,
                bReplaceExisting = false,
                bProvidesVision = false
            }
            ProjectileManager:CreateTrackingProjectile(projectile_info)
            max_targets = max_targets - 1
        end
        -- If we reached the maximum amount of targets then break the loop
        if max_targets == 0 then break end
    end
end

function SplitShotDamage( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.victim = target
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.damage = caster:GetAttackDamage()

    ApplyDamage(damage_table)
end

function KivinGoldTick(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    if GameRules:IsDaytime() == false and target:IsRealHero() == true then
        PlayerResource:ModifyGold(target:GetPlayerOwnerID(), GetGoldTickModifier(), false, 0) 
        PlusParticle(GetGoldTickModifier(), Vector(244,201,23), 3.0, target)
    end
end