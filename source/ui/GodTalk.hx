package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import globals.Globals;
import states.GameState.GameSubState;

using StringTools;
using flixel.util.FlxSpriteUtil;

class GodTalk extends GameSubState
{
	public var speech:TypingText;

	public var whichText:String = "";

	public var textPart:Int = 0;

	public var advance:FlxSprite;

	public var background:FlxSprite;

	public function new(WhichText:String = ""):Void
	{
		super();

		whichText = WhichText;
	}

	override public function create():Void
	{
		bgColor = Colors.TRANSPARENT;

		background = new FlxSprite();

		background.makeGraphic(Math.floor(FlxG.width * .8), Math.floor(FlxG.height * .25), Colors.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, Colors.WHITE);
		background.screenCenter();
		background.y = 20;
		add(background);

		add(speech = new TypingText(Std.int(background.x + 20), Std.int(background.y + 20), Std.int(background.width - 40), Colors.BLACK, GOD_TALK,
			"assets/sounds/god_talk_0"));

		add(advance = new FlxSprite("assets/images/advance.png"));
		advance.x = background.x + background.width - advance.width - 20;
		advance.y = background.y + background.height - advance.height - 20;
		advance.color = Colors.BLACK;
		advance.kill();

		FlxG.sound.play("assets/sounds/god_appear.ogg", 1, false);

		speech.showText(parse(Globals.PlayState.GodSpeeches[whichText].texts[textPart]), finishText);

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (advance.alive && (FlxG.keys.anyJustPressed([SPACE, ENTER, X]) || FlxG.mouse.justPressed))
		{
			FlxG.sound.play("assets/sounds/god_advance.ogg", 1, false);
			nextText();
		}
	}

	public function finishText():Void
	{
		advance.y = background.y + background.height - advance.height - 20;
		advance.revive();
		FlxTween.tween(advance, {y: advance.y - 10}, 0.5, {type: FlxTweenType.PINGPONG});
	}

	public function nextText():Void
	{
		textPart++;
		advance.kill();
		FlxTween.cancelTweensOf(advance);

		if (Globals.PlayState.GodSpeeches[whichText].texts.length > textPart)
		{
			speech.showText(parse(Globals.PlayState.GodSpeeches[whichText].texts[textPart]), finishText);
		}
		else
		{
			close();
		}
	}
	public function parse(Text:String):String
	{
		return Text.replace("$need", Std.string(Globals.PlayState.shrine.neededAmt));
	}
}
