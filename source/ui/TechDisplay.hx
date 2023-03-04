package ui;

import haxe.ui.containers.Box;
import haxe.ui.containers.HBox;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.VBox;
import axollib.TitleCase.Roman;
import gameObjects.IconSprite;
import globals.Globals;

class TechDisplay extends ScrollView
{
	public var vbox:VBox;

	public var icons:Map<Int, IconSprite> = [];
	public var boxes:Map<Int, Box> = [];
	public var grids:Map<Int, HBox> = [];

	public function new(Width:Float, Height:Float):Void
	{
		super();
		width = Width;
		height = Height;
		percentContentWidth = 100;

		vbox = new VBox();
		vbox.width = width - 20;
		vbox.padding = 10;
		vbox.styleString = "spacing:10px;";

		addComponent(vbox);

		addAge(1);
	}

	public function addAge(Age:Int):Void
	{
		var txt:GameText;
		var box:Box;
		var grid:HBox;

		box = new Box();
		box.width = width;

		txt = new GameText(0, 0, Std.int(width - 40), "Age " + Roman.arabic2Roman(Age), Colors.BLACK, SIZE_24);
		txt.alignment = "center";

		box.height = txt.height;

		box.add(txt);

		vbox.addComponent(box);

		grid = new HBox();

		grid.width = vbox.width - 20;
		grid.padding = 10;
		grid.styleString = "spacing:10px;";
		grid.continuous = true;
		grids.set(Age, grid);

		vbox.addComponent(grid);
	}

	public function addTech(Age:Int, NewTech:String):Void
	{
		var icon:IconSprite = new IconSprite(0, 0, SIZE_64);
		icon.icon = NewTech;
		icon.color = Colors.BLACK;

		var grid:HBox = grids.get(Age);
		var box:Box = new Box();

		box.width = icon.width;
		box.height = icon.height;

		box.add(icon);

		grid.addComponent(box);
	}
}
