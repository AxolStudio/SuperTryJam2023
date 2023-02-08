package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import gameObjects.Icon;
import gameObjects.IconSprite;
import globals.Globals;

class PlayState extends FlxState
{
	public static inline var GRID_SIZE:Float = 648;
	public static inline var GRID_MID:Float = 324;
	public static inline var GRID_SPACING:Float = 2;

	public var collection:Array<String> = [];
	public var screenIcons:Array<IconSprite> = [];

	public var spinButton:FlxButton;

	public var canSpin:Bool = false;

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
				if (collection.contains("blank"))
					collection.remove("blank");
				collection.push(n);
			}
		}

		var icon:IconSprite;
		for (i in 0...25)
		{
			icon = new IconSprite((FlxG.width / 2)
				- GRID_MID
				+ (i % 5) * 128
				+ ((i % 5) * GRID_SPACING),
				(FlxG.height / 2)
				- GRID_MID
				+ Std.int(i / 5) * 128
				+ (Std.int(i / 5) * GRID_SPACING));
			screenIcons.push(icon);
			add(icon);
		}

		add(spinButton = new FlxButton((FlxG.width / 2) - 100, (FlxG.height / 2) + GRID_MID + 50, "Spin!", spin));
		spinButton.makeGraphic(200, 50, FlxColor.BLUE);
		spinButton.label.setFormat(null, 32, FlxColor.WHITE, "center");
		spinButton.label.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		spinButton.active = false;

		spinButton.active = canSpin = true;
	}

	public function spin():Void
	{
		if (!spinButton.active || !canSpin)
			return;
		spinButton.active = canSpin = false;
		// some kind of animation!

		FlxG.random.shuffle(collection);
		for (i in 0...25)
		{
			screenIcons[i].icon = collection[i];
		}

		spinButton.active = canSpin = true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
