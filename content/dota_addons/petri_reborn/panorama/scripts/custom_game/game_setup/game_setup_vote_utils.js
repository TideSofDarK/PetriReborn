"use strict";

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
	var variants = $("#VoteVariants");
	var childCount = variants.GetChildCount();

	for (var i = 0; i < childCount; i++) {
		var child = variants.GetChild(i);
		var isDefault = child.GetAttributeString("default", "false");

		// Click event
		var click = (function( panel ) { 
			return function() {
				$.GetContextPanel().data().IsVoted = true;
				panel.SetHasClass("selected", true);
				$("#VoteVariants").enabled = false;

				Vote( panel.GetAttributeString("value", "") );
			}
		} (child));

		if (isDefault == "true")
			$.GetContextPanel().data().VoteDefault = click;

		child.SetPanelEvent("onmouseactivate", click);
	};	
}

(function ()
{
	$.GetContextPanel().data().IsVoted = false;

	SetClickHandler();
})();