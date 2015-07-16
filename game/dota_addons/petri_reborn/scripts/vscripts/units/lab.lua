function Spawn( keys )
	StartAnimation(thisEntity, {duration=-1, activity=ACT_DOTA_IDLE , rate=2.5})
end

function Upgrade (event)
	local caster = event.caster
	local ability = event.ability
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	local upgrade_level = ability:GetLevel()

	if hero:HasAbility("petri_upgrade_concrete") == false then
		hero:AddAbility("petri_upgrade_concrete")
	end

	local hero_ability = hero:FindAbilityByName("petri_upgrade_concrete")
	hero_ability:SetHidden(true)

	hero_ability:SetLevel(upgrade_level+1)
end