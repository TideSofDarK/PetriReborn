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
    $( "#Portrait" ).data().UpdatePortrait();
    $( "#Center" ).data().UpdateCenter();

	$.Schedule( 0.2, Update );
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

function SetSelectedUnit()
{
    GameUI.CustomUIConfig().selected_unit = Players.GetLocalPlayerPortraitUnit();
}

(function() {
	// Loading all parts of action_panel
	LoadUIElements();

    GameEvents.Subscribe( "dota_player_update_selected_unit", SetSelectedUnit );
    GameEvents.Subscribe( "dota_player_update_query_unit", SetSelectedUnit );
    
    GameEvents.Subscribe( "petri_set_gold_costs", GetGoldCosts );
    GameEvents.Subscribe( "petri_set_dependencies_table", GetDependencies );
    GameEvents.Subscribe( "petri_set_special_values_table", GetSpecialValues );

    Update();
})();