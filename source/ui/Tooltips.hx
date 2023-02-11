package ui;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameObjects.IconSprite;

using flixel.util.FlxSpriteUtil;

class Tooltips
{
	public static var tooltips:Array<ToolTip> = [];

	public static function draw():Void
	{
		for (t in tooltips)
			t.draw();
	}

	public static function update(elapsed:Float):Void
	{
		for (t in tooltips)
			t.update(elapsed);
	}
}

class ToolTip extends FlxGroup
{
	public var x(get, never):Float;
	public var y(get, never):Float;

	public var width(get, never):Float;
	public var height(get, never):Float;

	public function new(X:Float, Y:Float, Source:String):Void
	{
		super();

		var background:FlxSprite = new FlxSprite(X, Y);

		var icon:IconSprite = new IconSprite(X + 4, Y + 4);
		icon.icon = Source;

		var text:FlxText = new FlxText(X + 4, Y + icon.height + 4, 128, "This is the tooltip!");

		background.makeGraphic(136, Math.ceil(icon.height + 12 + text.height), FlxColor.BLACK);
	}
}
