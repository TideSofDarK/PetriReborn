"use strict";

var m_Unit = -1;

function LoadUIElements()
{
	$( "#AbilitiesContainer" ).BLoadLayout( "file://{resources}/layout/custom_game/action_panel/center/abilities/abilities_container.xml", false, false );
}

function UpdateCenterRight()
{
	m_Unit = GameUI.CustomUIConfig().selected_unit;
	$( "#AbilitiesContainer" ).data().UpdateAbilitiesContainer();
}

(function() {
	$.GetContextPanel().data().UpdateCenterRight = UpdateCenterRight;	

	LoadUIElements();
})();