package {
	import flash.events. * ;
	import flash.display. * ;
	import flash.utils. * ;

	import flash.display.MovieClip;
	import ValveLib.Globals;
	
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextField;
	import flash.events.Event;

	public class CustomUI extends MovieClip {
		public var gameAPI: Object;
		public var globals: Object;
		public var elementName: String;

		public var repeatTimer: Timer;
		
		public function CustomUI() : void {
			super();
		}

		public function onUnload() : void {
			repeatTimer.stop();
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy0.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy1.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy2.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy3.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy4.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy5.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy6.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy7.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy8.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item0.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item1.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item2.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item3.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item4.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item5.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
		}

		public function OnUnload() : void {
			repeatTimer.stop();
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy0.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy1.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy2.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy3.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy4.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy5.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy6.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy7.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy8.removeEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item0.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item1.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item2.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item3.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item4.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item5.removeEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
		}

		public function onLoaded() : void {
			this.gameAPI.OnReady();
			repeatTimer = new Timer((1000 / 60));
			repeatTimer.addEventListener(TimerEvent.TIMER, this.Stuff);
			repeatTimer.start();

			this.addEventListener ("unload", this.onUnload);


			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy0.addEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy1.addEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy2.addEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy3.addEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy4.addEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy5.addEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy6.addEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy7.addEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy8.addEventListener(MouseEvent.ROLL_OVER, this.CustomQuickBuyToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item0.addEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item1.addEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item2.addEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item3.addEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item4.addEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
			this.globals.Loader_inventory.movieclip.inventory.items.Item5.addEventListener(MouseEvent.ROLL_OVER, this.CustomInventoryToolTip, false, -1);
		}

		public function CustomInventoryToolTip() {
			this.globals.Loader_overlay.movieclip.hud_overlay.inventory_tooltip.rightArrow.visible = false;
			this.MoveInventoryToolTip();
		}

		public function MoveInventoryToolTip() {
			var tX: *=this.globals.Loader_inventory.movieclip.inventory.items.Item0.x;
			var tY: *=this.globals.Loader_inventory.movieclip.inventory.items.Item0.y;
			this.globals.Loader_overlay.movieclip.hud_overlay.inventory_tooltip.y = (this.globals.Loader_overlay.movieclip.hud_overlay.inventory_tooltip.y - 110);
		}
		
		public function CustomQuickBuyToolTip() {
			this.globals.Loader_overlay.movieclip.hud_overlay.shop_tooltip.rightArrow.visible = false;
			this.MoveToolTip();
		}
		
		public function MoveToolTip() {
			var tX: *=this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy0.x;
			var tY: *=this.globals.Loader_inventory.movieclip.inventory.quickbuy.quickBuy0.y;
			this.globals.Loader_overlay.movieclip.hud_overlay.shop_tooltip.y = (this.globals.Loader_overlay.movieclip.hud_overlay.shop_tooltip.y - 170);
		}
		
		public function Stuff(e: TimerEvent) {
			var abilities: *=this.globals.Loader_actionpanel.movieclip.middle.abilities;
			var inventory: *=this.globals.Loader_inventory.movieclip.inventory;
			var stash: *=this.globals.Loader_inventory.movieclip.inventory.stash_anim.stash;
			abilities.Ability0.visible = false;
			abilities.Ability1.visible = false;
			abilities.Ability2.visible = false;
			abilities.Ability3.visible = false;
			abilities.Ability4.visible = false;
			abilities.Ability5.visible = false;
			abilities.abilityBind0.visible = false;
			abilities.abilityBind1.visible = false;
			abilities.abilityBind2.visible = false;
			abilities.abilityBind3.visible = false;
			abilities.abilityBind4.visible = false;
			abilities.abilityBind5.visible = false;
			abilities.abilitybuild_ability0.visible = false;
			abilities.abilitybuild_ability1.visible = false;
			abilities.abilitybuild_ability2.visible = false;
			abilities.abilitybuild_ability3.visible = false;
			abilities.abilitybuild_ability4.visible = false;
			abilities.abilitybuild_ability5.visible = false;
			abilities.abilityGold0.visible = false;
			abilities.abilityGold1.visible = false;
			abilities.abilityGold2.visible = false;
			abilities.abilityGold3.visible = false;
			abilities.abilityGold4.visible = false;
			abilities.abilityGold5.visible = false;
			abilities.abilityLevelPips0.visible = false;
			abilities.abilityLevelPips1.visible = false;
			abilities.abilityLevelPips2.visible = false;
			abilities.abilityLevelPips3.visible = false;
			abilities.abilityLevelPips4.visible = false;
			abilities.abilityLevelPips5.visible = false;
			abilities.abilityMana0.visible = false;
			abilities.abilityMana1.visible = false;
			abilities.abilityMana2.visible = false;
			abilities.abilityMana3.visible = false;
			abilities.abilityMana4.visible = false;
			abilities.abilityMana5.visible = false;
		}
	}
}
