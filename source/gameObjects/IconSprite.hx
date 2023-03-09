package gameObjects;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import globals.Globals.Colors;
import globals.Globals.GlyphType;
import ui.Tooltips;

class IconSprite extends FlxSprite
{
	public static inline var ICON_SIZE:Int = 128;

	public var icon(get, set):String;

	public function new(X:Float, Y:Float, ?Size:IconSize = SIZE_128):Void
	{
		super(X, Y);

		var source:String = switch (Size)
		{
			case SIZE_128:
				"icons-128";
			case SIZE_72:
				"icons-72";
			case SIZE_64:
				"icons-64";
			case SIZE_32:
				"icons-32";
		}

		frames = GraphicsCache.loadGraphicFromAtlas('assets/images/${source}.png', 'assets/images/${source}.xml', false, 'icons-$source').atlasFrames;

		color = Colors.BLACK;

		if (Size == SIZE_128)
			animation.frameName = "blank";
	}

	private function set_icon(Value:String):String
	{
		if (Value == "blank")
			color = Colors.GRAY;
		else
			color = Colors.BLACK;

		animation.frameName = Value;

		return Value;
	}

	private function get_icon():String
	{
		return animation.frameName;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (alive)
			if (FlxG.mouse.overlaps(this))
				Tooltips.showTooltip(icon, this);
	}

	public function activate():Void
	{
		FlxTween.cancelTweensOf(this);
		FlxTween.shake(this, 0.05, 0.05, FlxAxes.X);
	}
}

class FakeIcon extends IconSprite
{
	public function new():Void
	{
		super(0, 0);
		kill();
	}

	public function spawn(Source:IconSprite):Void
	{
		reset(Source.x, Source.y);
		icon = Source.icon;
		Source.icon = "blank";
		acceleration.y = 4000;
		velocity.y = -500;
		angularVelocity = velocity.x = FlxG.random.float(-5, 5) * 50;
		alive = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (y > FlxG.height)
			kill();
	}
}

enum IconSize
{
	SIZE_128;
	SIZE_72;
	SIZE_64;
	SIZE_32;
}
