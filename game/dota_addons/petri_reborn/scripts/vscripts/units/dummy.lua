function Spawn ( entityKeyValues  )
	local ability = thisEntity:FindAbilityByName("petri_dummy_invisibility")
	ability:ApplyDataDrivenModifier( thisEntity, thisEntity, "unit_properties", {duration = -1} )
end 