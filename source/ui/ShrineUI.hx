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

	public var faith(default, set):Int = 0;
	public var spins(default, set):Int = 0;

	public function new():Void
	{
		super();

		add(shrine = new IconSprite(64, 0));
		shrine.icon = "shrine";

		add(faithAmount = new GameText(0, 0, 256, "0 {{faith}}", Colors.BLACK, SIZE_36));
		faithAmount.alignment = "center";
		faithAmount.y = shrine.y + shrine.height + 10;

		add(faithBar = new FlxBar(0, faithAmount.y + faithAmount.height + 10, FlxBarFillDirection.LEFT_TO_RIGHT, 256, 30, Globals.PlayState, "faith", 0, 1,
			true));
		faithBar.createFilledBar(Colors.GRAY, Colors.VIOLET, true, Colors.BLACK);

		add(faithNeeded = new GameText(0, 0, 256, "0 / 0", Colors.WHITE, SIZE_24));
		faithNeeded.alignment = "center";
		faithNeeded.setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 1);
		faithNeeded.y = faithBar.y + (faithBar.height / 2) - (faithNeeded.height / 2);

		add(spinBar = new FlxBar(0, faithNeeded.y + faithNeeded.height + 10, FlxBarFillDirection.LEFT_TO_RIGHT, 256, 30, Globals.PlayState, "spinsLeft", 0, 5,
			true));
		spinBar.createFilledBar(Colors.GRAY, Colors.RED, true, Colors.BLACK);

		add(spinCount = new GameText(0, 0, 256, "0 / 0", Colors.WHITE, SIZE_24));
		spinCount.alignment = "center";
		spinCount.setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 1);
		spinCount.y = spinBar.y + (spinBar.height / 2) - (spinCount.height / 2);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	private function set_spins(Value:Int):Int
	{
		spins = Value;
		spinCount.text = '{{spin count}} $spins / ' + Std.int(spinBar.max);
		return Value;
	}

	private function set_faith(Value:Int):Int
	{
		faith = Value;
		faithAmount.text = '$faith {{faith}}';
		faithNeeded.text = '$faith / ' + Std.int(faithBar.max);
		return Value;
	}

	private function get_neededAmt():Int
	{
		return Std.int(faithBar.max);
	}

	private function set_neededAmt(value:Int):Int
	{
		faithBar.setRange(0, value);
		faithNeeded.text = '$faith / ' + Std.int(faithBar.max);
		return Std.int(faithBar.max);
	}

	private function get_spinsNeeded():Int
	{
		return Std.int(spinBar.max);
	}

	private function set_spinsNeeded(value:Int):Int
	{
		spinBar.setRange(0, value);
		spinCount.text = '{{spin count}} $spins / ' + Std.int(spinBar.max);
		return Std.int(spinBar.max);
	}
}
