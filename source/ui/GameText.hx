package ui;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxFrame;
import flixel.text.FlxBitmapText;

class GameText extends FlxBitmapText
{
	public static var FONT:FlxBitmapFont;

	public var currLetter:Int = -1;

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
							Tooltips.showTooltip(font.revLookupTable.get(currFrame.name), this);
						return;
					}
				}
			}
		}
	}
}
