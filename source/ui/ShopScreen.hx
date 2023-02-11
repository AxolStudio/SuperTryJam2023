package ui;

import states.GameState.GameSubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import gameObjects.IconSprite;
import globals.Globals;

using flixel.util.FlxSpriteUtil;

class ShopScreen extends GameSubState
{
	public var shopItems:FlxTypedGroup<ShopItem>;

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

		var title:FlxText = new FlxText(0, 0, 0, "Choose Elements to Add");
		title.setFormat(null, 32, FlxColor.BLACK, "center");
		title.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 2);
		title.screenCenter(FlxAxes.X);
		title.y = background.y + 10;
		add(title);

		add(shopItems = new FlxTypedGroup<ShopItem>());

		var shopItem:ShopItem;
		for (s in Globals.SHOP_ITEMS)
		{
			shopItem = new ShopItem();
			shopItem.x = background.x + 10 + (shopItems.length % 2) * (shopItem.width + 10);
			shopItem.y = background.y + 60 + Std.int(shopItems.length / 2) * (shopItem.height + 10);
			shopItem.setIcon(s);
			shopItems.add(shopItem);
		}

		super.create();
	}
}

class ShopItem extends FlxGroup
{
	public var x(get, set):Float;
	public var y(get, set):Float;

	public var width(get, never):Float;
	public var height(get, never):Float;

	public var icon:IconSprite;

	public var background:FlxSprite;
	public var cost:FlxText;
	public var buyButton:FlxButton;

	public function new():Void
	{
		super();

		add(background = new FlxSprite());
		background.makeGraphic(136, 200, FlxColor.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, FlxColor.WHITE);

		add(icon = new IconSprite(background.x + 4, background.y + 4));

		add(cost = new FlxText(background.x + 4, icon.y + icon.height + 2, background.width - 8, "Cost: 0"));
		cost.setFormat(null, 16, FlxColor.BLACK, "center");
		cost.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 1);

		add(buyButton = new FlxButton(background.x + 4, cost.y + cost.height + 2, "Buy", onBuy));
		buyButton.makeGraphic(Std.int(background.width - 8), 32, FlxColor.BLUE);
		buyButton.label.setFormat(null, 16, FlxColor.BLACK, "center");
		buyButton.label.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 1);
	}

	public function setIcon(Icon:String):Void
	{
		icon.icon = Icon;
		cost.text = "Cost: " + Std.string(Globals.IconList.get(Icon).cost);
	}

	public function onBuy():Void {}

	public function set_x(Value:Float):Float
	{
		background.x = Value;
		icon.x = background.x + 4;
		cost.x = background.x + 4;
		buyButton.x = background.x + 4;
		return Value;
	}

	public function set_y(Value:Float):Float
	{
		background.y = Value;
		icon.y = background.y + 4;
		cost.y = icon.y + icon.height + 2;
		buyButton.y = cost.y + cost.height + 2;
		return Value;
	}

	public function get_width():Float
	{
		return background.width;
	}

	public function get_height():Float
	{
		return background.height;
	}

	public function get_x():Float
	{
		return background.x;
	}

	public function get_y():Float
	{
		return background.y;
	}
}
