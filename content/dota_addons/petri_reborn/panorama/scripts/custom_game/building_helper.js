'use strict';

var state = 'disabled';
var size = 0;
var particle;

function SnapToGrid64(coord){
  return 64*Math.floor(0.5+coord/64);
}

function SnapToGrid32(coord){
  return 32+64*Math.floor(coord/64);
}

function StartBuildingHelper( params )
{
  if (params !== undefined)
  {
    state = params["state"];
    size = params["size"];
    var entindex = params["entindex"];
    var fMaxScale = params["fMaxScale"];

    var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ); 

    if (particle !== undefined) {
      Particles.DestroyParticleEffect(particle, true)
    }

    $("#BuildingHelperBase").hittest = true;

    particle = Particles.CreateParticle("particles/buildinghelper/ghost_model.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, localHeroIndex);
    Particles.SetParticleControlEnt(particle, 1, entindex, ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, "follow_origin", Entities.GetAbsOrigin(entindex), true)            
    Particles.SetParticleControl(particle, 3, [255,0,0])
    Particles.SetParticleControl(particle, 4, [fMaxScale,0,0])
  }

  if (state === 'active')
  {
    $.Schedule(1/60, StartBuildingHelper);
    var mPos = GameUI.GetCursorPosition();

    var GamePos = Game.ScreenXYToWorld(mPos[0], mPos[1]);

    if (size % 2 != 0) {
      GamePos[0] = SnapToGrid32(GamePos[0]);
      GamePos[1] = SnapToGrid32(GamePos[1]);
    } else {
      GamePos[0] = SnapToGrid64(GamePos[0]);
      GamePos[1] = SnapToGrid64(GamePos[1]);
    }

    if (GamePos[0] > 10000000)
    {
      GamePos = [0,0,0];
    }

    Particles.SetParticleControl(particle, 0, [GamePos[0], GamePos[1], GamePos[2] + 1]); // #JustValveThings
    Particles.SetParticleControl(particle, 2, [0,255,0]);
  }
}

function SendBuildCommand( params )
{
  var mPos = GameUI.GetCursorPosition();
  var GamePos = Game.ScreenXYToWorld(mPos[0], mPos[1]);
  GameEvents.SendCustomGameEventToServer( "building_helper_build_command", { "X" : GamePos[0], "Y" : GamePos[1], "Z" : GamePos[2] } );

  state = 'disabled'

  $("#BuildingHelperBase").hittest = false;

  Particles.DestroyParticleEffect(particle, true)
}

function SendCancelCommand( params )
{
  Cancel(params);
  GameEvents.SendCustomGameEventToServer( "building_helper_cancel_command", {} );

  Particles.DestroyParticleEffect(particle, true)
}

function Cancel(params) {
  $("#BuildingHelperBase").hittest = false;
  state = 'disabled'

  Particles.DestroyParticleEffect(particle, true)
}

(function () {
  GameEvents.Subscribe( "building_helper_enable", StartBuildingHelper);
  GameEvents.Subscribe( "building_helper_force_cancel", Cancel);
})();