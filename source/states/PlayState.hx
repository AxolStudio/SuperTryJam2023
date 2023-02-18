package states;

import axollib.TitleCase.Roman;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Icon;
import gameObjects.IconSprite;
import globals.Globals;
import ui.AddedIcon;
import ui.CurrencyDisplay;
import ui.GameButton;
import ui.GameText;
import ui.ResGenText;
import ui.ShopScreen;
import ui.TechDisplay;
import ui.UpgradeScreen;

using StringTools;

class PlayState extends GameState
{
	public static inline var GRID_SIZE:Float = 648;
	public static inline var GRID_MID:Float = 324;
	public static inline var GRID_SPACING:Float = 2;

	public var collection:Array<GridIcon> = [];
	public var screenIcons:Array<IconSprite> = [];

	public var spinButton:GameButton;

	public var canSpin:Bool = false;

	public var age:Int = 0;

	public var txtAge:GameText;

	public var txtFood:GameText;
	public var txtProduction:GameText;
	public var txtScience:GameText;

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

	public var txtPopulation:GameText;

	public var checkingIcon:Int = -1;

	public var shopButton:GameButton;
	public var upgradeButton:GameButton;

	public var technologies:Map<Int, Array<String>> = [1 => []];

	public var techDisp:TechDisplay;
	public var techLabel:GameText;

	public var resourceLabel:GameText;

	public var timer:Float = -1;

	public var toKill:Array<Int> = [];
	public var toRemove:Array<Int> = [];

	public var starved:Int = 0;

	public var resGenTexts:FlxTypedGroup<ResGenText>;

	public var fakeIcons:FlxTypedGroup<FakeIcon>;
	public var addedIcons:FlxTypedGroup<AddedIcon>;

	public var shields:Array<FlxSprite>;
	public var crosshairs:Array<FlxSprite>;

	override public function create()
	{
		initializeGame();

		super.create();
	}

	public function initializeGame()
	{
		bgColor = FlxColor.WHITE;

		Globals.PlayState = this;
		Globals.initGame();

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

		shields = new Array<FlxSprite>();

		crosshairs = new Array<FlxSprite>();

		var shield:FlxSprite;

		var crosshair:FlxSprite;
		for (i in 0...25)
		{
			shield = new FlxSprite((FlxG.width / 2)
				- GRID_MID
				+ Std.int(i / 5) * 128
				+ (Std.int(i / 5) * GRID_SPACING),
				(FlxG.height / 2)
				- GRID_MID
				+ Std.int(i % 5) * 128
				+ (Std.int(i % 5) * GRID_SPACING), "assets/images/shield.png");
			shield.kill();
			shields.push(shield);
			add(shield);

			crosshair = new FlxSprite((FlxG.width / 2)
				- GRID_MID
				+ Std.int(i / 5) * 128
				+ (Std.int(i / 5) * GRID_SPACING),
				(FlxG.height / 2)
				- GRID_MID
				+ Std.int(i % 5) * 128
				+ (Std.int(i % 5) * GRID_SPACING), "assets/images/crosshair.png");
			crosshair.kill();
			crosshairs.push(crosshair);
			add(crosshair);
		}

		add(fakeIcons = new FlxTypedGroup<FakeIcon>());

		add(addedIcons = new FlxTypedGroup<AddedIcon>());

		add(spinButton = new GameButton((FlxG.width / 2) - 125, (FlxG.height / 2) + GRID_MID + 50, "Spin!", spin, 250, 50, SIZE_36, FlxColor.BLUE,
			FlxColor.BLACK, FlxColor.WHITE, FlxColor.BLACK));
		spinButton.active = false;

		add(shopButton = new GameButton(spinButton.x - 260, spinButton.y, "Shop", openShop, 250, 50, SIZE_36, FlxColor.GREEN, FlxColor.BLACK, FlxColor.WHITE,
			FlxColor.BLACK));
		shopButton.active = false;

		add(upgradeButton = new GameButton(spinButton.x + 260, spinButton.y, "Technologies", openUpgrade, 250, 50, SIZE_36, FlxColor.PURPLE, FlxColor.BLACK,
			FlxColor.WHITE, FlxColor.BLACK));
		upgradeButton.active = false;

		age = 1;

		add(txtAge = new GameText(0, 10, 100, "Age " + Roman.arabic2Roman(age), FlxColor.BLACK, SIZE_36));
		txtAge.alignment = "center";
		txtAge.screenCenter(FlxAxes.X);

		add(resourceLabel = new GameText(10, 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "Resources", FlxColor.BLACK, SIZE_36));
		resourceLabel.alignment = "center";

		add(txtPopulation = new GameText(10, resourceLabel.y + resourceLabel.height + 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "{{population}} 0",
			FlxColor.BLACK, SIZE_36));
		add(txtFood = new GameText(10, txtPopulation.y + txtPopulation.height + 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "{{food}} 0", FlxColor.BLACK,
			SIZE_36));
		add(txtProduction = new GameText(10, txtFood.y + txtFood.height + 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "{{production}} 0", FlxColor.BLACK,
			SIZE_36));
		add(txtScience = new GameText(10, txtProduction.y + txtProduction.height + 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "{{science}} 0",
			FlxColor.BLACK, SIZE_36));

		add(techLabel = new GameText(0, 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "Technologies Learned", FlxColor.BLACK, SIZE_36));
		techLabel.alignment = "center";
		techLabel.x = FlxG.width - techLabel.width - 10;

		techDisp = new TechDisplay((FlxG.width / 2) - GRID_MID - 20, FlxG.height - 120 - techLabel.height);
		techDisp.x = FlxG.width - techDisp.width - 10;
		techDisp.y = techLabel.y + techLabel.height + 10;
		add(techDisp);

		food = 10;

		updatePopText();

		add(resGenTexts = new FlxTypedGroup<ResGenText>());

		currentMode = "waiting-for-spin";

		upgradeButton.active = shopButton.active = spinButton.active = canSpin = true;
	}

	public function addTech(NewTech:String):Void
	{
		var collected:Array<String> = technologies.get(age);
		collected.push(NewTech);

		technologies.set(age, collected);

		techDisp.addTech(age, NewTech);
	}

	public function openShop():Void
	{
		openSubState(new ShopScreen());
	}

	public function openUpgrade():Void
	{
		openSubState(new UpgradeScreen());
	}

	public function updatePopText()
	{
		txtPopulation.text = "{{population}} " + Std.string(getIconsOfType(-1, "human").length);
	}

	public function spin():Void
	{
		if (!spinButton.active || !canSpin)
			return;
		currentMode = "spinning";
		upgradeButton.active = shopButton.active = spinButton.active = canSpin = false;
		// some kind of animation!

		willWound = [];
		preventedWound = [];
		iconsToKill = [];
		whosAdding = [];
		iconsToAdd = [];
		iconsToDelete = [];
		toKill = [];
		toRemove = [];

		for (i in 0...25)
		{
			wounds[i].kill();
			crosshairs[i].kill();
			shields[i].kill();
		}

		if (age == 1)
		{
			addRandomAnimal();
			addRandomResources();
		}

		FlxG.random.shuffle(collection);

		for (i in 0...25)
			if (collection[i].wounded)
				wounds[i].revive();

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
		upgradeButton.active = shopButton.active = spinButton.active = canSpin = true;
	}

	public function parseEffect(IconPos:Int, Effect:String):Void
	{
		var split:Array<String> = Effect.split("?");
		if (!checkEffect(IconPos, split[0], split[1]))
			timer = 0;
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

				showIconAdd(screenIcons[IconPos], type, count);
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
				showResGen(IconPos, details[1], Std.parseInt(details[0]));

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

	public function showResGen(IconPos:Int, Type:String, Amount:Int):Void
	{
		var rg:ResGenText = resGenTexts.getFirstAvailable();
		if (rg == null)
		{
			rg = new ResGenText();
			resGenTexts.add(rg);
		}
		rg.spawn(screenIcons[IconPos], switch (Type)
		{
			case "food": "food";
			case "prod": "production";
			case "sci": "science";
			default: null;
		}, Amount);
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
		// iconsToKill.push(IconPos);
		// iconsToAdd.push(NewIcon);
		screenIcons[IconPos].activate();
		screenIcons[IconPos].icon = NewIcon;

		collection[IconPos] = new GridIcon(NewIcon);

		showIconAdd(screenIcons[IconPos], NewIcon);
	}

	public function showIconAdd(Icon:IconSprite, NewIcon:String, Amount:Int = 1):Void
	{
		var ia:AddedIcon = addedIcons.getFirstAvailable();
		if (ia == null)
		{
			ia = new AddedIcon();
			addedIcons.add(ia);
		}
		ia.spawn(Icon, NewIcon, Amount);
	}

	public function checkEffect(IconPos:Int, Effect:String, DoEffect:String):Bool
	{
		var doPause:Bool = false;
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
					screenIcons[n].activate();
					doEffect(IconPos, DoEffect, n);
				}
				doPause = true;
			case "pair": // a pair of tiles of this type are touching
				var splitA:Array<String> = Effect.split(":");
				var match:String = splitA[1];
				var split:Array<String> = DoEffect.split(":");
				var type:String = split[1];

				var addedAny:Bool = false;
				for (n in getNeighborsOfType(IconPos, match))
				{
					if (whosAdding.contains('$IconPos:$n:$type') || whosAdding.contains('$n:$IconPos:$type'))
						continue;

					whosAdding.push('$IconPos:$n:$type');

					screenIcons[IconPos].activate();
					doEffect(IconPos, DoEffect, n);
				}
				doPause = true;
			case "chance": // a percentage of happening
				if (FlxG.random.bool(Std.parseFloat(value)))
				{
					screenIcons[IconPos].activate();
					doEffect(IconPos, DoEffect);
				}
				doPause = true;
			case "timer": // count down to 0 and then do the effect...
				var split:Array<String> = Effect.split(":");
				var time:Int = Std.parseInt(split[1]);
				if (collection[IconPos].timer == 0)
				{
					screenIcons[IconPos].activate();
					doEffect(IconPos, DoEffect);
				}
				else if (collection[IconPos].timer > 0)
				{
					collection[IconPos].timer--;
					// show this!
				}
				else
				{
					collection[IconPos].timer = time;
				}
				doPause = true;
			case "after": // after this spin, do this effect
				screenIcons[IconPos].activate();
				doEffect(IconPos, DoEffect);
				doPause = true;
			case "touch": // is touching a tile of a speficic type
				var types:Array<String> = value.split("/");

				for (t in types)
				{
					for (n in getNeighborsOfType(IconPos, t))
					{
						screenIcons[IconPos].activate();
						doEffect(IconPos, DoEffect, n);
					}
				}
				doPause = true;
		}
		return doPause;
	}

	public function killIcon(IconPos:Int):Void
	{
		var def:Icon = Globals.IconList.get(collection[IconPos].name);

		// if the icon is within the 25 shown, have an animation!
		if (IconPos < 25)
		{
			death(IconPos);
		}

		if (def.death != null)
		{
			for (e in def.death)
			{
				doEffect(IconPos, e);
			}
		}
	}

	public function death(IconPos:Int):Void
	{
		var f:FakeIcon = fakeIcons.getFirstAvailable();
		if (f == null)
		{
			f = new FakeIcon();
			fakeIcons.add(f);
		}
		if (wounds[IconPos].alive)
		{
			wounds[IconPos].kill();
		}
		if (shields[IconPos].alive)
		{
			shields[IconPos].kill();
		}
		if (crosshairs[IconPos].alive)
		{
			crosshairs[IconPos].kill();
		}
		f.spawn(screenIcons[IconPos]);
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
		super.update(elapsed);
		switch (currentMode)
		{
			case "did-spin":
				checkingIcon = 0;
				currentMode = "pre-checking";

				for (i in 0...25)
				{
					screenIcons[i].icon = collection[i].name;
				}

			case "pre-checking":
				timer -= elapsed;
				if (timer <= 0)
				{
					timer = .05;
					currentMode = "checking";
				}

			case "checking":
				timer -= elapsed;
				if (timer <= 0)
				{
					if (checkingIcon >= 25)
					{
						timer = 0;
						currentMode = "wounding";
						checkingIcon = 0;
						trace("willWound", willWound);
					}
					else
					{
						timer = .05;
						checkEffects();
					}
				}
			case "wounding":
				timer -= elapsed;
				if (timer <= 0)
				{
					if (checkingIcon >= willWound.length)
					{
						currentMode = "deleting";
						checkingIcon = 0;
						timer = 0;
						trace("deleting", iconsToDelete);
					}
					else
					{
						timer = .05;
						checkWounds();
					}
				}

			case "deleting":
				timer -= elapsed;
				if (timer <= 0)
				{
					if (checkingIcon >= iconsToDelete.length)
					{
						currentMode = "killing";
						checkingIcon = -1;
						timer = 0;
					}
					else
					{
						timer = .05;
						checkToDelete();
					}
				}

			case "killing":
				if (checkingIcon == -1)
				{
					if (iconsToKill.length > 0)
					{
						toKill = [];
						for (i in iconsToKill)
						{
							if (!toKill.contains(i) && !toRemove.contains(i))
								toKill.push(i);
						}
						iconsToKill = [];
						checkingIcon = 0;
						trace("killing", toKill);
					}
					else
					{
						currentMode = "starving";
						starved = 0;
						checkingIcon = 0;
						timer = 0;
					}
				}
				else
				{
					timer -= elapsed;
					if (timer <= 0)
					{
						if (checkingIcon >= toKill.length)
						{
							checkingIcon = -1;
							timer = 0;
						}
						else
						{
							timer = .05;
							checkToKill();
						}
					}
				}

			case "starving":
				timer -= elapsed;
				if (timer <= 0)
				{
					if (checkingIcon >= collection.length)
					{
						trace(starved + " humans starved to death.");
						checkingIcon = 0;
						currentMode = "finished";
					}
					else
					{
						timer = .05;
						checkStarving();
					}
				}

			case "finished":
				finishChecking();
		}
	}

	public function checkToDelete():Void
	{
		if (!toRemove.contains(iconsToDelete[checkingIcon]))
		{
			while (toKill.contains(iconsToDelete[checkingIcon]))
			{
				toKill.remove(iconsToDelete[checkingIcon]);
			};

			trace(iconsToDelete[checkingIcon]);

			toRemove.push(iconsToDelete[checkingIcon]);

			if (iconsToDelete[checkingIcon] < 25)
			{
				death(iconsToDelete[checkingIcon]);
			}
		}
		// animate!
		checkingIcon++;
	}

	public function checkWounds():Void
	{
		if (preventedWound.contains(willWound[checkingIcon]))
		{
			shields[willWound[checkingIcon]].revive();
			FlxTween.shake(shields[willWound[checkingIcon]], 0.05, 0.1, FlxAxes.X);
		}
		else
		{
			if (collection[willWound[checkingIcon]].wounded)
				iconsToKill.push(willWound[checkingIcon]);
			else
			{
				collection[willWound[checkingIcon]].wounded = true;
				screenIcons[willWound[checkingIcon]].activate();
				wounds[willWound[checkingIcon]].revive();
				FlxTween.shake(wounds[willWound[checkingIcon]], 0.05, 0.1, FlxAxes.X);
			}
		}
		checkingIcon++;
	}

	public function checkStarving():Void
	{
		if (collection[checkingIcon].name == "child" && !toRemove.contains(checkingIcon))
		{
			// feed this human or kill it!
			if (food > 0)
			{
				food--;
			}
			else
			{
				killIcon(checkingIcon);
				toRemove.push(checkingIcon);
				trace(checkingIcon);
				starved++;
			}
		}
		else if (collection[checkingIcon].name == "human" && !toRemove.contains(checkingIcon))
		{
			// feed this human or kill it!
			if (food > 0)
			{
				food--;
			}
			else
			{
				killIcon(checkingIcon);
				toRemove.push(checkingIcon);
				trace(checkingIcon);
				starved++;
			}
		}
		else
			timer = 0;
		checkingIcon++;
	}

	public function checkToKill():Void
	{
		killIcon(toKill[checkingIcon]);
		if (!toRemove.contains(toKill[checkingIcon]))
		{
			toRemove.push(toKill[checkingIcon]);
			trace(toKill[checkingIcon]);
		}

		checkingIcon++;
	}

	private function set_food(Value:Float):Float
	{
		food = Value;
		txtFood.text = "{{food}} " + Std.string(food);
		return food;
	}

	private function set_production(Value:Float):Float
	{
		production = Value;
		txtProduction.text = "{{production}} " + Std.string(production);
		return production;
	}

	private function set_science(Value:Float):Float
	{
		science = Value;
		txtScience.text = "{{science}} " + Std.string(science);
		return science;
	}
}
