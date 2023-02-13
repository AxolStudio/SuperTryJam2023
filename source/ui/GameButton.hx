package ui;

import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class GameButton extends FlxTypedButton<GameText>
{
	public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void, ?Width:Float = 80, ?Height:Float = 20,
			?WhichFont:GameText.WhichFont = GameText.WhichFont.SIZE_24, ?Color:FlxColor = FlxColor.BLUE, ?BorderColor:FlxColor = FlxColor.BLACK,
			?TextColor:FlxColor = FlxColor.WHITE, ?TextBorderColor:FlxColor = FlxColor.BLACK):Void
	{
		super(X, Y, OnClick);

		for (a in 0...labelAlphas.length)
			labelAlphas[a] = 1;

		makeGraphic(Std.int(Width), Std.int(Height), BorderColor, true);

		this.drawRect(2, 2, Width - 4, Height - 4, Color);

		initLabel(Text, Width, WhichFont, TextColor, TextBorderColor);

		for (point in labelOffsets)
			point.set((width / 2) - (label.width / 2), (height / 2) - (label.height / 2));

		labelOffsets[FlxButton.HIGHLIGHT].y += 1;
	}

	function initLabel(Text:String, ?Width:Float = 80, ?WhichFont:GameText.WhichFont = GameText.WhichFont.SIZE_24, ?TextColor:FlxColor = FlxColor.WHITE,
			?TextBorderColor:FlxColor = FlxColor.BLACK):Void
	{
		if (Text != null)
		{
			label = new GameText(0, 0, Std.int(Width), Text, TextColor, WhichFont);

			//label.setBorderStyle(FlxTextBorderStyle.OUTLINE, TextBorderColor, 1);
			label.alignment = "center";
			//label.alpha = labelAlphas[status];
			label.drawFrame(true);
		}
	}

	override function resetHelpers():Void
	{
		super.resetHelpers();

		if (label != null)
		{
			label.fieldWidth = label.frameWidth = Std.int(width);
			// label.size = label.size; // Calls set_size(), don't remove!
		}
	}

	inline function get_text():String
	{
		return (label != null) ? label.text : null;
	}

	inline function set_text(Text:String):String
	{
		if (label == null)
		{
			initLabel(Text);
		}
		else
		{
			label.text = Text;
		}
		return Text;
	}
}
