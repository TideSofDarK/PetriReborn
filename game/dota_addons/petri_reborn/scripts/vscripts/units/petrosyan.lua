function Sleep(keys)
	local caster = keys.caster
	local target = keys.target

	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local dur = ability:GetLevelSpecialValueFor("sleep_modifier", ability_level)

	ability:ApplyDataDrivenModifier( caster, target, "sleep_modifier", dur)
end

function Return( keys )
	local caster = keys.caster

	caster.teleportationState = 0

	caster:Stop()
    PlayerResource:SetCameraTarget(caster:GetPlayerOwnerID(), caster)

	Timers:CreateTimer(0.1,
    function()
    	local particleName = "particles/econ/events/nexon_hero_compendium_2014/teleport_end_ground_flash_nexon_hero_cp_2014.vpcf"
		local particle = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( particle, 0, caster.spawnPosition )

		PlayerResource:SetCameraTarget(caster:GetPlayerOwnerID(), nil)
    end)

	FindClearSpaceForUnit(caster,caster.spawnPosition,true)
end

function Explore(keys)
	local point = keys.target_points[1]
	local caster = keys.caster

	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local particleName = "particles/units/heroes/hero_rattletrap/clock_loadout_sparks.vpcf"

	local radius = ability:GetLevelSpecialValueFor("aoe_radius", ability_level)

	local particle = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( particle, 0, point )
	point.z = point.z - 90000

	ability:CreateVisibilityNode(point, radius, 6)	
end

function SpawnJanitor( keys )
	local caster = keys.caster

	local janitor = CreateUnitByName("npc_petri_janitor", caster:GetAbsOrigin(), true, nil, caster, DOTA_TEAM_BADGUYS)
	janitor:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
end

function ReadBookOfLaugh( keys )
	local caster = keys.caster
	caster:HeroLevelUp(true)
	caster:HeroLevelUp(false)
	caster:HeroLevelUp(false)
	caster:HeroLevelUp(false)
	caster:HeroLevelUp(false)
end

function ReadComedyStory( keys )
	local caster = keys.caster

	caster:SetBaseDamageMax(caster:GetBaseDamageMax() + 5000)
	caster:SetBaseDamageMin(caster:GetBaseDamageMax())

	caster:CalculateStatBonus()
end

function ReadComedyBook( keys )
	local caster = keys.caster
	
	caster:SetBaseStrength(caster:GetBaseStrength() + 500)

	caster:CalculateStatBonus()
end

function OnAwake( keys )
	if GameRules.firstPetrosyanIsAwake == nil then
		GameRules.firstPetrosyanIsAwake = true
		Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#petrosyan_is_awake", duration=4, style={color="red", ["font-size"]="45px"}})
		print("First petrosyan is awake")
	end
end