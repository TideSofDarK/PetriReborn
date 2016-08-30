"use strict";

var PREPARE_TIME = 5;
var SELECT_PETR_TIME = 20;

var isHostShuffle = false;

//--------------------------------------------------------------------------------------------------
// Setting state description
//--------------------------------------------------------------------------------------------------
function SetStateDescription( desc )
{
	var label = $( "#TimerLabelGameStart" );
	label.text = $.Localize( desc );
}

//--------------------------------------------------------------------------------------------------
// Check to see if the local player has host privileges and set the 'player_has_host_privileges' on
// the root panel if so, this allows buttons to only be displayed for the host.
//--------------------------------------------------------------------------------------------------
function CheckForHostPrivileges()
{
	var playerInfo = Game.GetLocalPlayerInfo();
	if ( !playerInfo )
		return;

	// Set the "player_has_host_privileges" class on the panel, this can be used 
	// to have some sub-panels on display or be enabled for the host player.
	$.GetContextPanel().SetHasClass( "player_has_host_privileges", playerInfo.player_has_host_privileges );
}


//--------------------------------------------------------------------------------------------------
// Update the state for the transition timer periodically
//--------------------------------------------------------------------------------------------------
function UpdateTimer()
{
	CheckForHostPrivileges();
	
	var mapInfo = Game.GetMapInfo();
	$( "#MapInfoLabel" ).SetDialogVariable( "map_name", mapInfo.map_display_name );

	var timer = 0;

	if ($( "#VotePanel" ).GetTimer)
		timer = $( "#VotePanel" ).GetTimer();

	if ( timer >= 0 ) 
	{
		$( "#StartGameCountdownTimer" ).SetDialogVariableInt( "countdown_timer_seconds", timer );
		$( "#StartGameCountdownTimer" ).SetHasClass( "countdown_active", true );
		$( "#StartGameCountdownTimer" ).SetHasClass( "countdown_inactive", false );
	}
	else
	{
		$( "#StartGameCountdownTimer" ).SetHasClass( "countdown_active", false );
		$( "#StartGameCountdownTimer" ).SetHasClass( "countdown_inactive", true );
	}

	var autoLaunch = Game.GetAutoLaunchEnabled();
	$( "#StartGameCountdownTimer" ).SetHasClass( "auto_start", autoLaunch );
	$( "#StartGameCountdownTimer" ).SetHasClass( "forced_start", ( autoLaunch == false ) );

	if (timer == 0)
		if ($( "#VotePanel" ).ShowNextVote != null)
			$( "#VotePanel" ).ShowNextVote();

	$.Schedule( 0.1, UpdateTimer );
}

//--------------------------------------------------------------------------------------------------
// Team assignment
//--------------------------------------------------------------------------------------------------
function AssignTeams()
{
	var teamsPanel = $( "#TeamsListContainer");
	var playersPanel = $( "#PlayersListContainer");

	var players = [];
	for (var i = 0; i < playersPanel.GetChildCount(); i++)
		players.push(playersPanel.GetChild(i));

	var teamsCount = teamsPanel.GetChildCount();

	for(var i = 0; i < players.length; i++)
	{
		players[i].SetHasClass("transition", false);

		var team = null;
		if(players[i].GetAttributeString("IsPetr", "false") == "true")
		{
			team = teamsPanel.GetChild(1);
			if (!team.CanAddPlayers())
				team = teamsPanel.GetChild(0)
		}
		else
		{
			team = teamsPanel.GetChild(0);
			if (!team.CanAddPlayers())
				team = teamsPanel.GetChild(1)
		}

		if (team)
		{
			players[i].SetHasClass("Cards", true);
			players[i].SetParent(team.FindChild("PlayerList"));
		}

 		players[i].FindChild("Indicators").FindChild("Petro").visible = false;
 		players[i].FindChild("Indicators").FindChild("PetroPrefer").visible = false;
 	}

 	var playerID = Game.GetLocalPlayerID();
 	for (var i = 0; i < teamsCount; i++)
 	{
		var curTeam = teamsPanel.GetChild(i);
		curTeam.SetHasClass("show", true);
		curTeam.AddClass("show_vote");
		var playerPanel = curTeam.FindChild("PlayerList").FindChild("Player_" + playerID);

		if (playerPanel)
			Game.PlayerJoinTeam( curTeam.GetAttributeInt( "team_id", -1 ) );
 	}

	$( "#VotePanel" ).SetTimer( 3, "#game_setup_shuffling" );
	$( "#VotePanel" ).UnfreezeVote();
}

//--------------------------------------------------------------------------------------------------
// Shuffles
//--------------------------------------------------------------------------------------------------
function ClearStyle()
{
	var playersPanel = $( "#TeamSelectContainer" ).FindChild("WorkArea").FindChild("PlayersPanel").FindChild("PlayersListContainer");
	var childCount = playersPanel.GetChildCount();

	var count = playersPanel.GetChildCount();
	
	for (var i = 0; i < count; i++)
	{
		var playerPanel = playersPanel.GetChild(i);

		playerPanel.SetHasClass( "upPaper", false )
		playerPanel.SetHasClass("hover", false);
	}
}

function SetPreferTeam( args )
{
	var playersPanel = $( "#PlayersListContainer");
	
	for(var playerID in args["petr"])
	{
		var playerPanel = playersPanel.FindChild( "Player_" + args["petr"][playerID] );
		playerPanel.FindChild("Indicators").FindChild("PetroPrefer").SetHasClass("visible", true);
	}
}

function ShuffleList( args )
{
	ClearStyle();

	if (!args)
		return;

	var playersPanel = $( "#TeamSelectContainer" ).FindChild("WorkArea").FindChild("PlayersPanel").FindChild("PlayersListContainer");
	var shuffleList = [];

	// Set team number
	for(var num in args["petr"]) 
	{
		var panel = playersPanel.FindChild("Player_" + args["petr"][num]);
		if (panel)
		{
			panel.SetAttributeString("IsPetr", "true");
			shuffleList.push(args["petr"][num]);
		}
	}

	for(var num in args["kvn"])
	{
		var panel = playersPanel.FindChild("Player_" + args["kvn"][num]);
		if (panel)
		{
			panel.SetAttributeString("IsPetr", "false")
			shuffleList.push(args["kvn"][num]);
		}
	}

	var childCount = playersPanel.GetChildCount();

	var count = shuffleList.length;
	var players = [];
	for (var i = 0; i < playersPanel.GetChildCount(); i++)
		players.push(playersPanel.GetChild(i));


	if (childCount > 1)
		for (var i = 0; i < childCount; i++) {
			var panel1 = players[i == 0 ? i : shuffleList[i - 1]];
			var panel2 = players[shuffleList[i]];
	 
			panel1.SetHasClass("upPaper", true);
			panel2.SetHasClass("upPaper", true);

			playersPanel.MoveChildAfter( panel2, panel1 );
		}
}

function SendHostShuffleList()
{
	var playersPanel = $( "#PlayersListContainer");
	var childCount = playersPanel.GetChildCount();

	// Form team lists
	var petrList = [];
	var kvnList = [];
	for (var i = 0; i < childCount; i++) {
		var playerPanel = playersPanel.GetChild(i);
		var isPetr = playerPanel.GetAttributeString("IsPetr", "false");
		if (playerPanel.FindChild("Indicators").FindChild("Petro").visible)
			petrList.push(i);
		else
			kvnList.push(i);		
	}

	GameEvents.SendCustomGameEventToServer( "petri_game_setup_set_host_list", { "kvn" : kvnList, "petr" : petrList } );
}

function HostShuffle()
{
	var playersPanel = $( "#PlayersListContainer");
	var childCount = playersPanel.GetChildCount();

	for (var i = 0; i < childCount; i++) {
		var playerPanel = playersPanel.GetChild(i);

		var isPreferPetri = playerPanel.FindChild("Indicators").FindChild("PetroPrefer").BHasClass( "visible" );

		if (!isPreferPetri)
			continue;
		
		playerPanel.SetHasClass("hover", true);

		var click = (function(panel) { 
			return function() {
				var isPetr = panel.GetAttributeString("IsPetr", "false");
				if (isPetr == "false")
					panel.SetAttributeString("IsPetr", "true");
				else
					panel.SetAttributeString("IsPetr", "false");

				panel.FindChild("Indicators").FindChild("Petro").SetHasClass("visible", isPetr == "true");
			}
		} (playerPanel));

		playerPanel.SetPanelEvent("onmouseactivate", click);
	}

	$( "#VotePanel" ).SetTimer( SELECT_PETR_TIME, "#game_setup_host_select_petrosyan" );
	$( "#VotePanel" ).FreezeVote();

	$.Schedule(SELECT_PETR_TIME, SendHostShuffleList)
}

//--------------------------------------------------------------------------------------------------
// Fill panels content
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
// Votes list
//--------------------------------------------------------------------------------------------------
function CreateVote()
{
	var votePanel = $( "#VotePanel");
	votePanel.BLoadLayout( "file://{resources}/layout/custom_game/game_setup/game_setup_votes.xml", false, false );
	votePanel.SetStateDescription = SetStateDescription;
}

//--------------------------------------------------------------------------------------------------
// Players list
//--------------------------------------------------------------------------------------------------
function CreatePlayerList()
{
	var playersPanel = $( "#PlayersListContainer");
	var playerIDs = Game.GetAllPlayerIDs();
	
	// Testing list
	/*
	var playerID = playerIDs[0];
	for (var i = 0; i < 14; i++) {
		var playerPanel = $.CreatePanel( "Panel", playersPanel, "Player_" + i );
		playerPanel.SetAttributeInt( "player_id", playerID );
		playerPanel.BLoadLayout( "file://{resources}/layout/custom_game/game_setup/game_setup_player.xml", false, false );
		playerPanel.SetHasClass("transition", true);
		playerPanel.SetParent( playersPanel );
		playerPanel.FindChild("PlayerName").text =  i;

		var executeCapture = (function(panel) { 
			return function() {

				var isPetr = panel.GetAttributeString("IsPetr", "false");
				if (isPetr == "false")
					panel.SetAttributeString("IsPetr", "true");
				else
					panel.SetAttributeString("IsPetr", "false");

				panel.FindChild("Petro").SetHasClass("visible", isPetr == "true");
			}
		} (playerPanel));

		playerPanel.SetPanelEvent("onmouseactivate", executeCapture);
	}*/
 
	for(var id of playerIDs)
	{
		var playerPanel = $.CreatePanel( "Panel", playersPanel, "Player_" + id );
		playerPanel.SetAttributeInt( "player_id", id );
		playerPanel.BLoadLayout( "file://{resources}/layout/custom_game/game_setup/game_setup_player.xml", false, false );

		playerPanel.AddClass("playerInfo");
		playerPanel.SetParent( playersPanel );
	}
}


//--------------------------------------------------------------------------------------------------
// Teams list
//--------------------------------------------------------------------------------------------------
function CreateTeamList()
{
	var teamsPanel = $( "#TeamsListContainer");

	var teamIDs = Game.GetAllTeamIDs();

	for ( var teamID of teamIDs )
	{
		var teamNode = $.CreatePanel( "Panel", teamsPanel, "Team_" + teamID );

		teamNode.SetAttributeInt( "team_id", teamID );
		teamNode.BLoadLayout( "file://{resources}/layout/custom_game/game_setup/game_setup_team.xml", false, false ); 
		teamNode.SetParent( teamsPanel );
	}
}

//--------------------------------------------------------------------------------------------------
// Init UI
//--------------------------------------------------------------------------------------------------
function LoadUI()
{
	CreatePlayerList();
	CreateTeamList(); 
	CreateVote();

	var playerInfo = Game.GetLocalPlayerInfo();
	if (playerInfo.player_has_host_privileges)
	{
		// Shuffle handlers
		GameEvents.Subscribe( "petri_host_shuffle", HostShuffle );		
		
		Game.SetAutoLaunchEnabled( false );
	}

	$( "#VotePanel" ).UnfreezeVote();
	
	$( "#VotePanel" ).SetTimer( PREPARE_TIME, "#game_setup_state_prevote" );	 

	// GameEvents.SendCustomGameEventToServer( "petri_game_setup_start_precache", {} );
}

function OpenLink() {
	$.DispatchEvent( 'BrowserGoToURL', $.GetContextPanel(), $.Localize("ad_url"));
}

//--------------------------------------------------------------------------------------------------
// Entry point called when the team select panel is created
//--------------------------------------------------------------------------------------------------
(function()
{
	// Start updating the timer, this function will schedule itself to be called periodically	
	UpdateTimer();

	GameEvents.Subscribe( "petri_set_prefer_team_list", SetPreferTeam );
	GameEvents.Subscribe( "petri_set_shuffled_list", ShuffleList );
	GameEvents.Subscribe( "petri_end_shuffle", AssignTeams );

	$.Schedule(2.0, LoadUI);

	Game.PlayerJoinTeam( DOTATeam_t.DOTA_TEAM_NOTEAM );

	GameEvents.SendCustomGameEventToServer( "petri_set_lang", { "lang" : $.Localize("lang_key"), "pID" : Players.GetLocalPlayer() } );
})();
