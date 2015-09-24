"use strict";
function Vote( param, value )
{
	GameEvents.SendCustomGameEventToServer( "petri_vote	", { "param" : value } );
}