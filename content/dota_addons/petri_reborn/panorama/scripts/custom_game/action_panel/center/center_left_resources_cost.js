"use strict";
function HidePanels()
{
	var localPlayer = Game.GetLocalPlayerInfo();
	var localPlayerTeamId;
	if ( localPlayer )
		localPlayerTeamId = localPlayer.player_team_id;

	if (localPlayerTeamId)
	{
		var resourcePanel = $( "#TotalResources" ).FindChild( "ResourcePanel" );
		switch(localPlayerTeamId)
		{
			case DOTATeam_t.DOTA_TEAM_GOODGUYS:
				$( "#AbilityCost" ).style["visibility"] = "visible;";
				resourcePanel.FindChild("TotalLumberText").style["visibility"] = "visible;";
				resourcePanel.FindChild("TotalFoodText").style["visibility"] = "visible;";
				break;
  			case DOTATeam_t.DOTA_TEAM_BADGUYS:
				$( "#AbilityCost" ).style["visibility"] = "collapse;";
				resourcePanel.FindChild("TotalLumberText").style["visibility"] = "collapse;";
				resourcePanel.FindChild("TotalFoodText").style["visibility"] = "collapse;";
				break;
		}
	}
}

(function() {
	// Подписываемся на событие "Смена команды"
    GameEvents.Subscribe("player_team", HidePanels);
})();