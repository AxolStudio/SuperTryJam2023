package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import gameObjects.IconSprite;
import globals.Globals;
import haxe.ui.components.VerticalScroll;
import haxe.ui.containers.Box;
import haxe.ui.containers.Grid;
import haxe.ui.containers.ScrollView;
import states.GameState.GameSubState;

using axollib.TitleCase;
using flixel.util.FlxSpriteUtil;

class ShopScreen extends GameSubState
{
	public var shopItems:Array<ShopItem> = [];
	public var productionAmount:GameText;

	public var scrollZone:ScrollView; // FlxSpriteGroup;
	public var scrollGrid:Grid;

	// public var scrollBounds:FlxRect;

	override public function create():Void
	{
		// simple border with all availble icons to purchase displayed

		// when an icon is clicked, it is added to the player's inventory

		// when the player clicks the "back" button, the shop screen is closed

		bgColor = FlxColor.TRANSPARENT;

		var background:FlxSprite = new FlxSprite();
		background.makeGraphic(Math.floor(FlxG.width * .6), Math.floor(FlxG.height * .9), FlxColor.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, FlxColor.WHITE);

		background.screenCenter();
		add(background);

		var title:GameText = new GameText(0, 0, 500, "Choose Elements to Add", FlxColor.BLACK, SIZE_36);
		// title.setFormat(null, 32, FlxColor.WHITE, "center");
		title.alignment = "center";
		// title.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		title.screenCenter(FlxAxes.X);
		title.y = background.y + 10;
		add(title);

		add(productionAmount = new GameText(background.x + background.width - 410, 0, 400,
			"Production: {{production}}" + Std.string(Globals.PlayState.production), FlxColor.BLACK, SIZE_36));
		productionAmount.alignment = "right";
		productionAmount.y = background.y + background.height - productionAmount.height - 10;

		add(scrollZone = new ScrollView());
		scrollZone.width = background.width - 24;
		scrollZone.height = background.height - title.height - productionAmount.height - 40;
		scrollZone.x = background.x + 12;
		scrollZone.y = title.y + title.height + 10;
		scrollZone.percentContentWidth = 100;

		scrollGrid = new Grid();
		scrollGrid.width = scrollZone.width;
		scrollGrid.columns = 3;
		scrollGrid.padding = 10;
		scrollGrid.styleString = "spacing:10px;";

		scrollZone.addComponent(scrollGrid);

		var shopItem:ShopItem;
		var box:Box;

		for (s in Globals.SHOP_ITEMS)
		{
			shopItem = new ShopItem(this);
			shopItem.setIcon(s);
			shopItems.push(shopItem);
			box = new Box();
			box.width = shopItem.width;
			box.height = shopItem.height;
			box.add(shopItem);
			scrollGrid.addComponent(box);
		}

		var closeButton:GameButton = new GameButton(background.x + background.width - 42, background.y + 8, "X", onClose, 32, 32, SIZE_36, FlxColor.RED,
			FlxColor.BLACK, FlxColor.WHITE, FlxColor.BLACK);
		// closeButton.makeGraphic(32, 32, FlxColor.RED);
		// closeButton.label.setFormat(null, 16, FlxColor.WHITE, "center");
		// closeButton.label.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		add(closeButton);

		updateButtons();

		// scrollBounds = new FlxRect(background.x
		// 	+ 12, background.y
		// 	+ 22
		// 	+ title.height, background.width
		// 	- 24,
		// 	background.height
		// 	- title.height
		// 	- productionAmount.height
		// 	- 44);

		// scrollZone.clipRect = new FlxRect(0, 0, background.width - 46, background.height - title.height - productionAmount.height - 44);

		super.create();
	}

	public function onClose():Void
	{
		close();
	}

	public function updateButtons():Void
	{
		for (shopItem in shopItems)
		{
			shopItem.buyButton.active = Globals.PlayState.production >= Globals.IconList.get(shopItem.iconSprite.icon).cost;
		}
		productionAmount.text = "Production: {{production}}" + Std.string(Globals.PlayState.production);
	}
}

class ShopItem extends FlxSpriteGroup
{
	// public var x(get, set):Float;
	// public var y(get, set):Float;
	// public var width(get, never):Float;
	// public var height(get, never):Float;
	public var iconSprite:IconSprite;

	public var background:FlxSprite;
	public var cost:GameText;
	public var buyButton:GameButton;
	public var title:GameText;

	public var parent:ShopScreen;

	public static inline var MARGINS:Int = 12;
	public static inline var PADDING:Int = 4;

	public function new(Parent:ShopScreen):Void
	{
		super();

		// width = 250 + (MARGINS * 2);
		// height = 270;
		// backgroundColor = 0xffff0000;

		parent = Parent;

		add(background = new FlxSprite());
		background.makeGraphic(250 + (MARGINS * 2), 270, FlxColor.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, FlxColor.WHITE);

		add(title = new GameText(background.x + MARGINS, background.y + MARGINS, Std.int(background.width - (MARGINS * 2)), "Title", FlxColor.BLACK, SIZE_36));
		title.alignment = "center";

		add(iconSprite = new IconSprite(background.x + (background.width / 2) - 64, title.y + title.height + PADDING));

		add(cost = new GameText(background.x + MARGINS, iconSprite.y + iconSprite.height + PADDING, Std.int(background.width - (MARGINS * 2)),
			"Cost: {{production}}0", FlxColor.BLACK, SIZE_24));
		cost.alignment = "center";

		add(buyButton = new GameButton(background.x + MARGINS, 0, "Buy", onBuy, background.width - (MARGINS * 2), 32, FlxColor.BLUE, FlxColor.BLACK,
			FlxColor.WHITE, FlxColor.BLACK));
		buyButton.active = false;
		buyButton.y = background.y + background.height - buyButton.height - MARGINS;
	}

	public function setIcon(Icon:String):Void
	{
		iconSprite.icon = Icon;
		cost.text = "Cost: {{production}}" + Std.string(Globals.IconList.get(Icon).cost);
		title.text = Icon.toTitleCase();
	}

	public function onBuy():Void
	{
		buyButton.active = false;
		// deduct cost from production

		Globals.PlayState.production -= Globals.IconList.get(iconSprite.icon).cost;

		// add the new icon to the player's collection

		Globals.PlayState.addNewIcon(iconSprite.icon);

		// update buttons of all shop items

		parent.updateButtons();
	}

	// override function set_left(value:Null<Float>):Null<Float>
	// {
	// 	if (background != null)
	// 	{
	// 		background.x = value;
	// 		title.x = background.x + MARGINS;
	// 		iconSprite.x = background.x + (background.width / 2) - 64;
	// 		cost.x = background.x + MARGINS;
	// 		buyButton.x = background.x + MARGINS;
	// 	}
	// 	return super.set_left(value);
	// }
	// override function set_top(value:Null<Float>):Null<Float>
	// {
	// 	if (background != null)
	// 	{
	// 		background.y = value;
	// 		title.y = background.y + MARGINS;
	// 		iconSprite.y = title.y + title.height + PADDING;
	// 		cost.y = iconSprite.y + iconSprite.height + PADDING;
	// 		buyButton.y = background.y + background.height - buyButton.height - MARGINS;
	// 	}
	// 	return super.set_top(value);
	// }
	// public function set_x(Value:Float):Float
	// {
	// 	background.x = Value;
	// 	title.x = background.x + MARGINS;
	// 	iconSprite.x = background.x + (background.width / 2) - 64;
	// 	cost.x = background.x + MARGINS;
	// 	buyButton.x = background.x + MARGINS;
	// 	return Value;
	// }
	// public function set_y(Value:Float):Float
	// {
	// 	background.y = Value;
	// 	title.y = background.y + MARGINS;
	// 	iconSprite.y = title.y + title.height + PADDING;
	// 	cost.y = iconSprite.y + iconSprite.height + PADDING;
	// 	buyButton.y = background.y + background.height - buyButton.height - MARGINS;
	// 	return Value;
	// }
	// public function get_width():Float
	// {
	// 	return background.width;
	// }
	// public function get_height():Float
	// {
	// 	return background.height;
	// }
	// public function get_x():Float
	// {
	// 	return background.x;
	// }
	// public function get_y():Float
	// {
	// 	return background.y;
	// }
}
