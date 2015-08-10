'use strict';

var state = 'disabled';
var size = 0;

function StartBuildingHelper( params )
{
  if (params !== undefined)
  {
    state = params["state"];
    size = params["size"];
  }
  if (state === 'active')
  {
    $.Schedule(0.001, StartBuildingHelper);
    var mPos = GameUI.GetCursorPosition();

    //mPos[0] = (mPos[0] * 1.0 / $( "#BuildingHelperBase").desiredlayoutwidth ) * Math.max(1920, $( "#BuildingHelperBase").desiredlayoutwidth );
    //mPos[1] = (mPos[1] * 1.0 / $( "#BuildingHelperBase").desiredlayoutheight) * Math.max(1080, $( "#BuildingHelperBase").desiredlayoutheight );

    mPos[0] = (mPos[0] * 1.0 / $( "#BuildingHelperBase").desiredlayoutwidth ) * 1920.0;
    mPos[1] = (mPos[1] * 1.0 / $( "#BuildingHelperBase").desiredlayoutheight) * 1080.0;

    $( "#GreenSquare").style['height'] = String(100) + "px;";
    $( "#GreenSquare").style['width'] = String(100) + "px;";
    $( "#GreenSquare").style['margin'] = String(mPos[1] - (25 * size)) + "px 0px 0px " + String(mPos[0] - (25 * size)) + "px;";
    $( "#GreenSquare").style['transform'] = "rotateX( 30deg );";
  }
}

function SendBuildCommand( params )
{
  var mPos = GameUI.GetCursorPosition();
  var GamePos = Game.ScreenXYToWorld(mPos[0], mPos[1]);
  GameEvents.SendCustomGameEventToServer( "building_helper_build_command", { "X" : GamePos[0], "Y" : GamePos[1], "Z" : GamePos[2] } );
  //if (!GameUI.IsShiftDown())
  //{
  state = 'disabled'
  $( "#GreenSquare").style['margin'] = "-1000px 0px 0px 0px;";
  //}
}

function SendCancelCommand( params )
{
  Cancel(params);
  GameEvents.SendCustomGameEventToServer( "building_helper_cancel_command", {} );
}

function Cancel(params) {
  state = 'disabled'
  $( "#GreenSquare").style['margin'] = "-1000px 0px 0px 0px;"; 
}

/*function OnUpdateSelectedUnit( event )
{
  var iPlayerID = Players.GetLocalPlayer();
  var selectedEntities = Players.GetSelectedEntities( iPlayerID );
  var mainSelected = Players.GetQueryUnit(iPlayerID);

  //$.Msg( "OnUpdateSelectedUnit" );
  $.Msg( selectedEntities );
  GameEvents.SendCustomGameEventToServer( "custom_dota_player_update_selected_unit", { "player_id" : iPlayerID, 
    "main_unit" : mainSelected} );
}*/

(function () {
  GameEvents.Subscribe( "building_helper_enable", StartBuildingHelper);
  GameEvents.Subscribe( "building_helper_force_cancel", Cancel);
  //GameEvents.Subscribe( "dota_player_update_selected_unit", OnUpdateSelectedUnit );
})();