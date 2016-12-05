function MiracleHeal(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	if target:GetUnitName() == "npc_petri_exit" or target:GetUnitName() == "npc_petri_earth_wall" then return end

	if target:HasAbility("petri_building") ~= true then
		Notifications:Bottom(caster:GetPlayerOwnerID(), {text="#repair_target_is_not_a_building", duration=1, style={color="red", ["font-size"]="45px"}})
		return
	end
	local healAmount = (target:GetMaxHealth() * 0.3)
	target:Heal(healAmount, caster)
end