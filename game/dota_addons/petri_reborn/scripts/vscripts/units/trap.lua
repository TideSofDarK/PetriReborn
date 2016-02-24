function AddTrap(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	EmitSoundOn("Hero_Techies.StasisTrap.Stun", caster) 

	Timers:CreateTimer(2.1, function ()
		if caster:IsAlive() then
			RemoveInvuModifiers(target)

			ability:ApplyDataDrivenModifier(caster, target, "modifier_techies_stasis_trap_stunned", { duration = 5})
			
			DestroyEntityBasedOnHealth(caster,caster)
		end
	end)
end

function OnAttacked(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	caster:SetHealth(caster:GetHealth()-1)
	print("Asd")

	local stacks = caster:GetModifierStackCount("modifier_evasion_stacks",caster)

	if stacks >= 2 then
		caster:SetModifierStackCount("modifier_evasion_stacks", caster, stacks - 1)
	elseif stacks == 1 then
		caster:RemoveModifierByName("modifier_evasion_stacks")
	end
end

function OnStacksCreated(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	caster:SetModifierStackCount("modifier_evasion_stacks", caster, 3)
end