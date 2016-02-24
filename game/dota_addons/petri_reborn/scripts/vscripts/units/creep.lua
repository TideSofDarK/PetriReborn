function Spawn( keys )
    if thisEntity:GetTeamNumber() == DOTA_TEAM_BADGUYS then -- Guys in cells
        thisEntity:AddAbility("petri_invulnerable_creep")
        InitAbilities(thisEntity)
        thisEntity:SetAttackCapability(0)
    else 
        FindClearSpaceForUnit(thisEntity, thisEntity:GetAbsOrigin(),true)
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
        
        PopupParticle(average_damage * current_stack, Vector(240,30,0), 0.47, caster, nil, POPUP_SYMBOL_POST_DROP)
        
        ability:ApplyDataDrivenModifier( target, target, modifierName, { Duration = duration } )
        target:SetModifierStackCount( modifierName, target, current_stack + 1 )
    else
        ability:ApplyDataDrivenModifier( target, target, modifierName, { Duration = duration } )
        target:SetModifierStackCount( modifierName, target, 1 )
    end
end

function CreepSplashDamage( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    keys.number = keys.number or 0

    local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
    if #units > 1 and keys.number < 2 then
        local tracking_projectile = 
        {
            EffectName = "particles/units/heroes/hero_necrolyte/necrolyte_pulse_enemy.vpcf",
            Ability = ability,
            vSpawnOrigin = caster:GetAbsOrigin(),
            Target = units[2],
            Source = keys.source or caster,
            bHasFrontalCone = false,
            iMoveSpeed = 2000,
            bReplaceExisting = false,
            bProvidesVision = false,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
        }
        ProjectileManager:CreateTrackingProjectile(tracking_projectile)

        local projectile = {
            vSpawnOrigin = target:GetAbsOrigin() + Vector(0,0,80),
            fDistance = 600,
            fStartRadius = 100,
            fEndRadius = 100,
            Source = target,
            fExpireTime = 8.0,
            vVelocity = (units[2]:GetAbsOrigin() - target:GetAbsOrigin()):Normalized() * 2000,
            UnitBehavior = PROJECTILES_DESTROY,
            bMultipleHits = false,
            bIgnoreSource = true,
            TreeBehavior = PROJECTILES_NOTHING,
            bCutTrees = false,
            bTreeFullCollision = false,
            WallBehavior = PROJECTILES_NOTHING,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            nChangeMax = 1,
            bRecreateOnChange = true,
            bZCheck = false,
            bGroundLock = true,
            bProvidesVision = true,
            iVisionRadius = 350,
            iVisionTeamNumber = caster:GetTeam(),
            bFlyingVision = false,
            fVisionTickTime = .1,
            fVisionLingerDuration = 1,
            draw = false,
            UnitTest = function(self, unit) return unit ~= target and unit:IsInvisible() == false and unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
            OnUnitHit = function(self, unit) 
                local damageTable = {
                    victim = unit,
                    attacker = caster,
                    damage = caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("max_stacks") * (ability:GetSpecialValueFor("bonus_damage_percent") / 100),
                    damage_type = 1,
                }

                ApplyDamage(damageTable)

                keys.number = keys.number + 1
                keys.target = units[2]
                keys.source = units[2]
                CreepSplashDamage( keys )
            end,
        }

        Projectiles:CreateProjectile(projectile)
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

    if GameRules:IsDaytime() == false and target:IsRealHero() == true and target:GetTeamNumber() == DOTA_TEAM_BADGUYS then
        PlayerResource:ModifyGold(target:GetPlayerOwnerID(), GetGoldTickModifier(), false, 0) 
        target:AddExperience(GetExpTickModifier(), 0, false, true)
        --PopupParticle(GetGoldTickModifier(), Vector(244,201,23), 2.0, target)
    end
end

function CreateProjectiles( keys )
    local caster = keys.caster
    local ability = keys.ability

    if GameRules:IsDaytime() == false then
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_tick_projectile", {})
    end
end

function Aggression( keys )
    local caster = keys.caster
    local target = keys.target

    if GridNav:FindPathLength(caster:GetAbsOrigin(), target:GetAbsOrigin()) ~= -1 and caster:IsAttacking() == false and UnitCanAttackTarget( caster, target ) == true and target:IsInvisible() == false then
        local newOrder = {
            UnitIndex       = caster:entindex(),
            OrderType       = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position        = target:GetAbsOrigin(), 
            Queue           = 0
        }
        ExecuteOrderFromTable(newOrder)
    else

    end
end