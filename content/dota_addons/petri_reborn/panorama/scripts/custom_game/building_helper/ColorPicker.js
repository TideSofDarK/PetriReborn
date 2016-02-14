'use strict';
//-----------------------------------------------------------------------------
//                         Color picker handlers
//-----------------------------------------------------------------------------
var markerPanel = $( "#Marker" );
var mainColorPanel = markerPanel.GetParent();

var markerGradientPanel = $( "#GradientMarker" );
var gradientPanel = markerGradientPanel.GetParent();

var isHoverMainColor = false;
var isHoverGradient = false;
var firstClick = true;

var startMousePos = null;
var startMargin = null;
// Size multiplier
var multiplier = 1;

var curColor = [];

//-----------------------------------------------------------------------------
//                         Main color
//-----------------------------------------------------------------------------
function GetMarkerMargin( startMousePos )
{
  var mainColorPos = mainColorPanel.GetPositionWithinWindow();
  return [
    (startMousePos[0] - mainColorPos["x"] - markerPanel.actuallayoutwidth / 2) * multiplier, 
    (startMousePos[1] - mainColorPos["y"] - markerPanel.actuallayoutheight / 2) * multiplier];
}

function SetPositionMarker( x, y )
{
  var halfSize = markerPanel.actuallayoutwidth / 2;

  // Check borders
  if (x < -halfSize * multiplier )
    x = -halfSize * multiplier;

  if (x > (mainColorPanel.actuallayoutwidth - halfSize) * multiplier )
    x = (mainColorPanel.actuallayoutwidth - halfSize) * multiplier;

  if (y < -halfSize * multiplier )
    y = -halfSize * multiplier;

  if (y > (mainColorPanel.actuallayoutheight - halfSize) * multiplier )
    y = (mainColorPanel.actuallayoutwidth -halfSize) * multiplier;

  markerPanel.style.marginLeft = x + "px;";
  markerPanel.style.marginTop = y + "px;";
}

function TrackMouseMarker()
{
  if (GameUI.IsMouseDown(0))
  {

    if (!markerPanel.BHasClass("active"))
      markerPanel.SetHasClass("active", true);

    if (firstClick)
    {
      startMousePos = GameUI.GetCursorPosition();
      startMargin = GetMarkerMargin( startMousePos );
      firstClick = false;

      SetPositionMarker(startMargin[0], startMargin[1]);
    }
    else
    {          
      var curPos = GameUI.GetCursorPosition();
      SetPositionMarker (
        startMargin[0] + multiplier * (curPos[0] - startMousePos[0]),
        startMargin[1]  + multiplier * (curPos[1] - startMousePos[1])
      );
    }

    OnColorChanged( HSBToRGB() );
  }
  else
  {
    firstClick = true;

    if (markerPanel.BHasClass("active"))
      markerPanel.SetHasClass("active", false);
  }

  if (!isHoverMainColor)
  {
    firstClick = true;
    return;
  }

  $.Schedule(0.01, TrackMouseMarker)
}

function OnLeaveMainColor()
{
  isHoverMainColor = false;
}

function OnHoverMainColor()
{
  if (!isHoverMainColor) 
  {
    multiplier = 200 / mainColorPanel.actuallayoutwidth;

    isHoverMainColor = true;
    TrackMouseMarker();
  }
}

//-----------------------------------------------------------------------------
//                         Gradient panel
//-----------------------------------------------------------------------------
function GetGradientMarkerMargin( startMousePos )
{
  var gradientPanelPos = gradientPanel.GetPositionWithinWindow();
  return (startMousePos[0] - gradientPanelPos["x"] - markerGradientPanel.actuallayoutwidth / 2) * multiplier;
}

function SetPositionGradientMarker( x )
{
  var halfSize = markerGradientPanel.actuallayoutwidth / 2;

  // Check borders
  if (x < -halfSize * multiplier )
    x = -halfSize * multiplier;

  if (x > (gradientPanel.actuallayoutwidth - halfSize) * multiplier )
    x = (gradientPanel.actuallayoutwidth - halfSize) * multiplier;

  markerGradientPanel.style.marginLeft = x + "px;";
  markerGradientPanel.style.marginBottom = "-10px;";
}

function SetColorFromAngle( angle )
{
  var num = Math.floor(angle / 60);
  var multiplier = (angle % 60) / 60;

  var color = [];
  switch(num)
  {
    case 0:
    case 6:
      color = [255, multiplier * 255, 0];
      break;
    case 1:
      color = [(1 - multiplier) * 255, 255, 0];
      break;
    case 2:
      color = [0, 255, multiplier * 255];
      break;
    case 3:
      color = [0, (1 - multiplier) * 255, 255];
      break;
    case 4:
      color = [multiplier * 255, 0, 255];
      break;
    case 5:
      color = [255, 0, (1 - multiplier) * 255];
      break;
    case 6:
      color = [255, 0, 0];
      break;
  }

  mainColorPanel.style.backgroundColor = "rgb(" + color[0] + "," + color[1] + "," + color[2] + ");";
} 

function GetGradientSliderValue()
{
  var halfSize = markerGradientPanel.actuallayoutwidth / 2;
  var gradientPanelPos = gradientPanel.GetPositionWithinWindow();
  var markerGradientPanelPos = markerGradientPanel.GetPositionWithinWindow();

  var value = Math.round(markerGradientPanelPos["x"] - gradientPanelPos["x"] + halfSize) / gradientPanel.actuallayoutwidth;
  return fullCircle * value;
}

function TrackMouseGradientMarker()
{
  if (GameUI.IsMouseDown(0))
  {
    if (firstClick)
    {
      startMousePos = GameUI.GetCursorPosition();
      startMargin = GetGradientMarkerMargin( startMousePos );
      firstClick = false;

      SetPositionGradientMarker(startMargin);
    }
    else
    {          
      var curPos = GameUI.GetCursorPosition();
      SetPositionGradientMarker (startMargin + multiplier * (curPos[0] - startMousePos[0]));
    }

    SetColorFromAngle( GetGradientSliderValue() );
    OnColorChanged( HSBToRGB() );
  }
  else
    firstClick = true;


  if (!isHoverGradient)
  {
    firstClick = true;
    return;
  }

  $.Schedule(0.01, TrackMouseGradientMarker)
}

function OnLeaveGradientPanel()
{
  isHoverGradient = false;
}

function OnHoverGradientPanel()
{
  if (!isHoverGradient) 
  {
    multiplier = 200 / gradientPanel.actuallayoutwidth;

    isHoverGradient = true;
    TrackMouseGradientMarker();
  }
}

//-----------------------------------------------------------------------------
//                         Color selection
//-----------------------------------------------------------------------------
var fullCircle = 360;
var curValue = -1;
var callbacks = {};

function OnColorChanged( color )
{
  curColor = color;

  for (var f in callbacks["OnColorChanged"])
    callbacks["OnColorChanged"][f]( curColor );
}

//-----------------------------------------------------------------------------
//                         Color convertion
//-----------------------------------------------------------------------------
function PositionToHSV()
{
  var H = GetGradientSliderValue();
  // Get saturation and brightness
  var halfSize = markerPanel.actuallayoutwidth / 2;
  var mainColorPos = mainColorPanel.GetPositionWithinWindow();
  var markerPos = markerPanel.GetPositionWithinWindow();
  var offset = [
    Math.round(markerPos["x"] - mainColorPos["x"] + halfSize) / mainColorPanel.actuallayoutwidth,
    1 - Math.round(markerPos["y"] - mainColorPos["y"] + halfSize) / mainColorPanel.actuallayoutheight,
  ]; 

  return [H, offset[0], offset[1]];
}

function HSBToRGB()
{
  var HSV = PositionToHSV();

  var H = HSV[0];
  var V = HSV[2] * 255;
  var Vmin = (1 - HSV[1] * 1) * V;
  var a = (V - Vmin) * (H % 60) / 60;
  var Vinc = Vmin + a;
  var Vdec = V - a;

  var num = Math.floor(H / 60);
  switch(num)
  {
    case 0:
    case 6:
      return [V, Vinc, Vmin];
    case 1:
      return [Vdec, V, Vmin];
    case 2:
      return [Vmin, V, Vinc];
    case 3:
      return [Vmin, Vdec, V];
    case 4:
      return [Vinc, Vmin, V];
    case 5:
      return [V, Vmin, Vdec];
  }
}

function HSVToPosition( HSV )
{
  // Get saturation and brightness
  var halfSize = markerPanel.actuallayoutwidth / 2;
  var mainColorPos = mainColorPanel.GetPositionWithinWindow();
  var markerPos = markerPanel.GetPositionWithinWindow();

  SetPositionGradientMarker( (gradientPanel.actuallayoutwidth * HSV[0] / fullCircle - halfSize) * multiplier );
  SetPositionMarker( 
    (mainColorPanel.actuallayoutwidth * HSV[1] - halfSize) * multiplier,  
    (mainColorPanel.actuallayoutheight * (1 - HSV[2]) - halfSize) * multiplier
    );
 
  SetColorFromAngle( HSV[0] );
}

function RGBToHSV()
{
  var normalColor = [curColor[0] / 255, curColor[1] / 255, curColor[2] / 255]
  var max = Math.max(normalColor[0], normalColor[1], normalColor[2]);
  var min = Math.min(normalColor[0], normalColor[1], normalColor[2]);

  var H = 0;
  if (max == min)
    H = 0;
  else if (normalColor[0] > normalColor[2] && normalColor[1] > normalColor[2])
  {
    H = (normalColor[1] - normalColor[2]) / (max - min) * 60;
  }

  else if (normalColor[0] < normalColor[2] && normalColor[1] < normalColor[2])
  {
    H = (normalColor[1] - normalColor[2]) / (max - min) * 60 + 360;
  }

  else if (max == normalColor[1])
  {
    H = (normalColor[2] - normalColor[0]) / (max - min) * 60 + 120;
  }

  else if (max == normalColor[2])
  {
    H = (normalColor[0] - normalColor[1]) / (max - min) * 60 + 240;
  }

  var S = max == 0 ? 0 : 1 - min/max;
  var V = max;

  HSVToPosition( [H, S, V] );
}


function SetColor( color )
{
  OnColorChanged( color );
  RGBToHSV();
}

// Event handlers
function RegisterEventHandler( eventName, callback)
{
  if (!callbacks[eventName])
    callbacks[eventName] = [];

  callbacks[eventName].push(callback);
}

(function () {
  multiplier = 200 / mainColorPanel.actuallayoutwidth;
 
  // Public functions
  $("#ColorPicker").SetColor = SetColor;
  $("#ColorPicker").RegisterEventHandler = RegisterEventHandler;
})();