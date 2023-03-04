package ui;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxFrame;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import globals.Globals.Colors;

class GameText extends FlxBitmapText
{
	public static var FONT_24:FlxBitmapFont;
	public static var FONT_36:FlxBitmapFont;

	public static var GOD_FONT:FlxBitmapFont;

	public var currLetter:Int = -1;
	public var tooltipLetter:Int = -1;

	public var allowTooltips:Bool = true;

	public function new(X:Float, Y:Float, FieldWidth:Int, Text:String, ?Color:FlxColor = Colors.BLACK, ?WhichFont:WhichFont = SIZE_24)
	{
		if (FONT_24 == null || FONT_36 == null)
			GameText.createFonts();

		var font:FlxBitmapFont = switch (WhichFont)
		{
			case SIZE_24: FONT_24;
			case SIZE_36: FONT_36;
			case GOD_TALK: GOD_FONT;
		}

		super(font);

		x = X;
		y = Y;
		fieldWidth = FieldWidth;
		autoSize = false;
		text = Text;
		color = Color;
	}

	public static function createFonts():Void
	{
		FONT_24 = cast FlxBitmapFont.fromAngelCode("assets/fonts/font-24.png", "assets/fonts/font-24.xml");
		FONT_24.appendFrames(GraphicsCache.loadAtlasFrames("assets/images/glyphs-24.png", "assets/images/glyphs-24.xml", true, "glyphs-24"));

		FONT_36 = cast FlxBitmapFont.fromAngelCode("assets/fonts/font-36.png", "assets/fonts/font-36.xml");
		FONT_36.appendFrames(GraphicsCache.loadAtlasFrames("assets/images/glyphs-36.png", "assets/images/glyphs-36.xml", true, "glyphs-36"));

		GOD_FONT = cast FlxBitmapFont.fromAngelCode("assets/fonts/god-font-36.png", "assets/fonts/god-font-36.xml");
		// GOD_FONT.appendFrames(GraphicsCache.loadAtlasFrames("assets/images/glyphs-36.png", "assets/images/glyphs-36.xml", true, "god-glyphs-36"));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (allowTooltips && visible)
			checkMouse();
	}

	public function checkMouse():Void
	{
		if (FlxG.mouse.overlaps(this))
		{
			// get the mouses position relative to the text
			var mouseX:Float = FlxG.mouse.x - x;
			var mouseY:Float = FlxG.mouse.y - y;

			// get the character index at the mouse position
			var textLength:Int = Std.int(textDrawData.length / 3);
			var dataPos:Int = 0;
			var currFrame:FlxFrame;
			var charCode:Int;
			currLetter = -1;

			// for each letter in the text's string...
			for (j in 0...textLength)
			{
				// textDrawData uses 3 slots per letter - the character code, x pos, and y pos
				dataPos = j * 3;

				// get the letter's character code
				charCode = Std.int(textDrawData[dataPos]);

				// if it is one of our special characters...
				if (charCode >= font.specialStart)
				{
					// check if the mouse is 'after' the starting pos (x, y) of the letter...
					if (mouseX >= textDrawData[dataPos + 1] && mouseY >= textDrawData[dataPos + 2])
					{
						// get the letter's frame size

						currFrame = font.getCharFrame(charCode);
						// check that we are also 'before' the end pos(x+width, y+height) of the letter
						if (mouseX <= textDrawData[dataPos + 1] + currFrame.sourceSize.x
							&& mouseY <= textDrawData[dataPos + 2] + currFrame.sourceSize.y)
						{
							// we are over a letter that is a special character - show a tooltip!
							currLetter = dataPos;
							tooltipLetter = currLetter;
							Tooltips.showTooltip(font.revLookupTable.get(currFrame.name), this);
							return;
						}
					}
				}
			}
		}
	}
}

enum WhichFont
{
	SIZE_24;
	SIZE_36;
	GOD_TALK;
}
