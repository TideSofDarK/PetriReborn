'use strict';

var upgrade = true;
var curNum = -1;
var endTime = 0;

function BetEntryHover()
{
	var betEntry = $( "#BetPanel" ).FindChild( "BetEntry" );
	if (betEntry.text == $.Localize( "#exchange_bet_text" ) )
		betEntry.text = "";
}

function BetStopHover()
{
	var betEntry = $( "#BetPanel" ).FindChild( "BetEntry" );
	if (betEntry.text == "" && !betEntry.BHasKeyFocus())
		betEntry.text = $.Localize( "#exchange_bet_text" );
}

function MakeBetClick()
{
	if (curNum == -1)
		return;

	var betEntry = $( "#BetPanel" ).FindChild( "BetEntry" );
	var bet = parseInt(betEntry.text);
	var playerGold = Players.GetGold(Players.GetLocalPlayer());

	if (bet <= playerGold)
	{
		$( "#BetPanel" ).FindChild( "BetEntry" ).enabled = false;
		$( "#BetPanel" ).FindChild( "Companies" ).enabled = false;

		var button = $( "#BetPanel" ).FindChild( "MakeBet" );
		button.enabled = false;
		button.SetHasClass("on_bet", true);
		
  		GameEvents.SendCustomGameEventToServer( "petri_make_bet", { "pID" : Players.GetLocalPlayer(), "bet" : bet, "option" : (curNum + 1) } );		
	}
}

function ClickNum()
{
	var numbers = $( "#BetPanel" ).FindChild( "Companies" );
	var childsCount = numbers.GetChildCount();
	for (var i = 0; i < childsCount; i++) 
	{
		var num = numbers.GetChild(i);
		num.SetHasClass("checked", num.checked);
		if (num.checked)
			curNum = i;
	};
}

function UpdateCountdown()
{
	$( "#Countdown" ).text = endTime - Math.floor( Game.GetDOTATime( false, false) );
	if (endTime - Math.floor( Game.GetDOTATime( false, false) ) >= 1) 
	{
		$.Schedule( 1.0, UpdateCountdown );
	} 
}

function InitExchange( args )
{
	var upgrades = CustomNetTables.GetTableValue( "players_upgrades", Players.GetLocalPlayer().toString() )
	if (upgrades == undefined)
		return;

	if (upgrades["petri_upgrade_exchange"] == 1) 
	{
		upgrade = true;

		//args = { "exchinge_time" : 180 };
		endTime = Math.floor( Game.GetDOTATime( false, false) ) + args["exchinge_time"];
		UpdateCountdown();

		$.GetContextPanel().style.width = "220px;";

		$( "#Bank" ).text = 0;	

		var makeBet = $( "#BetPanel" ).FindChild( "MakeBet" );
		makeBet.enabled = true;
		makeBet.SetHasClass("on_bet", false);

		$( "#BetPanel" ).FindChild( "BetEntry" ).enabled = true;
		$( "#BetPanel" ).FindChild( "Companies" ).enabled = true;
		
		curNum = -1;

		var numbers = $( "#BetPanel" ).FindChild( "Companies" );
		var childsCount = numbers.GetChildCount();
		for (var i = 0; i < childsCount; i++) 
		{
			var num = numbers.GetChild(i);
			num.checked = false;
			num.SetHasClass("checked", num.checked);
			num.SetHasClass("winner", false);
		};	
	}
}

function HidePanel()
{
	$.GetContextPanel().style.width = "0px;";
}

function FinishExchange( args )
{
	var upgrades = CustomNetTables.GetTableValue( "players_upgrades", Players.GetLocalPlayer().toString() )

	if (upgrades["petri_upgrade_exchange"] == 1 && upgrade == true) 
	{
		//args = { "winner" : 2 };
		var numbers = $( "#BetPanel" ).FindChild( "Companies" );
		var childsCount = numbers.GetChildCount();
		for (var i = 0; i < childsCount; i++) 
		{
			var num = numbers.GetChild(i);
			num.SetHasClass("winner", i == args["winner"]);
		};	
		
		$.Schedule( 5.0, HidePanel );
	}
}

function UpdateBank( args )
{
	//args = { "bank" : 1000 };
	$( "#Bank" ).text = args["bank"];	
}

(function () {
  	GameEvents.Subscribe( "petri_start_exchange", InitExchange );
  	GameEvents.Subscribe( "petri_bank_updated", UpdateBank );
  	GameEvents.Subscribe( "petri_finish_exchange", FinishExchange );
})();