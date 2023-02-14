package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import gameObjects.IconSprite;
import gameObjects.Technology;
import globals.Globals;
import states.GameState.GameSubState;

using axollib.TitleCase;
using flixel.util.FlxSpriteUtil;

class UpgradeScreen extends GameSubState
{
	public var techItems:FlxTypedGroup<TechItem>;
	public var scienceAmount:GameText;

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

		add(techItems = new FlxTypedGroup<TechItem>());

		var techItem:TechItem;
		for (k => v in Globals.TechnologiesList)
		{
			if (v.age == Globals.PlayState.age)
			{
				if (Globals.PlayState.technologies.contains(k))
					continue;
				techItem = new TechItem(this);
				techItem.x = background.x + 10 + (techItems.length % 2) * (techItem.width + 10);
				techItem.y = background.y + 60 + Std.int(techItems.length / 2) * (techItem.height + 10);
				techItem.setIcon(k);
				techItems.add(techItem);
			}
		}

		var closeButton:GameButton = new GameButton(background.x + background.width - 42, background.y + 8, "X", onClose, 32, 32, SIZE_36, FlxColor.RED,
			FlxColor.BLACK, FlxColor.WHITE, FlxColor.BLACK);
		add(closeButton);

		add(scienceAmount = new GameText(background.x + background.width - 210, 0, 200, "Science: {{science}}" + Std.string(Globals.PlayState.science),
			FlxColor.BLACK, SIZE_36));
		scienceAmount.alignment = "right";
		scienceAmount.y = background.y + background.height - scienceAmount.height - 10;

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
		for (techItem in techItems)
		{
			tech = Globals.TechnologiesList.get(techItem.icon.icon);
			var hasReq:Bool = true;
			for (req in tech.requires)
			{
				if (!Globals.PlayState.technologies.contains(req))
				{
					hasReq = false;
					break;
				}
			}

			techItem.buyButton.active = Globals.PlayState.science >= tech.scienceCost && hasReq;
		}
		scienceAmount.text = "Science: {{science}}" + Std.string(Globals.PlayState.science);
	}
}

class TechItem extends FlxGroup
{
	public var x(get, set):Float;
	public var y(get, set):Float;

	public var width(get, never):Float;
	public var height(get, never):Float;

	public var icon:IconSprite;

	public var background:FlxSprite;
	public var cost:GameText;
	public var buyButton:GameButton;
	public var title:GameText;

	public var requires:GameText;

	public var parent:UpgradeScreen;

	public static inline var MARGINS:Int = 12;
	public static inline var PADDING:Int = 4;

	public function new(Parent:UpgradeScreen):Void
	{
		super();

		parent = Parent;

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

		Globals.PlayState.science -= Globals.TechnologiesList.get(icon.icon).scienceCost;

		// add the new icon to the player's collection

		Globals.PlayState.technologies.push(icon.icon);

		// update buttons of all shop items

		parent.updateButtons();
	}

	public function set_x(Value:Float):Float
	{
		background.x = Value;
		title.x = background.x + MARGINS;
		icon.x = background.x + (background.width / 2) - 64;
		cost.x = background.x + MARGINS;
		requires.x = background.x + MARGINS;

		buyButton.x = background.x + MARGINS;
		return Value;
	}

	public function set_y(Value:Float):Float
	{
		background.y = Value;
		title.y = background.y + MARGINS;
		icon.y = title.y + title.height + PADDING;
		cost.y = icon.y + icon.height + PADDING;
		requires.y = cost.y + cost.height + PADDING;
		buyButton.y = background.y + background.height - buyButton.height - MARGINS;
		return Value;
	}

	public function get_width():Float
	{
		return background.width;
	}

	public function get_height():Float
	{
		return background.height;
	}

	public function get_x():Float
	{
		return background.x;
	}

	public function get_y():Float
	{
		return background.y;
	}
}
