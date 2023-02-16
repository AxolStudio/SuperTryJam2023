package ui;

import axollib.TitleCase.Roman;
import flixel.util.FlxColor;
import globals.Globals;
import haxe.ui.containers.Box;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.VBox;

class TechDisplay extends ScrollView
{
	public var vbox:VBox;

	public var txts:Map<Int, GameText> = [];
	public var boxes:Map<Int, Box> = [];

	public function new(Width:Float, Height:Float):Void
	{
		super();
		width = Width;
		height = Height;
		percentContentWidth = 100;

		vbox = new VBox();
		vbox.width = width;
		vbox.padding = 10;
		vbox.styleString = "spacing:10px;";

		addComponent(vbox);

		var txt:GameText;
		var box:Box;

		for (a in 1...(Globals.PlayState.age + 1))
		{
			box = new Box();
			box.width = width;

			txt = new GameText(0, 0, Std.int(width - 40), "Age " + Roman.arabic2Roman(a), FlxColor.BLACK, SIZE_24);
			txt.alignment = "center";

			box.height = txt.height;

			box.add(txt);

			vbox.addComponent(box);

			box = new Box();
			box.width = width;
			txt = new GameText(0, 0, Std.int(width - 40), "", FlxColor.BLACK, SIZE_36);
			txt.alignment = "left";

			box.height = txt.height;

			box.add(txt);
			txts.set(a, txt);
			boxes.set(a, box);

			vbox.addComponent(box);
		}
	}

	public function addTech(Age:Int, NewTech:String):Void
	{
		var txt:GameText = txts.get(Age);
		txt.text += '{{$NewTech}}';
		var box:Box = boxes.get(Age);
		box.height = txt.height;
	}
}
