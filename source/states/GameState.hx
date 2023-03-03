package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import ui.Tooltips;

class GameState extends FlxState
{
	override function create():Void
	{
		FlxG.autoPause = false;
		super.create();
	}

	override function draw()
	{
		super.draw();
		Tooltips.draw();
	}

	override function update(elapsed:Float):Void
	{
		

		if (Tooltips.tooltips.length > 0 && subState == null && alive && exists && visible)
		{
			Tooltips.update(elapsed);
		}
		else
		{
			super.update(elapsed);
		}
	}
}

class GameSubState extends FlxSubState
{
	override function create():Void
	{
		FlxG.autoPause = false;
		super.create();
	}

	override function draw()
	{
		super.draw();
		Tooltips.draw();
	}

	override function update(elapsed:Float):Void
	{
		if (Tooltips.tooltips.length > 0 && alive && exists && visible)
		{
			Tooltips.update(elapsed);
		}
		else
		{
			super.update(elapsed);
		}
	}
}
