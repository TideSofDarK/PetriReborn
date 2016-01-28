"use strict";

function CanAddPlayers()
{
	var teamId = $.GetContextPanel().GetAttributeInt( "team_id", -1 );
	return $("#PlayerList").GetChildCount() < Game.GetTeamDetails( teamId ).team_max_players
}

//--------------------------------------------------------------------------------------------------
// Entry point function for a team panel, there is one team panel per-team, so this will be called 
// once for each each of the teams.
//--------------------------------------------------------------------------------------------------
(function ()
{	
	var teamId = $.GetContextPanel().GetAttributeInt( "team_id", -1 );
	var teamDetails = Game.GetTeamDetails( teamId );
 
	// Add the team logo to the panel
	var logo_xml = GameUI.CustomUIConfig().team_logo_xml;
	if ( logo_xml ) 
	{
		var teamLogoPanel = $( "#TeamLogo" );
		teamLogoPanel.SetAttributeInt( "team_id", teamId );
		teamLogoPanel.BLoadLayout( logo_xml, false, false );
	}

	// Set the team name
	var teamDetails = Game.GetTeamDetails( teamId );
	$( "#TeamNameLabel" ).text = $.Localize( teamDetails.team_name );
	
	// Get the player list and add player slots so that there are upto team_max_player slots
	var playerListNode = $.GetContextPanel().FindChildInLayoutFile( "PlayerList" );

	if ( GameUI.CustomUIConfig().team_colors )
	{
		$( "#TeamPanelHeader" ).style.backgroundColor = "#ff0000;";
		var teamColor = GameUI.CustomUIConfig().team_colors[ teamId ];
		teamColor = teamColor.replace( ";", "" );
		
		$( "#TeamPanelHeader" ).style.backgroundColor = teamColor;
	}
	
	$.GetContextPanel().CanAddPlayers = CanAddPlayers;
})();
