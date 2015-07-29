function LoadUIElements()
{
    $( "#MinimapBorder" ).BLoadLayout( "file://{resources}/layout/custom_game/action_panel/minimap_border.xml", false, false );
    $( "#Spacer" ).BLoadLayout( "file://{resources}/layout/custom_game/action_panel/spacer.xml", false, false );
    $( "#Portrait" ).BLoadLayout( "file://{resources}/layout/custom_game/action_panel/portrait.xml", false, false );
    $( "#Center" ).BLoadLayout( "file://{resources}/layout/custom_game/action_panel/center.xml", false, false );
}

// Cascade updating
function Update()
{
	GameUI.CustomUIConfig().selected_unit = Players.GetLocalPlayerPortraitUnit();

    $( "#Portrait" ).data().UpdatePortrait();
    $( "#Center" ).data().UpdateCenter();

	$.Schedule( 0.2, Update );
}

function GetGoldCosts( eventArgs )
{
    GameUI.CustomUIConfig().goldCosts = eventArgs;
}

(function() {
	// Loading all parts of action_panel
	LoadUIElements();

	GameEvents.Subscribe( "dota_player_update_selected_unit", Update );    
    GameEvents.Subscribe( "petri_set_gold_costs", GetGoldCosts );
})();