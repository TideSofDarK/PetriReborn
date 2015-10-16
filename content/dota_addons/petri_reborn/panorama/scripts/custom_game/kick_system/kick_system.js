'use strict';
var lastVoteTime = {};

function AddVoteKickPanel( args )
{
	var playerID = args["KickPlayerID"];
	lastVoteTime[playerID] = Game.GetGameTime();

	var localPlayer = Players.GetLocalPlayer();
	if (localPlayer == args["KickPlayerID"] || localPlayer == args["VoteInitiator"])
		return;

	var playerPanel = $.CreatePanel( "Panel", $( "#KickList" ), "Player_" + playerID );
	playerPanel.SetAttributeInt("PlayerID", playerID);
	playerPanel.BLoadLayout( "file://{resources}/layout/custom_game/kick_system/kick_system_player.xml", false, false );


}

// Check kick rules
function IsAllowedToKick( playerID )
{
	var localPlayerInfo = Game.GetLocalPlayerInfo();
	var playerInfo = Game.GetPlayerInfo( playerID );
	var gameTime = Game.GetGameTime();
	var heroName = Players.GetPlayerSelectedHero( playerID );
	
	return heroName != "npc_dota_hero_brewmaster" &&  heroName != "npc_dota_hero_death_prophet" &&			// only mini actors or kvn
		!playerInfo.player_has_host_privileges &&															// only not host
		localPlayerInfo.player_id != playerID &&															// not yourself
		localPlayerInfo.player_team_id == playerInfo.player_team_id &&										// only your tean
		(lastVoteTime[playerID] != null && lastVoteTime[playerID] + 30 > gameTime) &&						// only every 30 second
		gameTime > 240;																						// after 4 min
}

(function () {
	GameEvents.Subscribe( "petri_vote_kick", AddVoteKickPanel );

	GameUI.CustomUIConfig().IsAllowedToKick = IsAllowedToKick;
})(); 