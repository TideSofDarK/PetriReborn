function Spawn( keys )
	print("asdsadsa")
	thisEntity:AddAbility("petri_building")
	thisEntity:FindAbilityByName("petri_building"):ApplyDataDrivenModifier(thisEntity, thisEntity, "modifier_disabled_invulnerable", {})
	thisEntity:SetAttackCapability(0)
	InitAbilities(thisEntity)
end