package ui;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import gameObjects.IconSprite;
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

		// var test:FlxSprite;
		// add(test = new FlxSprite());
		// test.makeGraphic(FlxG.width, FlxG.height, 0x66990099);

		trace(clipRect);
	}

	public function anySpinning():Bool
	{
		var any:Bool = false;
		for (w in wheels)
		{
			for (i in w.icons)
			{
				if (i.started)
				{
					any = true;
					break;
				}
			}
		}
		return any;
	}

	public function start():Void
	{
		trace(clipRect);

		var icon:String;

		for (w in 0...wheels.length)
		{
			for (i in 0...wheels[w].icons.length)
			{
				if (i > 0 && i < 6)
				{
					icon = Globals.PlayState.postSpin[(w * 5) + (i - 1)];
				}
				else
				{
					icon = Globals.PlayState.getIconName(FlxG.random.int(0, Globals.PlayState.collection.length - 1));
				}

				trace(w, i, icon, wheels[w].icons[i].y, wheels[w].icons[i].ID);

				wheels[w].icons[i].icon = icon;
				wheels[w].icons[i].pos = 0;
			}
		}

		for (s in Globals.PlayState.screenIcons)
		{
			s.visible = false;
		}

		for (i in 0...5)
			wheels[i].start(i);

		visible = true;
	}

	override public function draw():Void
	{
		clipRect = FlxRect.get((FlxG.width / 2) - PlayState.GRID_MID, (FlxG.height / 2) - PlayState.GRID_MID, PlayState.GRID_SIZE, PlayState.GRID_SIZE);

		super.draw();
	}
}

class Wheel extends FlxSpriteGroup
{
	public var icons:Array<SpinIcon> = [];

	public static inline var WHEEL_HEIGHT:Float = (IconSprite.ICON_SIZE + PlayState.GRID_SPACING) * 7;

	public function new(X:Float, Y:Float, Wheel:Int):Void
	{
		super(X, Y);

		ID = Wheel;

		trace(y);

		for (i in 0...7)
		{
			var icon = new SpinIcon(i, this);
			icon.icon = "blank";
			icon.visible = true;
			icons.push(icon);
			add(icon);

			trace(icon.parent.ID, icon.ID, icon.pos, icon.icon, icon.y);
		}
	}

	public function start(Time:Float):Void
	{
		trace(y);
		for (i in icons)
		{
			trace(i.parent.ID, i.ID, i.y, i.icon);
			i.start();

			// FlxTween.tween(i, {pos: 1}, .25, {
			// 	type: FlxTweenType.ONESHOT,
			// 	ease: FlxEase.sineIn,
			// 	onComplete: (_) ->
			// 	{
			// 		FlxTween.tween(i, {pos: (Time * 4) + 1.5}, Time, {
			// 			type: FlxTweenType.ONESHOT,
			// 			ease: FlxEase.linear,
			// 			onComplete: (_) ->
			// 			{
			// 				var icon:String = "";
			// 				var iconID:Int = -1;

			// 				if (i.ID > 0 && i.ID < 6)
			// 				{
			// 					iconID = (i.parent.ID * 5) + i.ID - 1;

			// 					icon = Globals.PlayState.collection[iconID].name;
			// 				}
			// 				else
			// 				{
			// 					icon = Globals.PlayState.getIconName(FlxG.random.int(0, Globals.PlayState.collection.length - 1));
			// 				}

			// 				i.icon = icon;

			// 				trace(i.parent.ID, i.ID, i.y, i.icon);

			// 				FlxTween.tween(i, {pos: (Time * 4) + 2}, .25, {
			// 					type: FlxTweenType.ONESHOT,
			// 					ease: FlxEase.backOut,
			// 					onComplete: (_) -> {
			// 						// i.ending = true;
			// 					}
			// 				});
			// 			}
			// 		});
			// 	}
			// });
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}

class SpinIcon extends FlxSprite
{
	public var parent:Wheel;

	public var icon(get, set):String;

	public var started:Bool = false;

	public var pos(default, set):Float = 0;

	public var rate:Float = .1;

	public var slowing:Bool = false;

	public function new(Id:Int, Parent:Wheel):Void
	{
		super(0, 0);

		ID = Id;

		parent = Parent;

		frames = GraphicsCache.loadGraphicFromAtlas('assets/images/icons-128.png', 'assets/images/icons-128.xml', false, 'icons-icons-128').atlasFrames;

		icon = "blank";
	}

	public function start():Void
	{
		pos = 0;
		rate = .1;
		started = true;
		slowing = false;
	}

	private function set_pos(Value:Float):Float
	{
		pos = Value;

		var ty:Float = parent.y + ((ID - 1) * (IconSprite.ICON_SIZE + PlayState.GRID_SPACING)) + (pos * Wheel.WHEEL_HEIGHT);

		while (ty >= parent.y + Wheel.WHEEL_HEIGHT)
		{
			ty -= Wheel.WHEEL_HEIGHT + (IconSprite.ICON_SIZE + PlayState.GRID_SPACING);
		}

		y = ty;

		return pos;
	}

	private function set_icon(Value:String):String
	{
		if (Value == "blank")
			color = Colors.GRAY;
		else
			color = Colors.BLACK;

		// color = Colors.ORANGE;
		// alpha = .66;

		animation.frameName = Value;

		return animation.frameName;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (started)
		{
			pos += elapsed * rate;
			if (rate < 5 && !slowing)
				rate *= 5;
			else if (pos >= ((parent.ID + 1.5)) + .66)
			{
				if (!slowing)
				{
					slowing = true;

					var iconID:Int = -1;

					if (ID > 0 && ID < 6)
					{
						iconID = (parent.ID * 5) + ID - 1;

						icon = Globals.PlayState.collection[iconID].name;
					}
					else
					{
						icon = Globals.PlayState.getIconName(FlxG.random.int(0, Globals.PlayState.collection.length - 1));
					}

					// trace(parent.ID, ID, pos, y, icon, (parent.ID * 5) + ID - 1);
				}
				rate -= .25;
				if (rate < .15)
					rate = .15;
				if (pos >= ((parent.ID + 2)) + 1.025)
				{
					slowing = started = false;
					pos = 0;
					trace(parent.ID, ID, pos, y, icon);
				}
			}

			// trace(parent.ID, ID, y, icon);
		}
	}

	private function get_icon():String
	{
		return animation.frameName;
	}
}
