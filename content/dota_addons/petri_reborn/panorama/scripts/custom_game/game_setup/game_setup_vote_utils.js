"use strict";

var syncDelay = 0.5;

function Vote( value )
{
	var variants = $("#VoteVariants");
	variants.enabled = false;

	var param = variants.GetAttributeString("param", "non_param")
	var params = {};
	params[param] = value;

	GameEvents.SendCustomGameEventToServer( "petri_vote", params );
}

//--------------------------------------------------------------------------------------------------
// Set universal handler
//--------------------------------------------------------------------------------------------------
function SetClickHandler()
{
	var childCount = $.GetContextPanel().GetChildCount();
	for (var i = 0; i < childCount; i++) 
	{
		var curVotePanel = $.GetContextPanel().GetChild(i);

		var variants = curVotePanel.FindChild( "VoteVariants" );
		var variantsCount = variants.GetChildCount();

		for (var j = 0; j < variantsCount; j++) {
			var child = variants.GetChild(j);
			var isDefault = child.GetAttributeString("default", "false");

			// Click event
			var click = (function( panel ) { 
				return function() {
					$.GetContextPanel().IsVoted = true;
					panel.SetHasClass("selected", true);
					$("#VoteVariants").enabled = false;

					Vote( panel.GetAttributeString("value", "") );
				}
			} (child));

			if (isDefault == "true")
				curVotePanel.VoteDefault = click;

			child.SetPanelEvent("onmouseactivate", click);
		};
	};	
}

function SetVoteTime( time )
{
	$.Schedule( time - syncDelay, function(){
		if (!$.GetContextPanel().IsVoted)
			$.GetContextPanel().GetChild(0).VoteDefault();
	});
}

(function ()
{
	$.GetContextPanel().IsVoted = false;
	$.GetContextPanel().SetVoteTime = SetVoteTime;

	SetClickHandler();
})();