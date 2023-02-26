package ui;

import haxe.ui.containers.Box;
import haxe.ui.containers.HBox;
import haxe.ui.containers.ScrollView;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxAxes;
import gameObjects.IconSprite;
import globals.Globals;
import states.GameState.GameSubState;

using StringTools;
using axollib.TitleCase;
using flixel.util.FlxSpriteUtil;

class InventoryScreen extends GameSubState
{
	public var scrollZone:ScrollView;
	public var scrollGrid:HBox;

	public function new()
	{
		super();
	}

	override public function create():Void
	{
		bgColor = Colors.TRANSPARENT;

		var background:FlxSprite = new FlxSprite();
		background.makeGraphic(Math.floor(FlxG.width * .6), Math.floor(FlxG.height * .9), Colors.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, Colors.WHITE);
		background.screenCenter();
		add(background);

		var title:GameText = new GameText(0, 0, 500, "Inventory", Colors.BLACK, SIZE_36);
		title.alignment = "center";
		title.screenCenter(FlxAxes.X);
		title.y = background.y + 10;
		add(title);

		scrollZone = new ScrollView();
		scrollZone.width = background.width - 24;
		scrollZone.height = background.height - title.height - 30;
		scrollZone.x = background.x + 12;
		scrollZone.y = title.y + title.height + 10;
		scrollZone.percentContentWidth = 100;

		add(scrollZone);

		scrollGrid = new HBox();
		scrollGrid.width = scrollZone.width;
		scrollGrid.padding = 10;
		scrollGrid.styleString = "spacing:10px;";
		scrollGrid.continuous = true;

		scrollZone.addComponent(scrollGrid);

		var invMap:Map<String, Int> = [];

		var str:String = "";
		for (c in Globals.PlayState.collection)
		{
			str = c.name + ":" + (c.wounded ? "y" : "n") + ":" + c.timer;
			if (invMap.exists(str))
			{
				invMap.set(str, invMap.get(str) + 1);
			}
			else
			{
				invMap.set(str, 1);
			}
		}

		var keys:Array<String> = [for (key in invMap.keys()) key];
		keys.sort((a, b) ->
		{
			if (a < b || a.startsWith("blank:"))
				return -1;
			else if (a > b || b.startsWith("blank:"))
				return 1;
			else
				return 0;
		});

		var item:InventoryItem;
		var count:Int;
		var parts:Array<String>;
		var box:Box;
		for (k in keys)
		{
			count = invMap.get(k);
			parts = k.split(":");
			item = new InventoryItem(parts[0], count, parts[1] == "y", Std.parseInt(parts[2]));

			box = new Box();
			box.width = item.width;
			box.height = item.height;
			box.add(item);
			scrollGrid.addComponent(box);
		}

		var closeButton:GameButton = new GameButton(background.x + background.width - 42, background.y + 8, "X", onClose, 32, 32, SIZE_36, Colors.RED,
			Colors.BLACK, Colors.WHITE, Colors.BLACK);
		add(closeButton);

		super.create();
	}

	public function onClose():Void
	{
		close();
	}
}

class InventoryItem extends FlxSpriteGroup
{
	// each inventory item consists of the inventory icon,
	// a timer-display on top (if it has a timer), wound icon
	// beneath (if it is wounded), and a text showing how many of
	// this object there are in the array "(3)"
	public var icon:IconSprite;
	public var timer:GameText;
	public var wound:FlxSprite;
	public var count:GameText;

	public function new(Icon:String, Count:Int = 1, Wounded:Bool = false, Timer:Int = -1):Void
	{
		super();

		if (Wounded)
		{
			add(wound = new FlxSprite(0, 0));
			wound.loadGraphic("assets/images/wound.png");
		}

		add(icon = new IconSprite(0, 0, SIZE_64));
		icon.icon = Icon;

		if (Timer > 0)
		{
			add(timer = new GameText(0, 0, 118, Std.string(Timer), Colors.WHITE, SIZE_36));
			timer.setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 1);
			timer.alignment = "left";
			timer.x = icon.x + 10;
			timer.y = icon.y + icon.height - timer.height;
		}

		add(count = new GameText(0, 0, 60, '(${Count})', Colors.GRAY, SIZE_36));
		count.setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 1);
		count.alignment = "left";
		count.x = icon.x + icon.width + 2;
		count.y = icon.y + icon.height - count.height;
	}
}
