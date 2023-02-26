package states;

import axollib.TitleCase.Roman;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxAxes;
import gameObjects.Icon;
import gameObjects.IconSprite;
import globals.Globals;
import ui.AddedIcon;
import ui.GameButton;
import ui.GameOverState;
import ui.GameText;
import ui.InventoryScreen;
import ui.LogState;
import ui.ResGenText;
import ui.ShopScreen;
import ui.TechDisplay;
import ui.TimerDisplay;
import ui.UpgradeScreen;

using StringTools;

@:build(macros.IconsBuilder.build()) // IconList
@:build(macros.TechnologiesBuilder.build()) // TechnologiesList
class PlayState extends GameState
{
	public static inline var BLANKS_PER_AGE:Int = 25;
	public static inline var GRID_SIZE:Float = 648;
	public static inline var GRID_MID:Float = 324;
	public static inline var GRID_SPACING:Float = 2;

	public var spinCount:Int = 0;

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
	public var population(default, set):Float = 0;

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
	public var inventoryButton:GameButton;
	public var logButton:GameButton;

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
	public var timerDisplays:Array<TimerDisplay>;

	public var constructionEnabled:Bool = false;

	public var ageProgress:FlxBar;

	public var ageProgression(get, never):Float;

	public var newShop:FlxSprite;

	public var STARTING_ICONS:Map<String, Int> = ["human" => 5, "tree" => 2, "boulder" => 2, "berry bush" => 10];
	public var WILD_ANIMALS:Array<String> = ["hare", "deer", "wolf", "bear", "mammoth"];
	public var WILD_ANIMAL_WEIGHTS:Array<Float> = [48, 38, 8, 4, 2];

	public var SHOP_ITEMS:Array<String> = ["child", "berry bush"];

	public var GLYPH_TYPES:Map<String, GlyphType> = [];

	public var TechnologiesByAge:Map<Int, Array<String>> = [];

	public var log:Array<String> = [];

	override public function create()
	{
		initializeGame();

		super.create();
	}

	public function addLog(Message:String):Void
	{
		log.push(Message);
	}

	private function get_ageProgression():Float
	{
		return (technologies[age].length / TechnologiesByAge[age].length) * 100;
	}

	public function initializeGame()
	{
		bgColor = Colors.WHITE;

		Globals.PlayState = this;
		Globals.initGame();

		for (k => v in IconList)
			GLYPH_TYPES.set(k, GlyphType.ICON);

		for (k => v in TechnologiesList)
		{
			GLYPH_TYPES.set(k, GlyphType.TECHNOLOGY);
			if (TechnologiesByAge.exists(v.age))
				TechnologiesByAge[v.age].push(k);
			else
				TechnologiesByAge[v.age] = [k];
		}

		GLYPH_TYPES.set("population", GlyphType.RESOURCE);
		GLYPH_TYPES.set("food", GlyphType.RESOURCE);
		GLYPH_TYPES.set("production", GlyphType.RESOURCE);
		GLYPH_TYPES.set("science", GlyphType.RESOURCE);

		for (b in 0...BLANKS_PER_AGE)
		{
			collection.push(new GridIcon("blank"));
		}

		for (n => v in STARTING_ICONS)
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

		timerDisplays = new Array<TimerDisplay>();

		var shield:FlxSprite;

		var crosshair:FlxSprite;

		var timerDisplay:TimerDisplay;

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

			timerDisplay = new TimerDisplay(screenIcons[i].x, screenIcons[i].y + screenIcons[i].height);
			timerDisplays.push(timerDisplay);
			add(timerDisplay);
		}

		add(fakeIcons = new FlxTypedGroup<FakeIcon>());

		add(addedIcons = new FlxTypedGroup<AddedIcon>());

		add(spinButton = new GameButton((FlxG.width / 2) - 125, (FlxG.height / 2) + GRID_MID + 50, "Spin!", spin, 250, 50, SIZE_36, Colors.BLUE, Colors.BLACK,
			Colors.WHITE, Colors.BLACK));
		spinButton.active = false;

		add(shopButton = new GameButton(spinButton.x - 260, spinButton.y, "Shop", openShop, 250, 50, SIZE_36, Colors.GREEN, Colors.BLACK, Colors.WHITE,
			Colors.BLACK));
		shopButton.active = false;

		add(upgradeButton = new GameButton(spinButton.x + 260, spinButton.y, "Technologies", openUpgrade, 250, 50, SIZE_36, Colors.VIOLET, Colors.BLACK,
			Colors.WHITE, Colors.BLACK));
		upgradeButton.active = false;

		add(inventoryButton = new GameButton(upgradeButton.x + 260, upgradeButton.y, "Inventory", openInventory, 250, 50, SIZE_36, Colors.ORANGE,
			Colors.BLACK, Colors.WHITE, Colors.BLACK));
		inventoryButton.active = false;

		add(logButton = new GameButton(shopButton.x - 260, shopButton.y, "Log", openLog, 250, 50, SIZE_36, Colors.MAGENTA, Colors.BLACK, Colors.WHITE,
			Colors.BLACK));
		logButton.active = false;

		add(newShop = new FlxSprite(0, 0, "assets/images/new.png"));
		newShop.x = shopButton.x + shopButton.width - newShop.width - 12;
		newShop.y = shopButton.y + (shopButton.height / 2) - (newShop.height / 2);
		newShop.kill();

		age = 1;

		add(txtAge = new GameText(0, 10, 100, "Age " + Roman.arabic2Roman(age), Colors.BLACK, SIZE_36));
		txtAge.alignment = "center";
		txtAge.screenCenter(FlxAxes.X);

		add(ageProgress = new FlxBar(0, txtAge.y + txtAge.height + 10, FlxBarFillDirection.LEFT_TO_RIGHT, Std.int(GRID_SIZE), 20, this, "ageProgression", 0,
			100, true));
		ageProgress.createGradientBar([Colors.GRAY], [Colors.CYAN, Colors.DARKBLUE], 1, 180, true, Colors.BLACK);
		ageProgress.screenCenter(FlxAxes.X);

		add(resourceLabel = new GameText(10, 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "Resources", Colors.BLACK, SIZE_36));
		resourceLabel.alignment = "center";

		add(txtPopulation = new GameText(10, resourceLabel.y + resourceLabel.height + 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "{{population}} 0",
			Colors.BLACK, SIZE_36));
		add(txtFood = new GameText(10, txtPopulation.y + txtPopulation.height + 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "{{food}} 0", Colors.BLACK,
			SIZE_36));
		add(txtProduction = new GameText(10, txtFood.y + txtFood.height + 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "{{production}} 0", Colors.BLACK,
			SIZE_36));
		add(txtScience = new GameText(10, txtProduction.y + txtProduction.height + 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "{{science}} 0",
			Colors.BLACK, SIZE_36));

		add(techLabel = new GameText(0, 10, Std.int((FlxG.width / 2) - GRID_MID - 10), "Technologies Learned", Colors.BLACK, SIZE_36));
		techLabel.alignment = "center";
		techLabel.x = FlxG.width - techLabel.width - 10;

		techDisp = new TechDisplay((FlxG.width / 2) - GRID_MID - 20, FlxG.height - 120 - techLabel.height);
		techDisp.x = FlxG.width - techDisp.width - 10;
		techDisp.y = techLabel.y + techLabel.height + 10;
		add(techDisp);

		food = 10;

		updatePop();

		add(resGenTexts = new FlxTypedGroup<ResGenText>());

		#if debug
		food = production = science = 1000;
		#end

		FlxG.camera.fade(Colors.BLACK, 1, true, () ->
		{
			currentMode = "waiting-for-spin";

			logButton.active = inventoryButton.active = upgradeButton.active = shopButton.active = spinButton.active = canSpin = true;
		});
	}

	public function addTech(NewTech:String):Void
	{
		var collected:Array<String> = technologies.get(age);
		collected.push(NewTech);

		technologies.set(age, collected);

		techDisp.addTech(age, NewTech);
	}

	public function openLog():Void
	{
		openSubState(new LogState());
	}

	public function openInventory():Void
	{
		openSubState(new InventoryScreen());
	}

	public function openShop():Void
	{
		newShop.kill();
		openSubState(new ShopScreen());
	}

	public function openUpgrade():Void
	{
		openSubState(new UpgradeScreen(returnFromUpgrade));
	}

	public function returnFromUpgrade():Void
	{
		// check if we should be in the next age
		if (ageProgression >= 100)
		{
			// TODO: animate this!

			age++;
			txtAge.text = "Age " + Roman.arabic2Roman(age);
			if (age < 5) // however many ages we have
				techDisp.addAge(age);
		}
	}

	public function updatePop()
	{
		var pop:Int = getIconsOfType(-1, "human", true).length;
		pop += getIconsOfType(-1, "child", true).length;
		pop += getIconsOfType(-1, "family", true).length * 3;
		pop += getIconsOfType(-1, "hut", true).length * 3 * 5;
		pop += getIconsOfType(-1, "tribe", true).length * 3 * 5 * 5;

		population = pop;
	}

	public function spin():Void
	{
		if (!spinButton.active || !canSpin)
			return;

		spinCount++;

		addLog('Spin $spinCount');

		currentMode = "spinning";
		logButton.active = inventoryButton.active = upgradeButton.active = shopButton.active = spinButton.active = canSpin = false;
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
			timerDisplays[i].kill();
		}

		if (age == 1)
		{
			addRandomAnimal();
			addRandomResources();
		}

		FlxG.random.shuffle(collection);

		for (i in 0...25)
		{
			if (collection[i].wounded)
				wounds[i].revive();
			if (collection[i].timer > 0)
				timerDisplays[i].show(collection[i].timer);
		}

		currentMode = "did-spin";
	}

	public function addRandomResources():Void
	{
		var saplings:Int = FlxMath.maxInt(0, FlxG.random.int(-10, 2));

		var boulders:Int = FlxMath.maxInt(0, FlxG.random.int(-10, 2));

		for (i in 0...saplings)
			addNewIcon("sapling");

		for (i in 0...boulders)
			addNewIcon("boulder");

		if (saplings > 0 || boulders > 0)
			addLog((saplings > 0 ? '$saplings {{sapling}} ' : '') + (saplings > 0 && boulders > 0 ? "and " : "")
				+ (boulders > 0 ? '$boulders {{boulder}} ' : '') + 'appeared!');
	}

	public function addRandomAnimal():Void
	{
		var newAnimal:String = WILD_ANIMALS[FlxG.random.weightedPick(WILD_ANIMAL_WEIGHTS)];
		addLog('A wild {{$newAnimal}} appeared!');
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

		var icon:Icon = IconList.get(collection[checkingIcon].name);
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

		updatePop();
		if (population > 0)
		{
			currentMode = "waiting-for-spin";
			logButton.active = inventoryButton.active = upgradeButton.active = shopButton.active = spinButton.active = canSpin = true;
		}
		else
		{
			currentMode = "game-over";
			openSubState(new GameOverState());
		}
	}

	public function parseEffect(IconPos:Int, Effect:String):Void
	{
		var split:Array<String> = Effect.split("?");
		if (!checkEffect(IconPos, split[0], split[1]))
			timer = 0;
	}

	public function getIconName(IconPos:Int):String
	{
		return collection[IconPos].name;
	}

	public function doEffect(IconPos:Int, Effect:String, ?Source:Int = -1, ?Mult:Float = 1):Void
	{
		var split:Array<String> = Effect.split(":");

		switch (split[0])
		{
			case "delete": // remove icon without it's death effect
				iconsToDelete.push(Source);

				addLog("A {{" + getIconName(Source) + "}} was Destroyed by {{" + getIconName(IconPos) + "}}!");

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
						count = FlxG.random.int(Std.int(Std.parseInt(minMax[0]) * Mult), Std.int(Std.parseInt(minMax[1]) * Mult));
					}
					else
					{
						count = Std.int(Std.parseInt(split2[1]) * Mult);
					}
				}
				for (i in 0...count)
				{
					iconsToAdd.push(type);
					whosAdding.push('$IconPos:$type');

					trace("create: " + IconPos + " : " + collection[IconPos].name + " = " + type);
				}
				if (count > 0)
				{
					addLog("A {{" + getIconName(Source) + '}} created {{' + getIconName(IconPos) + '}} x $count.');

					showIconAdd(screenIcons[IconPos], type, count);
					
				}
			case "replace": // replace this icon with another
				replaceIcon(IconPos, split[1]);

				trace("replace: " + IconPos + " : " + collection[IconPos].name + " = " + split[1]);
			case "gen": // generate a resource
				var details:Array<String> = split[1].split("$");
				var amount:Int = Std.int(Std.parseFloat(details[0]) * Mult);
				switch (details[1])
				{
					case "food": food += amount;
					case "prod": production += amount;
					case "sci": science += amount;
				}
				trace("gen: " + IconPos + " : " + collection[IconPos].name + " = " + split[1] + " x" + Mult + " = " + amount);
				trace("food: " + food + " prod: " + production + " sci: " + science);
				showResGen(IconPos, details[1], amount);

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

				var targets:Array<String> = [];
				var targetEffects:Map<String, String> = [];
				var targetSplit:Array<String> = split[1].split("|");
				for (t in targetSplit)
				{
					var split2:Array<String> = t.split("*");
					var tmpTargets:Array<String> = split2[0].split("/");
					targets = targets.concat(tmpTargets);
					for (tt in tmpTargets)
						targetEffects.set(tt, split2[1]);
				}
				var icons:Array<Int> = [];
				for (t in targets)
				{
					icons = icons.concat(getIconsOfType(IconPos, t));
				}
				if (icons.length == 0)
					return;

				FlxG.random.shuffle(icons);

				var target:Int = icons[0];
				var effect:String = targetEffects.get(collection[icons[0]].name);
				if (effect == "wound")
				{
					willWound.push(target);
				}
				else
				{
					iconsToKill.push(target);
				}

				trace("snipe: " + IconPos + " : " + collection[target].name + " = " + icons);
				if (!crosshairs[target].alive)
				{
					crosshairs[target].revive();
					crosshairs[target].alpha = 0;
					crosshairs[target].angle = 0;
					crosshairs[target].angularVelocity = 60;
					screenIcons[target].activate();

					FlxTween.tween(crosshairs[target], {alpha: 1}, 0.15, {
						type: FlxTweenType.ONESHOT
					});
				}
		}
	}

	public function removeResource(IconPos:Int, Type:String, Amount:Int):Void
	{
		var rg:ResGenText = resGenTexts.getFirstAvailable();
		if (rg == null)
		{
			rg = new ResGenText();
			resGenTexts.add(rg);
		}
		rg.reverseSpawn(screenIcons[IconPos], switch (Type)
		{
			case "food": "food";
			case "prod": "production";
			case "sci": "science";
			case "population": "population";
			default: null;
		}, Amount);
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
			case "population": "population";
			default: null;
		}, Amount);
	}

	public function getIconsOfType(IconPos:Int, Type:String, ?FullCollection:Bool = false):Array<Int>
	{
		var icons:Array<Int> = [];
		for (i in 0...(FullCollection ? collection.length : 25))
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

		var u:Int = IconPos % 5 > 0 ? IconPos - 1 : -1;
		var d:Int = IconPos % 5 < 4 ? IconPos + 1 : -1;

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

	public function getNeighborsWork(IconPos:Int):Array<Int>
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

		var icon:Icon;

		if (l > -1)
		{
			icon = IconList.get(collection[l].name);

			if (icon.workMultiplier > 0)
				neighbors.push(l);
		}
		if (r > -1)
		{
			icon = IconList.get(collection[r].name);

			if (icon.workMultiplier > 0)
				neighbors.push(r);
		}

		if (u > -1)
		{
			icon = IconList.get(collection[u].name);

			if (icon.workMultiplier > 0)
				neighbors.push(u);
		}

		if (d > -1)
		{
			icon = IconList.get(collection[d].name);

			if (icon.workMultiplier > 0)
				neighbors.push(d);
		}

		if (ul > -1)
		{
			icon = IconList.get(collection[ul].name);

			if (icon.workMultiplier > 0)
				neighbors.push(ul);
		}

		if (ur > -1)
		{
			icon = IconList.get(collection[ur].name);

			if (icon.workMultiplier > 0)
				neighbors.push(ur);
		}

		if (dl > -1)
		{
			icon = IconList.get(collection[dl].name);

			if (icon.workMultiplier > 0)
				neighbors.push(dl);
		}

		if (dr > -1)
		{
			icon = IconList.get(collection[dr].name);

			if (icon.workMultiplier > 0)
				neighbors.push(dr);
		}

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
			case "spin": // just do the effect!
				doEffect(IconPos, DoEffect, null, Math.max(1, IconList.get(collection[IconPos].name).workMultiplier));
			case "work": // a human is touching this tile
				for (n in getNeighborsWork(IconPos))
				{
					screenIcons[n].activate();
					doEffect(IconPos, DoEffect, n, Math.max(1, IconList.get(collection[n].name).workMultiplier));
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
				if (collection[IconPos].timer > -1)
				{
					collection[IconPos].timer--;
					timerDisplays[IconPos].transition(collection[IconPos].timer);
					// show this!
					if (collection[IconPos].timer <= 0)
					{
						screenIcons[IconPos].activate();
						collection[IconPos].timer = -1;
						doEffect(IconPos, DoEffect);
					}
				}
				else
				{
					collection[IconPos].timer = time;
					timerDisplays[IconPos].appear(time);
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
						doEffect(IconPos, DoEffect, n, Math.max(1, IconList.get(collection[IconPos].name).workMultiplier));
					}
				}
				doPause = true;
		}
		return doPause;
	}

	public function killIcon(IconPos:Int):Void
	{
		var def:Icon = IconList.get(collection[IconPos].name);

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
		var icon:Icon = IconList.get(collection[IconPos].name);
		if (icon.population > 0)
			removeResource(IconPos, "population", icon.population);
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
		if (timerDisplays[IconPos].alive)
		{
			timerDisplays[IconPos].kill();
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
					if (checkingIcon >= 25) // only spun population eat
					{
						trace(starved + " humans starved to death.");
						checkingIcon = 0;
						currentMode = "merging";
					}
					else
					{
						timer = .05;
						checkStarving();
					}
				}

			case "merging":
				mergeIcons();
				finishChecking();
		}
	}

	public function mergeIcons():Void
	{
		// 3 humans will merge into 1 family
		checkForMergableIcons("human", "family", 3);
	}

	public function newFunc():Void
	{
		trace("text");
	}

	public function checkForMergableIcons(WhichIcons:String, MergeInto:String, AmountNeeded:Int):Void
	{
		var mergables:Array<Int> = [];
		for (i in 0...25)
		{
			if (collection[i].name == WhichIcons)
				mergables.push(i);
		}
		var neighbors:Array<Int> = [];
		var m:Int;
		while (mergables.length >= 3)
		{
			m = mergables.pop();
			neighbors = getNeighborsOfType(m, WhichIcons);
			if (neighbors.length >= AmountNeeded - 1)
			{
				screenIcons[m].activate();
				screenIcons[m].icon = MergeInto;

				collection[m] = new GridIcon(MergeInto);

				showIconAdd(screenIcons[m], MergeInto);

				screenIcons[neighbors[0]].activate();
				screenIcons[neighbors[1]].activate();

				screenIcons[neighbors[0]].icon = "blank";
				screenIcons[neighbors[1]].icon = "blank";

				mergables.remove(neighbors[0]);
				mergables.remove(neighbors[1]);

				toRemove.push(neighbors[0]);
				toRemove.push(neighbors[1]);

				if (wounds[m].alive)
				{
					wounds[m].kill();
				}
				if (shields[m].alive)
				{
					shields[m].kill();
				}
				if (wounds[neighbors[0]].alive)
				{
					wounds[neighbors[0]].kill();
				}
				if (shields[neighbors[0]].alive)
				{
					shields[neighbors[0]].kill();
				}
				if (wounds[neighbors[1]].alive)
				{
					wounds[neighbors[1]].kill();
				}
				if (shields[neighbors[1]].alive)
				{
					shields[neighbors[1]].kill();
				}

				trace(MergeInto, m, neighbors[0], neighbors[1]);
			}
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
			FlxTween.cancelTweensOf(shields[willWound[checkingIcon]]);
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
				FlxTween.cancelTweensOf(wounds[willWound[checkingIcon]]);
				FlxTween.shake(wounds[willWound[checkingIcon]], 0.05, 0.1, FlxAxes.X);
			}
		}
		checkingIcon++;
	}

	public function checkStarving():Void
	{
		var icon:Icon = IconList.get(collection[checkingIcon].name);
		if (icon.food > 0)
		{
			if (food >= icon.food)
			{
				food -= icon.food;
				screenIcons[checkingIcon].activate();
				removeResource(checkingIcon, "food", icon.food);
			}
			else
			{
				killIcon(checkingIcon);
				toRemove.push(checkingIcon);
				// trace(checkingIcon);
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

	private function set_population(Value:Float):Float
	{
		population = Value;
		txtPopulation.text = "{{population}} " + Std.string(population);
		return population;
	}
}
