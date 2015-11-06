'use strict';

var state = 'disabled';
var size = 0;
var particle;
var gridParticles;

// Ghost Building Preferences
var GRID_ALPHA = 30 // Defines the transparency of the ghost squares

var gridColor = {};

function StartBuildingHelper( params )
{
    if (params !== undefined)
    {
        state = params["state"];
        size = params["size"];

        var scale = params["fMaxScale"]
        var entindex = params["entindex"];

        var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );

        if (particle !== undefined) {
            Particles.DestroyParticleEffect(particle, true)
        }
        if (gridParticles !== undefined) {
            for (var i in gridParticles) {
                Particles.DestroyParticleEffect(gridParticles[i], true)
            }
        }

        $("#BuildingHelperBase").hittest = true;

        // Building Ghost
        particle = Particles.CreateParticle("particles/buildinghelper/ghost_model.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, localHeroIndex);
        Particles.SetParticleControlEnt(particle, 1, entindex, ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, "follow_origin", Entities.GetAbsOrigin(entindex), true)
        Particles.SetParticleControl(particle, 2, [255,255,255]) //Keep the original color
        Particles.SetParticleControl(particle, 3, [100,0,0]) //Grid Alpha
        Particles.SetParticleControl(particle, 4, [scale,0,0]) //Model Scale

        // Grid squares
        gridParticles = [];
        for (var x=0; x < size*size; x++)
        {
            var gridParticle = Particles.CreateParticle("particles/buildinghelper/square_sprite.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
            Particles.SetParticleControl(gridParticle, 1, [32,0,0])
            Particles.SetParticleControl(gridParticle, 3, [GRID_ALPHA,0,0])
            gridParticles.push(gridParticle)
        }
    } 
    
    if (state == 'active')
        CheckMousePos();
}

var oldPos = null;
var positionChecked = false;
function CheckMousePos()
{
    if (state == 'active')
    {
        var mousePos = GameUI.GetCursorPosition();
        var GamePos = Game.ScreenXYToWorld(mousePos[0], mousePos[1]);

        if (GamePos[0] > 10000000) // fix for borderless windowed players
        {
          GamePos = [0,0,0];
        }

        if ( GamePos !== null ) 
        {
            SnapToGrid(GamePos, size)

            // Check GridNav once if mouse stopped
            if (oldPos != null && oldPos[0] == GamePos[0] && oldPos[1] == GamePos[1])
            {
                if (!positionChecked)
                {
                    GameEvents.SendCustomGameEventToServer( "building_helper_check_grid", { "X" : GamePos[0], "Y" : GamePos[1], "Z" : GamePos[2] } );
                    positionChecked = true;
                }
            }
            else
                positionChecked = false;

            oldPos = GamePos;

            var color = [0,255,0]
            var part = 0
            var halfSide = (size/2)*64
            var boundingRect = {}
            boundingRect["leftBorderX"] = GamePos[0]-halfSide
            boundingRect["rightBorderX"] = GamePos[0]+halfSide
            boundingRect["topBorderY"] = GamePos[1]+halfSide
            boundingRect["bottomBorderY"] = GamePos[1]-halfSide

            for (var x=boundingRect["leftBorderX"]+32; x <= boundingRect["rightBorderX"]-32; x+=64)
            {
                for (var y=boundingRect["topBorderY"]-32; y >= boundingRect["bottomBorderY"]+32; y-=64)
                {
                    var pos = [x,y,GamePos[2]]
                    var gridParticle = gridParticles[part]
                    Particles.SetParticleControl(gridParticle, 0, pos) ;
                    Particles.SetParticleControl(gridParticle, 2, gridColor[part])      
                    part++; 

                    if (part>size*size)
                    {
                        return
                    }    
                }
            }      

            // Update the model particle
            Particles.SetParticleControl(particle, 0, [GamePos[0], GamePos[1], GamePos[2] + 1])
        }

        $.Schedule(1/30, CheckMousePos);    
    }
}

function SendBuildCommand( params )
{
  var mPos = GameUI.GetCursorPosition();
  var GamePos = Game.ScreenXYToWorld(mPos[0], mPos[1]);
  GameEvents.SendCustomGameEventToServer( "building_helper_build_command", { "X" : GamePos[0], "Y" : GamePos[1], "Z" : GamePos[2] } );

  Cancel(params)
}

function SendCancelCommand( params )
{
  Cancel();
  GameEvents.SendCustomGameEventToServer( "building_helper_cancel_command", {} );
}

function Cancel() {
  state = 'disabled'
  Particles.DestroyParticleEffect(particle, true)
  for (var i in gridParticles) {
    Particles.DestroyParticleEffect(gridParticles[i], true)
  }

  $("#BuildingHelperBase").hittest = false;
}

function GetGridColor( value )
{
    return value == 0
        ? [0, 255, 0]
        : [255, 0, 0];    
}

function GridValidation( args )
{
    gridColor[0] = GetGridColor( args["0"] );
    gridColor[1] = GetGridColor( args["1"] );
    gridColor[2] = GetGridColor( args["2"] );
    gridColor[3] = GetGridColor( args["3"] );
}

(function () {
  GameEvents.Subscribe( "building_helper_enable", StartBuildingHelper);
  GameEvents.Subscribe( "building_helper_force_cancel", Cancel);

  GameEvents.Subscribe( "building_helper_grid_validation", GridValidation);
})();

function SnapToGrid(vec, size) {
    // Buildings are centered differently when the size is odd.
    if (size % 2 != 0) 
    {
        vec[0] = SnapToGrid32(vec[0])
        vec[1] = SnapToGrid32(vec[1])
    } 
    else 
    {
        vec[0] = SnapToGrid64(vec[0])
        vec[1] = SnapToGrid64(vec[1])
    }
}

function SnapToGrid64(coord){
  return 64*Math.floor(0.5+coord/64);
}

function SnapToGrid32(coord){
  return 32+64*Math.floor(coord/64);
}