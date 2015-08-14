var m_Unit = null;
var xpTable = {};

function UpdateLevelUpButton()
{
	var nRemainingPoints = Entities.GetAbilityPoints( m_Unit );
	var bPointsToSpend = ( nRemainingPoints > 0 );
	var bControlsUnit = Entities.IsControllableByPlayer( m_Unit, Game.GetLocalPlayerID() );
	$.GetContextPanel().SetHasClass( "could_level_up", ( bControlsUnit && bPointsToSpend ) );
}

function UpdateExperience( unitLevel )
{
	var player = Game.GetLocalPlayerID();
	var exp = Players.GetTotalEarnedXP( player );
	var curLevelExp = Entities.IsHero(m_Unit) ? exp - xpTable[String(unitLevel)] : 0;
	var maxLevelExp = Entities.IsHero(m_Unit) ? xpTable[String(unitLevel + 1)] - xpTable[String(unitLevel)] : 1;

	$( "#ExperienceCount" ).style.visibility = "visible;";
	$( "#ExperienceCount" ).text = curLevelExp + "/" + maxLevelExp;
	$( "#Experience" ).style.width = curLevelExp / maxLevelExp * 100 + "%;";
}

function UpdatePortrait()
{
	m_Unit = GameUI.CustomUIConfig().selected_unit;

	if (!m_Unit)
		return;

	var unitLevel = Entities.GetLevel( m_Unit );
	var unitName = Entities.GetUnitName(m_Unit);

	$( "#HeroName" ).text = $.Localize( "#" + unitName );
	$( "#HeroLevel" ).text = unitLevel;

	UpdateLevelUpButton();
	UpdateExperience(unitLevel);
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

function GetXPTable( table )
{
	xpTable = table;
}

(function() {
	$.GetContextPanel().data().UpdatePortrait = UpdatePortrait;	

	GameEvents.Subscribe( "dota_hero_ability_points_changed", UpdatePortrait );
    $.RegisterForUnhandledEvent( "DOTAAbility_LearnModeToggled", UpdatePortrait);	

	GameEvents.Subscribe( "dota_player_gained_level", UpdatePortrait );
	GameEvents.Subscribe( "petri_set_xp_table", GetXPTable );
})();