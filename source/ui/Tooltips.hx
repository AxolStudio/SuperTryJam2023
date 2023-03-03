package ui;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;
import gameObjects.Icon;
import gameObjects.Technology;
import globals.Globals;

using axollib.TitleCase;
using flixel.util.FlxSpriteUtil;

class Tooltips
{
	public static var tooltips:Array<ToolTip> = [];

	public static function draw():Void
	{
		for (t in tooltips)
			t.draw();
	}

	public static function update(elapsed:Float):Void
	{
		if (tooltips.length > 0)
			tooltips[tooltips.length - 1].update(elapsed);
	}

	public static function showTooltip(Source:String, Target:FlxObject):Void
	{
		if (tooltips.length > 0)
			if (tooltips[tooltips.length - 1].target == Target)
				return;

		// Tooltips.update(0);
		var t:ToolTip = getFirstAvailable();
		t.spawn(FlxG.mouse.x + 8, FlxG.mouse.y + 8, Source, Target);
		tooltips.push(t);
	}

	public static function getFirstAvailable():ToolTip
	{
		for (t in tooltips)
			if (!t.exists)
				return t;

		return new ToolTip();
	}

	public static function hideTooltip(Tooltip:ToolTip):Void
	{
		if (tooltips[tooltips.length - 1] == Tooltip)
		{
			tooltips.pop();
			Tooltip.kill();
			// Tooltip.destroy();
		}
	}
}

class ToolTip extends FlxGroup
{
	public var x(get, never):Float;
	public var y(get, never):Float;

	public var width(get, never):Float;
	public var height(get, never):Float;

	public var background:FlxSprite;
	public var icon:FlxSprite;
	public var text:GameText;
	public var title:GameText;

	public var target:FlxObject;
	public var type:GlyphType;

	public function new():Void
	{
		super();

		background = new FlxSprite();

		icon = new FlxSprite();
		icon.frames = GraphicsCache.loadGraphicFromAtlas("assets/images/icons-128.png", "assets/images/icons-128.xml", false, "icons-128").atlasFrames;

		icon.color = Colors.BLACK;

		title = new GameText(0, 0, 264 - 24, "", Colors.BLACK, SIZE_36);
		title.alignment = "center";

		text = new GameText(0, 0, 264 - 24, "", Colors.BLACK, SIZE_24);
		text.alignment = FlxTextAlign.LEFT;

		add(background);
		add(icon);
		add(text);
		add(title);
	}

	public function spawn(X:Float, Y:Float, Source:String, Target:FlxObject):Void
	{
		revive();
		target = Target;
		type = Globals.PlayState.GLYPH_TYPES.get(Source);
		icon.animation.frameName = Source;
		title.text = Source.toTitleCase();
		text.text = parseDetails(Source);

		background.makeGraphic(264, Math.ceil(icon.height + 32 + text.height + title.height), Colors.BLACK);
		background.drawRect(2, 2, background.width - 4, background.height - 4, Colors.WHITE);

		if (X + background.width > FlxG.width)
			X = FlxG.width - background.width;

		if (Y + background.height > FlxG.height)
			Y = FlxG.height - background.height;

		background.x = X;
		background.y = Y;

		title.x = background.x + 12;
		title.y = background.y + 12;

		icon.x = background.x + (background.width / 2) - (icon.width / 2);
		icon.y = title.y + title.height + 4;

		text.x = background.x + 12;
		text.y = icon.y + icon.height + 4;
	}

	public function parseDetails(Source:String):String
	{
		var details:String = "";

		switch (type)
		{
			case ICON:
				var icon:Icon = Globals.PlayState.IconList.get(Source);
				details = icon.description;

			case TECHNOLOGY:
				var tech:Technology = Globals.PlayState.TechnologiesList.get(Source);
				details = tech.description;

			case RESOURCE:
				details = Globals.RESOURCE_DETAILS.get(Source);

			case MISC:
				details = Globals.MISC_DETAILS.get(Source);
		}

		return details;
	}

	public function get_x():Float
	{
		return background.x;
	}

	public function get_y():Float
	{
		return background.y;
	}

	public function get_width():Float
	{
		return background.width;
	}

	public function get_height():Float
	{
		return background.height;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (target != null)
		{
			if (!FlxG.mouse.overlaps(target) && !FlxG.mouse.overlaps(background))
				Tooltips.hideTooltip(this);
			// if (target is GameText)
			// {
			// 	cast(target, GameText).checkMouse();
			// 	if (cast(target, GameText).tooltipLetter != cast(target, GameText).currLetter)
			// 		Tooltips.hideTooltip(this);
			// }
		}
	}

	override function destroy()
	{
		background = FlxDestroyUtil.destroy(background);
		icon = FlxDestroyUtil.destroy(icon);
		text = FlxDestroyUtil.destroy(text);
		target = null;

		super.destroy();
	}
}
