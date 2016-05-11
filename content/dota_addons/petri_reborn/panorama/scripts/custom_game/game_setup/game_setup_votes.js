"use strict";

var isDebug = true;

var AFTER_VOTE_TIME = 5;

var hostVoteNum = 0;
var currentVotePanel = null;
var isHost = false;
var isFreeze = false;

var timer = 0;

// Layout file, time for vote, state description
var votePanels = [
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_host_shuffle.xml", 10 ],
	//[ "file://{resources}/layout/custom_game/game_setup/votes/vote_build_exit_delay.xml", 5 ],
	[ "file://{resources}/layout/custom_game/game_setup/votes/vote_bonus_item.xml", 15 ],
	//[ "file://{resources}/layout/custom_game/game_setup/votes/vote_use_miniactors.xml", 5 ]
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
	Msg("Show vote ", args["vote_number"])
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

			// Update state description
			$.Schedule( 0.2, function(){
				var desc = votePanel.GetChild(0).GetAttributeString("desc", "");
				if ($.GetContextPanel().SetStateDescription && desc != "")
					$.GetContextPanel().SetStateDescription( desc );	

			});

			votePanel.AddClass("show_vote");
			votePanel.SetVoteTime(vote[1]);
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
	if ($.GetContextPanel().SetStateDescription && args["desc"] != "")
		$.GetContextPanel().SetStateDescription( args["desc"] );	
}

//--------------------------------------------------------------------------------------------------
// Show vote
//--------------------------------------------------------------------------------------------------
function ShowNextVote()
{
	if (isFreeze)
		return;

	if (votePanels[hostVoteNum])
		SetTimer( votePanels[hostVoteNum][1] + 1, "" )

	if (hostVoteNum < votePanels.length + 1)
		SendEventHostToClients( "petri_vote_current_vote", { "vote_number" : hostVoteNum++ } );
}

(function ()
{
	Msg("Vote loaded!")
	var playerInfo = Game.GetLocalPlayerInfo();
	isHost = playerInfo.player_has_host_privileges;
	if (isHost)
		Game.SetAutoLaunchEnabled( false );

	$.GetContextPanel().ShowNextVote = ShowNextVote;
	$.GetContextPanel().FreezeVote = FreezeVote;
	$.GetContextPanel().UnfreezeVote = UnfreezeVote;

	$.GetContextPanel().SetTimer = SetTimer;
	$.GetContextPanel().GetTimer = GetTimer;

	GameEvents.Subscribe( "petri_vote_sync_timer", SyncTimer );
	GameEvents.Subscribe( "petri_vote_current_vote", ShowVote );
	GameEvents.Subscribe( "petri_vote_freeze", SetFreeze );
	GameEvents.Subscribe( "petri_vote_unfreeze", SetUnfreeze );

	GameEvents.Subscribe( "petri_vote_results", ShowVoteResults );
})();
