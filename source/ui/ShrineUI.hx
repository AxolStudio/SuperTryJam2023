package ui;

import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxBar;
import gameObjects.IconSprite;
import globals.Globals.Colors;

class ShrineUI extends FlxSpriteGroup
{
	public var shrine:IconSprite;
	public var faithAmount:GameText;
	public var faithNeeded:GameText;
	public var faithBar:FlxBar;
	public var spinCount:GameText;
	public var spinBar:FlxBar;

	public function new():Void
	{
		super();

		add(shrine = new IconSprite(0, 0));
		shrine.icon = "shrine";

		add(faithAmount = new GameText(0, 0, 128, "{{faith}} 0", Colors.BLACK, SIZE_24));
	}
}
