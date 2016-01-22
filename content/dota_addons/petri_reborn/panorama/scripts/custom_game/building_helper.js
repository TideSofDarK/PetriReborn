'use strict';

var state = 'disabled';
var size = 0;
var particle;
var gridParticles;

var visibleGrid;

var QuadStatus = {
    Free: 0,
    Blocked: 1,
    Unit : 2
}

var GridMode = {
    None: 0,
    Full: 1,
    OnlyBlocked: 2,
    OnlyFree: 3
}

var gridMode = GridMode.None;

var screenCenterPos = [];
var screenStepSize = 16;

var topInsetOverride = 30;
var bottomInsetOverride = 100;


// Ghost Building Preferences
var GRID_ALPHA = 30 // Defines the transparency of the ghost squares
var VISIBLE_GRID_ALPHA = 255 // Defines the transparency of the ghost squares

// Store received data into panel data
var BHPanel = $.GetContextPanel();
if (!BHPanel.loaded)
{
    BHPanel.Grid = [];
    BHPanel.LastQueueNum = -1;
    BHPanel.XMin = 0;
    BHPanel.XMax = 0;
    BHPanel.YMin = 0;
    BHPanel.YMax = 0;
    BHPanel.Resolution = [];

    BHPanel.loaded = true;
}

function GetQuadColor( quadStatus )
{
    switch(quadStatus)
    {
        case QuadStatus.Unit:
            return [255, 240, 0];
        case QuadStatus.Blocked:
            return [255, 0, 0];
        case QuadStatus.Free:
            return [255, 255, 255];
    }
}

function GetBuildingQuadColor( quadStatus )
{
    switch(quadStatus)
    {
        case QuadStatus.Unit:
            return [255, 240, 0];
        case QuadStatus.Blocked:
            return [255, 0, 0];
        case QuadStatus.Free:
            return [0, 255, 0];
    }
}

function GetQuadStatus( pos )
{
    if (IsBlocked(pos))
        return QuadStatus.Blocked;

    if (IsEntityNearPoint( pos ))
        return QuadStatus.Unit;

    return QuadStatus.Free;
}

//-----------------------------------------------------------------------------
//                    Visible grid
//-----------------------------------------------------------------------------
function GetScreenResolution()
{
    // Full screen viewport
    GameUI.SetRenderTopInsetOverride(0);
    GameUI.SetRenderBottomInsetOverride(0);

    var x = 0;
    var y = 0;

    var pos = null;
    
    do 
    {
        pos = GameUI.GetScreenWorldPosition( ++x, 0 );
    } while(pos != null);

    do 
    {
        pos = GameUI.GetScreenWorldPosition( 0, ++y );
    } while(pos != null);    

    // Full screen viewport
    GameUI.SetRenderTopInsetOverride(topInsetOverride);
    GameUI.SetRenderBottomInsetOverride(bottomInsetOverride);

    return [x - 1, y - 1];
}

function ScreenToSnapWorldPos( x, y )
{
    var worldPos = GameUI.GetScreenWorldPosition( x, y );
    if (worldPos) 
        SnapToGrid(worldPos, 1);

    return worldPos;
}

function ScreenToGridPos( x, y )
{
    var worldPos = ScreenToSnapWorldPos( x, y )
    return [WorldToGridPosX(worldPos[0]) - BHPanel.XMin, WorldToGridPosY(worldPos[1]) - BHPanel.YMin];
}

function DestroyVisibleGridParticles()
{
    for (var x in visibleGrid)
        for (var y in visibleGrid[x])
            Particles.DestroyParticleEffect(visibleGrid[x][y]["Particle"], true);
}

function CreateVisibleGridParticle()
{
    // Destroy old particles
    DestroyVisibleGridParticles();

    visibleGrid = [];
    for (var x = 0; x < BHPanel.Resolution[0]; x += screenStepSize)
        for (var y = topInsetOverride; y < BHPanel.Resolution[1] - bottomInsetOverride; y += screenStepSize)
        {
            var pos = ScreenToSnapWorldPos( x, y );

            if (!pos)
                continue;

            var gridX = WorldToGridPosX(pos[0]) - BHPanel.XMin;
            var gridY = WorldToGridPosY(pos[1]) - BHPanel.YMin;

            if (!visibleGrid[gridX])
                visibleGrid[gridX] = [];

            if (visibleGrid[gridX][gridY])
                continue;

            var status = GetQuadStatus(pos)

            var gridParticle = Particles.CreateParticle("particles/buildinghelper/square_sprite.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0);
            Particles.SetParticleControl(gridParticle, 0, pos);
            Particles.SetParticleControl(gridParticle, 1, [32,0,0]);
            Particles.SetParticleControl(gridParticle, 2, GetQuadColor(status));
            Particles.SetParticleControl(gridParticle, 3, [VISIBLE_GRID_ALPHA,0,0]);

            visibleGrid[gridX][gridY] = [];
            visibleGrid[gridX][gridY]["Particle"] = gridParticle;
            visibleGrid[gridX][gridY]["Position"] = pos;
            visibleGrid[gridX][gridY]["Status"] = status;
        }  
}

function IsPointInRange( position, point, range )
{
    var length = Math.sqrt(
            Math.pow(point[0] - position[0], 2) +  
            Math.pow(point[1] - position[1], 2) +
            Math.pow(point[2] - position[2], 2)
        );

    return length <= range;
}

function IsEntityNearPoint( pos )
{
    var scrX = Game.WorldToScreenX( pos[0], pos[1], pos[2] )
    var scrY = Game.WorldToScreenY( pos[0], pos[1], pos[2] )
    var entities = GameUI.FindScreenEntities( scrX, scrY );

    var isInRange = false;
    for (var entity of entities) {
        var entOrigin = Entities.GetAbsOrigin( entity.entityIndex );
        var ringRadius = Entities.GetRingRadius( entity.entityIndex );

        isInRange = isInRange || IsPointInRange( pos, entOrigin, ringRadius );
    };
    
    return isInRange;   
}

function GetScreenCenterPos()
{
    if (state != 'active')
        return;

    var curPos = ScreenToSnapWorldPos( BHPanel.Resolution[0] / 2, BHPanel.Resolution[1] / 2 );

    if (!IsPointInRange(curPos, screenCenterPos, 64))
    {
        CreateVisibleGridParticle();
        screenCenterPos = curPos;
    }
}

function UpdateVisibleGrid()
{
    if (state != 'active')
        return;

    for (var x in visibleGrid)
        for (var y in visibleGrid[x])
        {
            var status = GetQuadStatus(visibleGrid[x][y]["Position"]);

            // Status doesn't changed
            if (status == visibleGrid[x][y]["Status"])
                continue;

            Particles.SetParticleControl(visibleGrid[x][y]["Particle"], 2, GetQuadColor(status));
            visibleGrid[x][y]["Status"] = status;
        }

    GetScreenCenterPos();

    // Change grid mode
    if (GameUI.IsAltDown())
    {
        gridMode++;

        if (gridMode > 3)
            gridMode = GridMode.None;
    }

    $.Schedule(1/5, UpdateVisibleGrid);
}

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
        for (var x = 0; x < size * size; x++)
        {
            var gridParticle = Particles.CreateParticle("particles/buildinghelper/square_sprite_building.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
            Particles.SetParticleControl(gridParticle, 1, [32,0,0])
            Particles.SetParticleControl(gridParticle, 2, [255,255,255]) //Keep the original color
            Particles.SetParticleControl(gridParticle, 3, [GRID_ALPHA,0,0])
            gridParticles.push(gridParticle)
        }
    } 
    
    if (state == 'active')
    {
        CheckMousePos();

        BHPanel.Resolution = GetScreenResolution();
        CreateVisibleGridParticle();
        UpdateVisibleGrid();
    }
}

function CheckMousePos()
{
    if (state == 'active')
    {
        var mousePos = GameUI.GetCursorPosition();
        var GamePos = Game.ScreenXYToWorld(mousePos[0], mousePos[1]);

        if (GamePos[0] > 10000000) // fix for borderless windowed players
          GamePos = [0,0,0];

        if ( GamePos !== null ) 
        {
            SnapToGrid(GamePos, size)

            var color = [0,255,0]
            var halfSide = (size/2)*64
            var part = 0;
            var boundingRect = {}
            boundingRect["leftBorderX"] = GamePos[0]-halfSide
            boundingRect["rightBorderX"] = GamePos[0]+halfSide
            boundingRect["topBorderY"] = GamePos[1]+halfSide
            boundingRect["bottomBorderY"] = GamePos[1]-halfSide

            var isAnyQuadBlocked = false;
            for (var x=boundingRect["leftBorderX"]+32; x <= boundingRect["rightBorderX"]-32; x+=64)
            {
                for (var y=boundingRect["topBorderY"]-32; y >= boundingRect["bottomBorderY"]+32; y-=64)
                {
                    var pos = [x,y,GamePos[2]]
                    var gridParticle = gridParticles[part]

                    var status = GetQuadStatus(pos);                    
                    isAnyQuadBlocked = isAnyQuadBlocked || status == QuadStatus.Blocked;

                    Particles.SetParticleControl(gridParticle, 0, pos);
                    Particles.SetParticleControl(gridParticle, 2,  GetBuildingQuadColor(status));

                    part ++;

                    if (part > size*size)
                        return;
                }
            }

            // Update the model particle
            Particles.SetParticleControl(particle, 0, [GamePos[0], GamePos[1], GamePos[2] + 1])
            Particles.SetParticleControl(particle, 2, GetBuildingQuadColor( isAnyQuadBlocked ? QuadStatus.Blocked : QuadStatus.Free ))
        }

        $.Schedule(1/60, CheckMousePos);    
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
    Particles.DestroyParticleEffect(particle, true)
    for (var i in gridParticles) {
        Particles.DestroyParticleEffect(gridParticles[i], true)
    }

    DestroyVisibleGridParticles();

    $("#BuildingHelperBase").hittest = false;
}

// Receive and decoding GNV
function GNV( args )
{
    $.Msg("GNV received")

    BHPanel.XMin = args["XMin"];
    BHPanel.XMax = args["XMax"];
    BHPanel.YMin = args["YMin"];
    BHPanel.YMax = args["YMax"];

    $.Msg("XMin: ", BHPanel.XMin, " XMax: ", BHPanel.XMax, " YMin: ", BHPanel.YMin, " YMax: ", BHPanel.YMax)

    var decoded = ""
    var pad = "00000000"

    var i = 0;
    var phrase = "";
    var code = "";
    while (i < args["gnv"].length)
    {
        phrase = args["gnv"].substring(i, i + 2);

        // Length
        if (phrase[0] == '(')
        {
            phrase = phrase.substring(1, 2)
            
            i += 2;

            while(args["gnv"][i] != ')')
            {
                phrase += args["gnv"][i];
                i++;
            }

            i++;

            var length = parseInt(phrase, 10);
            // Add last code n times
            for (var j = 1; j < length; j++)
                decoded += code;
        }
        else
        {
            code = parseInt(phrase, 16).toString(2);
            code = (pad.substring(0, pad.length - code.length) + code).substring(0, 8);
            decoded += code;
            i += 2;
        }
    }

    var layerName = args["LayerName"]
    BHPanel.Grid[layerName] = []
    var curQuad = 0;
    for (var j = 0; j < -BHPanel.YMin + BHPanel.YMax + 1; j++)
    {
        BHPanel.Grid[layerName][j] = []
        for (var i = 0; i < -BHPanel.XMin + BHPanel.XMax + 1; i++)
            BHPanel.Grid[layerName][j][i] = decoded[curQuad++];
    }
}

//-----------------------------------------------------------------------------
//                         Layers
//-----------------------------------------------------------------------------
function CreateLayer( layerName )
{
    BHPanel.Grid[layerName] = [];
    for (var j = 0; j < -BHPanel.YMin + BHPanel.YMax + 1; j++)
    {
        BHPanel.Grid[layerName][j] = []
        for (var i = 0; i < -BHPanel.XMin + BHPanel.XMax + 1; i++)
            BHPanel.Grid[layerName][j][i] = 0;
    }    
}

function LayerChanged( table_name, key, data )
{
    if (BHPanel.LastQueueNum >= parseInt(key, 10))
        return

    var layerName = data["LayerName"];
    if (BHPanel.Grid[layerName] == null)
        CreateLayer( layerName );

    var ltX = -BHPanel.XMin + data["X"] - 1;
    var ltY = -BHPanel.YMin + data["Y"] - 1;

    for (var y = 1; y <= data["Height"]; y++)
        for (var x = 1; x <= data["Width"]; x++)
            BHPanel.Grid[layerName][ltY + y - 1][ltX + x - 1] = data['Mapping'][y][x];
}

(function () {
    GameEvents.SendCustomGameEventToServer( "gnv_request", { "Layers" : { } } );

    GameEvents.Subscribe( "building_helper_enable", StartBuildingHelper);
    GameEvents.Subscribe( "building_helper_force_cancel", Cancel);

    CustomNetTables.SubscribeNetTableListener( "LayersQueue", LayerChanged );
    GameEvents.Subscribe( "gnv", GNV);
})();


function CheckGridSquare( layerName, x, y)
{
    if (BHPanel.Grid[layerName])
        if (BHPanel.Grid[layerName][y])
            if (BHPanel.Grid[layerName][y][x])
                return BHPanel.Grid[layerName][y][x] == 1;

    return false;
}

function IsBlocked(position) {
    if (!position)
        return false;

    var x = WorldToGridPosX(position[0]) - BHPanel.XMin;
    var y = WorldToGridPosY(position[1]) - BHPanel.YMin;
    
    var isBuilding = CheckGridSquare("Buildings", x, y);
    var isBlocked = CheckGridSquare("Terrain", x, y);

    return isBlocked || isBuilding;
}

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

function WorldToGridPosX(x){
    return Math.floor(x/64)
}

function WorldToGridPosY(y){
    return Math.floor(y/64)
}