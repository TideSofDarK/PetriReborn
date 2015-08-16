function Spawn( keys )
end

function TransferItems( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:MoveToPosition(caster.spawnPosition)

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_on_order_cancel", {})

	Timers:CreateTimer(0, function ()
	if caster:FindModifierByName("modifier_on_order_cancel") then
		local distance = (caster.spawnPosition - caster:GetAbsOrigin()):Length()
		if distance < 8 then
			caster:CastAbilityNoTarget(caster:FindAbilityByName("petri_janitor_take_items_from_stash"), caster:GetPlayerOwnerID())
		else
			return 0.5
		end
	end
	end)
end

function CancelTransferItems( keys )
	local caster = keys.caster
	caster:Stop()

	caster:RemoveModifierByName("modifier_on_order_cancel")
end

function TakeItemsFromStash( keys )
	local caster = keys.caster

	local hero = caster:GetOwner()

	if Entities:FindByName(nil,"PetrosyanShopTrigger"):IsTouching(caster) == false then
		return false
	end

	for i=6,11 do
		local item = hero:GetItemInSlot(i)
		if item then
			caster:AddItemByName(item:GetName())
			hero:RemoveItem(item)
		end
	end

	caster:MoveToNPC(hero)

	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_on_order_cancel", {})

	Timers:CreateTimer(0, function ()
		if caster:FindModifierByName("modifier_on_order_cancel") then
			local distance = (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length()
			if distance < 195 then
				for i=0,5 do
					local item = caster:GetItemInSlot(i)

					if item and hero:HasAnyAvailableInventorySpace() then
						hero:AddItemByName(item:GetName())
						caster:RemoveItem(item)
					end
				end

				caster:RemoveModifierByName("modifier_on_order_cancel")
				caster:Stop()
			else
				return 0.5
			end
		end
	end)
end