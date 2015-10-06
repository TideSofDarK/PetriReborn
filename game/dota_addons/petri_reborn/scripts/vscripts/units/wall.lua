function Upgrade (event)
	local caster = event.caster
	local ability = event.ability

	ability:SetHidden(false)

	local wall_level = ability:GetLevel()

	UpdateAttributes(caster, wall_level, ability)

	caster:SetAngles(0, -90, 0)

	if wall_level == 1 then
		caster:SetOriginalModel(GetModelNameForLevel(1))
		caster:SetModel(GetModelNameForLevel(1))
		caster:SetModelScale(3.35)

		caster:AddAbility("petri_wall_glyph")
		InitAbilities(caster)
	elseif wall_level == 2 then 
		caster:SetOriginalModel(GetModelNameForLevel(2))
		caster:SetModel(GetModelNameForLevel(2))
		caster:SetModelScale(0.8)

		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false)
	elseif wall_level == 3 then
		caster:SetOriginalModel(GetModelNameForLevel(3))
		caster:SetModel(GetModelNameForLevel(3))
		caster:SetModelScale(2.4)

		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false)
	elseif wall_level == 4 then
		caster:SetOriginalModel(GetModelNameForLevel(4))
		caster:SetModel(GetModelNameForLevel(4))
		caster:SetModelScale(2.4)

		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false)
	elseif wall_level == 5 then
		caster:SetOriginalModel(GetModelNameForLevel(5))
		caster:SetModel(GetModelNameForLevel(5))
		caster:SetModelScale(4.3)

		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false)
	elseif wall_level == 6 then
		caster:SetOriginalModel(GetModelNameForLevel(6))
		caster:SetModel(GetModelNameForLevel(6))
		caster:SetModelScale(3.0)

		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false)
	elseif wall_level == 7 then
		caster:SetOriginalModel(GetModelNameForLevel(7))
		caster:SetModel(GetModelNameForLevel(7))
		caster:SetModelScale(1.2)

		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})

		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false)
	elseif wall_level == 8 then
		caster:SetOriginalModel(GetModelNameForLevel(8))
		caster:SetModel(GetModelNameForLevel(8))
		caster:SetModelScale(1.2)

		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})

		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false)
	elseif wall_level == 9 then
		caster:SetOriginalModel(GetModelNameForLevel(9))
		caster:SetModel(GetModelNameForLevel(9))
		caster:SetModelScale(1.3)

		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})

		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false)
	elseif wall_level == 10 then
		caster:SetOriginalModel(GetModelNameForLevel(10))
		caster:SetModel(GetModelNameForLevel(10))
		caster:SetModelScale(1.3)

		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})

		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false)
	elseif wall_level == 11 then
		caster:SetOriginalModel(GetModelNameForLevel(11))
		caster:SetModel(GetModelNameForLevel(11))
		caster:SetModelScale(2.05)

		caster:SetAngles(-19, -45, -28)

		local oldPos = caster:GetAbsOrigin()
		oldPos.z = oldPos.z + 96
		caster:SetAbsOrigin(oldPos)

		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})

		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false)
	elseif wall_level == 12 then
		caster:SetOriginalModel(GetModelNameForLevel(12))
		caster:SetModel(GetModelNameForLevel(12))
		caster:SetModelScale(0.81)

		local oldPos = caster:GetAbsOrigin()
		oldPos.z = oldPos.z - 96
		caster:SetAbsOrigin(oldPos)

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_roshan_gold", {})

		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})

		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false)
	end
end

function UpdateAttributes(wall, level, ability)
	local newHealth = ability:GetLevelSpecialValueFor("health_points", level - 1)
	local newArmor = ability:GetLevelSpecialValueFor("armor", level - 1)

	local fullHP = wall:GetHealth() == wall:GetMaxHealth()

	wall:SetBaseMaxHealth(newHealth)

	if fullHP then
		wall:SetHealth(newHealth)
	end

	wall:RemoveModifierByName("modifier_armor")
	ability:ApplyDataDrivenModifier(wall, wall, "modifier_armor", {})
	wall:SetModifierStackCount("modifier_armor", wall, newArmor)
end

function GetModelNameForLevel(level)
	if level == 1 then
		return "models/items/rattletrap/forge_warrior_rocket_cannon/forge_warrior_rocket_cannon.vmdl"
	elseif level == 2 then 
		return "models/props_rock/riveredge_rock008a.vmdl"
	elseif level == 3 then
		return "models/props_magic/bad_crystals002.vmdl"
	elseif level == 4 then
		return "models/items/rattletrap/warmachine_cog_dc/warmachine_cog_dc.vmdl"
	elseif level == 5 then
		return "models/heroes/oracle/crystal_ball.vmdl"
	elseif level == 6 then
		return "models/props_items/bloodstone.vmdl"
	elseif level == 7 then
		return "models/creeps/neutral_creeps/n_creep_golem_a/neutral_creep_golem_a.vmdl"
	elseif level == 8 then
		return "models/heroes/undying/undying_flesh_golem.vmdl"
	elseif level == 9 then
		return "models/items/warlock/golem/obsidian_golem/obsidian_golem.vmdl"
	elseif level == 10 then
		return "models/items/terrorblade/dotapit_s3_fallen_light_metamorphosis/dotapit_s3_fallen_light_metamorphosis.vmdl"
	elseif level == 11 then
		return "models/creeps/roshan/aegis.vmdl"
	elseif level == 12 then
		return "models/creeps/roshan/roshan.vmdl"
	end
end

function Notification(keys)
	local caster = keys.caster
	local origin = caster:GetAbsOrigin()
	caster.lastWallIsUnderAttackNotification = caster.lastWallIsUnderAttackNotification or 0

	if GameRules:GetGameTime() - caster.lastWallIsUnderAttackNotification > 15.0 then
		EmitSoundOnClient("General.PingDefense", caster:GetPlayerOwner())
		caster.lastWallIsUnderAttackNotification = GameRules:GetGameTime()
	end

	caster.lastWallIsUnderAttackNotification = caster.lastWallIsUnderAttackNotification or 0
	
	MinimapEvent(DOTA_TEAM_GOODGUYS, caster, origin.x, origin.y, DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, 1 )
end

function ApplyBonusArmor( keys )
	local caster = keys.caster
	local ability = keys.ability

	local gold_cost = ability:GetGoldCost(ability:GetLevel()-1)

	PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), gold_cost, false, 7) 

	if caster.glyph_charges > 0 then
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "time", ( ability:GetLevel() - 1 ) )
		local stack_modifier = keys.modifier_name

		local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_glyph", {duration = ability:GetSpecialValueFor("duration")})

		for k,v in pairs(units) do
			if v:GetPlayerOwnerID() == caster:GetPlayerOwnerID() and
				v:HasAbility("petri_building") == true and 
				v:GetUnitName() ~= "npc_petri_wall" then
				ability:ApplyDataDrivenModifier(caster, v, "modifier_glyph", {duration = ability:GetSpecialValueFor("duration")})
			end
		end

		local next_charge = caster.glyph_charges - 1
		if caster.glyph_charges == maximum_charges then
		    caster:RemoveModifierByName( stack_modifier )
		    ability:ApplyDataDrivenModifier( caster, caster, stack_modifier, { Duration = charge_replenish_time } )
		    StartGlyphCooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( stack_modifier, ability, next_charge )
		caster.glyph_charges = next_charge

		PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), -gold_cost, false, 7) 
	end
end

function GlyphStartCharge( keys )
    -- Initial variables to keep track of different max charge requirements
    local caster = keys.caster
    local ability = keys.ability

    caster.maximum_charges = ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 1 ) )

    if keys.ability:GetLevel() ~= 1 then return end
  
    local modifierName = keys.modifier_name
    local charge_replenish_time = ability:GetLevelSpecialValueFor( "time", ( ability:GetLevel() - 1 ) )
    
    caster:SetModifierStackCount( modifierName, ability, 0 )
    caster.glyph_charges = caster.maximum_charges
    caster.start_charge = false
    caster.glyph_cooldown = 0.0
    
    ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
    caster:SetModifierStackCount( modifierName, ability, caster.maximum_charges )
    
    Timers:CreateTimer( function()
            -- Restore charge
            if caster.start_charge and caster.glyph_charges < caster.maximum_charges then
                -- Calculate stacks
                local next_charge = caster.glyph_charges + 1
                caster:RemoveModifierByName( modifierName )
                if next_charge ~= caster.maximum_charges then
                    ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
                    StartGlyphCooldown( caster, charge_replenish_time )
                else
                    ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
                    caster.start_charge = false
                end
                caster:SetModifierStackCount( modifierName, ability, next_charge )
                
                -- Update stack
                caster.glyph_charges = next_charge
            end
            
            -- Check if max is reached then check every 0.5 seconds if the charge is used
            if caster.glyph_charges ~= caster.maximum_charges then
                caster.start_charge = true
                -- On level up refresh the modifier
                ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
                return charge_replenish_time
            else
                return 0.5
            end
        end
    )
end

function StartGlyphCooldown( caster, charge_replenish_time )
    caster.glyph_cooldown = charge_replenish_time
    Timers:CreateTimer( function()
            local current_cooldown = caster.glyph_cooldown - 0.1
            if current_cooldown > 0.1 then
                caster.glyph_cooldown = current_cooldown
                return 0.1
            else
                return nil
            end
        end
    )
end