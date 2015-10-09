"use strict";

function DismissMenu()
{
	$.DispatchEvent( "DismissAllContextMenus" )
}

function VoteKick()
{
	DismissMenu();	
}
