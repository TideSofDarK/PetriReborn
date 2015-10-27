function Use( keys )
	local caster = keys.caster
	
	if caster:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		local chance = math.random(1, 100)
		if chance > 80  then
			CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_petri_candy_1_petri", caster, caster)) 
		elseif chance > 60 then
			CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_petri_candy_2_petri", caster, caster)) 
		elseif chance > 40 then
			CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_petri_candy_3_petri", caster, caster)) 
		elseif chance > 20 then
			CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_petri_candy_4_petri", caster, caster)) 
		elseif chance > 0 then
			CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_petri_candy_5_petri", caster, caster)) 
		end
	else
		local chance = math.random(1, 100)
		if chance > 80 then
			CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_petri_candy_1_kvn", caster, caster)) 
		elseif chance > 60 then
			CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_petri_candy_2_kvn", caster, caster)) 
		elseif chance > 40 then
			CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_petri_candy_3_kvn", caster, caster)) 
		elseif chance > 20 then
			CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_petri_candy_4_kvn", caster, caster)) 
		elseif chance > 0 then
			CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_petri_candy_5_kvn", caster, caster)) 
		end
	end
end

function CandyRepair(keys)
	local caster = keys.caster
	local target = keys.target

	local healAmount = 3 + (target:GetMaxHealth() * 0.01295)

	target:Heal(healAmount, caster)
	PlusParticle(math.floor(healAmount), Vector(50,221,60), 0.7, target)
end

function CandyBonusKVNDamage( keys )
	local caster = keys.caster
	local ability = keys.ability

	local time = math.floor(GameRules:GetDOTATime(false, false) / 60)
	local count = 1000

	if time > 32 then
		count = 25000
	elseif time >= 16 and time <= 32 then
		count = 4000
	elseif time < 16 then
		count = 1000 
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_damage", {})
	caster:SetModifierStackCount("modifier_bonus_damage", caster, count)
end

function CandyForceStaff( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:RemoveModifierByName("item_petri_alcohol")

	local caster_position = caster:GetAbsOrigin()
    local target_position = target:GetAbsOrigin()

    local angle = math.atan2(target_position.y - caster_position.y, target_position.x - caster_position.x)

    target.forcingTime = 0.0
    target.forcingPosition = target_position
    target.forcingAngle = angle

	Timers:CreateTimer(function (  )
		target.forcingPosition.x = target.forcingPosition.x + (math.cos(target.forcingAngle) * 60)
		target.forcingPosition.y = target.forcingPosition.y + (math.sin(target.forcingAngle) * 60)

		FindClearSpaceForUnit(target, target.forcingPosition, false)

		target.forcingTime = target.forcingTime + 0.03
		if target.forcingTime < 0.5 then
			return 0.03
		end
	end)
end

function CandyStar( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damageTable = {
	    victim = target,
	    attacker = caster,
	    damage = target:GetMaxHealth(),
	    damage_type = DAMAGE_TYPE_PURE,
	}
	if target:IsMagicImmune() == false then
		ApplyDamage(damageTable)
	end
end

function CandyBonusPetriDamage( keys )
	local caster = keys.caster
	local ability = keys.ability

	local damage = caster:GetAverageTrueAttackDamage()
	damage = math.floor(damage * 0.25)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_damage", {})
	caster:SetModifierStackCount("modifier_bonus_damage", caster, damage)
end

function CandyHungerDamage( keys )
	local caster = keys.caster
	local ability = keys.ability

	local damageTable = {
	    victim = caster,
	    attacker = caster,
	    damage = 1,
	    damage_type = DAMAGE_TYPE_PURE,
	}
	if caster:IsMagicImmune() == false and caster:HasModifier("modifier_snare") == false then
		ApplyDamage(damageTable)
	end
end

function CandyMintStorm( keys )
	local caster = keys.caster
	local target = keys.target_points[1]

    local storm = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_snow_arcana1.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(storm, 0, target)

    Timers:CreateTimer(15, function ()
    	ParticleManager:DestroyParticle(storm, false) 
	end)
end

function CandyLightning( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damageTable = {
	    victim = target,
	    attacker = caster,
	    damage = target:GetMaxHealth(),
	    damage_type = DAMAGE_TYPE_PURE,
	}
	if caster:IsMagicImmune() == false and caster:HasModifier("modifier_snare") == false then
		ApplyDamage(damageTable)
	end
end