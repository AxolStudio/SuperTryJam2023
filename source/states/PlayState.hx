package states;

import axollib.TitleCase.Roman;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxAxes;
import gameObjects.GodSpeeches;
import gameObjects.Icon;
import gameObjects.IconSprite;
import globals.Globals;
import ui.DemoEnd;
import ui.GameButton;
import ui.GameOverState;
import ui.GameText;
import ui.GodTalk;
import ui.InfoIcon;
import ui.InventoryScreen;
import ui.LogState;
import ui.ShopScreen;
import ui.ShrineUI;
import ui.SpinEffect;
import ui.TechDisplay;
import ui.TimerDisplay;
import ui.Tooltips;
import ui.UpgradeScreen;

using StringTools;
using flixel.util.FlxSpriteUtil;

@:build(macros.IconsBuilder.build()) // IconList
@:build(macros.TechnologiesBuilder.build()) // TechnologiesList
@:build(macros.GodTalkBuilder.build()) // GodSpeeches
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
	public var txtPopulation:GameText;

	public var food(default, set):Int = 0;
	public var production(default, set):Int = 0;
	public var science(default, set):Int = 0;
	public var population(default, set):Int = 0;
	public var faith(default, set):Int = 0;

	public var willWound:Array<Int> = [];
	public var preventedWound:Array<Int> = [];
	public var iconsToKill:Array<Int> = [];
	public var iconsToAdd:Array<String> = [];
	public var iconsToDelete:Array<Int> = [];

	public var wounds:Array<FlxSprite> = [];

	public var currentMode:String = "setting-up";

	public var whosAdding:Array<String> = [];

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

	public var fakeIcons:FlxTypedGroup<FakeIcon>;
	public var addedIcons:FlxTypedGroup<InfoIcon>;

	public var shields:Array<FlxSprite>;
	public var crosshairs:Array<FlxSprite>;
	public var timerDisplays:Array<TimerDisplay>;

	public var constructionEnabled:Bool = false;

	public var ageProgress:FlxBar;

	public var ageProgression(get, never):Float;

	public var newShop:FlxSprite;

	public var STARTING_ICONS:Map<String, Int> = ["human" => 5, "tree" => 2, "boulder" => 2, "berry bush" => 5];
	public var WILD_ANIMALS:Array<String> = ["hare", "deer", "wolf", "bear", "mammoth"];
	public var WILD_ANIMAL_WEIGHTS:Array<Float> = [48, 38, 8, 4, 2];

	public var SHOP_ITEMS:Array<String> = ["child", "berry bush"];

	public var GLYPH_TYPES:Map<String, GlyphType> = [];

	public var TechnologiesByAge:Map<Int, Array<String>> = [];

	public var log:Array<String> = [];

	public var ate:Int = 0;
	public var pop:Int = 0;

	public var spinEffect:SpinEffect;

	public var postSpin:Array<String> = [];

	public var conversions:Array<String> = [];

	public var spinsLeft(default, set):Int = 0;

	public var shrine:ShrineUI;

	public var nextMsg:String = "";

	public var lastNote:Int = -1;

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
		if (technologies.exists(age))
			return (technologies[age].length / TechnologiesByAge[age].length) * 100;
		else
			return 0;
	}

	public function initializeGame()
	{
		bgColor = Colors.WHITE;

		Tooltips.allowed = false;

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
		GLYPH_TYPES.set("faith", GlyphType.RESOURCE);

		GLYPH_TYPES.set("shrine", GlyphType.MISC);
		GLYPH_TYPES.set("spin count", GlyphType.MISC);

		for (b in 0...BLANKS_PER_AGE)
		{
			collection.push(new GridIcon("blank"));
			postSpin.push("blank");
		}

		add(new FlxSprite("assets/images/background.png"));

		var gridBack:FlxSprite = new FlxSprite();
		gridBack.makeGraphic(Std.int(GRID_SIZE), Std.int(GRID_SIZE), Colors.BLACK);
		gridBack.drawRect(2, 2, gridBack.width - 4, gridBack.height - 4, 0xFFFFFFFF);
		gridBack.replaceColor(0xFFFFFFFF, 0xA8FFFFFF, false);
		gridBack.screenCenter();
		add(gridBack);

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

		add(spinEffect = new SpinEffect());

		add(fakeIcons = new FlxTypedGroup<FakeIcon>());

		add(new FlxSprite((FlxG.width / 2) - GRID_MID - 2, (FlxG.height / 2) - GRID_MID - 2, "assets/images/grid_back.png"));

		add(spinButton = new GameButton((FlxG.width / 2) - 150, (FlxG.height / 2) + GRID_MID + 30, "Spin!", spin, 300, 50, SIZE_36, Colors.BLUE, Colors.BLACK,
			Colors.WHITE, Colors.BLACK));
		spinButton.active = false;

		add(shopButton = new GameButton(spinButton.x - 300, spinButton.y, "Shop", openShop, 250, 50, SIZE_24, Colors.GREEN, Colors.BLACK, Colors.WHITE,
			Colors.BLACK));
		shopButton.active = false;

		add(upgradeButton = new GameButton(spinButton.x + 350, spinButton.y, "Technologies", openUpgrade, 250, 50, SIZE_24, Colors.VIOLET, Colors.BLACK,
			Colors.WHITE, Colors.BLACK));
		upgradeButton.active = false;

		add(inventoryButton = new GameButton(upgradeButton.x + 260, upgradeButton.y, "Inventory", openInventory, 250, 50, SIZE_24, Colors.ORANGE,
			Colors.BLACK, Colors.WHITE, Colors.BLACK));
		inventoryButton.active = false;

		add(logButton = new GameButton(shopButton.x - 260, shopButton.y, "Log", openLog, 250, 50, SIZE_24, Colors.MAGENTA, Colors.BLACK, Colors.WHITE,
			Colors.BLACK));
		logButton.active = false;

		add(newShop = new FlxSprite(0, 0, "assets/images/new.png"));
		newShop.x = shopButton.x + shopButton.width - newShop.width - 12;
		newShop.y = shopButton.y + (shopButton.height / 2) - (newShop.height / 2);
		newShop.kill();

		age = 1;

		add(ageProgress = new FlxBar(0, Std.int((FlxG.height / 2) - GRID_MID) - 58, FlxBarFillDirection.LEFT_TO_RIGHT, Std.int(GRID_SIZE), 48, this,
			"ageProgression", 0, 100, true));
		ageProgress.createGradientBar([Colors.GRAY], [Colors.CYAN, Colors.DARKBLUE], 1, 180, true, Colors.BLACK);
		ageProgress.screenCenter(FlxAxes.X);

		add(txtAge = new GameText(0, 0, 100, "Age " + Roman.arabic2Roman(age), Colors.WHITE, SIZE_36));
		txtAge.alignment = "center";
		txtAge.setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 2);
		txtAge.screenCenter(FlxAxes.X);
		txtAge.y = ageProgress.y + (ageProgress.height / 2) - (txtAge.height / 2);

		add(resourceLabel = new GameText(20, Std.int((FlxG.height / 2) - GRID_MID), Std.int((FlxG.width / 2) - GRID_MID - 40), "Resources", Colors.WHITE,
			SIZE_36));
		resourceLabel.alignment = "center";
		resourceLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 2);

		var resBack:FlxSprite = new FlxSprite();
		resBack.makeGraphic(Std.int((FlxG.width / 2) - GRID_MID - 40), Std.int(GRID_SIZE - resourceLabel.height - 10), Colors.BLACK);
		resBack.drawRect(2, 2, resBack.width - 4, resBack.height - 4, 0xFFFFFFFF);
		resBack.replaceColor(0xFFFFFFFF, 0xA8FFFFFF, false);
		resBack.x = resourceLabel.x;
		resBack.y = resourceLabel.y + resourceLabel.height + 10;
		add(resBack);

		shrine = new ShrineUI();
		shrine.x = (((FlxG.width / 2) - GRID_MID) / 2) - 128;
		shrine.y = (FlxG.height / 2) + GRID_MID - shrine.height - 20;
		shrine.visible = false;
		add(shrine);

		add(txtPopulation = new GameText(40, resourceLabel.y + resourceLabel.height + 20, Std.int((FlxG.width / 2) - GRID_MID - 80), "0 {{population}}",
			Colors.BLACK, SIZE_36));
		add(txtFood = new GameText(40, txtPopulation.y + txtPopulation.height + 20, Std.int((FlxG.width / 2) - GRID_MID - 80), "0 {{food}}", Colors.BLACK,
			SIZE_36));
		add(txtProduction = new GameText(40, txtFood.y + txtFood.height + 20, Std.int((FlxG.width / 2) - GRID_MID - 80), "0 {{production}}", Colors.BLACK,
			SIZE_36));
		add(txtScience = new GameText(40, txtProduction.y + txtProduction.height + 20, Std.int((FlxG.width / 2) - GRID_MID - 80), "0 {{science}}",
			Colors.BLACK, SIZE_36));
		txtProduction.alignment = txtScience.alignment = txtFood.alignment = txtPopulation.alignment = "right";

		add(techLabel = new GameText(0, Std.int((FlxG.height / 2) - GRID_MID), Std.int((FlxG.width / 2) - GRID_MID - 40), "Technologies Learned",
			Colors.WHITE, SIZE_36));
		techLabel.alignment = "center";
		techLabel.setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 2);
		techLabel.x = Std.int((FlxG.width / 2) + GRID_MID) + 20;

		techDisp = new TechDisplay((FlxG.width / 2) - GRID_MID - 40, GRID_SIZE - techLabel.height - 10);
		techDisp.x = FlxG.width - techDisp.width - 20;
		techDisp.y = techLabel.y + techLabel.height + 10;
		add(techDisp);

		add(addedIcons = new FlxTypedGroup<InfoIcon>());

		for (a in 0...25)
		{
			addedIcons.add(new InfoIcon());
		}

		food = 10;

		updatePop();

		#if debug
		// food = production = science = 5000;
		#end

		spinsLeft = 5;
		var gT:GodTalk = new GodTalk("intro");

		var blackOut:FlxSprite = new FlxSprite();
		blackOut.makeGraphic(FlxG.width, FlxG.height, Colors.BLACK);
		add(blackOut);

		var earth:FlxSprite = new FlxSprite("assets/images/earth.jpg");

		earth.alpha = 0;
		earth.screenCenter();
		earth.y = FlxG.height - earth.height;
		add(earth);

		gT.closeCallback = () ->
		{
			blackOut.kill();
			FlxTween.tween(earth, {alpha: 0}, .33, {
				type: FlxTweenType.ONESHOT,
				onComplete: (_) ->
				{
					currentMode = "waiting-for-spin";
					// show next text?

					gT = new GodTalk("intro-2");
					gT.closeCallback = () ->
					{
						nextMsg = "first-check";
						Tooltips.allowed = true;
						logButton.active = inventoryButton.active = upgradeButton.active = shopButton.active = spinButton.active = canSpin = true;
					};
					openSubState(gT);
				}
			});
		};

		FlxTween.tween(earth, {alpha: 1}, .33, {
			startDelay: 0.5,
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				openSubState(gT);
			}
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

			upgradeButton.active = false;
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

		Globals.SND_SPIN.play();

		Tooltips.allowed = false;

		lastNote = -1;

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
		conversions = [];

		ate = pop = 0;

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

		spinEffect.start();

		currentMode = "waiting-for-spin-end";
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
		postSpin = [];
		var tmpCollection:Array<GridIcon> = [];
		trace("toRemove", toRemove);
		for (i in 0...collection.length)
		{
			if (!toRemove.contains(i))
			{
				tmpCollection.push(collection[i]);
				postSpin.push(collection[i].name);
			}
			else
			{
				postSpin.push("blank");
			}
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
			currentMode = "visit-from-god";
			spinsLeft--;
			if (spinsLeft > 0)
			{
				readyForNext();
			}
			else
			{
				if (shrine.visible)
				{
					if (faith < shrine.neededAmt)
					{
						failure();
					}
					else
					{
						showResTransfer("faith", "", shrine.neededAmt, () ->
						{
							faith -= shrine.neededAmt;
							vistFromGod();
						});
					}
				}
				else
				{
					vistFromGod();
				}
			}
		}
		else
		{
			currentMode = "game-over";
			var gameOverState:GameOverState = new GameOverState("pop");
			gameOverState.closeCallback = function():Void
			{
				FlxG.camera.fade(Colors.BLACK, 1, false, () ->
				{
					FlxG.resetState();
				});
			};
			openSubState(gameOverState);
		}
	}

	public function failure():Void
	{
		var gT:GodTalk = new GodTalk("failure");
		var fire:FlxSprite = new FlxSprite("assets/images/fire.jpg");
		fire.screenCenter();
		fire.alpha = 0;
		add(fire);

		gT.closeCallback = () ->
		{
			currentMode = "game-over";
			var gameOverState:GameOverState = new GameOverState("faith");
			gameOverState.closeCallback = function():Void
			{
				FlxG.camera.fade(Colors.BLACK, 1, false, () ->
				{
					FlxG.resetState();
				});
			};
			openSubState(gameOverState);
		}
		FlxTween.tween(fire, {alpha: 1}, .33, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				openSubState(gT);
			}
		});
	}

	public function vistFromGod():Void
	{
		var thisMsg:String = nextMsg;

		if (thisMsg == "first-check")
			shrine.visible = true;


		var msg:GodSpeeches = GodSpeeches.get(thisMsg);

		shrine.spinsNeeded = spinsLeft = msg.spins;
		if (nextMsg == "future-check")
			shrine.neededAmt =  Std.int(shrine.neededAmt * msg.needs);
		else
			shrine.neededAmt = Std.int(msg.needs);

		nextMsg = msg.next;

		var gT:GodTalk = new GodTalk(thisMsg);

		gT.closeCallback = () ->
		{
			readyForNext();
		}

		openSubState(gT);
	}

	public function readyForNext():Void
	{
		currentMode = "waiting-for-spin";
		logButton.active = inventoryButton.active = shopButton.active = spinButton.active = canSpin = true;

		Tooltips.allowed = true;

		if (age < 2)
			upgradeButton.active = true;
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

	public function doEffect(IconPos:Int, Effect:String, ?Source:Int = -1, ?Mult:Float = 1):String
	{
		var logResponse:String = "";
		var split:Array<String> = Effect.split(":");

		switch (split[0])
		{
			case "delete": // remove icon without it's death effect
				iconsToDelete.push(Source);

				logResponse = 'destroyed {{' + getIconName(Source) + '}}!';

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
				}
				if (count > 0)
				{
					logResponse = 'created {{' + getIconName(IconPos) + '}} x $count.';

					showIconAdd(screenIcons[IconPos], type, count);
				}
			case "replace": // replace this icon with another

				logResponse = ' replaced with {{' + split[1] + '}}.';

				replaceIcon(IconPos, split[1]);

			case "gen": // generate a resource
				var details:Array<String> = split[1].split("$");
				var amount:Int = Std.int(Std.parseFloat(details[0]) * Mult);
				switch (details[1])
				{
					case "food": food += amount;
					case "prod": production += amount;
					case "sci": science += amount;
				}

				logResponse = ' generated $amount {{' + (switch (details[1])
				{
					case "food": "food";
					case "prod": "production";
					case "sci": "science";
					default: "";
				}) + '}}.';
				showResGen(IconPos, details[1], amount);

			case "die": // remove this icon from the collection
				if (!iconsToKill.contains(IconPos))
				{
					iconsToKill.push(IconPos);

					logResponse = "died!";
				}
				else
					logResponse = "";

			case "wound": // wound all humans touching this tile - UNLESS it is prevented from doing so...

				// willWound.push(Source);

				var types:Array<String> = split[1].split("/");
				var any:Bool = false;
				var nCounts:Map<String, Int> = [];
				var thisWounds:Array<Int> = [];

				for (t in types)
				{
					var neighbors:Array<Int> = getNeighborsOfType(IconPos, t);

					for (n in neighbors)
					{
						any = true;
						if (!thisWounds.contains(n))
						{
							thisWounds.push(n);
							if (nCounts.exists(collection[n].name))
								nCounts[collection[n].name]++;
							else
								nCounts[collection[n].name] = 1;
						}
					}
				}

				if (any)
				{
					willWound = willWound.concat(thisWounds);
					for (k => v in nCounts)
						logResponse += (logResponse != "" ? ', ' : '') + '$v {{$k}}';

					logResponse = "wounded " + logResponse + ".";
				}

			case "protect":
				var types:Array<String> = split[1].split("/");
				var any:Bool = false;
				var nCounts:Map<String, Int> = [];
				for (t in types)
				{
					var neighbors:Array<Int> = getNeighborsOfType(IconPos, t);
					preventedWound = preventedWound.concat(neighbors);

					trace("protect: " + IconPos + " : " + collection[IconPos].name + " = " + neighbors);

					for (n in neighbors)
					{
						any = true;
						if (nCounts.exists(collection[n].name))
							nCounts[collection[n].name]++;
						else
							nCounts[collection[n].name] = 1;
					}
				}

				if (any)
				{
					for (k => v in nCounts)
						logResponse += (logResponse != "" ? ', ' : '') + '$v {{$k}}';

					logResponse = "protected " + logResponse + " against wounds.";
				}

			case "kill": // kill the types touching this icon
				var types:Array<String> = split[1].split("/");
				var any:Bool = false;
				var nCounts:Map<String, Int> = [];
				for (t in types)
				{
					var neighbors:Array<Int> = getNeighborsOfType(IconPos, t);
					iconsToKill = iconsToKill.concat(neighbors);
					trace("kill: " + IconPos + " : " + collection[IconPos].name + " = " + neighbors);

					for (n in neighbors)
					{
						any = true;
						if (nCounts.exists(collection[n].name))
							nCounts[collection[n].name]++;
						else
							nCounts[collection[n].name] = 1;
					}
				}

				if (any)
				{
					for (k => v in nCounts)
						logResponse += (logResponse != "" ? ', ' : '') + '$v {{$k}}';

					logResponse = "killed " + logResponse;
				}
			case "change": // change touching tile to another tile
				var types:Array<String> = split[1].split("/");
				var any:Bool = false;
				var nCounts:Map<String, Int> = [];

				for (t in types)
				{
					var neighbors:Array<Int> = getNeighborsOfType(IconPos, t);
					for (n in neighbors)
					{
						if (nCounts.exists(collection[n].name))
							nCounts[collection[n].name]++;
						else
							nCounts[collection[n].name] = 1;
						replaceIcon(n, split[2]);
						any = true;
					}
				}
				if (any)
				{
					for (k => v in nCounts)
						logResponse += (logResponse != "" ? ', ' : '') + '$v {{$k}} into {{' + split[2] + "}}";

					logResponse = "changed " + logResponse;
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
				if (icons.length > 0)
				{
					FlxG.random.shuffle(icons);

					var target:Int = icons[0];
					var effect:String = targetEffects.get(collection[target].name);
					if (effect == "wound")
					{
						logResponse = "sniped a {{" + getIconName(target) + "}}, wounding it!";

						willWound.push(target);
					}
					else
					{
						logResponse = "sniped a {{" + getIconName(target) + "}}, killing it!";

						iconsToKill.push(target);
					}

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
			case "convert":
				conversions.push(Std.string(IconPos) + "!" + split[1]);
		}
		return logResponse;
	}

	public function playPrevNote():Void
	{
		lastNote--;
		if (lastNote < 0)
			lastNote = 3;

		FlxG.sound.play('assets/sounds/note_0${lastNote + 1}.ogg', 1, false);
	}

	public function playNextNote():Void
	{
		lastNote++;
		if (lastNote > 3)
			lastNote = 0;
		FlxG.sound.play('assets/sounds/note_0${lastNote + 1}.ogg', 1, false);
	}

	public function removeResource(IconPos:Int, Type:String, Amount:Int, ?Callback:Void->Void):Void
	{
		
		var rg:InfoIcon = addedIcons.getFirstAvailable();
		if (rg == null)
		{
			rg = new InfoIcon();
			addedIcons.add(rg);
		}
		rg.spawn(screenIcons[IconPos], switch (Type)
		{
			case "food": "food";
			case "prod": "production";
			case "sci": "science";
			case "population": "population";
			case "faith": "faith";
			default: null;
		}, Amount, false, Callback);
	}

	public function showResGen(IconPos:Int, Type:String, Amount:Int, ?Callback:Void->Void):Void
	{
		
		var rg:InfoIcon = addedIcons.getFirstAvailable();
		if (rg == null)
		{
			rg = new InfoIcon();
			addedIcons.add(rg);
		}
		rg.spawn(screenIcons[IconPos], switch (Type)
		{
			case "food": "food";
			case "prod": "production";
			case "sci": "science";
			case "population": "population";
			case "faith": "faith";
			default: null;
		}, Amount, true, Callback);
	}

	public function showResTransfer(TypeFrom:String, TypeTo:String, Amount:Int, ?Callback:Void->Void):Void
	{
		
		var rg:InfoIcon = addedIcons.getFirstAvailable();
		if (rg == null)
		{
			rg = new InfoIcon();
			addedIcons.add(rg);
		}
		rg.transfer(switch (TypeFrom)
		{
			case "food": "food";
			case "prod": "production";
			case "sci": "science";
			case "population": "population";
			case "faith": "faith";
			default: null;
		}, switch (TypeTo)
			{
				case "food": "food";
				case "prod": "production";
				case "sci": "science";
				case "population": "population";
				case "faith": "faith";
				default: "";
			}, Amount, Callback);
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
		
		var ia:InfoIcon = addedIcons.getFirstAvailable();
		if (ia == null)
		{
			ia = new InfoIcon();
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
		var logResponse:String = "";

		switch (keyWord)
		{
			case "spin": // just do the effect!
				logResponse = doEffect(IconPos, DoEffect, null, Math.max(1, IconList.get(collection[IconPos].name).workMultiplier));
				if (logResponse != "")
					addLog("A {{" + getIconName(IconPos) + "}} " + logResponse);
			case "work": // a human is touching this tile
				for (n in getNeighborsWork(IconPos))
				{
					screenIcons[n].activate();
					logResponse = doEffect(IconPos, DoEffect, n, Math.max(1, IconList.get(collection[n].name).workMultiplier));
					if (logResponse != "")
						addLog("A {{" + getIconName(IconPos) + "}} was worked by a {{" + getIconName(n) + "}} and " + logResponse);
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
					logResponse = doEffect(IconPos, DoEffect, n);
					addLog("A pair of {{" + getIconName(IconPos) + "}} " + logResponse);
				}
				doPause = true;
			case "chance": // a percentage of happening
				if (FlxG.random.bool(Std.parseFloat(value)))
				{
					screenIcons[IconPos].activate();
					logResponse = doEffect(IconPos, DoEffect);
					addLog("A {{" + getIconName(IconPos) + "}} " + logResponse);
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
						logResponse = doEffect(IconPos, DoEffect);
						addLog("A {{" + getIconName(IconPos) + "}} " + logResponse);
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
				logResponse = doEffect(IconPos, DoEffect);
				addLog("A {{" + getIconName(IconPos) + "}} " + logResponse);
				doPause = true;
			case "touch": // is touching a tile of a speficic type
				var types:Array<String> = value.split("/");

				for (t in types)
				{
					for (n in getNeighborsOfType(IconPos, t))
					{
						screenIcons[IconPos].activate();
						logResponse = doEffect(IconPos, DoEffect, n, Math.max(1, IconList.get(collection[IconPos].name).workMultiplier));
						addLog("A {{" + getIconName(IconPos) + "}} touched a {{" + getIconName(n) + "}} and " + logResponse);
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
				addLog("A {{" + getIconName(IconPos) + "}} died and " + doEffect(IconPos, e));
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
			case "waiting-for-spin":
				if (age > 1)
				{
					currentMode = "demo-end";
					var demoEnd:DemoEnd = new DemoEnd();
					demoEnd.closeCallback = () ->
					{
						FlxG.camera.fade(Colors.BLACK, 1, false, () ->
						{
							// GameText.FONT_24 = FlxDestroyUtil.destroy(GameText.FONT_24);
							// GameText.FONT_36 = FlxDestroyUtil.destroy(GameText.FONT_36);
							FlxG.resetState();
						});
					}
					openSubState(demoEnd);
				}

			case "waiting-for-spin-end":
				if (!spinEffect.anySpinning())
				{
					currentMode = "did-spin";
				}

			case "did-spin":
				checkingIcon = 0;
				currentMode = "pre-checking";

				for (i in 0...25)
				{
					if (collection[i].wounded)
						wounds[i].revive();
					if (collection[i].timer > 0)
						timerDisplays[i].show(collection[i].timer);

					screenIcons[i].icon = collection[i].name;
					screenIcons[i].visible = true;
				}
				spinEffect.visible = false;

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
						timer = 0;
						currentMode = "conversions";
						addLog('$pop people consumed $ate {{food}}.');
						if (shrine.visible)
							convertFaithToShrine();
					}
					else
					{
						timer = .05;
						checkStarving();
					}
				}

			case "conversions":
				if (conversions.length > 0)
				{
					timer -= elapsed;
					if (timer <= 0)
					{
						checkConversions();
					}
				}
				else
				{
					currentMode = "merging";
					checkingIcon = 0;
					timer = 0;
				}

			case "merging":
				mergeIcons();
				finishChecking();
		}
	}

	public function checkConversions():Void
	{
		var c:String = conversions.pop();
		var split:Array<String> = c.split("!");
		var icon:Int = Std.parseInt(split[0]);
		var effects:Array<String> = split[1].split("|");
		var from:Array<String> = effects[0].split("$");
		var to:Array<String> = effects[1].split("$");
		var fromType:String = from[1];
		var fromAmount:Int = Std.parseInt(from[0]);
		var toType:String = to[1];
		var toAmount:Int = Std.parseInt(to[0]);

		var enough:Bool = false;

		switch (fromType)
		{
			case "food":
				if (food >= fromAmount)
				{
					food -= fromAmount;
					enough = true;
				}

			case "pop":
				if (population >= fromAmount)
				{
					population -= fromAmount;
					enough = true;
				}
			case "sci":
				if (science >= fromAmount)
				{
					science -= fromAmount;
					enough = true;
				}
			case "prod":
				if (production >= fromAmount)
				{
					production -= fromAmount;
					enough = true;
				}
			case "faith":
				if (faith >= fromAmount)
				{
					faith -= fromAmount;
					enough = true;
				}
			default:
		}

		if (enough)
		{
			switch (toType)
			{
				case "food":
					food += toAmount;
				case "pop":
					population += toAmount;
				case "sci":
					science += toAmount;
				case "prod":
					production += toAmount;
				case "faith":
					faith += toAmount;
				default:
			}

			removeResource(icon, fromType, fromAmount, () ->
			{
				showResGen(icon, toType, toAmount);
			});

			addLog("A {{" + getIconName(icon) + '}} converted $fromAmount {{$fromType}} into $toAmount {{$toType}}.');

			timer = .05;
		}
		else
		{
			addLog("A {{"
				+ getIconName(icon)
				+ '}} could not convert $fromAmount {{$fromType}} to $toAmount {{$toType}} because there was not enough {{$fromType}}.');
			timer = 0;
		}
	}

	public function convertFaithToShrine():Void
	{
		var amt:Int = Std.int(food / 10);
		if (amt > 0)
		{
			food -= amt;
			addLog('$amt {{food}} was converted into $amt {{faith}}.');
			showResTransfer("food", "faith", amt, () ->
			{
				faith += amt;
				timer = .05;
			});
		}
		else
		{
			timer = 0;
		}
	}

	public function mergeIcons():Void
	{
		// 3 humans will merge into 1 family
		checkForMergableIcons("human", "family", 3);
		if (constructionEnabled)
		{
			checkForMergableIcons("family", "hut", 3);
			checkForMergableIcons("hut", "tribe", 3);
		}
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

				trace('$AmountNeeded ' + getIconName(m) + ' merged to become a {{$MergeInto}}.');
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
			addLog("A {{" + getIconName(willWound[checkingIcon]) + "}} was protected from a wound!");
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
				ate += icon.food;
				pop += icon.population;
			}
			else
			{
				killIcon(checkingIcon);
				toRemove.push(checkingIcon);
				// trace(checkingIcon);
				addLog("A " + collection[checkingIcon].name + " starved to death.");
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

	private function set_food(Value:Int):Int
	{
		food = Value;
		txtFood.text = '$food {{food}}';
		return food;
	}

	private function set_production(Value:Int):Int
	{
		production = Value;
		txtProduction.text = '$production {{production}}';
		return production;
	}

	private function set_science(Value:Int):Int
	{
		science = Value;
		txtScience.text = '$science {{science}}';
		return science;
	}

	private function set_population(Value:Int):Int
	{
		population = Value;
		txtPopulation.text = '$population {{population}}';
		return population;
	}

	private function set_faith(Value:Int):Int
	{
		faith = Value;
		shrine.faith = faith;
		return faith;
	}

	override public function destroy():Void
	{
		super.destroy();
	}
	private function set_spinsLeft(Value:Int):Int
	{
		spinsLeft = Value;
		shrine.spins = spinsLeft;
		return spinsLeft;
	}
}
