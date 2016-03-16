'use strict';
var tableLayoutPath = "file://{resources}/layout/custom_game/MaterialDesign/";

function AddMMRTable()
{
	$( "#MMR" ).RemoveAndDeleteChildren();
	$( "#MMR" ).BLoadLayout( tableLayoutPath + "DataTable.xml", false, false );

	var layout = {
		"Header" : tableLayoutPath + "MMRTable/Header.xml",
		"DataRow" : tableLayoutPath + "MMRTable/DataRow.xml"
	}

	$( "#MMR" ).FillDataTable( layout );  
}

function UpdateMMRTable( data )
{
	$( "#MMR" ).UpdateData( data );
	$( "#HideStat" ).SetHasClass("hide", true);
	$( "#Statistics" ).visible = true;
}

function OnHideStat()
{
	var isHide = $( "#MMR" ).visible;
	$( "#HideStat" ).SetHasClass("hide", isHide);
	$( "#MMR" ).visible = !isHide;
}

(function () {
	AddMMRTable(); 
 
	GameEvents.Subscribe( "su_send_mmr", UpdateMMRTable);
})(); 