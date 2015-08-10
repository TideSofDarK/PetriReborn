"use strict";

var m_Unit = null;

function LoadUIElements()
{
	$( "#BuffPanel" ).BLoadLayout( "file://{resources}/layout/custom_game/action_panel/center_buff_list.xml", false, false );
    $( "#CenterLeft" ).BLoadLayout( "file://{resources}/layout/custom_game/action_panel/center/center_left.xml", false, false );
    $( "#CenterRight" ).BLoadLayout( "file://{resources}/layout/custom_game/action_panel/center/center_right.xml", false, false );
}

function FormatRegen( regen )
{
	return (regen > 0 ? "+" : "-" ) + regen;
}

function SetDead( isDead )
{
	var healthManaPanel = $.GetContextPanel().FindChild( "HealthAndMana" );
	var respawnPanel = $.GetContextPanel().FindChild( "RespawnPanel" );

	healthManaPanel.SetHasClass("dead", isDead);	
	respawnPanel.SetHasClass("dead", isDead);

	var respawnTimer = respawnPanel.FindChild( "RespawnTimer" );
	var localPlayer = Game.GetLocalPlayerInfo();
	respawnTimer.text = $.Localize( "#respawn_in" ) + (localPlayer.player_respawn_seconds + 1) + " ..."
}

function UpdateHealthAndMana()
{
	SetDead( !Entities.IsAlive(m_Unit) );

	var healthManaPanel = $( "#HealthAndMana" );
	if (healthManaPanel)
	{
		var mana = Entities.GetMana(m_Unit);
		var health = Entities.GetHealth(m_Unit);

		var manaRegen = Entities.GetManaThinkRegen(m_Unit);
		var healthRegen = Entities.GetHealthThinkRegen(m_Unit);

		var maxMana = Entities.GetMaxMana(m_Unit);
		var maxHealth = Entities.GetMaxHealth(m_Unit);

		var healthPanel = healthManaPanel.FindChild( "Health" )
		healthPanel.style.width = (maxHealth > 0 ? health / maxHealth * 100 : 0 )+ "%;"

		healthPanel.SetHasClass("enemy", Entities.IsEnemy( m_Unit ));

		var manaPanel = healthManaPanel.FindChild( "Mana" )
		manaPanel.style.width = (maxMana > 0 ? mana / maxMana * 100 : 0 ) + "%;";

		healthManaPanel.FindChild( "HealthCount" ).text = health + "/" + maxHealth;
		healthManaPanel.FindChild( "ManaCount" ).text = mana + "/" + maxMana;

		var regHPanel = healthManaPanel.FindChild( "HealthRegen" );
		regHPanel.text = FormatRegen( healthRegen );
		regHPanel.SetHasClass("visible", health < maxHealth);

		var regMPanel = healthManaPanel.FindChild( "ManaRegen" )
		regMPanel.text = FormatRegen( manaRegen );
		regMPanel.SetHasClass("visible", mana < maxMana);
	}
}


function UpdateCenter()
{
	m_Unit = GameUI.CustomUIConfig().selected_unit;

	UpdateHealthAndMana();

	$( "#BuffPanel" ).data().UpdateBuffs();
	$( "#CenterLeft" ).data().UpdateCenterLeft();
	$( "#CenterRight" ).data().UpdateCenterRight();
}

(function() {
	$.GetContextPanel().data().UpdateCenter = UpdateCenter;	

	LoadUIElements();
})();