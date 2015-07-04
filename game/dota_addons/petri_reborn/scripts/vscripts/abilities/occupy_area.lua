function OccupyArea( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	if target:GetUnitLabel() == "area_controller" then
		target:SetTeam(caster_team)
		target:SetOwner(caster)
		target:SetControllableByPlayer(player, true)
	end
end