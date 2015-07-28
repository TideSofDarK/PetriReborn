"use strict";

var currentResources = {};

(function(){Math.clamp=function(a,b,c){return Math.max(b,Math.min(c,a));}})();

function UpdateResources( args )
{
	 GameUI.CustomUIConfig().unitResources = args;


	 $.GetContextPanel().FindChild("TotalGoldText").text = args["gold"];
	 $.GetContextPanel().FindChild("TotalLumberText").text = args["lumber"];
	 $.GetContextPanel().FindChild("TotalFoodText").text = args["food"] + "/" + String(Math.clamp(parseInt(args["maxFood"]),0,250));
}

(function() 
{
    GameEvents.Subscribe( "receive_resources_info", UpdateResources);
})();