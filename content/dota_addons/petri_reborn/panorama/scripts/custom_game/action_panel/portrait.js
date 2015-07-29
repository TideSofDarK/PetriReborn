var m_Unit = -1;

function UpdateLevelUpButton()
{
	var nRemainingPoints = Entities.GetAbilityPoints( m_Unit );
	var bPointsToSpend = ( nRemainingPoints > 0 );
	var bControlsUnit = Entities.IsControllableByPlayer( m_Unit, Game.GetLocalPlayerID() );
	$.GetContextPanel().SetHasClass( "could_level_up", ( bControlsUnit && bPointsToSpend ) );
}

function UpdatePortrait()
{
	m_Unit = GameUI.CustomUIConfig().selected_unit;

	UpdateLevelUpButton();

	//var exp = Players.GetTotalEarnedXP( Game.GetLocalPlayerID() );
	//$.Msg("exp = ", exp);
	
	var unit = GameUI.CustomUIConfig().selected_unit;
	var unitLevel = Entities.GetLevel( unit );
	var unitName = Entities.GetUnitName(unit);

	$( "#HeroName" ).text = $.Localize( "#" + unitName );
	$( "#HeroLevel" ).text = unitLevel;

	//$.Msg("exp = ", unitName);
}

function OnLevelUpClicked()
{
	if ( Game.IsInAbilityLearnMode() )
	{
		Game.EndAbilityLearnMode();
	}
	else
	{
		Game.EnterAbilityLearnMode();
	}
}

function OnAbilityLearnModeToggled( bEnabled )
{
	UpdateAbilitiesContainer();
}

(function() {
	$.GetContextPanel().data().UpdatePortrait = UpdatePortrait;	

	GameEvents.Subscribe( "dota_hero_ability_points_changed", UpdatePortrait );
    $.RegisterForUnhandledEvent( "DOTAAbility_LearnModeToggled", UpdatePortrait);	

	GameEvents.Subscribe( "dota_player_gained_level", UpdatePortrait );		
})();