function Upgrade (event)
	local caster = event.caster
	local ability = event.ability

	ability:SetHidden(false)

	local wall_level = ability:GetLevel()

	UpdateAttributes(caster, wall_level, ability)

	caster:SetAngles(0, -90, 0)

	caster:RemoveModifierByName("modifier_building")

	SetWallModel(caster, wall_level)

	if caster:FindAbilityByName("petri_wall_glyph") then 
		caster:FindAbilityByName("petri_wall_glyph"):UpgradeAbility(false) 
	end

	if wall_level == 1 then
		caster:AddAbility("petri_wall_glyph")
		InitAbilities(caster)
	elseif wall_level == 12 then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_roshan_gold", {})
	end
	
	StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})
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

function SetWallModel(wall, level)
	local wallTable = GameMode.WallsKVs[wall:GetUnitName()][tostring(level+1)]
	for k,v in pairs(wallTable["model"]) do
		if v == "model" then 
			wall:SetOriginalModel(k)
			wall:SetModel(k)
			break
		end
	end
	wall:SetModelScale(tonumber(wallTable["scale"]))

	if wallTable["zOffset"] then
		local zOffset = tonumber(wallTable["zOffset"])

		local oldPos = wall:GetAbsOrigin()
		oldPos.z = oldPos.z + zOffset
		wall:SetAbsOrigin(oldPos)
	else 
	end

	if wallTable["angles"] then
		wall:SetAngles(tonumber(wallTable["angles"]["x"]), tonumber(wallTable["angles"]["y"]), tonumber(wallTable["angles"]["z"]))
	else 
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