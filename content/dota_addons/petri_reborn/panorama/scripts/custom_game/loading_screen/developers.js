'use strict';
var tooltipManager = $.GetContextPanel().GetParent().GetParent();
var rolePanel = null;

var roles = {
	"76561198001376044" : "#creator",
	"76561197996730911" : "#panoramaui",
	"76561198060190530" : "#gamedesigner",
	"76561198069840828" : "#models"
};

function ShowProfile()
{
	if (!rolePanel)
  		$.Schedule(0.05, AddRole);
  	else
  		$.Schedule(0.01, ChangeDeveloperRole);
}

function MoveBadge( isMove )
{
	var tooltip = tooltipManager.FindChildTraverse("DOTAProfileCardTooltip");
	var profileBadge = tooltip.FindChildTraverse("ProfileBadge");
	var profileBadgeBack = tooltip.FindChildTraverse("ProfileBadgeBackground");

	profileBadge.style.marginTop = (isMove ? 50 : 2) + "px;"
	profileBadgeBack.style.marginTop = (isMove ? 54 : 6) + "px;"
}

// Add developer panel
function AddRole()
{
	var tooltip = tooltipManager.FindChildTraverse("DOTAProfileCardTooltip");

	var contents = tooltip.FindChildTraverse("ContentsMain")
	rolePanel = contents.FindChild("RolePanel");

	if (!rolePanel)
	{
		rolePanel = $.CreatePanel( "Panel", contents, "RolePanel" );
		rolePanel.BLoadLayout( "file://{resources}/layout/custom_game/loading_screen/role_panel.xml", false, false );
		contents.MoveChildBefore(rolePanel, contents.FindChild("CardHeader"));
	}

	ChangeDeveloperRole();
}

// Change text in developer panel
function ChangeDeveloperRole()
{
	var contents = rolePanel.GetParent();
	var steamID = contents.FindChildTraverse("AvatarImage").steamid;

	MoveBadge( roles[steamID] != undefined );
	rolePanel.visible = roles[steamID] != undefined;
	rolePanel.FindChild("RoleName").text = $.Localize(roles[steamID]);
}

function FillDevelopers()
{
	var devPanel = $( "#Developers" );
	if (devPanel.GetChildCount() > 0)
		return;

	for (var steamID in roles) {
		var avatar = $.CreatePanel( "DOTAAvatarImage", devPanel, "id" + steamID );
		avatar.steamid = steamID;
		avatar.AddClass("circle avatar");
		avatar.SetHasClass("circle", true);
		avatar.SetHasClass("avatar", true);
	};
}

(function () {
	$.RegisterForUnhandledEvent( "DOTAShowProfileCardTooltip", ShowProfile);
	FillDevelopers();
})(); 