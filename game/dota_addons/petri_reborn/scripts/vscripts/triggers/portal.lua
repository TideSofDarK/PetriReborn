function OnStartTouch(trigger)
	if string.match(trigger.caller:GetName(), string.gsub(trigger.activator:GetUnitName(), "npc_dota_hero_", "")) and trigger.activator:GetLevel() >= tonumber(string.match(trigger.caller:GetName(),"%d+")) then
		local newPosition = thisEntity:GetAbsOrigin()

		trigger.activator.currentArea = trigger.caller
		FindClearSpaceForUnit(trigger.activator,newPosition,true)

		trigger.activator:Stop()

		if trigger.activator:IsHero() then MoveCamera(trigger.activator:GetPlayerOwnerID(), trigger.activator) end

		local particleName = "particles/econ/events/nexon_hero_compendium_2014/teleport_end_ground_flash_nexon_hero_cp_2014.vpcf"
		local particle = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	 	ParticleManager:SetParticleControl( particle, 0, trigger.activator:GetAbsOrigin() )
	end
end portal_death_prophet_in_dustzone