"use strict";

var g_ScoreboardHandle = null;

function SetFlyoutScoreboardVisible( bVisible )
{
	$.GetContextPanel().SetHasClass( "flyout_scoreboard_visible", bVisible );
	if ( bVisible )
	{
		ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, true );
	}
	else
	{
		ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, false );
	}
}

(function()
{
	if ( ScoreboardUpdater_InitializeScoreboard === null ) { $.Msg( "WARNING: This file requires shared_scoreboard_updater.js to be included." ); }

	var scoreboardConfig =
	{
		"teamXmlNameKVN" : "file://{resources}/layout/custom_game/scoreboard/scoreboard_team_kvn.xml",
		"playerXmlNameKVN" : "file://{resources}/layout/custom_game/scoreboard/scoreboard_player_kvn.xml",
		"teamXmlNamePetro" : "file://{resources}/layout/custom_game/scoreboard/scoreboard_team_petro.xml",
		"playerXmlNamePetro" : "file://{resources}/layout/custom_game/scoreboard/scoreboard_player_petro.xml",		
	};
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#TeamsContainer" ) );
	
	SetFlyoutScoreboardVisible( false );
	
	$.RegisterEventHandler( "DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), SetFlyoutScoreboardVisible );
})();
