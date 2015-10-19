function OnGreaseHit(keys)
	if keys.target:HasAbility("petri_building") == true then 
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.target, "modifier_grease_corruption", {})
	end
end