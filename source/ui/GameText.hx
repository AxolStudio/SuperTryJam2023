package ui;

import axollib.GraphicsCache;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class GameText extends FlxBitmapText
{
	public static var FONT:FlxBitmapFont;

	public function new(X:Float, Y:Float, FieldWidth:Int, Text:String)
	{
		if (FONT == null)
			GameText.createFont();

		super(FONT);

		x = X;
		y = Y;
		fieldWidth = FieldWidth;
		autoSize = false;
		text = Text;
	}

	public static function createFont():Void
	{
		FONT = cast FlxBitmapFont.fromAngelCode("assets/fonts/basic-font-18.png", "assets/fonts/basic-font-18.xml");
		FONT.appendFrames(GraphicsCache.loadAtlasFrames("assets/images/glyphs.png", "assets/images/glyphs.xml"));
	}
}
