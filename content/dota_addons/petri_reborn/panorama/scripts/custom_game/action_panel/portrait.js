function UpdatePortrait()
{
	//var exp = Players.GetTotalEarnedXP( Game.GetLocalPlayerID() );
	//$.Msg("exp = ", exp);
	
	var unit = GameUI.CustomUIConfig().selected_unit;
	var unitLevel = Entities.GetLevel( unit );
	var unitName = Entities.GetUnitName(unit);

	$( "#HeroName" ).text = $.Localize( "#" + unitName );
	$( "#HeroLevel" ).text = unitLevel;

	//$.Msg("exp = ", unitName);
}

(function() {
	$.GetContextPanel().data().UpdatePortrait = UpdatePortrait;	
	
	GameEvents.Subscribe( "dota_player_gained_level", UpdatePortrait );		
})();