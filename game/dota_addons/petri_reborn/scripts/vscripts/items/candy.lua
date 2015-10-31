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

function CandyHealing(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:HasAbility("petri_building") == true then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_healing", {duration=30})
	end
end

function CandyRepair(keys)
	local caster = keys.caster
	local target = keys.target

	local healAmount = 3 + (target:GetMaxHealth() * 0.02015)

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

	caster:RemoveModifierByName("modifier_item_petri_alcohol_active")

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
	--caster:EmitSound("Ability.StarfallImpact")
	-- StartSoundEvent("Ability.Starfall", caster)
	-- StartSoundEvent(, caster)
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
	local target = keys.target

	local damageTable = {
	    victim = target,
	    attacker = caster,
	    damage = 1,
	    damage_type = DAMAGE_TYPE_PURE,
	}
	if target:IsMagicImmune() == false and target:HasModifier("modifier_snare") == false then
		ApplyDamage(damageTable)
	end
end

function CandyMintStorm( keys )
	local caster = keys.caster
	local target = keys.target_points[1]

    local storm = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_snow_arcana1.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(storm, 0, target)

    local dummy = CreateUnitByName("petri_dummy_300vision", target, false, nil, nil, DOTA_TEAM_GOODGUYS)
    local dummy_petrosyan = CreateUnitByName("petri_dummy_300vision", target, false, nil, nil, DOTA_TEAM_BADGUYS)
    dummy:SetNightTimeVisionRange(0)
    dummy:SetDayTimeVisionRange(0)

    StartSoundEvent( "hero_Crystal.freezingField.wind", dummy )

    Timers:CreateTimer(15, function ()
    	ParticleManager:DestroyParticle(storm, false) 
    	StopSoundEvent("hero_Crystal.freezingField.wind", dummy)
    	UTIL_Remove(dummy)
    	UTIL_Remove(dummy_petrosyan)
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
	if target:IsMagicImmune() == false and target:HasModifier("modifier_snare") == false then
		ApplyDamage(damageTable)
	end
end

function CandySilence( keys )
	local caster = keys.caster
	local target = keys.target 
	local ability = keys.ability
	print(target:GetUnitName())
	if target:HasAbility("petri_building") == true or target:HasAbility("petri_tower") == true or target:GetUnitName() == "npc_petri_gold_bag" then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_silence", {duration=15})
	end
end

function CreatePetriVisionNode( keys )
	local caster = keys.caster
	local ability = keys.ability

	local dummy = CreateUnitByName("petri_dummy_300vision", caster:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS)

    caster.dummyTime = 0.0
	
	Timers:CreateTimer(function (  )
		dummy:SetAbsOrigin(caster:GetAbsOrigin())

		caster.dummyTime = caster.dummyTime + 0.03
		if caster.dummyTime < 3.5 then
			return 0.03
		else
			UTIL_Remove(dummy)
		end
	end)
end

function CreateKVNVisionNode( keys )
	local caster = keys.caster
	local ability = keys.ability

	local dummy = CreateUnitByName("petri_dummy_300vision", caster:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_GOODGUYS)

	caster.dummyTime = 0.0
	
	Timers:CreateTimer(function (  )
		dummy:SetAbsOrigin(caster:GetAbsOrigin())

		caster.dummyTime = caster.dummyTime + 0.03
		if caster.dummyTime < 3.5 then
			return 0.03
		else
			UTIL_Remove(dummy)
		end
	end)
end

function CandyReleaseSleep(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS, target, nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false)

	for k,v in pairs(units) do
		v:RemoveModifierByName("petri_petrosyan_sleep")
		v:RemoveModifierByName("modifier_snare")
	end
end