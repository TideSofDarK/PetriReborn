function ExploreWorld(keys)
	local caster = keys.caster
	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	if SpendCustomGold( player, GetAbilityGoldCost( ability ) ) == false then
		return
	end

	GameMode.explorationTower:FindAbilityByName(ability:GetName()):StartCooldown(ability:GetCooldown(-1))

	-- Just because i can
	for x=1,8,1 do
		for y=1,8,1 do
			local position = Vector((x*1800)-8000,(y*1800)-8000,3000)
			AddFOWViewer(caster_team, position,5000, 10, false)
		end
	end
	for x=1,8,1 do
		for y=1,8,1 do
			local position = Vector((x*1800)-16000,(y*1800)-16000,3000)
			AddFOWViewer(caster_team, position,5000, 10, false)
		end
	end
		for x=1,8,1 do
		for y=1,8,1 do
			local position = Vector((x*1800)-16000,(y*1800),3000)
			AddFOWViewer(caster_team, position,5000, 10, false)
		end
	end
		for x=1,8,1 do
		for y=1,8,1 do
			local position = Vector((x*1800),(y*1800)-16000,3000)
			AddFOWViewer(caster_team, position,5000, 10, false)
		end
	end
		for x=1,8,1 do
		for y=1,8,1 do
			local position = Vector((x*1800),(y*1800),3000)
			AddFOWViewer(caster_team, position,5000, 10, false)
		end
	end


	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#sputnik_launched", duration=4, style={color="red", ["font-size"]="40px"}})
end