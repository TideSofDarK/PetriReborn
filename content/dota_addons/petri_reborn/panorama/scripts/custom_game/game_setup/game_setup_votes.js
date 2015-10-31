"use strict";

var isDebug = true;

var AFTER_VOTE_TIME = 25;

var hostVoteNum = 0;
var currentVotePanel = null;
var isHost = false;
var isFreeze = false;

var timer = 0;

// Layout file, time for vote, state description
var votePanels = [
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_host_shuffle.xml", 10, "#game_setup_host_vote" ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_build_exit_delay.xml", 5, "#game_setup_build_delay_vote" ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_game_length.xml", 5, "#game_setup_game_length_vote" ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_use_miniactors.xml", 5, "#game_setup_use_miniactors_vote" ]
]; 

//--------------------------------------------------------------------------------------------------
// Utils
//--------------------------------------------------------------------------------------------------
function SendEventHostToClients( eventName, args )
{
	if (!isHost)
		return;

	var eventArgs = args;
	eventArgs["event_name"] = eventName;
	GameEvents.SendCustomGameEventToServer( "petri_client_to_all_clients", eventArgs );
}

function Msg()
{
	if (isDebug)
	{
		var str = "";
		for (var v of arguments)
			str += v;
		$.Msg(str);
	}
}

//--------------------------------------------------------------------------------------------------
// End utils
//--------------------------------------------------------------------------------------------------

function ShowVote( args )
{
	var currentVoteNum = args["vote_number"];
	if (currentVoteNum > votePanels.length)
		return;

	// End of votes
	if (currentVoteNum == votePanels.length)
	{
		SetTimer( AFTER_VOTE_TIME, "#game_setup_start" );
		if (isHost)
		{
			Game.SetRemainingSetupTime( AFTER_VOTE_TIME );
			GameEvents.SendCustomGameEventToServer( "petri_vote_end", { } );
		}

		currentVoteNum++;
		return;
	}

	if (isFreeze)
		return;

	var vote = votePanels[currentVoteNum];
	if (vote)
		if (vote[0] != "")
		{
			var votePanel = $.CreatePanel( "Panel", $.GetContextPanel(), "" );
			votePanel.BLoadLayout( vote[0], false, false );
			votePanel.AddClass("show_vote");
			votePanel.data().SetVoteTime(vote[1]);
			currentVotePanel = votePanel;
		}
}

//--------------------------------------------------------------------------------------------------
// Vote freezing
//--------------------------------------------------------------------------------------------------
function FreezeVote()
{
	SendEventHostToClients( "petri_vote_freeze", { } );
}

function UnfreezeVote()
{
	SendEventHostToClients( "petri_vote_unfreeze", { } );
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

//--------------------------------------------------------------------------------------------------
// Timer functions
//--------------------------------------------------------------------------------------------------
function SetTimer( time, description )
{
	SendEventHostToClients( "petri_vote_sync_timer", { "host_time" : Game.GetGameTime(), "length" : time, "desc" : description } )
}

function GetTimer()
{
	return Math.max( 0, Math.floor( timer - Game.GetGameTime() ) );
}

function SyncTimer( args )
{
	var clientTime = Game.GetGameTime();
	timer = clientTime + args["length"] - (clientTime - args["host_time"]);

	// Update state description
	if ($.GetContextPanel().data().SetStateDescription)
		$.GetContextPanel().data().SetStateDescription( args["desc"] );	
}

//--------------------------------------------------------------------------------------------------
// Show vote
//--------------------------------------------------------------------------------------------------
function ShowNextVote()
{
	if (isFreeze)
		return;

	if (votePanels[hostVoteNum])
		SetTimer( votePanels[hostVoteNum][1], votePanels[hostVoteNum][2] )

	if (hostVoteNum < votePanels.length + 1)
		SendEventHostToClients( "petri_vote_current_vote", { "vote_number" : hostVoteNum++ } );
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

	$.GetContextPanel().data().SetTimer = SetTimer;
	$.GetContextPanel().data().GetTimer = GetTimer;

	GameEvents.Subscribe( "petri_vote_sync_timer", SyncTimer );
	GameEvents.Subscribe( "petri_vote_current_vote", ShowVote );
	GameEvents.Subscribe( "petri_vote_freeze", SetFreeze );
	GameEvents.Subscribe( "petri_vote_unfreeze", SetUnfreeze );

	GameEvents.Subscribe( "petri_vote_results", ShowVoteResults );
})();
