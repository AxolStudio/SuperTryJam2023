package states;

import flixel.FlxState;
import flixel.FlxSubState;
import ui.Tooltips;

class GameState extends FlxState
{
	override function draw()
	{
		super.draw();
		Tooltips.draw();
	}

	override function update(elapsed:Float):Void
	{
		if (Tooltips.tooltips.length == 0)
		{
			super.update(elapsed);
		}
		else
		{
			if (subState == null)
				Tooltips.update(elapsed);
		}
	}
}

class GameSubState extends FlxSubState
{
	override function draw()
	{
		super.draw();
		Tooltips.draw();
	}

	override function update(elapsed:Float):Void
	{
		if (Tooltips.tooltips.length == 0)
		{
			super.update(elapsed);
		}
		else
		{
			Tooltips.update(elapsed);
		}
	}
}
