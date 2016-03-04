function Drink( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:EmitSound("Hero_Alchemist.UnstableConcoction.Fuse")
end

function ButtExplode( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:HasAbility("petri_building") == true or target:HasAbility("petri_tower") == true then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_butt_burning", {})

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin() + Vector(0,0,30))
	end
	
	caster:EmitSound("Hero_Techies.LandMine.Detonate")
end

function ButtDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local ability_damage = ((target:GetMaxHealth() / 100) * ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)) + 1

	local damageTable = {
	    victim = target,
	    attacker = caster,
	    damage = ability_damage,
	    damage_type = DAMAGE_TYPE_PURE
	}

  	if target:HasAbility("petri_building") == true or target:GetUnitName() == "npc_petri_wall" then 
  		ApplyDamage(damageTable)
  	end
end

function SetChainStacks( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local modifier_name = "modifier_chains_building"

	local minus_armor = ability:GetLevelSpecialValueFor("minus_armor", ability:GetLevel() - 1)

	target:SetModifierStackCount(modifier_name, caster, target:GetModifierStackCount(modifier_name, caster) + 1)
end

function ChainsModifier( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local hero_time = ability:GetLevelSpecialValueFor("channel_time_hero", ability:GetLevel() - 1)
	local building_time = ability:GetLevelSpecialValueFor("channel_time_building", ability:GetLevel() - 1)

	if IsBuilding(target) == true then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_chains_building", {duration = building_time})
		if target:GetUnitName() == "npc_petri_gold_tower" or
			target:GetUnitName() == "npc_petri_tower_basic" or
			target:GetUnitName() == "npc_petri_tower_of_evil" or
			target:GetUnitName() == "npc_petri_sawmill" or
			target:GetUnitName() == "npc_petri_exploration_tree" then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_chains_silence", {duration = building_time})
		end
		FreezeAnimation(caster, building_time)
	elseif target:IsHero() == true then
		local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length()
		if distance > 425 then
			hero_time = 0.01
		end
		ability:ApplyDataDrivenModifier(caster, target, "modifier_chains", {duration = hero_time})
		FreezeAnimation(caster, hero_time)
	end
end

function ForceRemoveChains( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:RemoveModifierByName("modifier_chains")
	target:RemoveModifierByName("modifier_chains_silence")
	target:RemoveModifierByName("modifier_chains_building")
end

function ForceEndChainsChannel( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target then ability:EndChannel(true) end
end

function ChainsAnimation( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	StartAnimation(caster, {duration=0.4, activity=ACT_DOTA_CAST_ABILITY_1, rate=1.0})
end

function CreateChainsParticle( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local particleName = "particles/miniactor_chains.vpcf"

	ability.particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(ability.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 5, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 6, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 7, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end

function DestroyChainsParticle( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if ability:IsChanneling() == true then
		ability:EndChannel(false)
	end

	UnfreezeAnimation(caster)

	ParticleManager:DestroyParticle(ability.particle, false)
end

function DrinkOnHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:GetUnitName() == "npc_dota_hero_storm_spirit" then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_drink_stun", {duration=2})
	else
		ability:ApplyDataDrivenModifier(caster, target, "modifier_drink", {})
	end

	caster:StopSound("Hero_Alchemist.UnstableConcoction.Fuse")
end

function PullEyes( event )
	local caster = event.caster
	local ability = event.ability
	local level = ability:GetLevel()
	local reveal_radius = ability:GetLevelSpecialValueFor( "reveal_radius", level - 1 )
	local duration = ability:GetChannelTime()

	local particleName = "particles/items_fx/dust_of_appearance.vpcf"
	local target = event.target_points[1]

	ability.target = target

	EmitSoundOnLocationForAllies(target, "DOTA_Item.DustOfAppearance.Activate", caster)

    -- Particle for team
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl( particle, 0, target )
    ParticleManager:SetParticleControl( particle, 1, Vector(reveal_radius,1,reveal_radius) )

   	caster:SetDayTimeVisionRange(0)
	caster:SetNightTimeVisionRange(0)
end

function PullEyesChanneling( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()
	local reveal_radius = ability:GetLevelSpecialValueFor( "reveal_radius", level - 1 )
	local duration = ability:GetChannelTime()

	local exp = ability:GetLevelSpecialValueFor("exp_per_tick", level-1)

	local particleName = "particles/items_fx/dust_of_appearance.vpcf"
	local target = ability.target

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, reveal_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER,false)

	if #units > 5 then
		caster:AddExperience(exp, 0, false, true)
	end

	-- Vision
    AddFOWViewer(caster:GetTeamNumber(), target, reveal_radius, 0.75, false)
end

function StopPullingEyes( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:SetDayTimeVisionRange(1000)
	caster:SetNightTimeVisionRange(1000)
end