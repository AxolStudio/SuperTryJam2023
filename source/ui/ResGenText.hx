package ui;

import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.IconSprite;
import globals.Globals;

class ResGenText extends GameText
{
	public var type:ResourceType;

	public function new():Void
	{
		super(0, 0, 100, "", FlxColor.LIME, SIZE_36);
		setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		alignment = "left";
		kill();
	}

	public function spawn(Source:IconSprite, Type:ResourceType, Amount:Int):Void
	{
		type = Type;
		text = getIcon(Type) + ' +$Amount';

		reset(Source.x + 64 - (width / 2), Source.y + 64 - (height / 2));
		alpha = 0;
		FlxTween.tween(this, {alpha: 1, y: y - 64}, .15, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				var target:GameText = getTarget(type);
				FlxTween.tween(this, {x: target.x, y: target.y + (target.height / 2) - (height / 2)}, .15, {
					type: FlxTweenType.ONESHOT,
					startDelay: .1,
					onComplete: (_) ->
					{
						FlxTween.tween(this, {alpha: 0}, .15, {type: FlxTweenType.ONESHOT, startDelay: .1, onComplete: (_) -> kill()});
					}
				});
			}
		});
	}

	public function getIcon(Type:ResourceType):String
	{
		return '{{$Type}}';
	}

	public function getTarget(Type:ResourceType):GameText
	{
		switch (Type)
		{
			case food:
				return Globals.PlayState.txtFood;
			case production:
				return Globals.PlayState.txtProduction;
			case science:
				return Globals.PlayState.txtScience;
		}
		return null;
	}
}

enum abstract ResourceType(String) from String to String
{
	var food;
	var production;
	var science;
}
