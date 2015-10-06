function EvasionTornado(keys)
    local caster_origin = keys.caster:GetAbsOrigin()

    local tornado_travel_distance = keys.ability:GetLevelSpecialValueFor("travel_distance", -1)
    tornado_lift_duration = keys.ability:GetLevelSpecialValueFor("lift_duration", -1)
    local tornado_landing_damage_bonus = keys.ability:GetLevelSpecialValueFor("wex_damage", -1)
    
    local tornado_dummy_unit = CreateUnitByName("npc_dummy_unit", caster_origin, false, nil, nil, keys.caster:GetTeam())
    local emp_unit_ability = keys.ability
   	emp_unit_ability:ApplyDataDrivenModifier(tornado_dummy_unit, tornado_dummy_unit, "modifier_tornado_unit_ability", {duration = -1})

    tornado_dummy_unit:EmitSound("Hero_Invoker.Tornado")  --Emit a sound that will follow the tornado.
    tornado_dummy_unit:SetDayTimeVisionRange(keys.VisionDistance)
    tornado_dummy_unit:SetNightTimeVisionRange(keys.VisionDistance)
    
    local projectile_information =  
    {
        EffectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf",
        Ability = emp_unit_ability,
        vSpawnOrigin = caster_origin,
        fDistance = tornado_travel_distance,
        fStartRadius = keys.AreaOfEffect,
        fEndRadius = keys.AreaOfEffect,
        Source = tornado_dummy_unit,
        bHasFrontalCone = false,
        iMoveSpeed = keys.TravelSpeed,
        bReplaceExisting = false,
        bProvidesVision = true,
        iVisionTeamNumber = keys.caster:GetTeam(),
        iVisionRadius = keys.VisionDistance,
        bDrawsOnMinimap = false,
        bVisibleToEnemies = true, 
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 20.0,
    }

    local target_point = keys.target_points[1]
    target_point.z = 0
    local caster_point = keys.caster:GetAbsOrigin()
    caster_point.z = 0
    local point_difference_normalized = (target_point - caster_point):Normalized()
    projectile_information.vVelocity = point_difference_normalized * keys.TravelSpeed
    
    local tornado_projectile = ProjectileManager:CreateLinearProjectile(projectile_information)
    
    --When the projectile ID can be passed into a OnProjectileHitUnit block, an array like this can be used to store the stats associated with the projectile.
    --[[
    --Store the lift duration and bonus landing damage associated with the projectile, using the Quas/Exort levels from when Tornado was cast.
    if keys.caster.tornado_projectile_information == nil then
        keys.caster.tornado_projectile_information = {}
    end
    local tornado_projectile_information = {}
    tornado_projectile_information["tornado_lift_duration"] = tornado_lift_duration
    tornado_projectile_information[tornado_projectile])["tornado_landing_damage_bonus"] = tornado_landing_damage_bonus
    keys.caster.tornado_projectile_information[tornado_projectile] = tornado_projectile_information
    ]]
    
    tornado_dummy_unit.invoker_tornado_lift_duration = tornado_lift_duration
    tornado_dummy_unit.invoker_tornado_landing_damage_bonus = tornado_landing_damage_bonus
    
    --Calculate where and when the Tornado projectile will end up.
    local tornado_duration = tornado_travel_distance / keys.TravelSpeed
    local tornado_final_position = caster_origin + (projectile_information.vVelocity * tornado_duration)
    local tornado_velocity_per_frame = projectile_information.vVelocity * .03
    
    --Adjust the dummy unit's position every frame to match that of the tornado particle effect.
    local endTime = GameRules:GetGameTime() + tornado_duration
    Timers:CreateTimer({
        endTime = .03,
        callback = function()
            tornado_dummy_unit:SetAbsOrigin(tornado_dummy_unit:GetAbsOrigin() + tornado_velocity_per_frame)
            if GameRules:GetGameTime() > endTime then
                tornado_dummy_unit:StopSound("Hero_Invoker.Tornado")
                
                --Have the dummy unit linger in the position the tornado ended up in, in order to provide vision.
                Timers:CreateTimer({
                    endTime = keys.EndVisionDuration,
                    callback = function()
                        tornado_dummy_unit:RemoveSelf()
                    end
                })
                
                return 
            else 
                return .03
            end
        end
    })
end

function TornadoHit(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
    if target:HasAbility("petri_building") == true then
    	ability:ApplyDataDrivenModifier(caster, target, "modifier_evasion_scroll", {duration = -1})
    end
end
