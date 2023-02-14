package ui;

import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

class CurrencyDisplay extends FlxGroup
{
	public var txtLabel:GameText;
	public var txtAmount:GameText;

	public var bar:FlxBar;
	public var max(get, set):Float;
	public var value(default, set):Float = 0;

	public var x(get, set):Float;
	public var y(get, set):Float;

	public var width(get, never):Float;
	public var height(get, never):Float;

	public var label(get, set):String;

	public function new(X:Float, Y:Float, Label:String, Max:Int):Void
	{
		super();

		add(txtLabel = new GameText(X, Y, 200, Label, FlxColor.BLACK, SIZE_24));
		// txtLabel.setFormat(null, 18, 0x000000, "left");

		add(bar = new FlxBar(X + txtLabel.width + 2, Y + 1, FlxBarFillDirection.LEFT_TO_RIGHT, 200, 22, this, "value", 0, Max, true));

		add(txtAmount = new GameText(X + txtLabel.width + 2 + bar.width + 2, Y, 150, "0/" + Std.string(Max), FlxColor.BLACK, SIZE_24));
		// txtAmount.setFormat(null, 18, 0x000000, "left");

		value = 0;
	}

	private function get_x():Float
	{
		return txtLabel.x;
	}

	private function set_x(Value:Float):Float
	{
		txtLabel.x = Value;
		bar.x = txtLabel.x + txtLabel.width + 2;
		txtAmount.x = bar.x + bar.width + 2;

		return Value;
	}

	private function get_y():Float
	{
		return txtLabel.y;
	}

	private function set_y(Value:Float):Float
	{
		txtLabel.y = Value;
		bar.y = txtLabel.y + 1;
		txtAmount.y = txtLabel.y;

		return Value;
	}

	private function get_width():Float
	{
		return txtLabel.width + bar.width + txtAmount.width + 4;
	}

	private function get_height():Float
	{
		return txtLabel.height;
	}

	private function get_label():String
	{
		return txtLabel.text;
	}

	private function set_label(Value:String):String
	{
		txtLabel.text = Value;
		return Value;
	}

	private function get_max():Float
	{
		return bar.max;
	}

	private function set_max(Value:Float):Float
	{
		bar.setRange(0, Value);
		txtAmount.text = Std.string(FlxMath.roundDecimal(value, 0)) + "/" + Std.string(FlxMath.roundDecimal(max, 0));
		return Value;
	}

	private function set_value(Value:Float):Float
	{
		value = Math.min(Value, max);
		txtAmount.text = Std.string(FlxMath.roundDecimal(value, 0)) + "/" + Std.string(FlxMath.roundDecimal(max, 0));
		return value;
	}
}
