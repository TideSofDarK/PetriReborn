'use strict';
var lastVoteTime = {};

function AddVoteKickPanel( args )
{
	var playerID = args["KickPlayerID"];
	var playerPanel = $.CreatePanel( "Panel", $( "#KickList" ), "Player_" + playerID );
	playerPanel.SetAttributeInt("PlayerID", playerID);
	playerPanel.BLoadLayout( "file://{resources}/layout/custom_game/kick_system/kick_system_player.xml", false, false );

	lastVoteTime[playerID] = Game.GetGameTime();
}

// Check kick rules
function IsAllowedToKick( playerID )
{
	var localPlayerInfo = Game.GetLocalPlayerInfo();
	var playerInfo = Game.GetPlayerInfo( playerID );
	var gameTime = Game.GetGameTime();
	
	return !playerInfo.player_has_host_privileges &&
		localPlayerInfo.player_id != playerID &&
		localPlayerInfo.player_team_id == playerInfo.player_team_id &&
		(lastVoteTime[playerID] != null && lastVoteTime[playerID] + 30 > gameTime) &&
		gameTime > 240;
}

(function () {
	GameEvents.Subscribe( "petri_vote_kick", AddVoteKickPanel );

	GameUI.CustomUIConfig().IsAllowedToKick = IsAllowedToKick;
})(); 