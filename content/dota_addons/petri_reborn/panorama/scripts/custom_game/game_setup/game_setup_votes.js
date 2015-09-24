"use strict";

var currentVote = 0;
var isHost = false;

// Layout file, time for vote
var votePanels = [
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_build_exit_delay.xml", 10 ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_game_length.xml", 15 ]
]; 

function ShowNextVote()
{
	var vote = votePanels[currentVote];
	if (vote)
	{
		var votePanel = $.CreatePanel( "Panel", $.GetContextPanel(), "" );
		votePanel.BLoadLayout( vote[0], false, false );
		
		if (isHost)
		{
			GameEvents.SendCustomGameEventToServer( "petri_vote_current_number", { "vote_number" : currentVote } );
			Game.SetRemainingSetupTime( vote[1] );
		}

		currentVote++;
	}
}

function SetCurrentVote( currentVoteNumber )
{
	currentVote = currentVoteNumber;
}

(function ()
{
	var playerInfo = Game.GetLocalPlayerInfo();
	isHost = playerInfo.player_has_host_privileges;
	if (isHost)
		Game.SetAutoLaunchEnabled( false );

	$.GetContextPanel().data().ShowNextVote = ShowNextVote;
	GameEvents.Subscribe( "petri_vote_current_vote", SetCurrentVote );
})();
