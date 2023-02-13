package ui;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxFrame;
import flixel.text.FlxBitmapText;

class GameText extends FlxBitmapText
{
	public static var FONT_22:FlxBitmapFont;
	public static var FONT_36:FlxBitmapFont;

	public var currLetter:Int = -1;
	public var tooltipLetter:Int = -1;

	public function new(X:Float, Y:Float, FieldWidth:Int, Text:String, ?WhichFont:WhichFont = SIZE_22)
	{
		if (FONT_22 == null || FONT_36 == null)
			GameText.createFonts();
		
		var font:FlxBitmapFont = switch (WhichFont)
		{
			case SIZE_22: FONT_22;
			case SIZE_36: FONT_36;
		}

		super(font);

		x = X;
		y = Y;
		fieldWidth = FieldWidth;
		autoSize = false;
		text = Text;
	}

	public static function createFonts():Void
	{
		FONT_22 = cast FlxBitmapFont.fromAngelCode("assets/fonts/basic-font-22.png", "assets/fonts/basic-font-22.xml");
		FONT_22.appendFrames(GraphicsCache.loadAtlasFrames("assets/images/glyphs-22.png", "assets/images/glyphs-22.xml", true, "glyphs-22"));

		FONT_36 = cast FlxBitmapFont.fromAngelCode("assets/fonts/basic-font-36.png", "assets/fonts/basic-font-36.xml");
		FONT_36.appendFrames(GraphicsCache.loadAtlasFrames("assets/images/glyphs-36.png", "assets/images/glyphs-36.xml", true, "glyphs-36"));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
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
			for (j in 0...textLength)
			{
				dataPos = j * 3;
				if (mouseX >= textDrawData[dataPos + 1] && mouseY >= textDrawData[dataPos + 2])
				{
					charCode = Std.int(textDrawData[dataPos]);
					currFrame = font.getCharFrame(charCode);
					if (mouseX <= textDrawData[dataPos + 1] + currFrame.sourceSize.x
						&& mouseY <= textDrawData[dataPos + 2] + currFrame.sourceSize.y)
					{
						currLetter = dataPos;
						if (charCode >= font.specialStart)
						{
							tooltipLetter = currLetter;
							Tooltips.showTooltip(font.revLookupTable.get(currFrame.name), this);
						}
						return;
					}
				}
			}
		}
	}
}

enum WhichFont
{
	SIZE_22;
	SIZE_36;
}