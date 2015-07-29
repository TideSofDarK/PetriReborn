NO_MENU = 0
BASIC_MENU = 1
ADVANCED_MENU = 2

NO_MENU_ABILITIES = {"petri_open_basic_buildings_menu",
					 "petri_open_advanced_buildings_menu",
					 "gather_lumber",
					 "petri_repair",
					 "petri_kvn_fan_deny",
					 "petri_empty1",
					 "return_resources"}
BASIC_MENU_ABILITIES = {"build_petri_tent",
						"build_petri_sawmill",
						"build_petri_lab",
						"build_petri_wall",
						"build_petri_tower_basic",
						"petri_close_basic_buildings_menu"}
ADVANCED_MENU_ABILITIES = {	"build_petri_gold_tower",
							"build_petri_idol",
							"build_petri_tower_of_evil",
							"build_petri_exploration_tree",
							"build_petri_exit",
							"petri_close_advanced_buildings_menu"}

function Spawn( event )
	for i=0, thisEntity:GetAbilityCount()-1 do
		if thisEntity:GetAbilityByIndex(i) ~= nil then
			thisEntity:RemoveAbility(thisEntity:GetAbilityByIndex(i):GetName())
		end
    end

	for i=1, table.getn(NO_MENU_ABILITIES) do
		thisEntity:AddAbility(NO_MENU_ABILITIES[i])
    end

	InitAbilities(thisEntity)
end

function SpawnTrap(keys)
	local point = keys.target_points[1]
	local caster = keys.caster

	local trap = CreateUnitByName("npc_petri_trap", point,  true, nil, caster, caster:GetTeam())

	InitAbilities(trap)
	trap:AddNewModifier(trap, nil, "modifier_kill", {duration = 240})
	StartAnimation(trap, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})
end

function GivePermissionToBuild( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability

	if CheckAreaClaimers(target, caster.currentArea.claimers) == true then return false end

	if caster.currentArea ~= nil and caster.currentArea.claimers ~= nil then
		if target.currentArea == caster.currentArea then
			if caster.currentArea.claimers[0] == caster then
				caster.currentArea.claimers[#caster.currentArea.claimers + 1] = target
			end
		end
	end
end

function Blink(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)	
end

function GetLumberAbilityName(caster)
	local lumberAbility = "gather_lumber"
	if caster.currentMenu == 0 then
		if caster:FindAbilityByName("gather_lumber"):IsHidden() then
			lumberAbility = "return_resources"
		end
	else
		if caster:HasModifier("modifier_returning_resources") then lumberAbility = "return_resources" end
	end
	return lumberAbility
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

	for i=1, table.getn(BASIC_MENU_ABILITIES) do
		caster:AddAbility(BASIC_MENU_ABILITIES[i])
    end

	InitAbilities(caster)

	for i=1, table.getn(BASIC_MENU_ABILITIES) do
		if NO_MENU_ABILITIES[i] == "gather_lumber" then
			caster:SwapAbilities(GetLumberAbilityName(caster), BASIC_MENU_ABILITIES[i], false, true)
		else
			caster:SwapAbilities(NO_MENU_ABILITIES[i], BASIC_MENU_ABILITIES[i], false, true)
		end
    end

    caster.currentMenu = 1
end

function CloseBasicBuildingsMenu(keys)
	local caster = keys.caster

	local lumberAbility = GetLumberAbilityName(caster)

	for i=1, table.getn(BASIC_MENU_ABILITIES) do
		if NO_MENU_ABILITIES[i] == "gather_lumber" then
			caster:SwapAbilities(GetLumberAbilityName(caster), BASIC_MENU_ABILITIES[i], true, false)
		else
			caster:SwapAbilities(NO_MENU_ABILITIES[i], BASIC_MENU_ABILITIES[i], true, false)
		end
    end

	for i=1, table.getn(BASIC_MENU_ABILITIES) do
		caster:RemoveAbility(BASIC_MENU_ABILITIES[i])
    end

    caster.currentMenu = 0
end

function OpenAdvancedBuildingsMenu(keys)
	local caster = keys.caster

	for i=1, table.getn(ADVANCED_MENU_ABILITIES) do
		caster:AddAbility(ADVANCED_MENU_ABILITIES[i])
    end

	InitAbilities(caster)

    for i=1, table.getn(ADVANCED_MENU_ABILITIES) do
		if NO_MENU_ABILITIES[i] == "gather_lumber" then
			caster:SwapAbilities(GetLumberAbilityName(caster), ADVANCED_MENU_ABILITIES[i], false, true)
		else
			caster:SwapAbilities(NO_MENU_ABILITIES[i], ADVANCED_MENU_ABILITIES[i], false, true)
		end
    end

    caster.currentMenu = 2
end

function CloseAdvancedBuildingsMenu(keys)
	local caster = keys.caster

	local lumberAbility = GetLumberAbilityName(caster)

	for i=1, table.getn(ADVANCED_MENU_ABILITIES) do
		if NO_MENU_ABILITIES[i] == "gather_lumber" then
			caster:SwapAbilities(GetLumberAbilityName(caster), ADVANCED_MENU_ABILITIES[i], true, false)
		else
			caster:SwapAbilities(NO_MENU_ABILITIES[i], ADVANCED_MENU_ABILITIES[i], true, false)
		end
    end

	for i=1, table.getn(ADVANCED_MENU_ABILITIES) do
		caster:RemoveAbility(ADVANCED_MENU_ABILITIES[i])
    end

    caster.currentMenu = 0
end

function SpawnGoldBag( keys )
	local caster = keys.caster

	local bag = CreateUnitByName("npc_petri_gold_bag", caster:GetAbsOrigin(), true, nil, caster, DOTA_TEAM_GOODGUYS)
	bag:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
	bag.spawnPosition = caster:GetAbsOrigin()
end

function Deny(keys)
	local caster = keys.caster
	local target = keys.target

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = target:GetMaxHealth(),
		damage_type = DAMAGE_TYPE_PURE,
	}
 
	if target:HasAbility("petri_building") == true and target:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
		ApplyDamage(damageTable)
	end
end