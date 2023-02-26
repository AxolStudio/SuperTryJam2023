package ui;

import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import globals.Globals.Colors;

class TimerDisplay extends GameText
{
	public function new(X:Float, Y:Float):Void
	{
		super(X, 0, 118, "0", Colors.WHITE, SIZE_36);

		setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 1);
		alignment = "right";
		drawFrame();
		y = Y - height;
		kill();
	}

	public function show(Value:Int):Void
	{
		text = Std.string(Value);

		revive();
	}

	public function appear(Value:Int):Void
	{
		text = Std.string(Value);
		drawFrame();
		alpha = 0;
		revive();

		FlxTween.tween(this, {alpha: 1}, 0.05);
	}

	public function transition(Value:Int):Void
	{
		drawFrame();
		revive();
		FlxTween.cancelTweensOf(this);
		FlxTween.shake(this, 0.05, 0.1, FlxAxes.X, {
			onComplete: (_) ->
			{
				text = Std.string(Value);
				if (Value <= 0)
					FlxTween.tween(this, {alpha: 0}, 0.05, {onComplete: (_) -> kill()});
			}
		});
	}
}
