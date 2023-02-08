package ui;

import flixel.ui.FlxButton;

class Button extends FlxButton
{
	public function new(X:Float, Y:Float, Label:String, OnClick:Void->Void):Void
	{
		super(X, Y, Label, OnClick);
	}
}
