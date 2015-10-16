'use strict';
var playerID = -1;

function HidePanel()
{
	$.GetContextPanel().enabled =  false;
	$.Schedule( 1.0, function() { 
		$.GetContextPanel().visible = false;
		$.GetContextPanel().DeleteAsync( 1.0 );
	});	
}

function GetPlayerColor( PlayerID )
{
	var color = Players.GetPlayerColor( PlayerID ).toString(16);
	color = color.substring(6, 8) + color.substring(4, 6) + color.substring(2, 4) + color.substring(0, 2);
	return "#" + color;
}

function FillPlayerData()
{
	playerID = $.GetContextPanel().GetAttributeInt("PlayerID", -1);
	if (playerID != -1)
	{
		var playerInfo = Game.GetPlayerInfo( playerID );
		if ( !playerInfo )
			return;

		$( "#PlayerName" ).text = playerInfo.player_name;
		$( "#AvatarPanel" ).FindChild( "PlayerAvatar" ).steamid = playerInfo.player_steamid;

		var color = GetPlayerColor( Game.GetLocalPlayerID() );
		$( "#AvatarPanel" ).FindChild( "PlayerColor" ).style.backgroundColor = color + ";";		
	}
}

function Close()
{
	$( "#ButtonClose" ).FindChild( "ImageClose" ).SetHasClass("select", true);
	GameEvents.SendCustomGameEventToServer( "petri_vote_kick_disagree", { "KickPlayerID" : playerID } );	
	HidePanel();
}

function VoteKick()
{
	$( "#ButtonKick" ).FindChild( "ImageKick" ).SetHasClass("select", true);
	GameEvents.SendCustomGameEventToServer( "petri_vote_kick_agree", { "KickPlayerID" : playerID } );
	HidePanel();
}

(function () {
	FillPlayerData();
	// 10 second to vote
	$.Schedule( 10.0, HidePanel )
})();