"use strict";

var currentVote = 0;
var isHost = false;

// Layout file, time for vote
var votePanels = [
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_build_exit_delay.xml", 10 ]
]; 

function VoteList()
{
	var vote = votePanels[currentVote];
	var votePanel = $.CreatePanel( "Panel", $.GetContextPanel(), "" );
	votePanel.BLoadLayout( vote[0], false, false );
	
	if (isHost)
		Game.SetRemainingSetupTime( vote[1] );

	currentVote++;
}

(function ()
{
	var playerInfo = Game.GetLocalPlayerInfo();
	isHost = playerInfo.player_has_host_privileges;
	if (isHost)
	{
		Game.SetAutoLaunchEnabled( false );
	}

	VoteList();
})();
