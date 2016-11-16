var selectedItem;

function ToggleShop() {
	$("#ShopWindow").ToggleClass("Hide");
	$("#ShopGuide").ToggleClass("Hide");
}

function OpenTab(arg) {
	$("#BasicShopTab").RemoveClass("ShopTabHighlight");
	$("#AdvancedShopTab").RemoveClass("ShopTabHighlight");
	$("#SecretShopTab").RemoveClass("ShopTabHighlight");

	$("#" + arg + "Tab").AddClass("ShopTabHighlight");

	$("#BasicShopContents").visible = false;
	$("#AdvancedShopContents").visible = false;
	$("#SideShopContents").visible = false;
	$("#SecretShopContents").visible = false;

	$("#" + arg + "Contents").visible = true;
}

function SetupItems() {
	if (!GameUI.CustomUIConfig().shopsKVs) {
		$.Schedule(0.1, SetupItems)
		return;
	}

	$("#Petri").visible = false;
	$("#KVN").visible = false;

	var team = Entities.GetTeamNumber(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ));
	var heroName = Entities.GetUnitName(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ));

	for (var key in GameUI.CustomUIConfig().shopsKVs) {
		var r = $("#ShopWindow").FindChildTraverse(key);
		if (r) {
			for (var key2 in GameUI.CustomUIConfig().shopsKVs[key]) {
				(function () {
					var itemname = GameUI.CustomUIConfig().shopsKVs[key][key2];

					CreateItem(r, itemname)
				})();
			}
			if (r.Children().length == 0) {
				r.visible = false;
			}
		}
	}

	if (team == 2) {
		$("#KVN").visible = true;
		OpenTab("SideShop");
		$("#SideShopTab").style.width = "100%;";
	} else {
		$("#Petri").visible = true;
		OpenTab("BasicShop");
	}

	for (var t in GameUI.CustomUIConfig().itemBuilds[heroName].Items) {
		var items = GameUI.CustomUIConfig().itemBuilds[heroName].Items[t];

		var guideBlock = $.CreatePanel("Panel", $("#ShopGuide"), t.replace("#", ""));
		guideBlock.BLoadLayoutSnippet("GuideBlock");

		guideBlock.FindChildTraverse("ShopGuideBlockLabel").text = $.Localize(t.replace("#", ""));

		var x = 0;
		var y = 0;
		for (var item in items) {
			var itemPanel = CreateItem(guideBlock.FindChildTraverse("ShopGuideBlockItems"), items[item]);
			itemPanel.style.position = (x * 60) + "px " + (y * 44) + "px " + "0px;";
			x++;
			if ((x ) % 3 == 0) {
				x = 0;
				y++;
			}
		}
	}
}

function OpenRecipe(itemname) {
	for (var key in $("#ShopRecipeContainer").Children()) {
		var child = $("#ShopRecipeContainer").Children()[key];
		if (child == selectedItem) {
			selectedItem = undefined;
		}
		child.RemoveAndDeleteChildren();
		child.DeleteAsync(0.0);
	}

	var recipeName = itemname.replace("item_", "item_recipe_");
	var recipe = GameUI.CustomUIConfig().itemsKVs[recipeName];
	if (recipe) {
		recipe = recipe.ItemRequirements["01"];
		recipe = recipe.split(";");

		$("#ShopRecipeLabel").visible = false;

		for (var key in recipe) {
			var recipePart = recipe[key];
			CreateItem($("#ShopRecipeContainer"), recipePart)
		}

		CreateItem($("#ShopRecipeContainer"), recipeName)
	}
	else {
		$("#ShopRecipeLabel").visible = true;
	}
}

function CreateItem(r, itemname) {
	if (itemname == "") {
		return;
	}
	var item = $.CreatePanel("Panel", r, itemname);
	item.BLoadLayoutSnippet("Item");

	item.FindChildTraverse("ItemImage").itemname = itemname;
	item.itemname = itemname;

	item.SetPanelEvent('oncontextmenu', (function () {
		GameEvents.SendCustomGameEventToServer("petri_buy_item", { itemname : itemname, hero : Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ) });
	}));
	item.SetPanelEvent('onactivate', (function () {
		if (selectedItem) {
			selectedItem.RemoveClass("Selected");
		}
		selectedItem = item;
		item.AddClass("Selected");
		OpenRecipe(itemname)
	}));

	return item;
}

(function () {
	SetupItems();
})();