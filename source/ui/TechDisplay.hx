package ui;

import axollib.TitleCase.Roman;
import flixel.util.FlxColor;
import gameObjects.IconSprite;
import globals.Globals;
import haxe.ui.containers.Box;
import haxe.ui.containers.Grid;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.VBox;

class TechDisplay extends ScrollView
{
	public var vbox:VBox;

	public var icons:Map<Int, IconSprite> = [];
	public var boxes:Map<Int, Box> = [];
	public var grids:Map<Int, Grid> = [];

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
		var grid:Grid;

		for (a in 1...(Globals.PlayState.age + 1))
		{
			box = new Box();
			box.width = width;

			txt = new GameText(0, 0, Std.int(width - 40), "Age " + Roman.arabic2Roman(a), FlxColor.BLACK, SIZE_24);
			txt.alignment = "center";

			box.height = txt.height;

			box.add(txt);

			vbox.addComponent(box);

			grid = new Grid();

			grid.width = vbox.width;
			grid.padding = 10;
			grid.styleString = "spacing:10px;";
			grids.set(a, grid);

			vbox.addComponent(grid);

			// box = new Box();

			// // txt = new GameText(0, 0, Std.int(width - 40), "", FlxColor.BLACK, SIZE_36);
			// // txt.alignment = "left";

			// icon = new IconSprite(0,0,)

			// box.width = icon.width;
			// box.height = icon.height;

			// box.add(icon);
			// icons.set(a, icon);
			// boxes.set(a, box);

			// grid.addComponent(box);
		}
	}

	public function addTech(Age:Int, NewTech:String):Void
	{
		var icon:IconSprite = new IconSprite(0, 0);
		icon.icon = NewTech;
		icon.color = FlxColor.BLACK;

		var grid:Grid = grids.get(Age);
		var box:Box = new Box();

		box.width = icon.width;
		box.height = icon.height;

		box.add(icon);

		grid.addComponent(box);
	}
}
