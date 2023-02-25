package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import states.GameState;

using flixel.util.FlxSpriteUtil;

class GameOverState extends GameSubState
{
	public var menuButton:GameButton;
	public var restartButton:GameButton;

	override public function create():Void
	{
		bgColor = FlxColor.TRANSPARENT;

		var background:FlxSprite = new FlxSprite();

		background.makeGraphic(Math.floor(FlxG.width * .66), Math.floor(FlxG.height * .5), FlxColor.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, FlxColor.WHITE);
		background.screenCenter();
		add(background);

		var title:GameText = new GameText(0, 0, 500, "Game Over!", FlxColor.BLACK, SIZE_36);
		title.alignment = "center";
		title.screenCenter(FlxAxes.X);
		title.y = background.y + 10;
		add(title);

		var subtitle:GameText = new GameText(0, 0, 500, "Your civilization has died out!", FlxColor.BLACK, SIZE_24);
		subtitle.alignment = "center";
		subtitle.screenCenter(FlxAxes.X);
		subtitle.y = title.y + title.height + 10;
		add(subtitle);

		menuButton = new GameButton(0, 0, "Main Menu", onMenu, 250, 50, SIZE_24, FlxColor.MAGENTA, FlxColor.BLACK, FlxColor.WHITE, FlxColor.BLACK);
		menuButton.screenCenter(FlxAxes.X);
		menuButton.x -= menuButton.width + 10;
		menuButton.y = background.y + background.height - menuButton.height - 10;
		add(menuButton);

		restartButton = new GameButton(0, 0, "Restart", onRestart, 250, 50, SIZE_24, FlxColor.CYAN, FlxColor.BLACK, FlxColor.WHITE, FlxColor.BLACK);
		restartButton.screenCenter(FlxAxes.X);
		restartButton.x += 10;
		restartButton.y = background.y + background.height - restartButton.height - 10;
		add(restartButton);

		super.create();
	}

	private function onMenu():Void
	{
		menuButton.active = restartButton.active = false;
		// go to the title state!
	}

	private function onRestart():Void
	{
		menuButton.active = restartButton.active = false;
		FlxG.camera.fade(FlxColor.BLACK, 1, false, () ->
		{
			FlxG.resetState();
		});
	}
}
