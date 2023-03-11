package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import globals.Globals.Colors;
import ui.GameButton;
import ui.GameText;

class TitleState extends FlxState
{
	public var playButton:GameButton;
	public var text:GameText;

	override public function create():Void
	{
		bgColor = Colors.BLACK;

		var title:FlxSprite = new FlxSprite(0, 0, "assets/images/title.png");
		title.screenCenter();
		title.y = FlxG.height / 4 - title.height / 2;
		title.alpha = 0;
		add(title);

		text = new GameText(0, 0, FlxG.width, "Made during the 2023 SuperTry Grab Bag Jam  -  ©2023 Axol Studio, LLC", Colors.WHITE, SIZE_24);
		text.alignment = "center";
		text.screenCenter();
		text.y = FlxG.height - text.height - 10;
		text.alpha = 0;
		add(text);

		playButton = new GameButton(0, 0, "Play", onPlay, 240, 60, SIZE_36, Colors.VIOLET, Colors.BLACK, Colors.WHITE, Colors.BLACK, Colors.RED);
		playButton.screenCenter();
		playButton.y = FlxG.height * 3 / 4 - playButton.height / 2;
		playButton.alpha = 0;
		add(playButton);

		super.create();

		FlxG.camera.fade(Colors.BLACK, .33, true, () ->
		{
			FlxTween.tween(title, {alpha: 1}, 1, {
				startDelay: .05,
				type: FlxTweenType.ONESHOT,
				onComplete: (_) ->
				{
					FlxTween.tween(text, {alpha: 1}, 1, {
						startDelay: .05,
						type: FlxTweenType.ONESHOT
					});
					FlxTween.tween(playButton, {alpha: 1}, 1, {
						startDelay: .05,
						type: FlxTweenType.ONESHOT
					});
				}
			});
		});
	}

	private function onPlay():Void
	{
		playButton.active = false;
		FlxG.camera.fade(Colors.BLACK, .33, false, () ->
		{
			FlxG.switchState(new PlayState());
		});
	}
}
