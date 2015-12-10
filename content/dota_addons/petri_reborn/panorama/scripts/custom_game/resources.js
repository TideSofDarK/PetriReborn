"use strict";

var currentResources = {};

(function(){Math.clamp=function(a,b,c){return Math.max(b,Math.min(c,a));}})();

function UpdateResources( )
{
	var gold = 0;

	var mainSelected = Players.GetLocalPlayerPortraitUnit();

	var localPlayer = Players.GetLocalPlayer();

	var resourceTable;

	if (Players.IsSpectator(localPlayer) == true)
	{
	 	var player = 0;
	 	for (var i = 0; i < 13; i++) {
	 		 if (Entities.IsControllableByPlayer( mainSelected, i ) == true)
	 		 {
	 		 	player = i;
	 		 	break;
	 		 }
	 	}
	 	resourceTable = CustomNetTables.GetTableValue("players_resources", String(player));
	 	gold = Players.GetGold(player);
	}
	else
	{
	 	resourceTable = CustomNetTables.GetTableValue("players_resources", String(localPlayer));
	 	gold = Players.GetGold(Players.GetLocalPlayer());
	}

	GameUI.CustomUIConfig().unitResources = resourceTable;

	if (resourceTable)
	{
		if (resourceTable["gold"]) {
	 		$( "#TotalGoldText" ).text = resourceTable["gold"];
	 	}

		if (resourceTable["lumber"]) {
		 	$( "#TotalLumberText" ).text = resourceTable["lumber"];
		}
		 
		if (resourceTable["food"] && resourceTable["maxFood"]) {
		 	$( "#TotalFoodText" ).text = resourceTable["food"] + "/" + String(Math.clamp(parseInt(resourceTable["maxFood"]),0,250));
		}
	}

	$.Schedule( 0.03, UpdateResources );
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

	UpdateResources();

    GameEvents.Subscribe("player_team", HidePanels);

    GameEvents.Subscribe( "petri_set_gold_costs", GetGoldCosts );
    GameEvents.Subscribe( "petri_set_dependencies_table", GetDependencies );
    GameEvents.Subscribe( "petri_set_special_values_table", GetSpecialValues );    
})();