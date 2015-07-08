(function(){Math.clamp=function(a,b,c){return Math.max(b,Math.min(c,a));}})();

function UpdateResources(args)
{
	$("#GoldText").text = args["gold"];
	$("#LumberText").text = args["lumber"];
	$("#FoodText").text = args["food"] + "/" + String(Math.clamp(parseInt(args["maxFood"]),0,250));
}

(function()
{
	GameEvents.Subscribe( "receive_resources_info", UpdateResources);
})();
