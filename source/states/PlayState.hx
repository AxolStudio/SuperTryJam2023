package states;

import axollib.TitleCase.Roman;
import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import gameObjects.Icon;
import gameObjects.IconSprite;
import globals.Globals;
import ui.CurrencyDisplay;

using StringTools;

class PlayState extends FlxState
{
	public static inline var GRID_SIZE:Float = 648;
	public static inline var GRID_MID:Float = 324;
	public static inline var GRID_SPACING:Float = 2;

	public var collection:Array<String> = [];
	public var screenIcons:Array<IconSprite> = [];

	public var spinButton:FlxButton;

	public var canSpin:Bool = false;

	public var age:Int = 0;

	public var txtAge:FlxText;

	public var foodBar:CurrencyDisplay;
	public var productionBar:CurrencyDisplay;
	public var scienceBar:CurrencyDisplay;

	public var food(default, set):Float = 0;
	public var production(default, set):Float = 0;
	public var science(default, set):Float = 0;

	public var willWound:Array<Int> = [];
	public var preventedWound:Array<Int> = [];
	public var iconsToKill:Array<Int> = [];
	public var iconsToAdd:Array<String> = [];

	public var currentMode:String = "setting-up";

	public var whosAdding:Array<String> = [];

	override public function create()
	{
		initializeGame();

		super.create();
	}

	public function initializeGame()
	{
		bgColor = FlxColor.WHITE;

		var iconData:Dynamic = Globals.IconList.get("blank");

		for (b in 0...Globals.BLANKS_PER_AGE)
		{
			collection.push("blank");
		}

		for (n => v in Globals.STARTING_ICONS)
		{
			for (i in 0...v)
			{
				addNewIcon(n);
			}
		}

		var icon:IconSprite;
		for (i in 0...25)
		{
			icon = new IconSprite((FlxG.width / 2)
				- GRID_MID
				+ Std.int(i / 5) * 128
				+ (Std.int(i / 5) * GRID_SPACING),
				(FlxG.height / 2)
				- GRID_MID
				+ Std.int(i % 5) * 128
				+ (Std.int(i % 5) * GRID_SPACING));
			screenIcons.push(icon);
			add(icon);
		}

		add(spinButton = new FlxButton((FlxG.width / 2) - 100, (FlxG.height / 2) + GRID_MID + 50, "Spin!", spin));
		spinButton.makeGraphic(200, 50, FlxColor.BLUE);
		spinButton.label.setFormat(null, 32, FlxColor.WHITE, "center");
		spinButton.label.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		spinButton.active = false;

		age = 1;
		add(txtAge = new FlxText(0, 10, 0, "Age " + Roman.arabic2Roman(age)));
		txtAge.setFormat(null, 32, FlxColor.BLACK, "center");
		txtAge.screenCenter(FlxAxes.X);

		add(foodBar = new CurrencyDisplay(10, 10, "Food", 10));
		add(productionBar = new CurrencyDisplay(10, 50, "Production", 25));
		add(scienceBar = new CurrencyDisplay(10, 90, "Science", 50));

		currentMode = "waiting-for-spin";

		spinButton.active = canSpin = true;
	}

	public function spin():Void
	{
		if (!spinButton.active || !canSpin)
			return;
		currentMode = "spinning";
		spinButton.active = canSpin = false;
		// some kind of animation!

		FlxG.random.shuffle(collection);
		for (i in 0...25)
		{
			screenIcons[i].icon = collection[i];
		}

		trace(collection);

		currentMode = "did-spin";
	}

	public function addNewIcon(Value:String):Void
	{
		if (collection.contains("blank"))
			collection.remove("blank");
		collection.push(Value);
	}

	private function checkEffects():Void
	{
		// perform each icon's effect

		willWound = [];
		preventedWound = [];
		iconsToKill = [];
		whosAdding = [];

		for (i in 0...25)
		{
			var icon:Icon = Icon.fromData(Globals.IconList.get(collection[i]));
			if (icon.effect != null)
			{
				for (e in icon.effect)
				{
					parseEffect(i, e);
				}
			}
		}

		// wound icons unless they are protected
		for (i in 0...willWound.length)
		{
			if (!preventedWound.contains(willWound[i]))
			{
				iconsToKill.push(willWound[i]);
			}
		}
		// add any double-wounded to 		iconsToKill // this might need to be removed
		// kill off iconsToKill

		// remove any duplicates in iconsToKill
		var toRemove:Array<Int> = [];
		while (iconsToKill.length > 0)
		{
			var tmpIconsToKill:Array<Int> = [];

			tmpIconsToKill = iconsToKill.filter((value) -> iconsToKill.indexOf(value) == iconsToKill.lastIndexOf(value));
			iconsToKill = [];

			for (i in 0...tmpIconsToKill.length)
			{
				killIcon(tmpIconsToKill[i]);
				toRemove.push(i);
			}
		}

		var newCollection:Array<String> = [for (i in 0...collection.length) if (!iconsToKill.contains(i)) collection[i]];
		collection = newCollection.copy();

		for (i in iconsToAdd)
		{
			addNewIcon(i);
		}

		for (i in collection.length...25)
		{
			collection.push("blank");
		}

		currentMode = "waiting-for-spin";
		spinButton.active = canSpin = true;
	}

	public function parseEffect(IconPos:Int, Effect:String):Void
	{
		var split:Array<String> = Effect.split("?");
		checkEffect(IconPos, split[0], split[1]);
	}

	public function doEffect(IconPos:Int, Effect:String):Void
	{
		var split:Array<String> = Effect.split(":");
		switch (split[0])
		{
			case "pair": // for each 2 of the same icons, create a new icon
				var type:String = collection[IconPos];
				var neighbors:Array<Int> = getNeighborsOfType(IconPos, type);
				var newType:String = split[1];
				for (n in neighbors)
				{
					if (whosAdding.contains('$IconPos:$n:$type') || whosAdding.contains('$n:$IconPos:$type'))
						continue;
					whosAdding.push('$IconPos:$n:$type');
					iconsToAdd.push(newType);

					trace("pair: " + IconPos + " : " + collection[IconPos] + " + " + collection[n] + " = " + newType);
				}

			case "create": // create a new icon

				var type:String = split[1];
				if (whosAdding.contains('$IconPos:$type'))
					return;
				var count:Int = 1;
				if (split[1].contains("*"))
				{
					var split2:Array<String> = split[1].split("*");
					type = split2[0];

					if (split2[1].contains("-"))
					{
						var minMax:Array<String> = split2[1].split("-");
						count = FlxG.random.int(Std.parseInt(minMax[0]), Std.parseInt(minMax[1]));
					}
					else
					{
						count = Std.parseInt(split2[1]);
					}
				}
				for (i in 0...count)
				{
					iconsToAdd.push(type);
					whosAdding.push('$IconPos:$type');

					trace("create: " + IconPos + " : " + collection[IconPos] + " = " + type);
				}
			case "replace": // replace this icon with another
				replaceIcon(IconPos, split[1]);
				trace("replace: " + IconPos + " : " + collection[IconPos] + " = " + split[1]);
			case "gen": // generate a resource
				var details:Array<String> = split[1].split("$");
				switch (details[1])
				{
					case "food": food += Std.parseFloat(details[0]);
					case "prod": production += Std.parseFloat(details[0]);
					case "sci": science += Std.parseFloat(details[0]);
				}
				trace("gen: " + IconPos + " : " + collection[IconPos] + " = " + split[1]);
			case "die": // remove this icon from the collection
				iconsToKill.push(IconPos);
				trace("die: " + IconPos + " : " + collection[IconPos]);
			case "wound": // wound all humans touching this tile - UNLESS it is prevented from doing so...
				var neighbors:Array<Int> = getNeighborsOfType(IconPos, "human");

				willWound.concat(neighbors); // we will actually do the wounding later
				trace("wound: " + IconPos + " : " + collection[IconPos] + " = " + neighbors);

			case "protect":
				var types:Array<String> = split[1].split("/");
				for (t in types)
				{
					var neighbors:Array<Int> = getNeighborsOfType(IconPos, t);
					preventedWound.concat(neighbors);

					trace("protect: " + IconPos + " : " + collection[IconPos] + " = " + neighbors);
				}

			case "kill": // kill the types touching this icon
				var types:Array<String> = split[1].split("/");
				for (t in types)
				{
					var neighbors:Array<Int> = getNeighborsOfType(IconPos, t);
					iconsToKill.concat(neighbors);
					trace("kill: " + IconPos + " : " + collection[IconPos] + " = " + neighbors);
				}
			case "change": // change touching tile to another tile
				var types:Array<String> = split[1].split("/");
				for (t in types)
				{
					var neighbors:Array<Int> = getNeighborsOfType(IconPos, t);
					for (n in neighbors)
					{
						replaceIcon(n, split[2]);
						trace("change: " + IconPos + " : " + collection[IconPos] + " : " + collection[n] + " = " + split[2]);
					}
				}
			case "snipe": // find a random tile of type on the board, kill it
				var types:Array<String> = split[1].split("/");
				var icons:Array<Int> = [];
				for (t in types)
				{
					icons.concat(getIconsOfType(IconPos, t));
				}
				iconsToKill.push(icons[FlxG.random.int(0, icons.length - 1)]);
				trace("snipe: " + IconPos + " : " + collection[IconPos] + " = " + icons);
		}
	}

	public function getIconsOfType(IconPos:Int, Type:String):Array<Int>
	{
		var icons:Array<Int> = [];
		for (i in 0...25)
		{
			if (collection[i] == Type && i != IconPos)
				icons.push(i);
		}
		return icons;
	}

	public function getNeighborsOfType(IconPos:Int, Type:String):Array<Int>
	{
		var neighbors:Array<Int> = [];

		var x:Int = IconPos % 5;
		var y:Int = Std.int(IconPos / 5);

		var l:Int = x - 1;
		var r:Int = x + 1;
		var u:Int = y - 1;
		var d:Int = y + 1;
		var ul:Int = u * 5 + l;
		var ur:Int = u * 5 + r;
		var dl:Int = d * 5 + l;
		var dr:Int = d * 5 + r;

		var x:Int = IconPos % 5;
		var y:Int = Std.int(IconPos / 5);

		var l:Int = x - 1;
		var r:Int = x + 1;
		var u:Int = y - 1;
		var d:Int = y + 1;
		var ul:Int = u * 5 + l;
		var ur:Int = u * 5 + r;
		var dl:Int = d * 5 + l;
		var dr:Int = d * 5 + r;

		if (l >= 0 && collection[l] == Type)
			neighbors.push(l);

		if (r < 5 && collection[r] == Type)
			neighbors.push(r);

		if (u >= 0 && collection[u] == Type)
			neighbors.push(u);

		if (d < 5 && collection[d] == Type)
			neighbors.push(d);

		if (l >= 0 && u >= 0 && collection[ul] == Type)
			neighbors.push(ul);

		if (r < 5 && u >= 0 && collection[ur] == Type)
			neighbors.push(ur);

		if (l >= 0 && d < 5 && collection[dl] == Type)
			neighbors.push(dl);

		if (r < 5 && d < 5 && collection[dr] == Type)
			neighbors.push(dr);

		return neighbors;
	}

	public function replaceIcon(IconPos:Int, NewIcon:String):Void
	{
		iconsToKill.push(IconPos);
		iconsToAdd.push(NewIcon);
	}

	public function checkEffect(IconPos:Int, Effect:String, DoEffect:String):Void
	{
		var check:Bool = false;
		var keyWord:String = "";
		var value:String = "";

		if (Effect.contains(":"))
		{
			var split:Array<String> = Effect.split(":");
			keyWord = split[0];
			value = split[1];
		}
		else
		{
			keyWord = Effect;
		}

		switch (keyWord)
		{
			case "work": // a human is touching this tile
				for (n in getNeighborsOfType(IconPos, "human"))
				{
					doEffect(IconPos, DoEffect);
				}

			case "chance": // a percentage of happening
				if (FlxG.random.bool(Std.parseFloat(value)))
					doEffect(IconPos, DoEffect);
			case "timer": // count down to 0 and then do the effect...

			case "after": // after this spin, do this effect
				doEffect(IconPos, DoEffect);

			case "touch": // is touching a tile of a speficic type
				var types:Array<String> = value.split("/");
				for (t in types)
				{
					if (hasNeighborType(IconPos, t))
					{
						check = true;
						break;
					}
				}
				if (check)
					doEffect(IconPos, DoEffect);
		}
	}

	public function killIcon(IconPos:Int):Void
	{
		var def:Icon = Icon.fromData(Globals.IconList.get(collection[IconPos]));
		if (def.death != null)
		{
			for (e in def.death)
			{
				doEffect(IconPos, e);
			}
		}
	}

	public function hasNeighborType(IconPos:Int, Value:String):Bool
	{
		// look at the neighbors of this icon and return true if any of them are Value

		var x:Int = IconPos % 5;
		var y:Int = Std.int(IconPos / 5);

		var l:Int = x - 1;
		var r:Int = x + 1;
		var u:Int = y - 1;
		var d:Int = y + 1;
		var ul:Int = u * 5 + l;
		var ur:Int = u * 5 + r;
		var dl:Int = d * 5 + l;
		var dr:Int = d * 5 + r;

		if (l >= 0 && collection[l] == Value)
			return true;

		if (r < 5 && collection[r] == Value)
			return true;

		if (u >= 0 && collection[u] == Value)
			return true;

		if (d < 5 && collection[d] == Value)
			return true;

		if (l >= 0 && u >= 0 && collection[ul] == Value)
			return true;

		if (r < 5 && u >= 0 && collection[ur] == Value)
			return true;

		if (l >= 0 && d < 5 && collection[dl] == Value)
			return true;

		if (r < 5 && d < 5 && collection[dr] == Value)
			return true;

		return false;
	}

	override public function update(elapsed:Float)
	{
		switch (currentMode)
		{
			case "did-spin":
				draw();
				checkEffects();
		}

		super.update(elapsed);
	}

	private function set_food(Value:Float):Float
	{
		food = Value;
		foodBar.value = Value;
		return food;
	}

	private function set_production(Value:Float):Float
	{
		production = Value;
		productionBar.value = Value;
		return production;
	}

	private function set_science(Value:Float):Float
	{
		science = Value;
		scienceBar.value = Value;
		return science;
	}
}
