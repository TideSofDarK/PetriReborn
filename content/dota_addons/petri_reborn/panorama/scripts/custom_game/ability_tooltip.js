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
  if (element.paneltype == "CustomUIElement")
  {
    // magic number, ширина панели на разрешении 16:9
    x_mult = 480 / element.desiredlayoutwidth;
    return (offset + element.actualxoffset);
  }

  return GetOffsetX(element.GetParent(), offset + element.actualxoffset);
}

function GetOffsetY( element, offset)
{
  if (element.paneltype == "CustomUIElement")
  {
    // magic number, высота панели на разрешении 16:9
    y_mult = 121 / element.desiredlayoutheight;
    return (offset + element.actualyoffset);
  }

  return GetOffsetY(element.GetParent(), offset + element.actualyoffset);
}

function SetPosition()
{
  var x = (GetOffsetX( m_panel, 0) + m_panel.actuallayoutwidth) * x_mult;
  var y = (GetOffsetY( m_panel, 0) - ( $.GetContextPanel().actuallayoutheight - m_panel.actuallayoutheight )) * y_mult;

  $.GetContextPanel().style.position = x + "px " + y + "px 0px;";
}

/*
      Описание
*/

function FillDescription( abilityID )
{
  var abilityName = Abilities.GetAbilityName( abilityID );
  var abilityLevel = Abilities.GetLevel( abilityID );
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

  var curRes = GameUI.CustomUIConfig().unitResources;

  goldText.text = goldCost;
  goldText.SetHasClass("not_enought", goldCost > Players.GetGold(Players.GetLocalPlayer()) );
  goldText.SetHasClass("null", goldCost == 0);

  lumberText.text = lumberCost;
  lumberText.SetHasClass("not_enought", lumberCost > curRes["lumber"] );  
  lumberText.SetHasClass("null", lumberCost == 0);

  foodText.text = foodCost;
  foodText.SetHasClass("not_enought", curRes["food"] + foodCost > curRes["maxFood"]);    
  foodText.SetHasClass("null", foodCost == 0);

  manaText.text = manaCost;
  manaText.SetHasClass("null", manaCost == 0);

  var cdPanel = $( "#CooldownAndCosts" ).FindChild( "Cooldown" );
  var cd = Abilities.GetCooldown( abilityID );
  cdPanel.FindChild( "CooldownLabel").text = Math.floor(cd * 100) / 100;
  cdPanel.SetHasClass( "no_cd", cd == 0);
}

/*
      Зависимости
*/

function CheckDependence( name, level )
{
  var table = CustomNetTables.GetTableValue("players_dependencies", Players.GetLocalPlayer());
  if (table[name] == undefined)
    return false;

  return table[name] >= level;
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

  var dependencies = GameUI.CustomUIConfig().dependencies[abilityName];
  if (dependencies == undefined)
    return;

  var isAllDependencies = true;
  for(var name in dependencies)
  {
    var cur_panel = $.CreatePanel( "Label", dependPanel, "_dependence_" + name );
    var upgradeLevel = dependencies[name];
    cur_panel.text = $.Localize( "#DOTA_Tooltip_ability_" + name ) + 
      (upgradeLevel > 1 ? " (" + dependencies[name] + ")" : "");

    cur_panel.AddClass( "DependenceLabel" );

    var curDepend = CheckDependence( name, upgradeLevel );
    cur_panel.SetHasClass( "isBuild",  curDepend );
    isAllDependencies = isAllDependencies && curDepend;
  }
  
  dependPanel.SetHasClass( "all_enought", isAllDependencies );

  var splitter = $.CreatePanel( "Panel", dependPanel, undefined ); 
  splitter.AddClass( "Splitter" );
}

/*
      Специальные значения
*/

function SetHTMLStyle( text, style)
{
  return "<span class=\"" + style + "\">" + text + "</span>";
}

function GetSpecialValuesList( abilityID, name )
{
  var abilityLevel = Abilities.GetLevel( abilityID );
  var maxAbilityLevel = Abilities.GetMaxLevel( abilityID );

  var str = abilityLevel == 0 
    ? Abilities.GetLevelSpecialValueFor( abilityID, name, abilityLevel ) 
    : SetHTMLStyle( Abilities.GetLevelSpecialValueFor( abilityID, name, abilityLevel - 1 ), "SpecialsLabelColor" );
  var prevValue = str;
  for (var i = abilityLevel; i < maxAbilityLevel - 1; i++) 
  {
    var curValue = Abilities.GetLevelSpecialValueFor( abilityID, name, i );
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

  var splitter = $.CreatePanel( "Panel", specialsPanel, undefined ); 
  splitter.AddClass( "Splitter" );    
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

  $.GetContextPanel().visible = true;
  $.GetContextPanel().style.position = "-1000px 0px 0px;";

  $.Schedule(0.1, SetPosition);
}

function HideTooltip()
{
  $.GetContextPanel().visible = false;
}

(function () {
  GameEvents.Subscribe( "dota_player_update_selected_unit", HideTooltip );
  GameEvents.Subscribe( "dota_player_update_query_unit", HideTooltip );
  
  $.GetContextPanel().data().ShowTooltip = ShowTooltip;
  $.GetContextPanel().data().HideTooltip = HideTooltip;

  GameUI.CustomUIConfig().tooltip = $.GetContextPanel();
})();