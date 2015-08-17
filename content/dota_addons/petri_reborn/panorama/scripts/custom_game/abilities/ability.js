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
	
	$.GetContextPanel().SetHasClass( "no_ability", ( ability == -1 ) );
	$.GetContextPanel().SetHasClass( "learnable_ability", bInLevelUp && canUpgrade );

	RebuildAbilityUI();
	UpdateAbility();
}
function AutoUpdateAbility()
{
	UpdateAbility();
	$.Schedule( 0.1, AutoUpdateAbility );
}

function CheckDependencies()
{
	var abilityName = Abilities.GetAbilityName( m_Ability );
	var abilityLevel = Abilities.GetLevel( m_Ability ); 

	var expr = new RegExp("build");
	if (!expr.test(abilityName))
		abilityName += "_" + abilityLevel;

	var dependencies = GameUI.CustomUIConfig().dependencies[abilityName];
	if (dependencies == undefined)
		return true;

	var flag = true;
	for(var name in dependencies)
	{
		var table = CustomNetTables.GetTableValue("players_dependencies", Players.GetLocalPlayer());
		if (table[name] == undefined)
			return false;

		flag = flag && (table[name] >= dependencies[name]);
	}

	return flag;
}

function CheckSpellCost()
{
	var gold = Players.GetGold( Players.GetLocalPlayer() );

	var currentResources = GameUI.CustomUIConfig().unitResources;
	if (!currentResources)
		currentResources = { "lumber" : 0, "maxFood" : 0, "food" : 0 };

    var abilityLevel = Abilities.GetLevel( m_Ability );
	var manaCost = Abilities.GetManaCost( m_Ability );
    var lumberCost = Abilities.GetLevelSpecialValueFor( m_Ability, "lumber_cost", abilityLevel - 1 );
    var foodCost = Abilities.GetLevelSpecialValueFor( m_Ability, "food_cost", abilityLevel - 1 );
    var goldCost = 0;

    try
    {
	    goldCost = GameUI.CustomUIConfig().goldCosts [ Abilities.GetAbilityName( m_Ability ) ][ String(abilityLevel) ];
    }
    catch( error ) { }

    return !(manaCost > Entities.GetMana( m_QueryUnit ) ||
    	lumberCost > currentResources["lumber"] ||
    	currentResources["maxFood"] < currentResources["food"] + foodCost ||
    	goldCost > gold);
}

function UpdateAbility()
{
	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( m_Ability );

	var noLevel =( 0 == Abilities.GetLevel( m_Ability ) );
	var isCastable = !Abilities.IsPassive( m_Ability ) && !noLevel;
	var manaCost = Abilities.GetManaCost( m_Ability );
	var hotkey = Abilities.GetKeybind( m_Ability, m_QueryUnit );
	var unitMana = Entities.GetMana( m_QueryUnit );

	var abilityLevel = Abilities.GetLevel( m_Ability );
	var lumberCost = Abilities.GetLevelSpecialValueFor( m_Ability, "lumber_cost", abilityLevel - 1 );
    var foodCost = Abilities.GetLevelSpecialValueFor( m_Ability, "food_cost", abilityLevel - 1 );
    var goldCost = 0;

    try
    {
	    goldCost = GameUI.CustomUIConfig().goldCosts [ Abilities.GetAbilityName( m_Ability ) ][ String(abilityLevel) ];
    }
    catch( error ) { }

	$.GetContextPanel().SetHasClass( "no_level", noLevel );
	$.GetContextPanel().SetHasClass( "is_passive", Abilities.IsPassive(m_Ability) );
	
	$.GetContextPanel().SetHasClass( "no_mana_cost", ( 0 == manaCost ) );
	$.GetContextPanel().SetHasClass( "no_food_cost", ( 0 == foodCost ) );
	$.GetContextPanel().SetHasClass( "no_gold_cost", ( 0 == goldCost ) );
	$.GetContextPanel().SetHasClass( "no_lumber_cost", ( 0 == lumberCost ) );

	$.GetContextPanel().SetHasClass( "insufficient_mana", !CheckSpellCost() || !CheckDependencies() );
	$.GetContextPanel().SetHasClass( "auto_cast_enabled", Abilities.GetAutoCastState(m_Ability) );
	$.GetContextPanel().SetHasClass( "toggle_enabled", Abilities.GetToggleState(m_Ability) );
	$.GetContextPanel().SetHasClass( "is_active", ( m_Ability == Abilities.GetLocalPlayerActiveAbility() ) );

	abilityButton.enabled = ( isCastable || m_bInLevelUp );
	
	$( "#HotkeyText" ).text = hotkey;
	$( "#AbilityImage" ).abilityname = abilityName;
	$( "#AbilityImage" ).contextEntityIndex = m_Ability;
	$( "#ManaCost" ).text = manaCost;

	$( "#FoodCost" ).text = foodCost;
	$( "#GoldCost" ).text = goldCost;
	$( "#LumberCost" ).text = lumberCost;

	if ( Abilities.IsCooldownReady( m_Ability ) )
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
		var cooldownPercent = Math.ceil( 100 * cooldownRemaining / cooldownLength );
		$( "#CooldownTimer" ).text = Math.ceil( cooldownRemaining );
		$( "#CooldownOverlay" ).style.width = cooldownPercent+"%";
	}
	
}

function AbilityShowTooltip()
{
	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( m_Ability );
	// If you don't have an entity, you can still show a tooltip that doesn't account for the entity
	//$.DispatchEvent( "DOTAShowAbilityTooltip", abilityButton, abilityName );
	
	// If you have an entity index, this will let the tooltip show the correct level / upgrade information
	//$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", abilityButton, abilityName, m_QueryUnit );

	var tooltip = GameUI.CustomUIConfig().tooltip;
	tooltip.data().ShowTooltip(abilityButton, m_Ability);
}

function AbilityHideTooltip()
{
	var abilityButton = $( "#AbilityButton" );
	//$.DispatchEvent( "DOTAHideAbilityTooltip", abilityButton );

	var tooltip = GameUI.CustomUIConfig().tooltip;
	tooltip.data().HideTooltip();
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

	if (CheckSpellCost() && CheckDependencies())
		Abilities.ExecuteAbility( m_Ability, m_QueryUnit, false );
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
	$.GetContextPanel().data().SetAbility = SetAbility;

	GameEvents.Subscribe( "dota_ability_changed", RebuildAbilityUI ); // major rebuild
	AutoUpdateAbility(); // initial update of dynamic state
})();
