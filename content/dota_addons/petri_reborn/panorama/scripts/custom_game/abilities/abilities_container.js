"use strict";

var m_AbilityPanels = []; // created up to a high-water mark, but reused when selection changes
var m_QueryUnit = -1;

function UpdateAbilitiesContainer()
{
	var queryUnit = GameUI.CustomUIConfig().selected_unit;
	var abilityListPanel = $( "#AbilityList" );
	if ( !abilityListPanel )
		return;


	// Прячем панель скиллов
	abilityListPanel.style["visibility"] = "collapse";

	var bSameUnit = ( m_QueryUnit == queryUnit );
	m_QueryUnit = queryUnit;

	// see if we can level up
	var nRemainingPoints = Entities.GetAbilityPoints( queryUnit );
	var bPointsToSpend = ( nRemainingPoints > 0 );
	var bControlsUnit = Entities.IsControllableByPlayer( queryUnit, Game.GetLocalPlayerID() );
	$.GetContextPanel().SetHasClass( "could_level_up", ( bControlsUnit && bPointsToSpend ) );

	if ( !bPointsToSpend )
		Game.EndAbilityLearnMode();

	// update all the panels
	var nUsedPanels = 0;
	for ( var i = 0; i < Entities.GetAbilityCount( m_QueryUnit ); ++i )
	{
		// Костыль на количество отображаемых скиллов
		if ( i > 5)
			break;

		var ability = Entities.GetAbility( m_QueryUnit, i );

		if ( ability == -1 )
			continue;

		if ( !Abilities.IsDisplayedAbility( ability ) )
			continue;
		
		if ( nUsedPanels >= m_AbilityPanels.length )
		{
			// create a new panel
			var abilityPanel = $.CreatePanel( "Panel", abilityListPanel, "" );
			abilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/abilities/ability.xml", false, false );
			m_AbilityPanels.push( abilityPanel );
		}

		// update the panel for the current unit / ability
		var abilityPanel = m_AbilityPanels[ nUsedPanels ];
		abilityPanel.data().SetAbility( ability, m_QueryUnit, Game.IsInAbilityLearnMode() );
		
		nUsedPanels++;
	}

	// clear any remaining panels
	for ( var i = nUsedPanels; i < m_AbilityPanels.length; ++i )
	{
		var abilityPanel = m_AbilityPanels[ i ];
		abilityPanel.data().SetAbility( -1, -1, false );
	}

	// Если есть дочерние панели, то показываем основную
	if ( nUsedPanels > 0)
		abilityListPanel.style["visibility"] = "visible";
}

function Update()
{
	UpdateAbilitiesContainer();
	$.Schedule( 0.07, Update );
}

function SetSelectedUnit()
{
    GameUI.CustomUIConfig().selected_unit = Players.GetLocalPlayerPortraitUnit();
	//UpdateAbilitiesContainer();
}

(function()
{
	//GameEvents.Subscribe( "dota_ability_changed", UpdateAbilitiesContainer );

    GameEvents.Subscribe( "dota_player_update_selected_unit", SetSelectedUnit );
    GameEvents.Subscribe( "dota_player_update_query_unit", SetSelectedUnit );

	GameEvents.Subscribe( "dota_hero_ability_points_changed", UpdateAbilitiesContainer );
    $.RegisterForUnhandledEvent( "DOTAAbility_LearnModeToggled", UpdateAbilitiesContainer);	

	GameEvents.Subscribe( "dota_player_gained_level", UpdateAbilitiesContainer );

	Update();
})();

