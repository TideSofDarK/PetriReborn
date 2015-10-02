"use strict";

var currentVoteNum = 0;
var currentVotePanel = null;
var isHost = false;
var isFreeze = false;

// Layout file, time for vote
var votePanels = [
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_host_shuffle.xml", 10 ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_build_exit_delay.xml", 10 ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_game_length.xml", 10 ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_use_miniactors.xml", 10 ],
]; 

function ShowNextVote()
{
	if (isFreeze)
		return;

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

//--------------------------------------------------------------------------------------------------
// Vote freezing
//--------------------------------------------------------------------------------------------------
function FreezeVote()
{
	if (isHost)
		GameEvents.SendCustomGameEventToServer( "petri_send_vote_freeze", { } );
}

function UnfreezeVote()
{
	if (isHost)
		GameEvents.SendCustomGameEventToServer( "petri_send_vote_unfreeze", { } );
}

function SetFreeze()
{
	isFreeze = true;
}

function SetUnfreeze()
{
	isFreeze = false;
}

(function ()
{
	var playerInfo = Game.GetLocalPlayerInfo();
	isHost = playerInfo.player_has_host_privileges;
	if (isHost)
		Game.SetAutoLaunchEnabled( false );

	$.GetContextPanel().data().ShowNextVote = ShowNextVote;
	$.GetContextPanel().data().FreezeVote = FreezeVote;
	$.GetContextPanel().data().UnfreezeVote = UnfreezeVote;

	GameEvents.Subscribe( "petri_vote_current_vote", SetCurrentVote );
	GameEvents.Subscribe( "petri_vote_freeze", SetFreeze );
	GameEvents.Subscribe( "petri_vote_unfreeze", SetUnfreeze );
})();
