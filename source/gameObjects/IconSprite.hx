package gameObjects;

import axollib.GraphicsCache;
import flixel.FlxSprite;

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
}
