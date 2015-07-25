function Upgrade (event)
	local caster = event.caster
	local ability = event.ability

	ability:SetHidden(false)

	local wall_level = ability:GetLevel()

	UpdateAttributes(caster, wall_level, ability)

	if wall_level == 1 then
		caster:SetOriginalModel(GetModelNameForLevel(1))
		caster:SetModel(GetModelNameForLevel(1))
		caster:SetModelScale(3.35)
	elseif wall_level == 2 then 
		caster:SetOriginalModel(GetModelNameForLevel(2))
		caster:SetModel(GetModelNameForLevel(2))
		caster:SetModelScale(0.8)
	elseif wall_level == 3 then
		caster:SetOriginalModel(GetModelNameForLevel(3))
		caster:SetModel(GetModelNameForLevel(3))
		caster:SetModelScale(2.4)
	elseif wall_level == 4 then
		caster:SetOriginalModel(GetModelNameForLevel(4))
		caster:SetModel(GetModelNameForLevel(4))
		caster:SetModelScale(4.3)
	elseif wall_level == 5 then
		caster:SetOriginalModel(GetModelNameForLevel(5))
		caster:SetModel(GetModelNameForLevel(5))
		caster:SetModelScale(3.0)
	elseif wall_level == 6 then
		caster:SetOriginalModel(GetModelNameForLevel(6))
		caster:SetModel(GetModelNameForLevel(6))
		caster:SetModelScale(1.2)

		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})
	elseif wall_level == 7 then
		caster:SetOriginalModel(GetModelNameForLevel(7))
		caster:SetModel(GetModelNameForLevel(7))
		caster:SetModelScale(1.2)

		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})
	elseif wall_level == 8 then
		caster:SetOriginalModel(GetModelNameForLevel(8))
		caster:SetModel(GetModelNameForLevel(8))
		caster:SetModelScale(1.3)

		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})
	elseif wall_level == 9 then
		caster:SetOriginalModel(GetModelNameForLevel(9))
		caster:SetModel(GetModelNameForLevel(9))
		caster:SetModelScale(1.3)

		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_IDLE , rate=1.5})
	end
end

function UpdateAttributes(wall, level, ability)
	local newHealth = ability:GetLevelSpecialValueFor("health_points", level - 1)
	local newArmor = ability:GetLevelSpecialValueFor("armor", level - 1)

	local fullHP = wall:GetHealth() == wall:GetMaxHealth()

	wall:SetBaseMaxHealth(newHealth)

	if fullHP then
		wall:SetHealth(newHealth)
	end

	wall:RemoveModifierByName("modifier_armor")
	ability:ApplyDataDrivenModifier(wall, wall, "modifier_armor", {})
	wall:SetModifierStackCount("modifier_armor", wall, newArmor)
end

function GetModelNameForLevel(level)
	if level == 1 then
		return "models/items/rattletrap/forge_warrior_rocket_cannon/forge_warrior_rocket_cannon.vmdl"
	elseif level == 2 then 
		return "models/props_rock/riveredge_rock008a.vmdl"
	elseif level == 3 then
		return "models/props_magic/bad_crystals002.vmdl"
	elseif level == 4 then
		return "models/heroes/oracle/crystal_ball.vmdl"
	elseif level == 5 then
		return "models/props_items/bloodstone.vmdl"
	elseif level == 6 then
		return "models/creeps/neutral_creeps/n_creep_golem_a/neutral_creep_golem_a.vmdl"
	elseif level == 7 then
		return "models/heroes/undying/undying_flesh_golem.vmdl"
	elseif level == 8 then
		return "models/items/warlock/golem/obsidian_golem/obsidian_golem.vmdl"
	elseif level == 9 then
		return "models/items/terrorblade/dotapit_s3_fallen_light_metamorphosis/dotapit_s3_fallen_light_metamorphosis.vmdl"
	end
end

function Notification(keys)
	local caster = keys.caster
	local origin = caster:GetAbsOrigin()
	caster.lastWallIsUnderAttackNotification = caster.lastWallIsUnderAttackNotification or 0

	if GameRules:GetGameTime() - caster.lastWallIsUnderAttackNotification > 15.0 then
		EmitSoundOnClient("General.PingDefense", caster:GetPlayerOwner())
		caster.lastWallIsUnderAttackNotification = GameRules:GetGameTime()
	end

	caster.lastWallIsUnderAttackNotification = caster.lastWallIsUnderAttackNotification or 0
	
	MinimapEvent(DOTA_TEAM_GOODGUYS, caster, origin.x, origin.y, DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, 1 )
end