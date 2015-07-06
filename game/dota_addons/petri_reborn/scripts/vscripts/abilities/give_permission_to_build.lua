function GivePermissionToBuild( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	if target.currentArea == caster.claimedArea then
		if target.claimedArea == nil then
			target.claimedArea = caster.claimedArea
		end
	end
end