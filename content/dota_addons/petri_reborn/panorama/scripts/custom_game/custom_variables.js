function UpdateResources(args)
{
	$("#GoldText").text = args["gold"];
	$("#LumberText").text = args["lumber"];
	$("#FoodText").text = args["food"] + "/" + args["maxFood"];
}

(function()
{
	GameEvents.Subscribe( "receive_resources_info", UpdateResources);
})();
