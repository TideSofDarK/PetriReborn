"use strict";

var m_Ability = -1;
var m_QueryUnit = -1;
var m_bInLevelUp = false;

var currentResources = {};
var goldCosts;

(function(){Math.clamp=function(a,b,c){return Math.max(b,Math.min(c,a));}})();

function UpdateResources(args)
{
	// Обновляем соседнюю панель
	var resourcesPanel = $.GetContextPanel().GetParent().GetParent()
		.FindChild("TotalResources").FindChild("ResourcePanel");

	currentResources = args;
	resourcesPanel.FindChild("TotalGoldText").text = args["gold"];
	resourcesPanel.FindChild("TotalLumberText").text = args["lumber"];
	resourcesPanel.FindChild("TotalFoodText").text = args["food"] + "/" + String(Math.clamp(parseInt(args["maxFood"]),0,250));
}

function SetAbility( ability, queryUnit, bInLevelUp, costs )
{
	goldCosts = costs;
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

function UpdateCostsPanel()
{
    var abilityLevel = Abilities.GetLevel( m_Ability );
	var manaCost = Abilities.GetManaCost( m_Ability );
    var lumberCost = Abilities.GetLevelSpecialValueFor( m_Ability, "lumber_cost", abilityLevel - 1 );
    var foodCost = Abilities.GetLevelSpecialValueFor( m_Ability, "food_cost", abilityLevel - 1 );
    var goldCost = 0;

    try
    {
	    goldCost = goldCosts[ Abilities.GetAbilityName( m_Ability ) ][ String(abilityLevel) ];
    }
    catch( error ) { }

    var costsPanel = $.GetContextPanel().GetParent().GetParent().FindChild( "AbilityCost" );
    costsPanel.FindChild( "GoldText" ).text = goldCost;
    costsPanel.FindChild( "LumberText" ).text = lumberCost;
    costsPanel.FindChild( "FoodText" ).text = foodCost;
}

function CheckSpellCost()
{
    var abilityLevel = Abilities.GetLevel( m_Ability );
	var manaCost = Abilities.GetManaCost( m_Ability );
    var lumberCost = Abilities.GetLevelSpecialValueFor( m_Ability, "lumber_cost", abilityLevel - 1 );
    var foodCost = Abilities.GetLevelSpecialValueFor( m_Ability, "food_cost", abilityLevel - 1 );
    var goldCost = 0;

    try
    {
	    goldCost = goldCosts[ Abilities.GetAbilityName( m_Ability ) ][ String(abilityLevel) ];
    }
    catch( error ) { }

    return !(manaCost > Entities.GetMana( m_QueryUnit ) ||
    	lumberCost > currentResources["lumber"] ||
    	currentResources["maxFood"] < currentResources["food"] + foodCost ||
    	goldCost > currentResources["gold"]);
}

function UpdateAbility()
{
	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( m_Ability );

	var textureName = Abilities.GetAbilityTextureName( m_Ability );

	var noLevel =( 0 == Abilities.GetLevel( m_Ability ) );
	var isCastable = !Abilities.IsPassive( m_Ability ) && !noLevel;
	var manaCost = Abilities.GetManaCost( m_Ability );
	var hotkey = Abilities.GetKeybind( m_Ability, m_QueryUnit );
	var unitMana = Entities.GetMana( m_QueryUnit );

	$.GetContextPanel().SetHasClass( "no_level", noLevel );
	$.GetContextPanel().SetHasClass( "is_passive", Abilities.IsPassive(m_Ability) );
	$.GetContextPanel().SetHasClass( "no_mana_cost", ( 0 == manaCost ) );
	$.GetContextPanel().SetHasClass( "insufficient_mana", !CheckSpellCost() );
	$.GetContextPanel().SetHasClass( "auto_cast_enabled", Abilities.GetAutoCastState(m_Ability) );
	$.GetContextPanel().SetHasClass( "toggle_enabled", Abilities.GetToggleState(m_Ability) );
	$.GetContextPanel().SetHasClass( "is_active", ( m_Ability == Abilities.GetLocalPlayerActiveAbility() ) );

	abilityButton.enabled = ( isCastable || m_bInLevelUp );
	
	$( "#HotkeyText" ).text = hotkey;
	$( "#AbilityImage" ).abilityname = abilityName;
	$( "#AbilityImage" ).contextEntityIndex = m_Ability;
	$( "#ManaCost" ).text = manaCost;
	
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
	UpdateCostsPanel();

	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( m_Ability );
	// If you don't have an entity, you can still show a tooltip that doesn't account for the entity
	//$.DispatchEvent( "DOTAShowAbilityTooltip", abilityButton, abilityName );
	
	// If you have an entity index, this will let the tooltip show the correct level / upgrade information
	$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", abilityButton, abilityName, m_QueryUnit );
}

function AbilityHideTooltip()
{
	var abilityButton = $( "#AbilityButton" );
	$.DispatchEvent( "DOTAHideAbilityTooltip", abilityButton );
}

function ActivateAbility()
{
	if ( m_bInLevelUp )
	{
		Abilities.AttemptToUpgrade( m_Ability );
		return;
	}

	if (CheckSpellCost())
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
		levelPanel.style["visibility"] = "visible;";
		levelPanel.style["width"] = String(currentLevel / maxLevel * 100) + "%;";
	}
}

(function()
{
	$.GetContextPanel().data().SetAbility = SetAbility;

	GameEvents.Subscribe( "dota_ability_changed", RebuildAbilityUI ); // major rebuild
	AutoUpdateAbility(); // initial update of dynamic state

	GameEvents.Subscribe( "receive_resources_info", UpdateResources);
})();
