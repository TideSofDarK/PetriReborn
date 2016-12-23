function SpawnCop( keys )
	local caster = keys.caster
	local ability = keys.ability
	local player = caster:GetPlayerOwnerID()

	if SpendCustomGold( player, GetAbilityGoldCost( ability ) ) == false then
		return
	end

	local hero = GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()]

	if not hero.copIsPresent then 
		hero.copIsPresent = true
	else
		return false
	end

	local cop = CreateUnitByName("npc_petri_cop", caster:GetAbsOrigin(), true, GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()], GameMode.assignedPlayerHeroes[caster:GetPlayerOwnerID()], DOTA_TEAM_GOODGUYS)
	cop:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
	SetCustomBuildingModel(cop, PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID()))

	if caster:HasAbility("petri_suicide") == true then
		caster:CastAbilityNoTarget(caster:FindAbilityByName("petri_suicide"), caster:GetPlayerOwnerID())
	end

	cop:SetHasInventory(true)
	cop.spawnPosition = caster:GetAbsOrigin()
end