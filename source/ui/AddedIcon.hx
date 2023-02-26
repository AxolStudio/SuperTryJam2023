package ui;

import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxTween;
import gameObjects.IconSprite;
import globals.Globals.Colors;

class AddedIcon extends GameText
{
	// TODO: delay all new pop-ups for the same icon!
	public static var Delays:Map<Int, Int> = [];

	public function new():Void
	{
		super(0, 0, 0, "", Colors.CYAN, SIZE_36);
		setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 1);
		alignment = "left";
		autoSize = true;
		kill();
	}

	public function spawn(Source:IconSprite, Icon:String, Amount:Int = 1):Void
	{
		text = '+{{$Icon}}' + (Amount > 1 ? ' x$Amount' : '');
		drawFrame();
		reset(Source.x + 64 - (width / 2), Source.y + 64 - (height / 2));
		alpha = 0;

		FlxTween.tween(this, {alpha: 1, y: y - 64}, 0.15, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				FlxTween.tween(this, {alpha: 0, y: y - 64}, 0.15, {
					type: FlxTweenType.ONESHOT,
					startDelay: .25,
					onComplete: (_) -> kill()
				});
			}
		});
	}
}
