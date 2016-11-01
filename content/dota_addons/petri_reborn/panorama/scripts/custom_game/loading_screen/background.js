'use strict';
// Current date
var date = new Date();
var curDate = date.getFullYear() * 10000 + (date.getMonth() + 1) * 100 + date.getDate();

var backgroundPath = "file://{resources}/layout/custom_game/loading_screen/backgrounds/";
var backgroundPanel = $( "#CustomBackground" );

//-----------------------------------------------------------------------------
//						Default backgrounds
//-----------------------------------------------------------------------------
var defaultBackgrounds = [
	"default"
];

//-----------------------------------------------------------------------------
//						Halloween backgrounds
//-----------------------------------------------------------------------------
var halloween = [
	"halloween"
];

function SetBackground()
{
	var backList = defaultBackgrounds;
	var dayMonth = curDate % 10000;

	// if (dayMonth > 1024 && dayMonth < 1107)
	// 	backList = halloween;

	var backNum = Math.floor(Math.random() * backList.length);
	backgroundPanel.BLoadLayout( backgroundPath + backList[backNum] + ".xml", false, false );
}

(function () {
	SetBackground();
})(); 