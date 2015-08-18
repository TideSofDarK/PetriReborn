"use strict";

var g_ScoreboardHandle = null;

function SetUpdatePlayers()
{
	g_ScoreboardHandle.scoreboardConfig["updatePlayersCount"] = true;
}

function UpdateScoreboard()
{
	ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, true );

 	$.Schedule( 0.8, UpdateScoreboard );
}

(function()
{
	if ( ScoreboardUpdater_InitializeScoreboard === null ) { $.Msg( "WARNING: This file requires shared_scoreboard_updater.js to be included." ); }

	var scoreboardConfig =
	{
		"teamXmlName" : "file://{resources}/layout/custom_game/top_scoreboard/top_scoreboard_team.xml",
		"playerXmlName" : "file://{resources}/layout/custom_game/top_scoreboard/top_scoreboard_player.xml",
		"updatePlayersCount" : false,		
	};

	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#MultiteamScoreboard" ) );

	UpdateScoreboard();

	// Подписываемся на событие "Смена команды"
    GameEvents.Subscribe("player_team", SetUpdatePlayers);
})();

