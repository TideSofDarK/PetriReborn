"use strict";

var currentVoteNum = 0;
var currentVotePanel = null;
var isHost = false;

// Layout file, time for vote
var votePanels = [
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_host_shuffle.xml", 10 ],
	/*[ "file://{resources}/layout/custom_game/game_setup/votes/vote_build_exit_delay.xml", 10 ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_game_length.xml", 15 ]*/
]; 

function ShowNextVote()
{
	// Default vote
	if (currentVotePanel)
		if (!currentVotePanel.data().IsVoted)
			currentVotePanel.data().VoteDefault();

	var vote = votePanels[currentVoteNum];
	if (vote)
	{
		if (vote[0] != "")
		{
			var votePanel = $.CreatePanel( "Panel", $.GetContextPanel(), "" );
			votePanel.BLoadLayout( vote[0], false, false );
			currentVotePanel = votePanel;
			
			if (isHost)
			{
				// Vote sync event
				GameEvents.SendCustomGameEventToServer( "petri_vote_current_number", { "vote_number" : currentVoteNum } );
				Game.SetRemainingSetupTime( vote[1] );
			}
		}
		
		currentVoteNum++;
	}
}

function SetCurrentVote( currentVoteNumber )
{
	currentVoteNum = currentVoteNumber;
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
