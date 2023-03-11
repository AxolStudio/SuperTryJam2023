package;

import axollib.AxolAPI;
import axollib.DissolveState;
import flixel.FlxGame;
import globals.Globals;
import openfl.display.Sprite;
import states.TitleState;

class Main extends Sprite
{
	public function new()
	{
		super();

		AxolAPI.firstState = TitleState;
		AxolAPI.init = Globals.initGame;

		var game:FlxGame = new FlxGame(0, 0, DissolveState);

		addChild(game);
	}
}
