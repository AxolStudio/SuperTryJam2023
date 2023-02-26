package ui;

import haxe.ui.containers.Box;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.VBox;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import globals.Globals;
import states.GameState;

using flixel.util.FlxSpriteUtil;

class LogState extends GameSubState
{
	public var scrollZone:ScrollView;
	public var scrollGrid:VBox;

	override public function create():Void
	{
		bgColor = Colors.TRANSPARENT;

		var background:FlxSprite = new FlxSprite();
		background.makeGraphic(Math.floor(FlxG.width * .6), Math.floor(FlxG.height * .9), Colors.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, Colors.WHITE);
		background.screenCenter();
		add(background);

		var title:GameText = new GameText(0, 0, 500, "Spin Log", Colors.BLACK, SIZE_36);
		title.alignment = "center";
		title.screenCenter(FlxAxes.X);
		title.y = background.y + 10;
		add(title);

		var closeButton:GameButton = new GameButton(background.x + background.width - 42, background.y + 8, "X", onClose, 32, 32, SIZE_36, Colors.RED,
			Colors.BLACK, Colors.WHITE, Colors.BLACK);
		add(closeButton);

		scrollZone = new ScrollView();
		scrollZone.width = background.width - 24;
		scrollZone.height = background.height - title.height - 20;
		scrollZone.x = background.x + 12;
		scrollZone.y = title.y + title.height + 10;
		scrollZone.percentContentWidth = 100;
		// scrollZone.scrollMode = ScrollMode.NORMAL;

		add(scrollZone);

		scrollGrid = new VBox();
		scrollGrid.width = scrollZone.width - 20;
		scrollGrid.padding = 10;
		scrollGrid.styleString = "spacing:10px;";

		scrollZone.addComponent(scrollGrid);

		var entryBox:Box;
		var entryText:GameText;

		for (l in Globals.PlayState.log)
		{
			entryText = new GameText(0, 0, Std.int(scrollGrid.width), l, Colors.BLACK, SIZE_24);

			entryBox = new Box();
			entryBox.width = scrollGrid.width;
			entryBox.height = entryText.height;
			entryBox.add(entryText);

			scrollGrid.addComponent(entryBox);
		}

		scrollZone.vscrollPos = scrollZone.vscrollMax;

		super.create();
	}

	private function onClose():Void
	{
		close();
	}
}
