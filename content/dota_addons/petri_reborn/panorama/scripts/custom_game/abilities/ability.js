"use strict";

var m_Ability = -1;
var m_QueryUnit = -1;
var m_bInLevelUp = false;

var goldCosts;

function SetAbility( ability, queryUnit, bInLevelUp )
{
	goldCosts = GameUI.CustomUIConfig().goldCosts;
	var bChanged = ( ability !== m_Ability || queryUnit !== m_QueryUnit );
	m_Ability = ability;
	m_QueryUnit = queryUnit;
	m_bInLevelUp = bInLevelUp;
	
	var canUpgradeRet = Abilities.CanAbilityBeUpgraded( m_Ability );
	var canUpgrade = ( canUpgradeRet == AbilityLearnResult_t.ABILITY_CAN_BE_UPGRADED );
	
	$.GetContextPanel().ability = ability;
	$.GetContextPanel().SetHasClass( "no_ability", ( ability == -1 ) );
	// $.GetContextPanel().SetHasClass( "learnable_ability", bInLevelUp && canUpgrade );

	RebuildAbilityUI();
	UpdateAbility();
}
function AutoUpdateAbility()
{
	UpdateAbility();
	$.Schedule( 0.1, AutoUpdateAbility );
}

function CheckDependenciesList( abilityName, isAlt )
{
	var dependenciesTable = GameUI.CustomUIConfig().dependencies;
	// Priority of main dependence
  	if (!dependenciesTable)
		return true && !isAlt;
	
	var dependencies = dependenciesTable[abilityName];
	if (dependencies == undefined)
		return true && !isAlt;

	var flag = true;
	for(var name in dependencies)
	{
		var table = CustomNetTables.GetTableValue("players_dependencies", Players.GetLocalPlayer());
		if (table == undefined)
			return false;

		if (table[name] == undefined)
			return false;

		flag = flag && (table[name] >= dependencies[name]);
	}

	return flag;
}

function CheckDependencies()
{
	var abilityName = Abilities.GetAbilityName( m_Ability );
	var abilityLevel = Abilities.GetLevel( m_Ability ); 

	var expr = new RegExp("build");
	if (!expr.test(abilityName))
		abilityName += "_" + abilityLevel;

	// Main or alt dependencies list
	return CheckDependenciesList( abilityName, false ) || CheckDependenciesList( abilityName + "_alt", true )
}

function CheckSpellCost()
{
	var isEnemy = GameUI.CustomUIConfig().IsEnemySelected();
 
	var curRes = CustomNetTables.GetTableValue("players_resources", GameUI.CustomUIConfig().GetSelectedUnitOwner());
	if (curRes == undefined || isEnemy)
		curRes = { "lumber": 0, "food": 0, "gold": 0, "maxFood": 0 };

	if (!curRes)
		curRes = { "lumber" : 0, "maxFood" : 0, "food" : 0 };

    var abilityLevel = Abilities.GetLevel( m_Ability );
	var manaCost = Abilities.GetManaCost( m_Ability );
    var lumberCost = Abilities.GetLevelSpecialValueFor( m_Ability, "lumber_cost", abilityLevel - 1 );
    var foodCost = Abilities.GetLevelSpecialValueFor( m_Ability, "food_cost", abilityLevel - 1 );
    var isActivated =  	Abilities.IsActivated( m_Ability );
    var goldCost = 0;

    try
    {
	    goldCost = GameUI.CustomUIConfig().goldCosts [ Abilities.GetAbilityName( m_Ability ) ][ String(abilityLevel) ];
    }
    catch( error ) { }

    return !isActivated || !(manaCost > Entities.GetMana( m_QueryUnit ) ||
    	lumberCost > curRes["lumber"] ||
    	(foodCost != 0 && curRes["maxFood"] < curRes["food"] + foodCost) ||
    	goldCost > curRes["gold"]);
}

function UpdateAbility()
{
	var isEnemy = GameUI.CustomUIConfig().IsEnemySelected();
	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( m_Ability );

	var noLevel =( 0 == Abilities.GetLevel( m_Ability ) );
	var isCastable = !Abilities.IsPassive( m_Ability ) && !noLevel;
	var manaCost = Abilities.GetManaCost( m_Ability );
	var unitMana = Entities.GetMana( m_QueryUnit );

	var abilityLevel = Abilities.GetLevel( m_Ability );
	var lumberCost = Abilities.GetLevelSpecialValueFor( m_Ability, "lumber_cost", abilityLevel - 1 );
    var foodCost = Abilities.GetLevelSpecialValueFor( m_Ability, "food_cost", abilityLevel - 1 );
    var goldCost = 0;

    var isActivated = Abilities.IsActivated( m_Ability );

    try
    {
	    goldCost = GameUI.CustomUIConfig().goldCosts [ Abilities.GetAbilityName( m_Ability ) ][ String(abilityLevel) ];
    }
    catch( error ) { }
    // 
    var shared = Abilities.GetAbilityName(m_Ability) == "petri_exploration_tower_explore_world";

	$.GetContextPanel().SetHasClass( "no_level", noLevel || isEnemy );
	$.GetContextPanel().SetHasClass( "is_passive", Abilities.IsPassive(m_Ability) || isActivated == false);
	
	$.GetContextPanel().SetHasClass( "no_mana_cost", ( 0 == manaCost || manaCost == undefined || isActivated == false || isEnemy) );
	$.GetContextPanel().SetHasClass( "no_food_cost", ( 0 == foodCost || foodCost == undefined || isActivated == false || isEnemy) );
	$.GetContextPanel().SetHasClass( "no_gold_cost_c", ( 0 == goldCost || goldCost == undefined || isActivated == false || isEnemy) );
	$.GetContextPanel().SetHasClass( "no_lumber_cost", ( 0 == lumberCost || isActivated == false || isEnemy) );
	// $.Msg(Abilities.GetAbilityName( m_Ability ), $.GetContextPanel().BHasClass("no_gold_cost"));
	$.GetContextPanel().SetHasClass( "insufficient_mana", (!CheckSpellCost() || !CheckDependencies() || isActivated == false) && !isEnemy && !shared );
	$.GetContextPanel().SetHasClass( "auto_cast_enabled", Abilities.GetAutoCastState(m_Ability) );
	$.GetContextPanel().SetHasClass( "toggle_enabled", Abilities.GetToggleState(m_Ability) );
	$.GetContextPanel().SetHasClass( "is_active", ( m_Ability == Abilities.GetLocalPlayerActiveAbility()  ) );

	abilityButton.enabled = ( isCastable || m_bInLevelUp || shared);

	$( "#HotkeyText" ).text = Abilities.GetKeybind( m_Ability, m_QueryUnit );
	$( "#AbilityImage" ).abilityname = abilityName;
	$( "#AbilityImage" ).contextEntityIndex = m_Ability;

	$( "#ManaCost" ).text = manaCost;
	$( "#FoodCost" ).text = foodCost;
	$( "#GoldCost" ).text = goldCost;
	$( "#LumberCost" ).text = lumberCost;

	if ( Abilities.IsCooldownReady( m_Ability ) || isEnemy)
	{
		$.GetContextPanel().SetHasClass( "cooldown_ready", true );
		$.GetContextPanel().SetHasClass( "in_cooldown", false );
	}
	else
	{
		$.GetContextPanel().SetHasClass( "cooldown_ready", false );
		$.GetContextPanel().SetHasClass( "in_cooldown", true );
		var cooldownLength = Abilities.GetCooldownLength( m_Ability );
		var cooldownRemaining = Abilities.GetCooldownTimeRemaining( m_Ability );
		var cooldownPercent = cooldownRemaining / cooldownLength;
		$( "#CooldownTimer" ).text = "";
		// $( "#CooldownOverlay" ).style.clip = "radial(50% 50%, 0deg, " + cooldownPercent * -360 + "deg)";
	}
}

function AbilityShowTooltip(ab)
{
	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( ab );
	// If you don't have an entity, you can still show a tooltip that doesn't account for the entity
	//$.DispatchEvent( "DOTAShowAbilityTooltip", abilityButton, abilityName );
	
	// If you have an entity index, this will let the tooltip show the correct level / upgrade information
	//$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", abilityButton, abilityName, m_QueryUnit );

	var tooltip = GameUI.CustomUIConfig().tooltip;
	tooltip.ShowTooltip(abilityButton, ab);
}

function AbilityHideTooltip()
{
	var abilityButton = $( "#AbilityButton" );
	//$.DispatchEvent( "DOTAHideAbilityTooltip", abilityButton );

	var tooltip = GameUI.CustomUIConfig().tooltip;
	tooltip.HideTooltip();
}

function GetAbilityOrder( abilityID )
{
	var order = {
		OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex : abilityID,
		OrderIssuer : PlayerOrderIssuer_t.DOTA_ORDER_ISSUER_SELECTED_UNITS,
	};

	return order;
}

function ActivateAbility()
{
	if ( m_bInLevelUp )
	{
		Abilities.AttemptToUpgrade( m_Ability );
		return;
	}
	if (Abilities.GetAbilityName(m_Ability) == "petri_exploration_tower_explore_world") 
	{
		Game.PrepareUnitOrders( { OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_CAST_NO_TARGET, AbilityIndex: Entities.GetAbilityByName( Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ), Abilities.GetAbilityName(m_Ability) ), TargetIndex: Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ) } );
	}
	else if (CheckSpellCost() && CheckDependencies()) 
	{
		Abilities.ExecuteAbility( m_Ability, m_QueryUnit, false );
	}
}

function DoubleClickAbility()
{
	// Handle double-click like a normal click - ExecuteAbility will either double-tap (self cast) or normal toggle as appropriate
	ActivateAbility();
}

function RightClickAbility()
{
	if ( m_bInLevelUp )
		return;

	if ( Abilities.IsAutocast( m_Ability ) )
	{
		Game.PrepareUnitOrders( { OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO, AbilityIndex: m_Ability } );
	}
}

function RebuildAbilityUI()
{
	var abilityLevelContainer = $( "#AbilityLevelContainer" );
	abilityLevelContainer.RemoveAndDeleteChildren();

	var abilityMaxLevelContainer = $( "#AbilityMaxLevelContainer" );
	abilityMaxLevelContainer.style["visibility"] = "collapse;";

	var levelLabel = $( "#CurrentLevel" );
	levelLabel.style["visibility"] = "collapse;";

	var currentLevel = Abilities.GetLevel( m_Ability );
	var maxLevel = Abilities.GetMaxLevel( m_Ability );

	if (GameUI.CustomUIConfig().IsEnemySelected())
		return;

	if (maxLevel > 1)
	{
		abilityMaxLevelContainer.style["visibility"] = "visible;";
		var levelLabel = $( "#CurrentLevel" );
		levelLabel.style["visibility"] = "visible;";
		levelLabel.text = currentLevel;

		var levelPanel = $.CreatePanel( "Panel", abilityLevelContainer, "" );		
		levelPanel.AddClass( "LevelPanel" );
		levelPanel.SetHasClass( "active_level", true );
		levelPanel.style.visibility = "visible;";
		levelPanel.style.width = String(currentLevel / maxLevel * 100) + "%;";
	}
}


(function()
{
	$.GetContextPanel().SetAbility = SetAbility;
	$.GetContextPanel().AbilityShowTooltip = AbilityShowTooltip;
	$.GetContextPanel().AbilityHideTooltip = AbilityHideTooltip;

	GameEvents.Subscribe( "dota_ability_changed", RebuildAbilityUI ); // major rebuild
	AutoUpdateAbility(); // initial update of dynamic state
})();
