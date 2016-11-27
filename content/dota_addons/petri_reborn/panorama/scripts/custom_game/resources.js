"use strict";

var currentResources = {};

(function(){Math.clamp=function(a,b,c){return Math.max(b,Math.min(c,a));}})();

function commafy( num ) {
    var str = num.toString().split('.');
    if (str[0].length >= 5) {
        str[0] = str[0].replace(/(\d)(?=(\d{3})+$)/g, '$1,');
    }
    if (str[1] && str[1].length >= 5) {
        str[1] = str[1].replace(/(\d{3})/g, '$1 ');
    }
    return str.join('.');
}

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
 		$( "#TotalGoldText" ).text = isEnemy ? "0" : commafy(resourceTable["gold"]);
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
	for (var ab in eventArgs) {
		for (var lvl in eventArgs[ab]) {
			eventArgs[ab][lvl] = eventArgs[ab][lvl].replace("%", "");
		}
	}
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

    GameEvents.Subscribe("petri_set_builds", (function (eventArgs) {
        GameUI.CustomUIConfig().itemBuilds = {};
        for (var hero in eventArgs) {
            GameUI.CustomUIConfig().itemBuilds[hero] = {};
            GameUI.CustomUIConfig().itemBuilds[hero].Items = {};
            var s = 1;
            for (var t in eventArgs[hero].Items) {
                var i = 1;
                GameUI.CustomUIConfig().itemBuilds[hero].Items["#"+hero+s] = {};
                for (var item in eventArgs[hero].Items["#"+hero+s]) {
                    GameUI.CustomUIConfig().itemBuilds[hero].Items["#"+hero+s][i] = eventArgs[hero].Items["#"+hero+s]["item"+i];
                    i++;
                }
                s++;
            }
        }
        $.Msg(GameUI.CustomUIConfig().itemBuilds);
    }));

    GameEvents.Subscribe( "petri_set_shops", (function (eventArgs) {
    	GameUI.CustomUIConfig().shopsKVs = {};
    	for (var t in eventArgs) {
    		GameUI.CustomUIConfig().shopsKVs[t] = {};
    		var i = 1;
    		for (var item in eventArgs[t]) {
    			$.Msg("item"+i);
    			GameUI.CustomUIConfig().shopsKVs[t][i] = eventArgs[t]["item"+i];
    			i++;
    		}
    	}
    	$.Msg(GameUI.CustomUIConfig().shopsKVs);
    }));
    GameEvents.Subscribe( "petri_set_items", (function (eventArgs) {
    	GameUI.CustomUIConfig().itemsKVs = eventArgs;
    }));
    GameEvents.Subscribe( "petri_set_gold_costs", GetGoldCosts );
    GameEvents.Subscribe( "petri_set_dependencies_table", GetDependencies );
    GameEvents.Subscribe( "petri_set_special_values_table", GetSpecialValues );
    $.Schedule(1, HidePanels);
	$.Schedule(1, UpdateResources);
})();