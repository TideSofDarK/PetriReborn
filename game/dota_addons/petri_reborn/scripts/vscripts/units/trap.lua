function AddTrap(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	Timers:CreateTimer(2.1, function ()
		if caster:IsAlive() then
			for i=0,target:GetModifierCount() do
				local modifierName = target:GetModifierNameByIndex(i)
				target:RemoveModifierByName(modifierName)
			end

			ability:ApplyDataDrivenModifier(caster, target, "modifier_techies_stasis_trap_stunned", { duration = 5})
			DestroyEntityBasedOnHealth(caster,caster)
		end
	end)
end