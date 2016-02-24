function Frostbite( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, target, "modifier_vip_frostbite_active", {})
end

function Sunder( event )
	local caster = event.caster
    local target = event.target
    local ability = event.ability

    local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"  
    local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, target )

    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

    local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"  
    local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )

    ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end