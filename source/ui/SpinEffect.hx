package ui;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import globals.Globals;
import states.PlayState;

class SpinEffect extends FlxSpriteGroup
{
	public var wheels:Array<Wheel> = [];

	public function new():Void
	{
		super();
		var wheel:Wheel;
		for (w in 0...5)
		{
			wheel = new Wheel((FlxG.width / 2) - PlayState.GRID_MID + (w * (128 + PlayState.GRID_SPACING)), (FlxG.height / 2) - PlayState.GRID_MID, w);
			wheels.push(wheel);
			add(wheel);
		}
		visible = false;

		var test:FlxSprite;
		add(test = new FlxSprite());
		test.makeGraphic(FlxG.width, FlxG.height, 0x66990099);

		clipRect = FlxRect.get((FlxG.width / 2) - PlayState.GRID_MID, (FlxG.height / 2) - PlayState.GRID_MID, PlayState.GRID_SIZE, PlayState.GRID_SIZE);
		trace(clipRect);
	}

	public function start():Void
	{
		trace(clipRect);

		var icon:String;
		for (c in 0...25)
		{
			icon = Globals.PlayState.postSpin[c];

			trace(c, c / 5, c % 5, icon);

			wheels[Std.int(c / 5)].icons[Std.int(c % 5)].icon = icon;
		}

		for (i in 0...5)
			wheels[i].start(i);

		visible = true;
	}
}

class Wheel extends FlxSpriteGroup
{
	public var icons:Array<SpinIcon> = [];

	public var timer:Float = -1;

	public var slowingDown:Bool = false;

	public function new(X:Float, Y:Float, Wheel:Int):Void
	{
		super(X, Y);

		ID = Wheel;

		for (i in 0...8)
		{
			var icon = new SpinIcon(0, 2 + (Std.int(i) * (128 + PlayState.GRID_SPACING)), i, this);
			icon.icon = "blank";
			icon.visible = true;
			icons.push(icon);
			add(icon);
		}

		clipRect = FlxRect.get((FlxG.width / 2) - PlayState.GRID_MID, (FlxG.height / 2) - PlayState.GRID_MID, PlayState.GRID_SIZE, PlayState.GRID_SIZE);
		// clipRect = new FlxRect(0, 0, 128, (128 + PlayState.GRID_SPACING) * 5);
	}

	public function start(Time:Float):Void
	{
		timer = Time;
		slowingDown = false;
		for (i in icons)
		{
			i.velocity.y = 1000;
		}
	}

	public function slowDown():Void
	{
		slowingDown = true;
		for (i in icons)
		{
			i.velocity.y = 0;
			i.slowStart = i.y;

			FlxTween.num(0, 128 * 7, 1, {type: FlxTweenType.ONESHOT, ease: FlxEase.backOut}, (Value:Float) ->
			{
				i.y = ((i.slowStart + Value) % (128 * 7));
			});
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (slowingDown) {}
		else if (timer > -1)
		{
			timer -= elapsed;
			if (timer < 0)
			{
				timer = -1;
				for (i in icons)
				{
					i.ending = true;
				}
			}
		}
	}
}

class SpinIcon extends FlxSprite
{
	public var parent:Wheel;

	public var icon(never, set):String;

	public var ending(default, set):Bool = false;

	public var slowStart:Float = -1;

	public function new(X:Float, Y:Float, Id:Int, Parent:Wheel):Void
	{
		super(X, Y);

		ID = Id;

		parent = Parent;

		frames = GraphicsCache.loadGraphicFromAtlas('assets/images/icons-128.png', 'assets/images/icons-128.xml', false, 'icons-icons-128').atlasFrames;

		icon = "blank";

		clipRect = FlxRect.get((FlxG.width / 2) - PlayState.GRID_MID, (FlxG.height / 2) - PlayState.GRID_MID, PlayState.GRID_SIZE, PlayState.GRID_SIZE);
	}

	private function set_icon(Value:String):String
	{
		if (Value == "blank")
			color = Colors.GRAY;
		else
			color = Colors.BLACK;

		color = Colors.ORANGE;
		alpha = .66;

		animation.frameName = Value;

		return Value;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (velocity.y > 0 && y > 2 + (128 + PlayState.GRID_SPACING) * 6)
		{
			y = 2;
			// velocity.y = 0;
			if (!ending || ID > 5)
				icon = Globals.PlayState.collection[FlxG.random.int(0, Globals.PlayState.collection.length - 1)].name;
			else if (ending && ID <= 5)
			{
				icon = Globals.PlayState.collection[ID + (parent.ID * 5)].name;
			}
			if (ID == 7)
			{
				parent.slowDown();
			}
		}
	}

	private function set_ending(Value:Bool):Bool
	{
		ending = Value;

		return ending;
	}
}
