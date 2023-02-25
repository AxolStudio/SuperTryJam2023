package ui;

import haxe.ui.containers.HBox;
import haxe.ui.containers.ScrollView;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import states.GameState;

using flixel.util.FlxSpriteUtil;

class LogState extends GameSubState
{
	public var scrollZone:ScrollView;
	public var scrollGrid:HBox;

	override public function create():Void
	{
		bgColor = FlxColor.TRANSPARENT;

		var background:FlxSprite = new FlxSprite();
		background.makeGraphic(Math.floor(FlxG.width * .6), Math.floor(FlxG.height * .9), FlxColor.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, FlxColor.WHITE);
		background.screenCenter();
		add(background);

		var title:GameText = new GameText(0, 0, 500, "Spin Log", FlxColor.BLACK, SIZE_36);
		title.alignment = "center";
		title.screenCenter(FlxAxes.X);
		title.y = background.y + 10;
		add(title);

		var closeButton:GameButton = new GameButton(background.x + background.width - 42, background.y + 8, "X", onClose, 32, 32, SIZE_36, FlxColor.RED,
			FlxColor.BLACK, FlxColor.WHITE, FlxColor.BLACK);
		add(closeButton);

		scrollZone = new ScrollView();
		scrollZone.width = background.width - 24;
		scrollZone.height = background.height - title.height - 20;
		scrollZone.x = background.x + 12;
		scrollZone.y = title.y + title.height + 10;
		scrollZone.percentContentWidth = 100;
		// scrollZone.scrollMode = ScrollMode.NORMAL;

		add(scrollZone);

		scrollGrid = new HBox();
		scrollGrid.width = scrollZone.width;
		scrollGrid.continuous = false;
		scrollGrid.padding = 10;
		scrollGrid.styleString = "spacing:10px;";

		scrollZone.addComponent(scrollGrid);

		super.create();
	}

	private function onClose():Void
	{
		close();
	}
}
