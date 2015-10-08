"use strict";

var currentVoteNum = 0;
var currentVotePanel = null;
var isHost = false;
var isFreeze = false;

// Layout file, time for vote, state description
var votePanels = [
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_host_shuffle.xml", 10, "#game_setup_host_vote" ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_build_exit_delay.xml", 10, "#game_setup_build_delay_vote" ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_game_length.xml", 10, "#game_setup_game_length_vote" ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_use_miniactors.xml", 10, "#game_setup_use_miniactors_vote" ]
]; 

function ShowNextVote()
{
	// Default vote
	if (currentVotePanel)
		if (!currentVotePanel.data().IsVoted)
			currentVotePanel.data().VoteDefault();

	if (isFreeze)
		return;
	
	if (currentVoteNum > votePanels.length)
		return

	// End of votes
	if (currentVoteNum == votePanels.length)
	{
		if (isHost)
		{
			$.GetContextPanel().data().SetStateDescription( "#game_setup_start" );			
			Game.SetRemainingSetupTime( 10 );
			GameEvents.SendCustomGameEventToServer( "petri_vote_end", { } );
		}

		currentVoteNum++;
		return;
	}

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

			if ($.GetContextPanel().data().SetStateDescription)
			{
				if (vote[2])
					$.GetContextPanel().data().SetStateDescription( vote[2] );
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

//--------------------------------------------------------------------------------------------------
// Vote results
//--------------------------------------------------------------------------------------------------
function ShowVoteResults( args )
{
	var childCount = $.GetContextPanel().GetChildCount();
	
	// Update all panels
	for (var i = 0; i < childCount; i++) {
		var votePanel = $.GetContextPanel().GetChild(i).FindChild( "VoteVariants" );
		if (!votePanel)
			continue;

		var param = votePanel.GetAttributeString("param", "");
		if (param == "")
			continue;

		var variantsCount = votePanel.GetChildCount();
		// Update all variants
		for (var j = 0; j < variantsCount; j++) {
			var variantPanel = votePanel.GetChild(j);
			var value = variantPanel.GetAttributeString("value", "");

			var isWrongVariant = args["results"][param] != value;
			variantPanel.SetHasClass("wrong", isWrongVariant);
			variantPanel.SetHasClass("selected", false);
		};
	};
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

	GameEvents.Subscribe( "petri_vote_results", ShowVoteResults );
})();
