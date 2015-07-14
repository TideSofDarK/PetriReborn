function GivePermissionToBuild( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	if target.currentArea == caster.claimedArea then
		if target.claimedArea == nil then
			target.claimedArea = caster.claimedArea
		end
	end
end

function Blink(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)	
end

function CloseAllMenus(entity)
	local keys = {}
	keys.caster = entity
	if entity.currentMenu == 1 then
		CloseBasicBuildingsMenu(keys)
	elseif entity.currentMenu == 2 then
		CloseAdvancedBuildingsMenu(keys)
	end
end

function OpenBasicBuildingsMenu(keys)
	local caster = keys.caster

	local lumberAbility = "gather_lumber"
	if caster:HasModifier("modifier_gathering_lumber") or caster:HasModifier("modifier_returning_resources") then lumberAbility = "return_resources" end

	caster.currentMenu = 1

	caster:AddAbility("build_petri_tent")
	caster:AddAbility("build_petri_sawmill")
	caster:AddAbility("build_petri_tower_basic")
	caster:AddAbility("petri_close_basic_buildings_menu")

	InitAbilities(caster)

	caster:SwapAbilities("petri_open_basic_buildings_menu", "build_petri_tent", false, true)
	caster:SwapAbilities("petri_open_advanced_buildings_menu", "build_petri_sawmill", false, true)
	caster:SwapAbilities(lumberAbility, "build_petri_tower_basic", false, true)
	--caster:SwapAbilities("petri_repair", "petri_empty1", false, true)
	--caster:SwapAbilities("petri_empty2", "petri_empty2", false, true)
	caster:SwapAbilities("petri_repair", "petri_close_basic_buildings_menu", false, true)
end

function OpenAdvancedBuildingsMenu(keys)
	local caster = keys.caster

	local lumberAbility = "gather_lumber"
	if caster:HasModifier("modifier_gathering_lumber") or caster:HasModifier("modifier_returning_resources") then lumberAbility = "return_resources" end

	caster.currentMenu = 2

	caster:AddAbility("build_petri_gold_tower")
	caster:AddAbility("build_petri_exploration_tree")
	caster:AddAbility("petri_empty4")
	caster:AddAbility("petri_close_advanced_buildings_menu")

	InitAbilities(caster)

	caster:SwapAbilities("petri_open_basic_buildings_menu", "build_petri_gold_tower", false, true)
	caster:SwapAbilities("petri_open_advanced_buildings_menu", "build_petri_exploration_tree", false, true)
	caster:SwapAbilities(lumberAbility, "petri_empty4", false, true)
	--caster:SwapAbilities("petri_empty1", "petri_empty1", false, true)
	--caster:SwapAbilities("petri_empty2", "petri_empty2", false, true)
	caster:SwapAbilities("petri_repair", "petri_close_advanced_buildings_menu", false, true)
end

function CloseBasicBuildingsMenu(keys)
	local caster = keys.caster

	local lumberAbility = "gather_lumber"
	if caster:HasModifier("modifier_gathering_lumber") or caster:HasModifier("modifier_returning_resources") then lumberAbility = "return_resources" end

	caster.currentMenu = 0

	caster:SwapAbilities("petri_open_basic_buildings_menu", "build_petri_tent", true, false)
	caster:SwapAbilities("petri_open_advanced_buildings_menu", "build_petri_sawmill",true, false)
	caster:SwapAbilities(lumberAbility, "build_petri_tower_basic", true, false)
	--caster:SwapAbilities("petri_empty1", "petri_empty1", false, true)
	--caster:SwapAbilities("petri_empty2", "petri_empty2", false, true)
	caster:SwapAbilities("petri_repair", "petri_close_basic_buildings_menu", true, false)

	caster:RemoveAbility("build_petri_tent")
	caster:RemoveAbility("build_petri_sawmill")
	caster:RemoveAbility("build_petri_tower_basic")
	caster:RemoveAbility("petri_close_basic_buildings_menu")
end

function CloseAdvancedBuildingsMenu(keys)
	local caster = keys.caster

	local lumberAbility = "gather_lumber"
	if caster:HasModifier("modifier_gathering_lumber") or caster:HasModifier("modifier_returning_resources") then lumberAbility = "return_resources" end

	caster.currentMenu = 0

	caster:SwapAbilities("petri_open_basic_buildings_menu", "build_petri_gold_tower", true, false)
	caster:SwapAbilities("petri_open_advanced_buildings_menu", "build_petri_exploration_tree", true, false)
	caster:SwapAbilities(lumberAbility, "petri_empty4", true, false)
	--caster:SwapAbilities("petri_empty1", "petri_empty1", false, true)
	--caster:SwapAbilities("petri_empty2", "petri_empty2", false, true)
	caster:SwapAbilities("petri_repair", "petri_close_advanced_buildings_menu", true, false)

	caster:RemoveAbility("build_petri_gold_tower")
	caster:RemoveAbility("build_petri_exploration_tree")
	caster:RemoveAbility("petri_empty4")
	caster:RemoveAbility("petri_close_advanced_buildings_menu")
end