"use strict";
var isHostShuffle = false;

//--------------------------------------------------------------------------------------------------
// Handler for when the Lock and Start button is pressed
//--------------------------------------------------------------------------------------------------
function OnLockAndStartPressed()
{
	// Don't allow a forced start if there are unassigned players
	if ( Game.GetUnassignedPlayerIDs().length > 0  )
		return;

	// Lock the team selection so that no more team changes can be made
	Game.SetTeamSelectionLocked( true );
	
	// Disable the auto start count down
	Game.SetAutoLaunchEnabled( false );

	// Set the remaining time before the game starts
	Game.SetRemainingSetupTime( 4 ); 
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
	var gameTime = Game.GetGameTime();
	var transitionTime = Game.GetStateTransitionTime();

	CheckForHostPrivileges();
	
	var mapInfo = Game.GetMapInfo();
	$( "#MapInfoLabel" ).SetDialogVariable( "map_name", mapInfo.map_display_name );

	var timer = Math.max( 0, Math.floor( transitionTime - gameTime ) );
	if ( transitionTime >= 0 ) 
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

	if (timer < 1)
	{
		if (isHostShuffle)
		{
			SendHostShuffleList();
			isHostShuffle = false;
			Game.SetRemainingSetupTime( 10 );
		}
		else
		{
			// Vote changes
			if ($( "#VotePanel" ).data().ShowNextVote != null)
				$( "#VotePanel" ).data().ShowNextVote();
		}
	}

	$.Schedule( 0.1, UpdateTimer );
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
		// Priority by visibility of petr icon
		var priorTeam = i % teamsCount;
		var team = teamsPanel.GetChild(priorTeam);
		players[i].SetHasClass("transition", false);

		// try to add player in prior team
		if (team.data().CanAddPlayers())
		{
			players[i].SetParent(team.FindChild("PlayerList"));
		}
		else
			// add to another
	 		for (var j = 0; j < teamsCount; j++) 
	 			if (j != priorTeam)
		 		{
					team = teamsPanel.GetChild(j);

					// try to add player in prior team
					if (team.data().CanAddPlayers())
						players[i].SetParent(team.FindChild("PlayerList"));
		 		};

 		players[i].FindChild("Petro").visible = false;
 	}

 	var playerID = Game.GetLocalPlayerID();
 	for (var i = 0; i < teamsCount; i++)
 	{
		var curTeam = teamsPanel.GetChild(i);
		curTeam.SetHasClass("show", true);
		var playerPanel = curTeam.FindChild("PlayerList").FindChild("Player_" + playerID);

		if (playerPanel)
			Game.PlayerJoinTeam( curTeam.GetAttributeInt( "team_id", -1 ) );
 	}
}

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
		Game.SetRemainingSetupTime( 5 );
	}
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
		playersPanel.GetChild(i).SetHasClass( "upPaper", false )
}

function ShuffleList( args )
{
	ClearStyle();

	var shuffleList = args["list"];
	if (!shuffleList)
		return;

	var playersPanel = $( "#TeamSelectContainer" ).FindChild("WorkArea").FindChild("PlayersPanel").FindChild("PlayersListContainer");
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
		if (playerPanel.FindChild("Petro").visible)
			petrList.push(i);
		else
			kvnList.push(i);		
	}

	// Merge lists
	var list = [];
	for (var i = 0; i < childCount; i++) {
		var array = i % 2 
				? (petrList.length > 0 ? petrList : kvnList)
				: (kvnList.length > 0 ? kvnList : petrList);

		if (array.length > 0)
			list.push(array.pop());
	};

	GameEvents.SendCustomGameEventToServer( "petri_game_setup_set_host_list", { "list" : list } );
}

function HostShuffle()
{
	var playersPanel = $( "#PlayersListContainer");
	var childCount = playersPanel.GetChildCount();

	for (var i = 0; i < childCount; i++) {
		var playerPanel = playersPanel.GetChild(i);

		var click = (function(panel) { 
			return function() {
				var isPetr = panel.GetAttributeString("IsPetr", "false");
				if (isPetr == "false")
					panel.SetAttributeString("IsPetr", "true");
				else
					panel.SetAttributeString("IsPetr", "false");

				panel.FindChild("Petro").SetHasClass("visible", isPetr == "true");
			}
		} (playerPanel));

		playerPanel.SetPanelEvent("onmouseactivate", click);
	}

	Game.SetRemainingSetupTime( 10 );
	isHostShuffle = true;
}

//--------------------------------------------------------------------------------------------------
// Entry point called when the team select panel is created
//--------------------------------------------------------------------------------------------------
(function()
{
	// Start updating the timer, this function will schedule itself to be called periodically
	UpdateTimer();

	GameEvents.Subscribe( "petri_set_shuffled_list", ShuffleList );
	GameEvents.Subscribe( "petri_end_shuffle", AssignTeams );

	$.Schedule(2.0, LoadUI);

	Game.PlayerJoinTeam( DOTATeam_t.DOTA_TEAM_NOTEAM );
})();
