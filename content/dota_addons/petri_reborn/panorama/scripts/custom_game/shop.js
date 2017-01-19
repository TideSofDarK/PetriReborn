var selectedItem;

var shopItems = {};

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

function Clean(panel) {
	var children = panel.Children();
	for (var key in children) {
		children[key].RemoveAndDeleteChildren();
		children[key].DeleteAsync(0.0);
	}
}

function SetupItems(team, hero) {
	if (!GameUI.CustomUIConfig().shopsKVs || !GameUI.CustomUIConfig().itemBuilds) {
		$.Schedule(0.1, SetupItems)
		return;
	}

	Clean($("#ShopGuide"));
	Clean($("#ShopQuickbuy"));

	$("#Petri").visible = false;
	$("#KVN").visible = false;

	var team = team || Entities.GetTeamNumber(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ));
	var heroName = hero || Entities.GetUnitName(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ));

	for (var key in GameUI.CustomUIConfig().shopsKVs) {
		var r = $("#ShopWindow").FindChildTraverse(key);
		if (r) {
			Clean(r);
			for (var key2 in GameUI.CustomUIConfig().shopsKVs[key]) {
				(function () {
					var itemname = GameUI.CustomUIConfig().shopsKVs[key][key2];

					shopItems[itemname] = CreateItem(r, itemname);
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

	if (GameUI.CustomUIConfig().itemBuilds[heroName]) {
		for (var t in GameUI.CustomUIConfig().itemBuilds[heroName].Items) {
			var items = GameUI.CustomUIConfig().itemBuilds[heroName].Items[t];

			var guideBlock = $.CreatePanel("Panel", $("#ShopGuide"), t.replace("#", ""));
			guideBlock.BLoadLayoutSnippet("GuideBlock");

			guideBlock.FindChildTraverse("ShopGuideBlockLabel").text = $.Localize(t.replace("#", ""));

			var x = 0;
			var y = 0;
			var i = 1;
			for (var item in items) {
				var itemPanel = CreateItem(guideBlock.FindChildTraverse("ShopGuideBlockItems"), items[i]);
				itemPanel.style.position = (x * 60) + "px " + (y * 44) + "px " + "0px;";
				x++;
				if ((x ) % 3 == 0) {
					x = 0;
					y++;
				}

				i++;
			}
		}
		$("#ShopGuide").visible = true;
	} else {
		$("#ShopGuide").visible = false;
	}
}

function OpenQuickbuy(itemname) {
	for (var key in $("#ShopQuickbuy").Children()) {
		var child = $("#ShopQuickbuy").Children()[key];
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

		for (var key in recipe) {
			var recipePart = recipe[key];
			CreateItem($("#ShopQuickbuy"), recipePart)
		}

		CreateItem($("#ShopQuickbuy"), recipeName)
	} else {
		CreateItem($("#ShopQuickbuy"), itemname)
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
		$("#ShopRecipeLabel").visible = false;
		CreateItem($("#ShopRecipeContainer"), itemname)
		// $("#ShopRecipeLabel").visible = true;
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
		GameEvents.SendCustomGameEventToServer("petri_buy_item", { itemname : itemname, hero : Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ), buyer : Players.GetLocalPlayerPortraitUnit() });
	}));
	item.SetPanelEvent('onactivate', (function () {
		if (selectedItem) {
			selectedItem.RemoveClass("Selected");
		}
		selectedItem = item;
		item.AddClass("Selected");
		OpenRecipe(itemname)
		OpenQuickbuy(itemname)
	}));

	return item;
}

var convertTime = (function (d) {
	d = Number(d);
	var h = Math.floor(d / 3600);
	var m = Math.floor(d % 3600 / 60);
	var s = Math.floor(d % 3600 % 60);
	return ((h > 0 ? h + ":" + (m < 10 ? "0" : "") : "") + m + ":" + (s < 10 ? "0" : "") + s); 
});

function ShopStock(table_name, key, data) {
	if (shopItems[key]) {
		if (CustomNetTables.GetTableValue(table_name, key).count == 0) {
			shopItems[key].AddClass("OutOfStock");
			shopItems[key].FindChildTraverse("StockLabel").visible = true;
		} else {
			shopItems[key].RemoveClass("OutOfStock");
			shopItems[key].FindChildTraverse("StockLabel").visible = false;
		}
		shopItems[key].FindChildTraverse("StockLabel").text = convertTime(CustomNetTables.GetTableValue(table_name, key).time);
	}
}

function ChangeTeam(args) {
	for (var key in $("#ShopRecipeContainer").Children()) {
		var child = $("#ShopRecipeContainer").Children()[key];
		if (child == selectedItem) {
			selectedItem = undefined;
		}
		child.RemoveAndDeleteChildren();
		child.DeleteAsync(0.0);
	}
	
	for (var key in $("#ShopQuickbuy").Children()) {
		var child = $("#ShopQuickbuy").Children()[key];
		if (child == selectedItem) {
			selectedItem = undefined;
		}
		child.RemoveAndDeleteChildren();
		child.DeleteAsync(0.0);
	}
	SetupItems(args.team, args.hero);
}

(function () {
	GameEvents.Subscribe("petri_team", ChangeTeam);
	CustomNetTables.SubscribeNetTableListener("shop", ShopStock)

	SetupItems();
})();