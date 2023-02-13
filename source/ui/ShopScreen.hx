package ui;

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
import states.GameState.GameSubState;

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
		title.setFormat(null, 32, FlxColor.WHITE, "center");
		title.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		title.screenCenter(FlxAxes.X);
		title.y = background.y + 10;
		add(title);

		add(shopItems = new FlxTypedGroup<ShopItem>());

		var shopItem:ShopItem;
		for (s in Globals.SHOP_ITEMS)
		{
			shopItem = new ShopItem(this);
			shopItem.x = background.x + 10 + (shopItems.length % 2) * (shopItem.width + 10);
			shopItem.y = background.y + 60 + Std.int(shopItems.length / 2) * (shopItem.height + 10);
			shopItem.setIcon(s);
			shopItems.add(shopItem);
		}

		var closeButton:FlxButton = new FlxButton(background.x + background.width - 42, background.y + 8, "X", onClose);
		closeButton.makeGraphic(32, 32, FlxColor.RED);
		closeButton.label.setFormat(null, 16, FlxColor.WHITE, "center");
		closeButton.label.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		add(closeButton);

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
			shopItem.buyButton.active = Globals.PlayState.production >= Globals.IconList.get(shopItem.icon.icon).cost;
		}
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

	public var parent:ShopScreen;

	public function new(Parent:ShopScreen):Void
	{
		super();

		parent = Parent;

		add(background = new FlxSprite());
		background.makeGraphic(136, 200, FlxColor.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, FlxColor.WHITE);

		add(icon = new IconSprite(background.x + 4, background.y + 4));

		add(cost = new FlxText(background.x + 4, icon.y + icon.height + 2, background.width - 8, "Cost: 0"));
		cost.setFormat(null, 16, FlxColor.BLACK, "center");
		cost.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 1);

		add(buyButton = new FlxButton(background.x + 4, cost.y + cost.height + 2, "Buy", onBuy));
		buyButton.makeGraphic(Std.int(background.width - 8), 32, FlxColor.BLUE);
		buyButton.label.setFormat(null, 16, FlxColor.WHITE, "center");
		buyButton.label.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		buyButton.active = Globals.PlayState.production >= Globals.IconList.get(icon.icon).cost;
	}

	public function setIcon(Icon:String):Void
	{
		icon.icon = Icon;
		cost.text = "Cost: " + Std.string(Globals.IconList.get(Icon).cost);
	}

	public function onBuy():Void
	{
		// deduct cost from production

		Globals.PlayState.production -= Globals.IconList.get(icon.icon).cost;

		// add the new icon to the player's collection

		Globals.PlayState.addNewIcon(icon.icon);

		// update buttons of all shop items

		parent.updateButtons();
	}

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