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
		super.update(elapsed);

		if (subState == null)
			Tooltips.update(elapsed);
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
		super.update(elapsed);
		Tooltips.update(elapsed);
	}
}
