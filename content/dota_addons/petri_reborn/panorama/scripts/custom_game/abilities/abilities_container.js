"use strict";

var m_AbilityPanels = []; // created up to a high-water mark, but reused when selection changes
var m_QueryUnit = -1;

// Hide skills enemy skills information
function IsEnemySelected()
{
	return Entities.IsEnemy(GameUI.CustomUIConfig().selected_unit);
}

//
function GetSelectedUnitOwner()
{
	var teamNum = Entities.GetTeamNumber(GameUI.CustomUIConfig().selected_unit);
	var playerIDs = Game.GetPlayerIDsOnTeam( teamNum );

	if (!playerIDs || playerIDs == undefined)
		return - 1;
	
	for (var id of playerIDs)
		if (Entities.IsControllableByPlayer( GameUI.CustomUIConfig().selected_unit, id))
			return id;

	return -1;
}

function UpdateAbilitiesContainer()
{
	var queryUnit = GameUI.CustomUIConfig().selected_unit;
	var abilityListPanel = GameUI.CustomUIConfig().abilities.Children();

	// $.GetContextPanel().SetHasClass( "flip", Game.IsHUDFlipped())

	var bSameUnit = ( m_QueryUnit == queryUnit );
	m_QueryUnit = queryUnit;

	// see if we can level up
	var nRemainingPoints = Entities.GetAbilityPoints( queryUnit );
	var bPointsToSpend = ( nRemainingPoints > 0 );
	var bControlsUnit = Entities.IsControllableByPlayer( queryUnit, Game.GetLocalPlayerID() );
	$.GetContextPanel().SetHasClass( "could_level_up", ( bControlsUnit && bPointsToSpend ) );

	if ( !bPointsToSpend )
		Game.EndAbilityLearnMode();

	for ( var i = 0; i < Entities.GetAbilityCount( m_QueryUnit ); ++i )
	{
		// Костыль на количество отображаемых скиллов
		if ( i > 6)
			break;

		var ability = Entities.GetAbility( m_QueryUnit, i );
		var name = Abilities.GetAbilityName(ability)

		if ( ability == -1 )
			continue;

		if ( !Abilities.IsDisplayedAbility( ability ) )
			continue;

	    for (var p in abilityListPanel) {
	    	var panel = abilityListPanel[p];

			if (panel.FindChildTraverse("AbilityImage").abilityname == name) {
				var button = panel.FindChildTraverse("AbilityButton");
				try {
					// if (button.subPanel) {
						// button.subPanel.RemoveAndDeleteChildren()
						// button.subPanel.DeleteAsync(0.0);
					// }
					if (!button.subPanel) {
						button.subPanel = $.CreatePanel( "Panel", button, name );
						button.subPanel.BLoadLayout( "file://{resources}/layout/custom_game/abilities/ability.xml", false, false );
					}
					button.subPanel.SetAbility(ability, m_QueryUnit);
				} catch (err) {

				}
			}
	    }
	}
}

function Update()
{
	UpdateAbilitiesContainer();
	$.Schedule( 0.07, Update );
}

function SetQueryUnit()
{
    GameUI.CustomUIConfig().selected_unit = Players.GetLocalPlayerPortraitUnit();
}

function SetSelectedUnit()
{
    SetQueryUnit();

	var iPlayerID = Players.GetLocalPlayer();
	var selectedEntities = Players.GetSelectedEntities( iPlayerID );
	var mainSelected = Players.GetLocalPlayerPortraitUnit();

	GameEvents.SendCustomGameEventToServer( "update_selected_entities", { pID: iPlayerID, selected_entities: selectedEntities })
}

(function()
{
	GameUI.CustomUIConfig().IsEnemySelected = IsEnemySelected;
	GameUI.CustomUIConfig().GetSelectedUnitOwner = GetSelectedUnitOwner;

	GameEvents.Subscribe( "dota_player_update_selected_unit", SetSelectedUnit );
	GameEvents.Subscribe( "dota_player_update_query_unit", SetQueryUnit );

	var iPlayerID = Players.GetLocalPlayer();
	GameEvents.SendCustomGameEventToServer( "set_player_name", { pID: iPlayerID, name: Game.GetPlayerInfo( iPlayerID ).player_name })


	$.Schedule(5.0, function () {
		GameUI.CustomUIConfig().Hack();

		GameEvents.Subscribe( "dota_ability_changed", UpdateAbilitiesContainer );

		UpdateAbilitiesContainer()
		Update();
	})
})();

