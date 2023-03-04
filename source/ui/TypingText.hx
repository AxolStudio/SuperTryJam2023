package ui;

import flixel.FlxG;
import flixel.util.FlxColor;
import globals.Globals.Colors;
import ui.GameText.WhichFont;

class TypingText extends GameText
{
	private var letters:Array<String> = [];
	private var newText:String = "";
	private var timer:Float = -5;

	public var whichFont:WhichFont;

	private static inline var LETTERS_PER_SEC:Float = 0.025;

	private var curLine:Int = -1;

	private var tmpText:GameText;

	public var showing:Bool = false;

	public var callback:Void->Void = null;

	public function new(X:Float, Y:Float, FieldWidth:Int, ?Color:FlxColor = Colors.BLACK, ?WhichFont:WhichFont = SIZE_24):Void
	{
		super(X, Y, FieldWidth, "", Color, WhichFont);

		whichFont = WhichFont;

		autoSize = false;
		multiLine = true;
	}

	public function showText(Text:String, ?Callback:Void->Void):Void
	{
		callback = Callback;
		curLine = 0;
		clearText();
		newText = "";

		tmpText = new GameText(0, 0, fieldWidth, Text, Colors.BLACK, whichFont);
		tmpText.autoSize = false;
		tmpText.multiLine = true;
		tmpText.updateText();

		for (l in curLine...Std.int(Math.min(curLine + 10, tmpText._lines.length)))
		{
			newText += tmpText._lines[l] + "\n";
		}
		curLine += Std.int(Math.min(curLine + 10, tmpText._lines.length));

		showing = true;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (showing)
		{
			var newChar:String = "";
			timer -= elapsed;

			if (text.length < newText.length)
			{
				if ((FlxG.keys.anyJustPressed([SPACE, ENTER, X]) || FlxG.mouse.justPressed))
				{
					text = newText;
					timer = -5;
					return;
				}
				if (timer <= 0)
				{
					if (newText.charCodeAt(text.length) == 92)
					{
						newChar = newText.substr(text.length, 2);
					}
					else
					{
						newChar = newText.substr(text.length, 1);
					}
					text += newChar;

					if (newChar == "." || newChar == "!" || newChar == "?")
						timer = LETTERS_PER_SEC * 4;
					else
						timer = LETTERS_PER_SEC;
				}
			}
			else
			{
				showing = false;
				if (callback != null)
					callback();
			}
		}
	}

	public function clearText():Void
	{
		text = "";
	}
}
