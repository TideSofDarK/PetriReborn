'use strict';
// Store received data into panel data
var GNVPanel = $.GetContextPanel();
if (!GNVPanel.loaded)
{
    GNVPanel.Grid = [];
    GNVPanel.LastQueueNum = -1;
    GNVPanel.XMin = 0;
    GNVPanel.XMax = 0;
    GNVPanel.YMin = 0;
    GNVPanel.YMax = 0;
    GNVPanel.Resolution = [];

    GNVPanel.loaded = true;
}

var state = 'disabled';
var WHITE_COLOR = [255,255,255];

//-----------------------------------------------------------------------------
//                         Main function
//-----------------------------------------------------------------------------
(function () {
    GameEvents.SendCustomGameEventToServer( "gnv_request", { "Layers" : { } } );
    GameEvents.SendCustomGameEventToServer( "gnv_config_request", { } );   

    CustomNetTables.SubscribeNetTableListener( "LayersQueue", LayerChanged );
    GameEvents.Subscribe( "gnv", GNV);
    GameEvents.Subscribe( "gnv_config", GNVConfig);

    // Visible module functions
	GNVPanel.CreateParticles = CreateParticles;
    GNVPanel.DestroyParticles = DestroyParticles;

    GNVPanel.IsBlocked = IsBlocked;
    GNVPanel.GetEntitiesNearPoint = GetEntitiesNearPoint;
    // User quad statuses
    GNVPanel.GetQuadStatusEx = null;
})();

//-----------------------------------------------------------------------------
//                          Visible grid vars
//-----------------------------------------------------------------------------
var visibleGrid;

var GridMode = {
    None: 0,
    AroundBuildingQuad: 1,
    AroundBuildingCircle: 2,
    Full: 3,
    OnlyBlocked: 4,
    OnlyFree: 5
};

// Position for hided particles
var outPos = [-1000, -1000, -1000];

var altPressed = false;

// Position to detect if need remap grid
var screenCenterPos = [];

// Step size for grid generation
var screenStepSize = 16;

var topInsetOverride = 30;
var bottomInsetOverride = 120;

//-----------------------------------------------------------------------------
//                         Grid config
//-----------------------------------------------------------------------------
var GridConfig = {};

function GNVConfig( args )
{
	GridConfig = args.config;
}

function GNVConfigUpdate()
{
	GameEvents.SendCustomGameEventToServer( "gnv_config_update", { "config" : GridConfig } );
}

function SetSliderPosition( sliderName, value)
{
	var slider = $( "#" + sliderName );
	slider.GetChild(1).value = 0;
	var sliderMinValue = parseInt(slider.GetChild(0).FindChild("Value").text);

	slider.GetChild(1).value = 1;
	var sliderMaxValue = parseInt(slider.GetChild(0).FindChild("Value").text);

	slider.GetChild(1).value = (value - sliderMinValue) / (sliderMaxValue - sliderMinValue);
}

function GetSliderPosition( sliderName )
{
	var slider = $( "#" + sliderName );
	return parseInt(slider.GetChild(0).FindChild("Value").text);
}

function UpdateConfigPanel()
{
	$( "#RecolorValidGhost" ).checked = tobool(GridConfig.RecolorValidGhost);
	$( "#RecolorInvalidGhost" ).checked = tobool(GridConfig.RecolorInvalidGhost);
	$( "#DrawVisibleGrid" ).checked = tobool(GridConfig.DrawVisibleGrid);

	SetSliderPosition("GhostAlpha", GridConfig.GhostAlpha);
	SetSliderPosition("EntityGridAlpha", GridConfig.EntityGridAlpha);
	SetSliderPosition("EntityGridFPS", GridConfig.EntityGridFPS);

	SetSliderPosition("VisibleGridAlpha", GridConfig.VisibleGridAlpha);
	SetSliderPosition("FieldRadius", GridConfig.FieldRadius);
	SetSliderPosition("VisibleGridFPS", GridConfig.VisibleGridFPS);
	SetSliderPosition("GridMode", GridConfig.GridMode);
}

function SaveConfigFromPanel()
{
	GridConfig.RecolorValidGhost = $( "#RecolorValidGhost" ).checked.toString();
	GridConfig.RecolorInvalidGhost = $( "#RecolorInvalidGhost" ).checked.toString();
	GridConfig.DrawVisibleGrid = $( "#DrawVisibleGrid" ).checked.toString();

	GridConfig.GhostAlpha = GetSliderPosition("GhostAlpha");
	GridConfig.EntityGridAlpha = GetSliderPosition("EntityGridAlpha");
	GridConfig.EntityGridFPS = GetSliderPosition("EntityGridFPS");

	GridConfig.VisibleGridAlpha = GetSliderPosition("VisibleGridAlpha");
	GridConfig.FieldRadius = GetSliderPosition("FieldRadius");
	GridConfig.VisibleGridFPS = GetSliderPosition("VisibleGridFPS");
	GridConfig.GridMode = GetSliderPosition("GridMode");

	GNVConfigUpdate();
}
//-----------------------------------------------------------------------------
//                         Visible grid
//-----------------------------------------------------------------------------
function GetQuadColor( name )
{
	if (GridConfig.Colors)
		if (GridConfig.Colors[name])
			return [ GridConfig.Colors[name][1], GridConfig.Colors[name][2], GridConfig.Colors[name][3] ];

	return WHITE_COLOR;
}

//-----------------------------------------------------------------------------
//                         Quad status override
//-----------------------------------------------------------------------------
function GetQuadStatus( pos )
{
	// Callback
	var status = null;
	if (GNVPanel.GetQuadStatusEx)
		status = GNVPanel.GetQuadStatusEx(pos);
	if (status)
		return status;

    if (GNVPanel.IsBlocked(pos))
        return "Blocked";

    var entities = GNVPanel.GetEntitiesNearPoint( pos );
    if (entities.length > 0)
        return Entities.IsEnemy(entities[0]) 
            ? "EnemyUnit"
            : "Unit";

    return "Free";
}

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
    return GetGridPosition( ScreenToSnapWorldPos( x, y ) );
}

function DestroyVisibleGridParticles()
{
    for (var x in visibleGrid)
        for (var y in visibleGrid[x])
            Particles.DestroyParticleEffect(visibleGrid[x][y]["Particle"], true);
}

function DestroyUnusedVisibleGridParticles()
{
	var list = [];
    for (var x in visibleGrid)
        for (var y in visibleGrid[x])
        {
        	var pos = visibleGrid[x][y]["Position"]
        	var scrX = Game.WorldToScreenX( pos[0], pos[1], pos[2] );
        	var scrY = Game.WorldToScreenY( pos[0], pos[1], pos[2] );

        	// Remove quads outside screen
        	if (scrX < 0 || scrX > GNVPanel.Resolution[0] ||
        		scrY < 0 || scrY > GNVPanel.Resolution[1] )
        	{
            	Particles.DestroyParticleEffect(visibleGrid[x][y]["Particle"], true);
        	}
            else
            {
            	if (!list[x])
            		list[x] = [];
            	list[x][y] = visibleGrid[x][y];
            }
        }

    visibleGrid = list;
}

function CreateVisibleGridParticle()
{
    // Destroy old particles
    DestroyUnusedVisibleGridParticles();

    for (var x = 0; x < GNVPanel.Resolution[0]; x += screenStepSize)
        for (var y = topInsetOverride; y < GNVPanel.Resolution[1] - bottomInsetOverride; y += screenStepSize)
        {
            var pos = ScreenToSnapWorldPos( x, y );

            if (!pos)
                continue;

            var gridX = WorldToGridPosX(pos[0]) - GNVPanel.XMin;
            var gridY = WorldToGridPosY(pos[1]) - GNVPanel.YMin;

            if (!visibleGrid[gridX])
                visibleGrid[gridX] = [];

            if (visibleGrid[gridX][gridY])
                continue;

            var status = GetQuadStatus(pos)

            var gridParticle = Particles.CreateParticle("particles/buildinghelper/square_sprite.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0);
            Particles.SetParticleControl(gridParticle, 0, outPos);
            Particles.SetParticleControl(gridParticle, 1, [32,0,0]);
            Particles.SetParticleControl(gridParticle, 2, GetQuadColor(status));
            Particles.SetParticleControl(gridParticle, 3, [GridConfig.VisibleGridAlpha,0,0]);

            visibleGrid[gridX][gridY] = [];
            visibleGrid[gridX][gridY]["Particle"] = gridParticle;
            visibleGrid[gridX][gridY]["Position"] = pos;
            visibleGrid[gridX][gridY]["Status"] = status;
        }
}

function IsPointInRange( position, point, range )
{
    if (!position || !point)
        return false;
    
    var length = Math.sqrt(
            Math.pow(point[0] - position[0], 2) +  
            Math.pow(point[1] - position[1], 2) +
            Math.pow(point[2] - position[2], 2)
        );

    return length < range;
}

function IsPointInQuad( position, point, size )
{
    if (!position || !point)
        return false;
    
    return position[0] > (point[0] - size / 2) && position[0] < (point[0] + size / 2) &&
           position[1] > (point[1] - size / 2) && position[1] < (point[1] + size / 2);;
}

function GetEntitiesNearPoint( pos )
{
    var scrX = Game.WorldToScreenX( pos[0], pos[1], pos[2] )
    var scrY = Game.WorldToScreenY( pos[0], pos[1], pos[2] )
    var entities = GameUI.FindScreenEntities( scrX, scrY );

    var isInRange = false;
    var entitiesList = [];
    for (var entity of entities) {
        var entOrigin = Entities.GetAbsOrigin( entity.entityIndex );
        var ringRadius = Entities.GetRingRadius( entity.entityIndex );

        if (IsPointInRange( pos, entOrigin, ringRadius ))
            entitiesList.push(entity.entityIndex)
    };
    
    return entitiesList;
}

function GetScreenCenterPos()
{
    if (state != 'active')
        return;

    var curPos = ScreenToSnapWorldPos( GNVPanel.Resolution[0] / 2, GNVPanel.Resolution[1] / 2 );

    if (!IsPointInRange(curPos, screenCenterPos, 128))
    {
        CreateVisibleGridParticle();
        screenCenterPos = curPos;
    }

    $.Schedule(1/10, GetScreenCenterPos);
}

function SnapMousePosToWorld()
{
    var mousePos = GameUI.GetCursorPosition();
    var gamePos = GameUI.GetScreenWorldPosition( mousePos[0], mousePos[1] );

    if (!gamePos)
        return [0, 0, 0]
    
    var snapGamePos = ScreenToSnapWorldPos(mousePos[0], mousePos[1]);

    var offset = 0;

    if (GridConfig.GridMode == GridMode.AroundBuildingQuad)
        offset = 16;
    if (GridConfig.GridMode == GridMode.AroundBuildingCircle)
        offset = 32;

    var xSign = gamePos[0] < snapGamePos[0] ? -1 : 1;
    var ySign = gamePos[1] < snapGamePos[1] ? -1 : 1;

    snapGamePos[0] = snapGamePos[0] + offset * xSign;
    snapGamePos[1] = snapGamePos[1] + offset * ySign;  

    return snapGamePos;
}

function UpdateVisibleGrid()
{
    if (state != 'active')
        return;

    var gamePos = SnapMousePosToWorld() 

    for (var x in visibleGrid)
        for (var y in visibleGrid[x])
        {
            var status = GetQuadStatus(visibleGrid[x][y]["Position"]);
            var pos = visibleGrid[x][y]["Position"];

            switch(GridConfig.GridMode)
            {
                case GridMode.None:
                    pos = outPos;
                    break;

                case GridMode.AroundBuildingQuad:
                    if (!IsPointInQuad( gamePos, pos, GridConfig.FieldRadius * 2 ))
                        pos = outPos;
                    break;

                case GridMode.AroundBuildingCircle:
                    if (!IsPointInRange( gamePos, pos, GridConfig.FieldRadius ))
                        pos = outPos;
                    break;

                case GridMode.OnlyBlocked:
                    if (status == "Free")
                        pos = outPos;
                    break;

                case GridMode.OnlyFree:
                    if (status == "Blocked") 
                        pos = outPos;
                    break;
            }

            Particles.SetParticleControl(visibleGrid[x][y]["Particle"], 0, pos);

            // Status doesn't changed
            if (status == visibleGrid[x][y]["Status"])
                continue;

            Particles.SetParticleControl(visibleGrid[x][y]["Particle"], 2, GetQuadColor(status));
            visibleGrid[x][y]["Status"] = status;
        }

    // Change grid mode
    if (GameUI.IsAltDown())
    {
        if (!altPressed)
        {
            altPressed = true;
            GridConfig.GridMode++;

            if (GridConfig.GridMode > GridMode.OnlyFree)
                GridConfig.GridMode = GridMode.None;
        }
    }
    else
        altPressed = false;

    $.Schedule(1/GridConfig.VisibleGridFPS, UpdateVisibleGrid);
}

//-----------------------------------------------------------------------------
//                         Entity particle vars
//-----------------------------------------------------------------------------
var size = 0;
var particle;
var gridParticles;

//-----------------------------------------------------------------------------
//                         Entity particle
//-----------------------------------------------------------------------------
function CreateEntityParticle( params )
{
    if (params !== undefined)
    {	
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

        // Building Ghost
        particle = Particles.CreateParticle("particles/buildinghelper/ghost_model.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, localHeroIndex);
        Particles.SetParticleControlEnt(particle, 1, entindex, ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, "follow_origin", Entities.GetAbsOrigin(entindex), true)
        Particles.SetParticleControl(particle, 2, [255,255,255]) //Keep the original color
        Particles.SetParticleControl(particle, 3, [GridConfig.GhostAlpha,0,0]) //Grid Alpha
        Particles.SetParticleControl(particle, 4, [scale,0,0]) //Model Scale

        // Grid squares
        gridParticles = [];
        for (var x = 0; x < size * size; x++)
        {
            var gridParticle = Particles.CreateParticle("particles/buildinghelper/square_sprite_building.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
            Particles.SetParticleControl(gridParticle, 1, [32,0,0])
            Particles.SetParticleControl(gridParticle, 2, [255,255,255]) //Keep the original color
            Particles.SetParticleControl(gridParticle, 3, [GridConfig.EntityGridAlpha,0,0])
            gridParticles.push(gridParticle)
        }
    } 
}

function UpdateEntityParticle()
{
    if (state != 'active')
        return;

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
                isAnyQuadBlocked = isAnyQuadBlocked || status == "Blocked" || status == "EnemyUnit";

                Particles.SetParticleControl(gridParticle, 0, pos);
                Particles.SetParticleControl(gridParticle, 2, GetQuadColor(status == "Free" ? "ValidGhost" : status ));

                part ++;

                if (part > size*size)
                    return;
            }
        }

        // Update the model particle
        Particles.SetParticleControl(particle, 0, [GamePos[0], GamePos[1], GamePos[2] + 1])

        var ghostColor = isAnyQuadBlocked 
        	? tobool(GridConfig.RecolorInvalidGhost) ? GetQuadColor( "InvalidGhost" ) : WHITE_COLOR
        	: tobool(GridConfig.RecolorValidGhost) ? GetQuadColor( "ValidGhost" ) : WHITE_COLOR;
        Particles.SetParticleControl(particle, 2, ghostColor);
    }

    $.Schedule(1/GridConfig.EntityGridFPS, UpdateEntityParticle);
}

function DestroyEntityParticle()
{
	if (particle)
    	Particles.DestroyParticleEffect(particle, true)
    for (var i in gridParticles)
        Particles.DestroyParticleEffect(gridParticles[i], true)
}

//-----------------------------------------------------------------------------
//                         GNV particle controls
//-----------------------------------------------------------------------------
function CreateParticles( params )
{
	state = params["state"];	
    GNVPanel.Resolution = GetScreenResolution();

	CreateEntityParticle( params )
	UpdateEntityParticle();

	if (!tobool(GridConfig.DrawVisibleGrid))
		return;

	visibleGrid = [];
    CreateVisibleGridParticle();
	GetScreenCenterPos();
    UpdateVisibleGrid();	
}

function DestroyParticles()
{
    state = 'disabled';

	DestroyEntityParticle();
	DestroyVisibleGridParticles();
}

//-----------------------------------------------------------------------------
//                         Layers
//-----------------------------------------------------------------------------
function CreateLayer( layerName )
{
    GNVPanel.Grid[layerName] = [];
    for (var j = 0; j < -GNVPanel.YMin + GNVPanel.YMax + 1; j++)
    {
        GNVPanel.Grid[layerName][j] = []
        for (var i = 0; i < -GNVPanel.XMin + GNVPanel.XMax + 1; i++)
            GNVPanel.Grid[layerName][j][i] = 0;
    }    
}

function LayerChanged( table_name, key, data )
{
    if (GNVPanel.LastQueueNum >= parseInt(key, 10))
        return

    var layerName = data["LayerName"];
    if (GNVPanel.Grid[layerName] == null)
        CreateLayer( layerName );

    var ltX = -GNVPanel.XMin + data["X"] - 1;
    var ltY = -GNVPanel.YMin + data["Y"] - 1;

    for (var y = 1; y <= data["Height"]; y++)
        for (var x = 1; x <= data["Width"]; x++)
            GNVPanel.Grid[layerName][ltY + y - 1][ltX + x - 1] = data['Mapping'][y][x];
}

//-----------------------------------------------------------------------------
//                         GNV load/unpack
//-----------------------------------------------------------------------------
// Receive and decoding GNV
function GNV( args )
{
    $.Msg("GNV received")

    GNVPanel.XMin = args["XMin"];
    GNVPanel.XMax = args["XMax"];
    GNVPanel.YMin = args["YMin"];
    GNVPanel.YMax = args["YMax"];

    $.Msg("XMin: ", GNVPanel.XMin, " XMax: ", GNVPanel.XMax, " YMin: ", GNVPanel.YMin, " YMax: ", GNVPanel.YMax)

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
    GNVPanel.Grid[layerName] = []
    var curQuad = 0;
    for (var j = 0; j < -GNVPanel.YMin + GNVPanel.YMax + 1; j++)
    {
        GNVPanel.Grid[layerName][j] = []
        for (var i = 0; i < -GNVPanel.XMin + GNVPanel.XMax + 1; i++)
            GNVPanel.Grid[layerName][j][i] = decoded[curQuad++];
    }
}

//-----------------------------------------------------------------------------
//                         Util functions
//-----------------------------------------------------------------------------
function CheckGridSquare( layerName, x, y)
{
    if (GNVPanel.Grid[layerName])
        if (GNVPanel.Grid[layerName][y])
            if (GNVPanel.Grid[layerName][y][x])
                return GNVPanel.Grid[layerName][y][x] == 1;

    return false;
}

function IsBlocked(position) {
    if (!position)
        return false;

    var gridPos = GetGridPosition(position);

    var isBuilding = CheckGridSquare("Buildings", gridPos[0], gridPos[1]);
    var isBlocked = CheckGridSquare("Terrain", gridPos[0], gridPos[1]);

    return isBlocked || isBuilding;
}

function GetGridPosition( position )
{
    return [WorldToGridPosX(position[0]) - GNVPanel.XMin, WorldToGridPosY(position[1]) - GNVPanel.YMin];
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

function tobool( value )
{
	return value == "true";
}