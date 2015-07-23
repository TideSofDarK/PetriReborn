'use strict';

var abilityLayouts = {}

function GetPresentAbilities(entity, count) {
	var presentAbilities = new Array(count);
    
	for (var i = 0; i < 16; i++) {
    	var ability = Entities.GetAbility(entity, i );
    	
    	if (Abilities.IsDisplayedAbility ( ability ) ) {
    		presentAbilities[Object.keys(presentAbilities).length] = ability;
    		if (Object.keys(presentAbilities).length == count) {
    			return presentAbilities;
    		}
    	}
    }
    return presentAbilities;
}

function SetAbilitiesFoodAndLumber(abilities, count) {
	for (var i = 0; i < count; i++) {

        var lumberElement = "#Layout" + String(count) + "Ability" + String(i+1) + "Lumber";
        var foodElement = "#Layout" + String(count) + "Ability" + String(i+1) + "Food";

        if (Object.keys(abilities).length-1<i) {
            $(foodElement).style['visibility'] = "collapse;";
            $(lumberElement).style['visibility'] = "collapse;";
        }
        else {
            var ability_level = Abilities.GetLevel(abilities[i]);

            var lumber_cost = Abilities.GetLevelSpecialValueFor( abilities[i], "lumber_cost", ability_level - 1 )
            var food_cost = Abilities.GetLevelSpecialValueFor( abilities[i], "food_cost", ability_level - 1 )

            
            if (lumber_cost == 0) {
                $(lumberElement).style['visibility'] = "collapse;";
            }
            else {
                $(lumberElement).style['visibility'] = "visible;";
                $(lumberElement + "Text").text = String(lumber_cost);
            }

            
            if (food_cost == 0) {
                $(foodElement).style['visibility'] = "collapse;";
            }
            else {
                $(foodElement).style['visibility'] = "visible;";
                $(foodElement + "Text").text = String(food_cost);
            }
        }
    }
}

function OnUpdateSelectedUnit() {
    $.Schedule(0.003, OnUpdateSelectedUnit);

    var iPlayerID = Players.GetLocalPlayer();
    var selectedEntities = Players.GetSelectedEntities(iPlayerID);
    var mainSelected = Players.GetLocalPlayerPortraitUnit();

    var unitName = Entities.GetUnitName(mainSelected);
    var layout = abilityLayouts[unitName]

    if (!Entities.IsEnemy(mainSelected) && Entities.IsControllableByPlayer( mainSelected, iPlayerID)) {
        if (layout <= 4) {
            $("#Layout4").style['visibility'] = "visible;";

            $("#Layout5").style['visibility'] = "collapse;";
            $("#Layout6").style['visibility'] = "collapse;";

            SetAbilitiesFoodAndLumber(GetPresentAbilities(mainSelected, 4), 4);
        } else if (layout == 5) {
            $("#Layout5").style['visibility'] = "visible;";

            $("#Layout6").style['visibility'] = "collapse;";
            $("#Layout4").style['visibility'] = "collapse;";

            SetAbilitiesFoodAndLumber(GetPresentAbilities(mainSelected, 5), 5);
        } else if (layout >= 6) {
            $("#Layout6").style['visibility'] = "visible;";

            $("#Layout5").style['visibility'] = "collapse;";
            $("#Layout4").style['visibility'] = "collapse;";

            SetAbilitiesFoodAndLumber(GetPresentAbilities(mainSelected, 6), 6);
        }
    } else {
        $("#Layout4").style['visibility'] = "collapse;";
        $("#Layout5").style['visibility'] = "collapse;";
        $("#Layout6").style['visibility'] = "collapse;";
    }

}

function SetAbilityLayouts(event) {
    abilityLayouts = event;
}

(function() {
    GameEvents.Subscribe("petri_set_ability_layouts", SetAbilityLayouts);
    //GameEvents.Subscribe("dota_player_update_selected_unit", OnUpdateSelectedUnit);
    OnUpdateSelectedUnit();
})();
