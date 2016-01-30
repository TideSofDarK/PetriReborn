'use strict';

var state = 'disabled';

var GNVPanel = null;

function StartBuildingHelper( params )
{
    state = params["state"];
    if (params !== undefined && state == 'active')
    {
        $("#BuildingHelperBase").hittest = true;
        GNVPanel.CreateParticles( params );
    }
}

function SendBuildCommand( params )
{
  var mPos = GameUI.GetCursorPosition();
  var GamePos = Game.ScreenXYToWorld(mPos[0], mPos[1]);
  GameEvents.SendCustomGameEventToServer( "building_helper_build_command", { "X" : GamePos[0], "Y" : GamePos[1], "Z" : GamePos[2] } );

  Cancel(params);
}

function SendCancelCommand( params )
{
  Cancel();
  GameEvents.SendCustomGameEventToServer( "building_helper_cancel_command", {} );
}

function Cancel() {
    state = 'disabled'

    GNVPanel.DestroyParticles();

    $("#BuildingHelperBase").hittest = false;
}

(function () {
    // Load GridNav module
    GNVPanel = $( "#GNV");
    GNVPanel.BLoadLayout( "file://{resources}/layout/custom_game/building_helper/gnv.xml", false, false );

    GameEvents.Subscribe( "building_helper_enable", StartBuildingHelper);
    GameEvents.Subscribe( "building_helper_force_cancel", Cancel);
})();