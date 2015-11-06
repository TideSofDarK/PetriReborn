function OnGreaseHit(keys)
	if keys.target:HasAbility("petri_building") == true and keys.target:HasModifier("modifier_grease_corruption") == false then 
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.target, "modifier_grease_corruption", {})
	end
end