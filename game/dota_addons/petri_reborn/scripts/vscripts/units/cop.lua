function SpawnCop( keys )
	local caster = keys.caster
	local ability = keys.ability

	local hero = GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]

	if not hero.copIsPresent then 
		hero.copIsPresent = true
	else
		return false
	end

	local cop = CreateUnitByName("npc_petri_cop", caster:GetAbsOrigin(), true, nil, GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()], DOTA_TEAM_GOODGUYS)
	cop:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)

	if caster:HasAbility("petri_suicide") == true then
		caster:CastAbilityNoTarget(caster:FindAbilityByName("petri_suicide"), caster:GetPlayerOwnerID())
	end

	cop:SetHasInventory(true)
	cop.spawnPosition = caster:GetAbsOrigin()
end