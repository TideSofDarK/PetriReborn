"use strict";

var layouts = null;

function AddDivider()
{
	var divider = $.CreatePanel( "Panel", $.GetContextPanel(), "divider" );
	divider.AddClass("divider");
	divider.SetHasClass("divider", true);
}

function FillDataTable( xmlLayoutList )
{
	layouts = xmlLayoutList;

	$( "#Header" ).RemoveAndDeleteChildren();
	$( "#Header" ).BLoadLayout( layouts["Header"], false, false );

	// Add blank row to fit width
	$( "#Data" ).RemoveAndDeleteChildren();
	$( "#Header" ).BLoadLayout( layouts["DataRow"], false, false );
}

function UpdateData( dataArray )
{
	$( "#Data" ).RemoveAndDeleteChildren();

	for (var i in dataArray)
	{
		var panel = $.CreatePanel( "Panel", $( "#Data" ), "DataRow" + i );
		panel.BLoadLayout( layouts["DataRow"], false, false );

		panel.FillRowData( dataArray[i] );
		panel.Data = dataArray[i];
	}
}

(function()
{
	$.GetContextPanel().FillDataTable = FillDataTable;
	$.GetContextPanel().UpdateData = UpdateData;
})();