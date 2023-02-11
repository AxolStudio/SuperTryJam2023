package states;

import axollib.TitleCase.Roman;
import flixel.FlxG;
import flixel.FlxSprite;
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
import ui.ShopScreen;

using StringTools;

class PlayState extends GameState
{
	public static inline var GRID_SIZE:Float = 648;
	public static inline var GRID_MID:Float = 324;
	public static inline var GRID_SPACING:Float = 2;

	public var collection:Array<GridIcon> = [];
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
	public var iconsToDelete:Array<Int> = [];

	public var wounds:Array<FlxSprite> = [];

	public var currentMode:String = "setting-up";

	public var whosAdding:Array<String> = [];

	public var txtPopulation:FlxText;

	public var checkingIcon:Int = -1;

	public var shopButton:FlxButton;

	override public function create()
	{
		initializeGame();

		super.create();
	}

	public function initializeGame()
	{
		bgColor = FlxColor.WHITE;

		for (b in 0...Globals.BLANKS_PER_AGE)
		{
			collection.push(new GridIcon("blank"));
		}

		for (n => v in Globals.STARTING_ICONS)
		{
			for (i in 0...v)
			{
				addNewIcon(n);
			}
		}

		var wound:FlxSprite;
		for (i in 0...25)
		{
			wound = new FlxSprite((FlxG.width / 2)
				- GRID_MID
				+ Std.int(i / 5) * 128
				+ (Std.int(i / 5) * GRID_SPACING),
				(FlxG.height / 2)
				- GRID_MID
				+ Std.int(i % 5) * 128
				+ (Std.int(i % 5) * GRID_SPACING), "assets/images/wound.png");
			wound.kill();
			wounds.push(wound);
			add(wound);
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

		add(shopButton = new FlxButton(spinButton.x - 210, spinButton.y, "Shop", openShop));
		shopButton.makeGraphic(200, 50, FlxColor.GREEN);
		shopButton.label.setFormat(null, 32, FlxColor.WHITE, "center");
		shopButton.label.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		shopButton.active = false;

		age = 1;
		add(txtAge = new FlxText(0, 10, 0, "Age " + Roman.arabic2Roman(age)));
		txtAge.setFormat(null, 32, FlxColor.BLACK, "center");
		txtAge.screenCenter(FlxAxes.X);

		add(foodBar = new CurrencyDisplay(10, 10, "Food", 25));
		add(productionBar = new CurrencyDisplay(10, 50, "Production", 25));
		add(scienceBar = new CurrencyDisplay(10, 90, "Science", 50));

		add(txtPopulation = new FlxText(FlxG.width - 200, 10, 0, "Population: 0"));
		txtPopulation.setFormat(null, 18, FlxColor.BLACK, "right");

		food = 10;

		updatePopText();

		currentMode = "waiting-for-spin";

		shopButton.active = spinButton.active = canSpin = true;
	}

	public function openShop():Void
	{
		openSubState(new ShopScreen());
	}

	public function updatePopText()
	{
		txtPopulation.text = "Population: " + Std.string(getIconsOfType(-1, "human").length);
	}

	public function spin():Void
	{
		if (!spinButton.active || !canSpin)
			return;
		currentMode = "spinning";
		shopButton.active = spinButton.active = canSpin = false;
		// some kind of animation!

		willWound = [];
		preventedWound = [];
		iconsToKill = [];
		whosAdding = [];
		iconsToAdd = [];
		iconsToDelete = [];

		for (i in 0...25)
		{
			wounds[i].kill();
		}

		if (age == 1)
		{
			addRandomAnimal();
			addRandomResources();
		}

		FlxG.random.shuffle(collection);

		currentMode = "did-spin";
	}

	public function addRandomResources():Void
	{
		var saplings:Int = FlxMath.maxInt(0, FlxG.random.int(-10, 2));
		// var berries:Int = FlxMath.maxInt(0, FlxG.random.int(-1, 2));
		var boulders:Int = FlxMath.maxInt(0, FlxG.random.int(-10, 2));

		for (i in 0...saplings)
			addNewIcon("sapling");
		// for (i in 0...berries)
		// 	addNewIcon("berry bush");
		for (i in 0...boulders)
			addNewIcon("boulder");
	}

	public function addRandomAnimal():Void
	{
		var newAnimal:String = Globals.WILD_ANIMALS[FlxG.random.weightedPick(Globals.WILD_ANIMAL_WEIGHTS)];
		trace("Adding " + newAnimal + " to the collection.");
		addNewIcon(newAnimal);
	}

	public function addNewIcon(Value:String):Void
	{
		if (collectionContains("blank"))
			collectionRemoveFirst("blank");
		collection.push(new GridIcon(Value));
	}

	public function collectionContains(Name:String):Bool
	{
		for (i in 0...collection.length)
		{
			if (collection[i].name == Name)
				return true;
		}
		return false;
	}

	public function collectionRemoveFirst(Name:String):Void
	{
		for (i in 0...collection.length)
		{
			if (collection[i].name == Name)
			{
				collection.splice(i, 1);
				return;
			}
		}
	}

	private function checkEffects():Void
	{
		// perform each icon's effect

		var icon:Icon = Globals.IconList.get(collection[checkingIcon].name);
		if (icon.effect != null)
		{
			for (e in icon.effect)
			{
				parseEffect(checkingIcon, e);
			}
		}

		checkingIcon++;
	}

	public function finishChecking():Void
	{
		checkingIcon = -1;

		// wound icons unless they are protected
		trace(willWound);
		for (i in willWound)
		{
			if (!preventedWound.contains(i))
			{
				if (collection[i].wounded)
					iconsToKill.push(i);
				else
					collection[i].wounded = true;
			}
		}
		// add any double-wounded to 		iconsToKill
		// kill off iconsToKill

		for (i in 0...25)
		{
			screenIcons[i].icon = collection[i].name;

			if (collection[i].wounded)
				wounds[i].revive();
		}

		var toKill:Array<Int> = [];
		var toRemove:Array<Int> = [];
		trace("iconsToKill", iconsToKill);
		while (iconsToKill.length > 0)
		{
			toKill = [];
			for (i in iconsToKill)
			{
				if (!toKill.contains(i) && !toRemove.contains(i))
					toKill.push(i);
			}
			iconsToKill = [];
			for (i in toKill)
			{
				killIcon(i);
				toRemove.push(i);
			}
		}

		var starved:Int = 0;
		for (h in 0...collection.length)
		{
			if (collection[h].name == "child" && !toRemove.contains(h))
			{
				// feed this human or kill it!
				if (food > 0)
				{
					food--;
				}
				else
				{
					toRemove.push(h);
					starved++;
				}
			}
			if (collection[h].name == "human" && !toRemove.contains(h))
			{
				// feed this human or kill it!
				if (food > 0)
				{
					food--;
				}
				else
				{
					toRemove.push(h);
					starved++;
				}
			}
		}
		trace(starved + " humans starved to death.");

		for (i in iconsToDelete)
		{
			toRemove.push(i);
		}

		var tmpCollection:Array<GridIcon> = [];
		trace("toRemove", toRemove);
		for (i in 0...collection.length)
		{
			if (!toRemove.contains(i))
				tmpCollection.push(collection[i]);
		}

		collection = tmpCollection.copy();

		trace("iconsToAdd", iconsToAdd);
		for (i in iconsToAdd)
		{
			addNewIcon(i);
		}

		for (i in collection.length...25)
		{
			collection.push(new GridIcon("blank"));
		}

		var collTmp:String = "";
		for (i in 0...collection.length)
			collTmp += collection[i].name + ",";
		trace("collection", collTmp);

		updatePopText();

		currentMode = "waiting-for-spin";
		shopButton.active = spinButton.active = canSpin = true;
	}

	public function parseEffect(IconPos:Int, Effect:String):Void
	{
		var split:Array<String> = Effect.split("?");
		checkEffect(IconPos, split[0], split[1]);
	}

	public function doEffect(IconPos:Int, Effect:String, ?Source:Int = -1):Void
	{
		var split:Array<String> = Effect.split(":");
		switch (split[0])
		{
			case "delete": // remove icon without it's death effect
				iconsToDelete.push(Source);
				trace("delete: " + IconPos + " : " + collection[IconPos].name + " = " + collection[Source].name);
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

					trace("create: " + IconPos + " : " + collection[IconPos].name + " = " + type);
				}
			case "replace": // replace this icon with another
				replaceIcon(IconPos, split[1]);
				trace("replace: " + IconPos + " : " + collection[IconPos].name + " = " + split[1]);
			case "gen": // generate a resource
				var details:Array<String> = split[1].split("$");
				switch (details[1])
				{
					case "food": food += Std.parseFloat(details[0]);
					case "prod": production += Std.parseFloat(details[0]);
					case "sci": science += Std.parseFloat(details[0]);
				}
				trace("gen: " + IconPos + " : " + collection[IconPos].name + " = " + split[1]);
				trace("food: " + food + " prod: " + production + " sci: " + science);
			case "die": // remove this icon from the collection
				iconsToKill.push(IconPos);
				trace("die: " + IconPos + " : " + collection[IconPos].name);
			case "wound": // wound all humans touching this tile - UNLESS it is prevented from doing so...

				willWound.push(Source);
				trace("wound: " + IconPos + " : " + collection[IconPos].name + " = " + Source + " / " + willWound);

			case "protect":
				var types:Array<String> = split[1].split("/");
				for (t in types)
				{
					var neighbors:Array<Int> = getNeighborsOfType(IconPos, t);
					preventedWound = preventedWound.concat(neighbors);

					trace("protect: " + IconPos + " : " + collection[IconPos].name + " = " + neighbors);
				}

			case "kill": // kill the types touching this icon
				var types:Array<String> = split[1].split("/");
				for (t in types)
				{
					var neighbors:Array<Int> = getNeighborsOfType(IconPos, t);
					iconsToKill = iconsToKill.concat(neighbors);
					trace("kill: " + IconPos + " : " + collection[IconPos].name + " = " + neighbors);
				}
			case "change": // change touching tile to another tile
				var types:Array<String> = split[1].split("/");
				for (t in types)
				{
					var neighbors:Array<Int> = getNeighborsOfType(IconPos, t);
					for (n in neighbors)
					{
						replaceIcon(n, split[2]);
						trace("change: " + IconPos + " : " + collection[IconPos].name + " : " + collection[n].name + " = " + split[2]);
					}
				}
			case "snipe": // find a random tile of type on the board, kill it
				var types:Array<String> = split[1].split("/");
				var icons:Array<Int> = [];
				for (t in types)
				{
					icons = icons.concat(getIconsOfType(IconPos, t));
				}
				iconsToKill.push(icons[FlxG.random.int(0, icons.length - 1)]);
				trace("snipe: " + IconPos + " : " + collection[IconPos].name + " = " + icons);
		}
	}

	public function getIconsOfType(IconPos:Int, Type:String):Array<Int>
	{
		var icons:Array<Int> = [];
		for (i in 0...25)
		{
			if (collection[i].name == Type && i != IconPos)
				icons.push(i);
		}
		return icons;
	}

	public function getNeighborsOfType(IconPos:Int, Type:String):Array<Int>
	{
		var neighbors:Array<Int> = [];

		var l:Int = IconPos >= 5 ? IconPos - 5 : -1;
		var r:Int = IconPos < 20 ? IconPos + 5 : -1;

		var u:Int = IconPos % 5 != 0 ? IconPos - 1 : -1;
		var d:Int = IconPos % 5 != 4 ? IconPos + 1 : -1;

		var ul:Int = l >= 0 && u >= 0 ? l - 1 : -1;
		var ur:Int = r >= 0 && u >= 0 ? r - 1 : -1;

		var dl:Int = l >= 0 && d >= 0 ? l + 1 : -1;
		var dr:Int = r >= 0 && d >= 0 ? r + 1 : -1;

		if (l > -1 && collection[l].name == Type)
			neighbors.push(l);

		if (r > -1 && collection[r].name == Type)
			neighbors.push(r);

		if (u > -1 && collection[u].name == Type)
			neighbors.push(u);

		if (d > -1 && collection[d].name == Type)
			neighbors.push(d);

		if (ul > -1 && collection[ul].name == Type)
			neighbors.push(ul);

		if (ur > -1 && collection[ur].name == Type)
			neighbors.push(ur);

		if (dl > -1 && collection[dl].name == Type)
			neighbors.push(dl);

		if (dr > -1 && collection[dr].name == Type)
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
					doEffect(IconPos, DoEffect, n);
				}
			case "pair": // a pair of tiles of this type are touching
				var splitA:Array<String> = Effect.split(":");
				var match:String = splitA[1];
				var split:Array<String> = DoEffect.split(":");
				var type:String = split[1];

				for (n in getNeighborsOfType(IconPos, match))
				{
					// if (!whosAdding.contains('$IconPos:$type') && !whosAdding.contains('$n:$type'))
					// {
					// whosAdding.push('$IconPos:$type');
					whosAdding.push('$n:$type');
					doEffect(IconPos, DoEffect, n);
					// }
				}
			case "chance": // a percentage of happening
				if (FlxG.random.bool(Std.parseFloat(value)))
					doEffect(IconPos, DoEffect);
			case "timer": // count down to 0 and then do the effect...
				var split:Array<String> = Effect.split(":");
				var time:Int = Std.parseInt(split[1]);
				if (collection[IconPos].timer == 0)
				{
					doEffect(IconPos, DoEffect);
				}
				else if (collection[IconPos].timer > 0)
				{
					collection[IconPos].timer--;
				}
				else
				{
					collection[IconPos].timer = time;
				}

			case "after": // after this spin, do this effect
				doEffect(IconPos, DoEffect);

			case "touch": // is touching a tile of a speficic type
				var types:Array<String> = value.split("/");

				for (t in types)
				{
					for (n in getNeighborsOfType(IconPos, t))
					{
						doEffect(IconPos, DoEffect, n);
					}
				}
		}
	}

	public function killIcon(IconPos:Int):Void
	{
		var def:Icon = Globals.IconList.get(collection[IconPos].name);
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

		var l:Int = IconPos >= 5 ? IconPos - 5 : -1;
		var r:Int = IconPos < 20 ? IconPos + 5 : -1;

		var u:Int = IconPos % 5 != 0 ? IconPos - 1 : -1;
		var d:Int = IconPos % 5 != 4 ? IconPos + 1 : -1;

		var ul:Int = l >= 0 && u >= 0 ? l - 1 : -1;
		var ur:Int = r >= 0 && u >= 0 ? r - 1 : -1;

		var dl:Int = l >= 0 && d >= 0 ? l + 1 : -1;
		var dr:Int = r >= 0 && d >= 0 ? r + 1 : -1;

		if (l > -1 && collection[l].name == Value)
			return true;

		if (r > -1 && collection[r].name == Value)
			return true;

		if (u > -1 && collection[u].name == Value)
			return true;

		if (d > -1 && collection[d].name == Value)
			return true;

		if (ul > -1 && collection[ul].name == Value)
			return true;

		if (ur > -1 && collection[ur].name == Value)
			return true;

		if (dl > -1 && collection[dl].name == Value)
			return true;

		if (dr > -1 && collection[dr].name == Value)
			return true;

		return false;
	}

	override public function update(elapsed:Float)
	{
		switch (currentMode)
		{
			case "did-spin":
				draw();
				checkingIcon = 0;
				currentMode = "checking";

			case "checking":
				checkEffects();
				if (checkingIcon >= 25)
					finishChecking();
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
