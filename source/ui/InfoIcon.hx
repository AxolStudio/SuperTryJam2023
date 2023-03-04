package ui;

import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.IconSprite;
import globals.Globals;

class InfoIcon extends GameText
{
	public static var Delays:Map<IconSprite, Int> = [];

	public static inline var TIME_STEP:Float = .5;

	public var source:IconSprite = null;

	public function new():Void
	{
		super(0, 0, 0, "", Colors.CYAN, SIZE_36);
		setBorderStyle(FlxTextBorderStyle.OUTLINE, Colors.BLACK, 2);
		alignment = "left";
		autoSize = true;
		allowTooltips = false;
		kill();
	}

	public function transfer(Source:String, Destination:String, Amount:Int = 1, ?Callback:Void->Void):Void
	{
		text = '+ {{$Source}}' + (Amount > 1 ? ' x $Amount' : '');

		var delayAmt:Int = 0;

		drawFrame();
		alpha = 0;

		var from:GameText = getTarget(Source);

		color = resourceColors(Source);

		if (Destination != "")
		{
			var target:GameText = getTarget(Destination);

			reset(from.x + (from.width / 2) - (width / 2), from.y + (from.height / 2) - (height / 2));
			FlxTween.tween(this, {alpha: 1, y: y - 64}, TIME_STEP * .33, {
				startDelay: delayAmt * TIME_STEP * 2,
				type: FlxTweenType.ONESHOT,
				onComplete: (_) ->
				{
					FlxTween.tween(this, {x: target.x + (target.width / 2) - (width / 2), y: target.y + (target.height / 2) - (height / 2)}, TIME_STEP * .33, {
						type: FlxTweenType.ONESHOT,
						startDelay: TIME_STEP,
						onComplete: (_) ->
						{
							FlxTween.tween(this, {alpha: 0}, TIME_STEP * .33, {
								type: FlxTweenType.ONESHOT,
								startDelay: TIME_STEP,
								onComplete: (_) ->
								{
									if (Callback != null)
										Callback();
									kill();
								}
							});
						}
					});
				}
			});
		}
		else
		{
			reset(from.x + (from.width / 2) - (width / 2), from.y + (from.height / 2) - (height / 2));
			FlxTween.tween(this, {alpha: 1, y: y - 64}, TIME_STEP * .33, {
				type: FlxTweenType.ONESHOT,
				startDelay: delayAmt * TIME_STEP * 2,
				onComplete: (_) ->
				{
					FlxTween.tween(this, {alpha: 0, y: y - 64}, TIME_STEP * .33, {
						type: FlxTweenType.ONESHOT,
						startDelay: TIME_STEP,
						onComplete: (_) ->
						{
							if (Callback != null)
								Callback();
							kill();
						}
					});
				}
			});
		}
	}

	public function spawn(Source:IconSprite, Type:String, Amount:Int = 1, FromIcon:Bool = true, ?Callback:Void->Void):Void
	{
		source = Source;
		text = '+ {{$Type}}' + (Amount > 1 ? ' x $Amount' : '');

		var delayAmt:Int = 0;

		if (Delays.exists(source))
		{
			delayAmt = Delays[source] + 1;
			Delays.set(source, delayAmt);
		}
		else
		{
			Delays.set(source, 0);
		}

		drawFrame();
		alpha = 0;

		if (Globals.RESOURCES.contains(Type))
		{
			var target:GameText = getTarget(Type);
			color = resourceColors(Type);

			if (FromIcon)
			{
				reset(Source.x + 64 - (width / 2), Source.y + 64 - (height / 2));
				FlxTween.tween(this, {alpha: 1, y: y - 64}, TIME_STEP * .33, {
					startDelay: delayAmt * TIME_STEP * 2,
					type: FlxTweenType.ONESHOT,
					onComplete: (_) ->
					{
						FlxTween.tween(this, {x: target.x + (target.width / 2) - (width / 2), y: target.y + (target.height / 2) - (height / 2)},
							TIME_STEP * .33, {
								type: FlxTweenType.ONESHOT,
								startDelay: TIME_STEP,
								onComplete: (_) ->
								{
									FlxTween.tween(this, {alpha: 0}, TIME_STEP * .33, {
										type: FlxTweenType.ONESHOT,
										startDelay: TIME_STEP,
										onComplete: (_) ->
										{
											if (Callback != null)
												Callback();
											kill();
										}
									});
								}
							});
					}
				});
			}
			else
			{
				reset(target.x, target.y + (target.height / 2) - (height / 2));
				FlxTween.tween(this, {alpha: 1, x: source.x + (source.width / 2) - (width / 2), y: source.y + (source.height / 2) - height - 64},
					TIME_STEP * .33, {
						startDelay: delayAmt * TIME_STEP * 2,
						type: FlxTweenType.ONESHOT,
						onComplete: (_) ->
						{
							FlxTween.tween(this, {y: y + 64}, TIME_STEP * .33, {
								type: FlxTweenType.ONESHOT,
								startDelay: TIME_STEP,
								onComplete: (_) ->
								{
									FlxTween.tween(this, {alpha: 0}, TIME_STEP * .33, {
										type: FlxTweenType.ONESHOT,
										startDelay: .1,
										onComplete: (_) ->
										{
											if (Callback != null)
												Callback();
											kill();
										}
									});
								}
							});
						}
					});
			}
		}
		else
		{
			color = Colors.LIME;
			reset(source.x + (source.width / 2) - (width / 2), source.y + (source.height / 2) - (height / 2));
			FlxTween.tween(this, {alpha: 1, y: y - 64}, TIME_STEP * .33, {
				type: FlxTweenType.ONESHOT,
				startDelay: delayAmt * TIME_STEP * 2,
				onComplete: (_) ->
				{
					FlxTween.tween(this, {alpha: 0, y: y - 64}, TIME_STEP * .33, {
						type: FlxTweenType.ONESHOT,
						startDelay: TIME_STEP,
						onComplete: (_) ->
						{
							if (Callback != null)
								Callback();
							kill();
						}
					});
				}
			});
		}
	}

	public function getTarget(Type:String):GameText
	{
		switch (Type)
		{
			case "food":
				return Globals.PlayState.txtFood;
			case "production":
				return Globals.PlayState.txtProduction;
			case "science":
				return Globals.PlayState.txtScience;
			case "population":
				return Globals.PlayState.txtPopulation;
			case "faith":
				return Globals.PlayState.shrine.faithAmount;
			default:
				return null;
		}
		return null;
	}

	public function resourceColors(Resource:String):FlxColor
	{
		switch (Resource)
		{
			case "food":
				return Colors.PINK;
			case "production":
				return Colors.ORANGE;
			case "science":
				return Colors.CYAN;
			case "population":
				return Colors.DARKBLUE;
			case "faith":
				return Colors.VIOLET;
			default:
				return Colors.WHITE;
		}
	}

	override public function kill():Void
	{
		super.kill();
		var delayAmt:Int = 0;
		if (source != null)
		{
			if (Delays.exists(source))
			{
				delayAmt = Delays[source];
				if (delayAmt > 0)
				{
					Delays.set(source, delayAmt - 1);
				}
				else
				{
					Delays.remove(source);
				}
			}
		}
	}
}
