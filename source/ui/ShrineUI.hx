package ui;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.ui.FlxBar;
import gameObjects.IconSprite;
import globals.Globals;

class ShrineUI extends FlxSpriteGroup
{
	public var shrine:IconSprite;
	public var faithAmount:GameText;
	public var faithNeeded:GameText;
	public var faithBar:FlxBar;
	public var spinCount:GameText;
	public var spinBar:FlxBar;

	public var neededAmt(get, set):Int;

	public var spinsNeeded(get, set):Int;

	public function new():Void
	{
		super();

		add(shrine = new IconSprite(0, 0));
		shrine.icon = "shrine";

		add(faithAmount = new GameText(0, 0, 128, "{{faith}} 0", Colors.BLACK, SIZE_24));
		faithAmount.alignment = "center";
		faithAmount.y = shrine.y + shrine.height + 4;

		add(faithBar = new FlxBar(0, faithAmount.y + faithAmount.height + 4, FlxBarFillDirection.LEFT_TO_RIGHT, 128, 8, Globals.PlayState, "faith", 0, 5,
			true));

		add(faithNeeded = new GameText(0, 0, 128, "0 / 0", Colors.VIOLET, SIZE_24));
		faithNeeded.alignment = "center";
		faithNeeded.setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 1);
		faithNeeded.y = faithBar.y + (faithBar.height / 2) - (faithNeeded.height / 2);

		add(spinBar = new FlxBar(0, faithNeeded.y + faithNeeded.height + 4, FlxBarFillDirection.LEFT_TO_RIGHT, 128, 8, Globals.PlayState, "spinsLeft", 0, 5,
			true));
	}

	private function get_neededAmt():Int
	{
		return Std.int(faithBar.max);
	}

	private function set_neededAmt(value:Int):Int
	{
		faithBar.setRange(0, value);
		return Std.int(faithBar.max);
	}

	private function get_spinsNeeded():Int
	{
		return Std.int(spinBar.max);
	}

	private function set_spinsNeeded(value:Int):Int
	{
		spinBar.setRange(0, value);
		return Std.int(spinBar.max);
	}
}
