-- The following three functions are necessary for building helper.

function build( keys )
	local player = keys.caster:GetPlayerOwner()
	local pID = player:GetPlayerID()

	-- Check if player has enough resources here. If he doesn't they just return this function.
	
	local returnTable = BuildingHelper:AddBuilding(keys)

	keys:OnBuildingPosChosen(function(vPos)
		--print("OnBuildingPosChosen")
		-- in WC3 some build sound was played here.
	end)

	keys:OnConstructionStarted(function(unit)
		if Debug_BH then
			print("Started construction of " .. unit:GetUnitName())
		end
		-- Unit is the building be built.
		-- Play construction sound
		-- FindClearSpace for the builder
		FindClearSpaceForUnit(keys.caster, keys.caster:GetAbsOrigin(), true)
		-- start the building with 0 mana.
		unit:SetMana(0)
	end)
	keys:OnConstructionCompleted(function(unit)
		if Debug_BH then
			print("Completed construction of " .. unit:GetUnitName())
		end
		-- Play construction complete sound.
		-- Give building its abilities
		-- add the mana
		unit:SetMana(unit:GetMaxMana())

		-- You can build only on claimed area
		if keys.caster.currentArea ~= nil then
			if keys.caster.currentArea ~= keys.caster.claimedArea then
				if keys.caster.currentArea.claimers == nil then
					keys.caster.currentArea.claimers = {}
					keys.caster.currentArea.claimers[0] = keys.caster

					keys.caster.claimedArea = keys.caster.currentArea

					--[[
					area_controlllers  = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, keys.caster.currentArea:GetOrigin(),nil,
						700,DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	                              FIND_ANY_ORDER,
	                              false)

					for k, v in pairs( area_controlllers ) do
					   v:SetTeam(keys.caster:GetTeamNumber())
						v:SetOwner(keys.caster)
						v:SetControllableByPlayer(pID, true)
						break
					end
					--]]

					Notifications:Top(pID, {text="This area is now yours", duration=4, style={color="white"}, continue=true})
				elseif keys.caster.currentArea.claimers[0] ~= keys.caster
					or keys.caster.currentArea.claimers[1] ~= keys.caster then

					Notifications:Top(pID, {text="You are not allowed to build here", duration=4, style={color="white"}, continue=true})
					
					-- Destroy unit
					if BuildingHelper:IsBuilding(unit) then
					    unit:RemoveBuilding(false)
					end
					UTIL_Remove(unit)
				end
			end
		end
	end)

	-- These callbacks will only fire when the state between below half health/above half health changes.
	-- i.e. it won't unnecessarily fire multiple times.
	keys:OnBelowHalfHealth(function(unit)
		if Debug_BH then
			print(unit:GetUnitName() .. " is below half health.")
		end
	end)

	keys:OnAboveHalfHealth(function(unit)
		if Debug_BH then
			print(unit:GetUnitName() .. " is above half health.")
		end
	end)

	keys:OnConstructionFailed(function( building )
		-- This runs when a building cannot be placed, you should refund resources if any. building is the unit that would've been built.
		FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "Building cannot be placed there!" } )
	end)

	keys:OnConstructionCancelled(function( building )
		-- This runs when a building is cancelled, building is the unit that would've been built.
	end)

	-- Have a fire effect when the building goes below 50% health.
	-- It will turn off it building goes above 50% health again.
	keys:EnableFireEffect("modifier_jakiro_liquid_fire_burn")
end

function building_canceled( keys )
	BuildingHelper:CancelBuilding(keys)
end

function create_building_entity( keys )
	BuildingHelper:InitializeBuildingEntity(keys)
end

function builder_queue( keys )
	local ability = keys.ability
  local caster = keys.caster  

  if caster.ProcessingBuilding ~= nil then
    -- caster is probably a builder, stop them
    player = PlayerResource:GetPlayer(caster:GetMainControllingPlayer())
    player.activeBuilder:ClearQueue()
    player.activeBuilding = nil
    player.activeBuilder:Stop()
    player.activeBuilder.ProcessingBuilding = false
  end
end