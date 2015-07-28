"use strict";

var m_Unit = -1;
var infoPanel;
var statsPanel;
var costsPanel;

function LoadUIElements()
{
	infoPanel = $( "#InfoPanel" ).FindChild( "Info" );
	statsPanel = $( "#InfoPanel" ).FindChild( "Stats" );
	costsPanel = $( "#InfoPanel" ).FindChild( "ResourcesCost" );
	
	infoPanel.BLoadLayout( "file://{resources}/layout/custom_game/action_panel/center/center_left_info.xml", false, false );

	var playerInfo = Game.GetLocalPlayerInfo();

	switch(playerInfo.player_team_id)
	{
		case DOTATeam_t.DOTA_TEAM_GOODGUYS: 
			costsPanel.BLoadLayout( "file://{resources}/layout/custom_game/action_panel/center/center_left_resources_cost.xml", false, false );
			break;
		case DOTATeam_t.DOTA_TEAM_BADGUYS:
		    statsPanel.BLoadLayout( "file://{resources}/layout/custom_game/action_panel/center/center_left_stats.xml", false, false );
			break;
	}
}

function ShowDamageTooltip()
{
	var attackSpeed = Entities.GetBaseAttackTime( Players.GetLocalPlayerPortraitUnit() );
	$.DispatchEvent( "DOTAShowTextTooltip", $.Localize( "#damage_speed" ) + Math.round(attackSpeed * 100) / 100 );
}

function HideDamageTooltip()
{
	$.DispatchEvent( "DOTAHideTextTooltip" );
}

function UpdateInfo()
{
	if (!infoPanel)
		return;
	
	var damage = (Entities.GetDamageMax( m_Unit ) + Entities.GetDamageMin( m_Unit )) / 2;
	var bonusDamage = Entities.GetDamageBonus( m_Unit );
	infoPanel.FindChild( "Damage" ).text = damage + bonusDamage;

	infoPanel.FindChild( "Armor" ).text = Math.floor( Entities.GetArmorForDamageType( m_Unit, DAMAGE_TYPES.DAMAGE_TYPE_PHYSICAL ) );

	var msModifier = Entities.GetMoveSpeedModifier( m_Unit, Entities.GetBaseMoveSpeed( m_Unit ) );
	infoPanel.FindChild( "Speed" ).text = msModifier;
}

function UpdateStats()
{
}

function UpdateInfoAndStats()
{
	if (m_Unit == -1)
		return;

	UpdateInfo();
	UpdateStats();
}

function UpdateCenterLeft()
{
	m_Unit = GameUI.CustomUIConfig().selected_unit

	UpdateInfoAndStats();
}

(function() {
	$.GetContextPanel().data().UpdateCenterLeft = UpdateCenterLeft;	

	LoadUIElements();
})();