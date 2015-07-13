'use strict';

var abilityLayouts = {}

function FindByName(array, name) {
	    for (var i=0, len=array.length; i<len; i++) {
	        if (array[i].name === name) return array[i].value;
	    }
	}

function OnUpdateSelectedUnit( event )
{
  var iPlayerID = Players.GetLocalPlayer();
  var selectedEntities = Players.GetSelectedEntities( iPlayerID );
  var mainSelected = Players.GetLocalPlayerPortraitUnit();

  var unitName = Entities.GetUnitName(mainSelected);
  var layout = abilityLayouts[unitName]

  if (layout <= 4) 
  {
  	$( "#Layout4").style['visibility'] = "visible;";

  	$( "#Layout5").style['visibility'] = "collapse;";
  	$( "#Layout6").style['visibility'] = "collapse;";
  }
  else if (layout == 5) 
  {
	$( "#Layout5").style['visibility'] = "visible;";

	$( "#Layout6").style['visibility'] = "collapse;";
  	$( "#Layout4").style['visibility'] = "collapse;";
  }
  else if (layout >= 6) 
  {
  	$( "#Layout6").style['visibility'] = "visible;";

  	$( "#Layout5").style['visibility'] = "collapse;";
  	$( "#Layout4").style['visibility'] = "collapse;";
  }
}

function SetAbilityLayouts(event)
{
	abilityLayouts = event;
	$.Msg( "OnMyEvent: ", abilityLayouts );
}

(function () {
	GameEvents.Subscribe( "petri_set_ability_layouts", SetAbilityLayouts );
	GameEvents.Subscribe( "dota_player_update_selected_unit", OnUpdateSelectedUnit );
})();