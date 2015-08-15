"use strict";

var currentResources = {};

(function(){Math.clamp=function(a,b,c){return Math.max(b,Math.min(c,a));}})();

function UpdateResources( args )
{
	 GameUI.CustomUIConfig().unitResources = args;

	 $( "#TotalGoldText" ).text = args["gold"];
	 $( "#TotalLumberText" ).text = args["lumber"];
	 $( "#TotalFoodText" ).text = args["food"] + "/" + String(Math.clamp(parseInt(args["maxFood"]),0,250));
}

function HidePanels()
{
	var localPlayer = Game.GetLocalPlayerInfo();
	var localPlayerTeamId;
	if ( localPlayer )
		localPlayerTeamId = localPlayer.player_team_id;

	$( "#TotalFoodText" ).SetHasClass( "hide", localPlayerTeamId == DOTATeam_t.DOTA_TEAM_BADGUYS);
	$( "#TotalLumberText" ).SetHasClass( "hide", localPlayerTeamId == DOTATeam_t.DOTA_TEAM_BADGUYS);
}

function GetGoldCosts( eventArgs )
{
    GameUI.CustomUIConfig().goldCosts = eventArgs;
}

function GetDependencies( eventArgs )
{
    GameUI.CustomUIConfig().dependencies = eventArgs;
}

function GetSpecialValues( eventArgs )
{
    GameUI.CustomUIConfig().specialValues = eventArgs;
}

(function() 
{
	HidePanels();

    GameEvents.Subscribe("player_team", HidePanels);
    GameEvents.Subscribe( "receive_resources_info", UpdateResources);

    GameEvents.Subscribe( "petri_set_gold_costs", GetGoldCosts );
    GameEvents.Subscribe( "petri_set_dependencies_table", GetDependencies );
    GameEvents.Subscribe( "petri_set_special_values_table", GetSpecialValues );    
})();