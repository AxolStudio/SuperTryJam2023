package gameObjects;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import globals.Globals.GlyphType;
import ui.Tooltips;

class IconSprite extends FlxSprite
{
	public static inline var ICON_SIZE:Int = 128;

	public var icon(get, set):String;

	public function new(X:Float, Y:Float):Void
	{
		super(X, Y);

		frames = GraphicsCache.loadGraphicFromAtlas("assets/images/icons.png", "assets/images/icons.xml", false, "icons").atlasFrames;

		animation.frameName = "blank";
	}

	private function set_icon(Value:String):String
	{
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
		FlxTween.shake(this, 0.05, 0.1, FlxAxes.X);
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
