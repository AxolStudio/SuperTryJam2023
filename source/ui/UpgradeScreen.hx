package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import gameObjects.IconSprite;
import gameObjects.Technology;
import globals.Globals;
import haxe.ui.constants.ScrollMode;
import haxe.ui.containers.Box;
import haxe.ui.containers.Grid;
import haxe.ui.containers.HBox;
import haxe.ui.containers.ScrollView;
import openfl.events.MouseEvent;
import states.GameState.GameSubState;

using axollib.TitleCase;
using flixel.util.FlxSpriteUtil;

class UpgradeScreen extends GameSubState
{
	public var techItems:Array<TechItem>;
	public var scienceAmount:GameText;

	public var scrollZone:ScrollView;
	public var scrollGrid:HBox;

	override public function create():Void
	{
		// simple border with all availble icons to purchase displayed

		// when an icon is clicked, it is added to the player's inventory

		// when the player clicks the "back" button, the shop screen is closed

		bgColor = FlxColor.TRANSPARENT;

		var background:FlxSprite = new FlxSprite();
		background.makeGraphic(Math.floor(FlxG.width * .6), Math.floor(FlxG.height * .9), FlxColor.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, FlxColor.WHITE);
		background.screenCenter();
		add(background);

		var title:GameText = new GameText(0, 0, 500, "Choose Technology to Learn", FlxColor.BLACK, SIZE_36);
		title.alignment = "center";
		title.screenCenter(FlxAxes.X);
		title.y = background.y + 10;
		add(title);

		add(scienceAmount = new GameText(background.x + background.width - 510, 0, 500, "Science: {{science}}" + Std.string(Globals.PlayState.science),
			FlxColor.BLACK, SIZE_36));
		scienceAmount.alignment = "right";
		scienceAmount.y = background.y + background.height - scienceAmount.height - 10;

		scrollZone = new ScrollView();
		scrollZone.width = background.width - 24;
		scrollZone.height = background.height - title.height - scienceAmount.height - 40;
		scrollZone.x = background.x + 12;
		scrollZone.y = title.y + title.height + 10;
		scrollZone.percentContentWidth = 100;
		// scrollZone.scrollMode = ScrollMode.NORMAL;

		add(scrollZone);

		scrollGrid = new HBox();
		scrollGrid.width = scrollZone.width;
		scrollGrid.continuous = true;
		scrollGrid.padding = 10;
		scrollGrid.styleString = "spacing:10px;";

		scrollZone.addComponent(scrollGrid);

		techItems = [];

		var techItem:TechItem;
		var box:Box;
		var collected:Array<String> = Globals.PlayState.technologies.get(Globals.PlayState.age);

		for (k => v in Globals.TechnologiesList)
		{
			if (v.age == Globals.PlayState.age)
			{
				if (collected.contains(k))
					continue;

				box = new Box();

				techItem = new TechItem(this, box);
				techItem.setIcon(k);
				techItems.push(techItem);

				box.width = techItem.width;
				box.height = techItem.height;

				box.add(techItem);
				scrollGrid.addComponent(box);
			}
		}

		var closeButton:GameButton = new GameButton(background.x + background.width - 42, background.y + 8, "X", onClose, 32, 32, SIZE_36, FlxColor.RED,
			FlxColor.BLACK, FlxColor.WHITE, FlxColor.BLACK);
		add(closeButton);

		updateButtons();

		super.create();
	}

	public function onClose():Void
	{
		close();
	}

	public function updateButtons():Void
	{
		var tech:Technology;
		var collected:Array<String> = Globals.PlayState.technologies.get(Globals.PlayState.age);

		for (techItem in techItems)
		{
			tech = Globals.TechnologiesList.get(techItem.icon.icon);
			var hasReq:Bool = true;

			for (req in tech.requires)
			{
				if (!collected.contains(req))
				{
					hasReq = false;
					break;
				}
			}

			trace(tech.requires, collected, hasReq);

			techItem.buyButton.active = Globals.PlayState.science >= tech.scienceCost && hasReq;
		}
		scienceAmount.text = "Science: {{science}}" + Std.string(Globals.PlayState.science);
	}
}

class TechItem extends FlxSpriteGroup
{
	public var icon:IconSprite;

	public var background:FlxSprite;
	public var cost:GameText;
	public var buyButton:GameButton;
	public var title:GameText;

	public var requires:GameText;

	public var parent:UpgradeScreen;
	public var box:Box;

	public static inline var MARGINS:Int = 12;
	public static inline var PADDING:Int = 4;

	public function new(Parent:UpgradeScreen, Box:Box):Void
	{
		super();

		parent = Parent;
		box = Box;

		add(background = new FlxSprite());
		background.makeGraphic(250 + (MARGINS * 2), 300, FlxColor.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, FlxColor.WHITE);

		add(title = new GameText(background.x + MARGINS, background.y + MARGINS, Std.int(background.width - (MARGINS * 2)), "Title", FlxColor.BLACK, SIZE_36));
		title.alignment = "center";

		add(icon = new IconSprite(background.x + (background.width / 2) - 64, title.y + title.height + PADDING));

		add(cost = new GameText(background.x + MARGINS, icon.y + icon.height + PADDING, Std.int(background.width - (MARGINS * 2)), "Cost: {{science}}0",
			FlxColor.BLACK, SIZE_24));
		cost.alignment = "center";

		add(requires = new GameText(background.x + MARGINS, cost.y + cost.height + PADDING, Std.int(background.width - (MARGINS * 2)), "Requires: ",
			FlxColor.BLACK, SIZE_24));
		requires.alignment = "center";

		add(buyButton = new GameButton(background.x + MARGINS, 0, "Learn", onBuy, background.width - (MARGINS * 2), 32, FlxColor.BLUE, FlxColor.BLACK,
			FlxColor.WHITE, FlxColor.BLACK));
		buyButton.active = false;
		buyButton.y = background.y + background.height - buyButton.height - MARGINS;
	}

	public function setIcon(Icon:String):Void
	{
		var tech:Technology = Globals.TechnologiesList.get(Icon);
		icon.icon = Icon;
		cost.text = "Cost: {{science}}" + Std.string(tech.scienceCost);
		title.text = Icon.toTitleCase();

		if (tech.requires.length > 0)
		{
			var req:String = "";
			for (r in tech.requires)
			{
				req += "{{" + r + "}}";
			}
			requires.text = "Requires: " + req;
			requires.visible = true;
		}
		else
		{
			requires.text = "";
			requires.visible = false;
		}
	}

	public function onBuy():Void
	{
		buyButton.active = false;
		// deduct cost from production

		var tech:Technology = Globals.TechnologiesList.get(icon.icon);

		Globals.PlayState.science -= tech.scienceCost;

		// add the new icon to the player's collection
		Globals.PlayState.addTech(tech.name);

		tech.doEffect();

		parent.techItems.remove(this);
		parent.scrollGrid.removeComponent(box);

		// update buttons of all shop items

		parent.updateButtons();
	}
}
