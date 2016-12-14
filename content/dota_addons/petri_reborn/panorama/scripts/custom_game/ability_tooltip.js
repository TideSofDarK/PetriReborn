'use strict';

// Таблицы с данными для подсказок
var specialValues = null;

var m_panel = null;
var x_mult = 1;
var y_mult = 1;

/*
      Позиция
*/

function GetOffsetX( element, offset)
{
  if (!element) {
    return 0;
  }
  if (element && element.paneltype == "CustomUIElement")
  {
    // magic number, ширина панели на разрешении 16:9
    x_mult = 480 / element.desiredlayoutwidth;
    return (offset + element.actualxoffset);
  }

  return GetOffsetX(element.GetParent(), offset + element.actualxoffset);
}

function GetOffsetY( element, offset)
{
  if (!element) {
    return 0;
  }
  if (element && element.paneltype == "CustomUIElement")
  {
    // magic number, высота панели на разрешении 16:9
    y_mult = 121 / element.desiredlayoutheight;
    return (offset + element.actualyoffset);
  }

  return GetOffsetY(element.GetParent(), offset + element.actualyoffset);
}

function SetPosition()
{
  if (!m_panel) return;
  var x = (GetOffsetX( m_panel, 0) + m_panel.actuallayoutwidth) * x_mult;
  var y = (GetOffsetY( m_panel, 0) - ( $.GetContextPanel().actuallayoutheight - m_panel.actuallayoutheight )) * y_mult;

  //$.GetContextPanel().style.position = x + "px " + y + "px 0px;"; 
  SetPositionRotation( $.GetContextPanel(), [x, y], 0 );
}

/*
      Описание
*/

function FillDescription( abilityID )
{
  var abilityName = Abilities.GetAbilityName( abilityID );
  var abilityLevel = GameUI.CustomUIConfig().IsEnemySelected() ? 0 : Abilities.GetLevel( abilityID );
  var maxAbilityLevel = Abilities.GetMaxLevel( abilityID );

  $( "#Header" ).FindChild( "AbilityName" ).text = $.Localize( "#DOTA_Tooltip_ability_" + abilityName );
  var levelLabel = $( "#Header" ).FindChild( "AbilityLevel" );
  levelLabel.text = $.Localize( "#level") + abilityLevel;
  levelLabel.SetHasClass( "one_level", abilityLevel == maxAbilityLevel);
  
  $( "#Description" ).FindChild( "AbilityDescription" ).text = $.Localize( "#DOTA_Tooltip_ability_" + abilityName + "_Description" );  
}

/*
      Стоимость
*/

function FillCosts( abilityID )
{
  var isEnemy = GameUI.CustomUIConfig().IsEnemySelected();

  var abilityLevel = Abilities.GetLevel( abilityID );
  var manaCost = Abilities.GetManaCost( abilityID );
  var lumberCost = Abilities.GetLevelSpecialValueFor( abilityID, "lumber_cost", abilityLevel - 1 );
  var foodCost = Abilities.GetLevelSpecialValueFor( abilityID, "food_cost", abilityLevel - 1 );
  var goldCost = 0;

  try
  {
    goldCost = GameUI.CustomUIConfig().goldCosts [ Abilities.GetAbilityName( abilityID ) ][ String(abilityLevel) ];
  }
  catch( error ) { }

  var costsPanel = $( "#CooldownAndCosts" ).FindChild( "Costs" );
  var goldText = costsPanel.FindChild( "GoldText" );
  var lumberText = costsPanel.FindChild( "LumberText" );
  var foodText = costsPanel.FindChild( "FoodText" );
  var manaText = costsPanel.FindChild( "ManaText" );

  var curRes = CustomNetTables.GetTableValue("players_resources", GameUI.CustomUIConfig().GetSelectedUnitOwner());
  if (curRes == undefined || isEnemy)
    curRes = { "lumber": 0, "food": 0, "gold": 0, "maxFood": 0 };

  goldText.text = goldCost;
  goldText.SetHasClass("not_enought", goldCost > curRes["gold"] );
  goldText.SetHasClass("null", goldCost == 0 || isEnemy);

  lumberText.text = lumberCost;
  lumberText.SetHasClass("not_enought", lumberCost > curRes["lumber"] );  
  lumberText.SetHasClass("null", lumberCost == 0 || isEnemy);

  foodText.text = foodCost;
  foodText.SetHasClass("not_enought", curRes["food"] + foodCost > curRes["maxFood"]);    
  foodText.SetHasClass("null", foodCost == 0 || isEnemy);

  manaText.text = manaCost;
  manaText.SetHasClass("null", manaCost == 0 || isEnemy);

  var timers = $( "#CooldownAndCosts" ).FindChild( "Timers" );
  var cd = Abilities.GetCooldown( abilityID );
  var cdPanel = timers.FindChild( "CooldownLabel");
  cdPanel.text = Math.floor(cd * 100) / 100;
  cdPanel.SetHasClass( "no_cd", cd == 0 || isEnemy);

  var channel = Abilities.GetChannelTime( abilityID );
  var channelPanel = timers.FindChild( "ChannelLabel");
  channelPanel.text = Math.floor(channel * 100) / 100;
  channelPanel.SetHasClass( "no_channel", channel == 0 || isEnemy);  
}

/*
      Зависимости
*/

function CheckDependence( name, level )
{
  var table = CustomNetTables.GetTableValue("players_dependencies", GameUI.CustomUIConfig().GetSelectedUnitOwner());
  if (table[name] == undefined)
    return false;

  return table[name] >= level;
}

function CreateDependencyPanel( abilityName )
{
  var dependenciesTable = GameUI.CustomUIConfig().dependencies;
  if (!dependenciesTable)
    return;

  var mainPanel = $.CreatePanel( "Panel", $.GetContextPanel(), "Dependence_" + abilityName );

  var dependencies = dependenciesTable[abilityName];
  mainPanel.SetHasClass( "all_enought", dependencies == undefined);
  if (dependencies == undefined)
    return null;

  var isEnemy = GameUI.CustomUIConfig().IsEnemySelected();
  var isAllDependencies = true;
  for(var name in dependencies)
  {
    var cur_panel = $.CreatePanel( "Label", mainPanel, "_dependence_" + name );
    var upgradeLevel = dependencies[name];
    cur_panel.text = $.Localize( "#DOTA_Tooltip_ability_" + name ) + 
      (upgradeLevel > 1 ? " (" + dependencies[name] + ")" : "");

    cur_panel.AddClass( "DependenceLabel" );

    var curDepend = CheckDependence( name, upgradeLevel );
    cur_panel.SetHasClass( "isBuild",  curDepend );
    cur_panel.SetHasClass( "isEnemy",  isEnemy );
    isAllDependencies = isAllDependencies && curDepend && !isEnemy;
  }

  mainPanel.SetHasClass( "flowDowm", true);
  mainPanel.SetHasClass( "all_enought", isAllDependencies );

  return mainPanel;
}

function FillDependencies( abilityID )
{
  var dependPanel = $( "#Dependencies" );  
  dependPanel.RemoveAndDeleteChildren();

  var abilityName = Abilities.GetAbilityName( abilityID );
  var abilityLevel = Abilities.GetLevel( abilityID ); 

  var expr = new RegExp("build");
  if (!expr.test(abilityName))
    abilityName += "_" + abilityLevel;

  var panels = [];

  var mainDependecies = CreateDependencyPanel( abilityName );
  panels.push(CreateDependencyPanel( abilityName + "_alt" ));

  if (!mainDependecies)
    return;

  var all_enought = mainDependecies.BHasClass("all_enought");
  mainDependecies.SetParent(dependPanel);

  for(var panel of panels)
    if (panel)
    {
      all_enought = all_enought || panel.BHasClass("all_enought");

      var cur_panel = $.CreatePanel( "Label", dependPanel, "separator" );
      cur_panel.text = $.Localize( "#OR" );
      cur_panel.AddClass( "SeparateLabel" );

      panel.SetParent(dependPanel);
    }

  dependPanel.SetHasClass( "all_enought", all_enought );
}

/*
      Специальные значения
*/

function SetHTMLStyle( text, style)
{
  return "<span class=\"" + style + "\">" + text + "</span>";
}

function roundToTwo(num) {    
    return +(Math.round(num + "e+2")  + "e-2");
}

function GetSpecialValuesList( abilityID, name )
{
  var abilityLevel = GameUI.CustomUIConfig().IsEnemySelected() ? 0 : Abilities.GetLevel( abilityID );
  var maxAbilityLevel = Abilities.GetMaxLevel( abilityID );

  var str = abilityLevel == 0
    ? roundToTwo(Abilities.GetLevelSpecialValueFor( abilityID, name, abilityLevel ))
    : SetHTMLStyle( Abilities.GetLevelSpecialValueFor( abilityID, name, abilityLevel - 1 ), "SpecialsLabelColor" );
  var prevValue = str;
  for (var i = abilityLevel; i < maxAbilityLevel - 1; i++) 
  {
    var curValue = Abilities.GetLevelSpecialValueFor( abilityID, name, i ).toFixed(2);
    curValue = roundToTwo(curValue);
    // if (typeof(curValue) == "float")
    if (curValue != prevValue)
    {
      str += " / " +  curValue;
      prevValue = curValue;
    }
  };

  return str;
}

function FillSpecials( abilityID )
{
  var specialsPanel = $( "#Specials" );
  specialsPanel.RemoveAndDeleteChildren();

  var abilityName = Abilities.GetAbilityName( abilityID );
  var specials = GameUI.CustomUIConfig().specialValues[abilityName];

  specialsPanel.SetHasClass( "empty", specials == undefined || Object.keys(specials).length == 0 );
  if (specials == undefined || Object.keys(specials).length == 0)
    return;

  for(var name in specials)
  {
    var cur_panel = $.CreatePanel( "Label", specialsPanel, "_special_" + name );
    cur_panel.html = true;
    cur_panel.text = SetHTMLStyle( $.Localize( "#DOTA_Tooltip_ability_" + abilityName + "_" + specials[name]), "SpecialsLabelName" ) + 
      " " + GetSpecialValuesList(abilityID, specials[name]);
    cur_panel.AddClass( "SpecialsLabel" );
  }
}

function SetPositionRotation( element, position, rotation ) {
  var oldPosition = element.oldPosition || [0, 0];
  var oldRotation = element.oldRotation || 0;

  //Revert previous transformation
  element.style.transform = "translate3d(" +
          -oldPosition[0] + "px, " + -oldPosition[1] + "px, 0px) rotateZ("+(-oldRotation)+"deg)";

  //Apply new transformation
  element.style.transform = "rotateZ("+rotation+"deg) translate3d(" +
          position[0] + "px, " + position[1] + "px, 0px)";

  element.oldPosition = position;
  element.oldRotation = rotation;
}

function ShowTooltip( panel, abilityID )
{
  if (!panel)
    return;

  m_panel = panel;

  FillDescription( abilityID );
  FillCosts( abilityID );
  
  FillDependencies( abilityID );
  FillSpecials( abilityID );

  //$.GetContextPanel().style.position = "-1000px 0px 0px;";
  SetPositionRotation( $.GetContextPanel(), [-400, 0], 0 );
  
  // Delay to recalculate sizes
  $.Schedule(0.1, SetPosition);
  $.GetContextPanel().visible = true; 
}

function HideTooltip()
{
  $.GetContextPanel().visible = false;
}

(function () {
  SetPositionRotation( $.GetContextPanel(), [-400, 0], 0 );

  GameEvents.Subscribe( "dota_player_update_selected_unit", HideTooltip );
  GameEvents.Subscribe( "dota_player_update_query_unit", HideTooltip );

  $.GetContextPanel().ShowTooltip = ShowTooltip;
  $.GetContextPanel().HideTooltip = HideTooltip;

  GameUI.CustomUIConfig().tooltip = $.GetContextPanel();
})();