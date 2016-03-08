"use strict";

var currentResources = {};

(function(){Math.clamp=function(a,b,c){return Math.max(b,Math.min(c,a));}})();

function UpdateResources( )
{
	var isEnemy = GameUI.CustomUIConfig().IsEnemySelected();
	var player = Entities.IsCourier(GameUI.CustomUIConfig().selected_unit)
		? Players.GetLocalPlayer()
		: GameUI.CustomUIConfig().GetSelectedUnitOwner();

	var resourceTable = CustomNetTables.GetTableValue("players_resources", String(player));
	var gold = Players.GetGold(player);

	if (resourceTable)
	{
 		$( "#TotalGoldText" ).text = isEnemy ? "0" : String(gold);
	 	$( "#TotalLumberText" ).text = isEnemy ? "0" : resourceTable["lumber"];
	 	$( "#TotalFoodText" ).text = isEnemy ? "0/0" : resourceTable["food"] + "/" + String(Math.clamp(parseInt(resourceTable["maxFood"]),0,250));
	}

	$.Schedule( 0.03, UpdateResources );
}

function HidePanels()
{
	var player = Game.GetPlayerInfo( GameUI.CustomUIConfig().GetSelectedUnitOwner() );
	var playerTeamId;
	if ( player )
		playerTeamId = player.player_team_id;

	$( "#TotalFoodText" ).SetHasClass( "hide", playerTeamId == DOTATeam_t.DOTA_TEAM_BADGUYS);
	$( "#TotalLumberText" ).SetHasClass( "hide", playerTeamId == DOTATeam_t.DOTA_TEAM_BADGUYS);
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
    GameEvents.Subscribe( "dota_player_update_selected_unit", HidePanels );
    GameEvents.Subscribe( "dota_player_update_query_unit", HidePanels );
    GameEvents.Subscribe("player_team", HidePanels);

    GameEvents.Subscribe( "petri_set_gold_costs", GetGoldCosts );
    GameEvents.Subscribe( "petri_set_dependencies_table", GetDependencies );
    GameEvents.Subscribe( "petri_set_special_values_table", GetSpecialValues );
    $.Schedule(1, HidePanels);
	$.Schedule(1, UpdateResources);
})();