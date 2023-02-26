package ui;

import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxTween;
import gameObjects.IconSprite;
import globals.Globals;

class ResGenText extends GameText
{
	public var type:ResourceType;

	public function new():Void
	{
		super(0, 0, 0, "", Colors.LIME, SIZE_36);
		setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 1);
		alignment = "left";
		autoSize = true;
		kill();
	}

	public function spawn(Source:IconSprite, Type:ResourceType, Amount:Int):Void
	{
		type = Type;
		text = getIcon(Type) + ' +$Amount';
		color = Colors.LIME;
		drawFrame();
		reset(Source.x + 64 - (width / 2), Source.y + 64 - (height / 2));
		alpha = 0;
		FlxTween.tween(this, {alpha: 1, y: y - 64}, .15, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				var target:GameText = getTarget(type);
				FlxTween.tween(this, {x: target.x, y: target.y + (target.height / 2) - (height / 2)}, .15, {
					type: FlxTweenType.ONESHOT,
					startDelay: .25,
					onComplete: (_) ->
					{
						FlxTween.tween(this, {alpha: 0}, .15, {type: FlxTweenType.ONESHOT, startDelay: .1, onComplete: (_) -> kill()});
					}
				});
			}
		});
	}

	public function reverseSpawn(Target:IconSprite, Type:ResourceType, Amount:Int):Void
	{
		type = Type;
		text = getIcon(Type) + ' -$Amount';
		color = Colors.RED;
		drawFrame();
		var source:GameText = getTarget(type);
		reset(source.x, source.y + (source.height / 2) - (height / 2));
		alpha = 0;
		FlxTween.tween(this, {alpha: 1, x: Target.x + (Target.width / 2) - (width / 2), y: Target.y + (Target.height / 2) - height - 64}, .15, {
			startDelay: .15,
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				FlxTween.tween(this, {y: y + 64}, .15, {
					type: FlxTweenType.ONESHOT,
					startDelay: .25,
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
			case population:
				return Globals.PlayState.txtPopulation;
		}
		return null;
	}
}

enum abstract ResourceType(String) from String to String
{
	var food;
	var production;
	var science;
	var population;
}
