package globals;

import states.PlayState;

@:build(macros.IconsBuilder.build()) // IconList
@:build(macros.TechnologiesBuilder.build()) // TechnologiesList
class Globals
{
	public static var PlayState:PlayState;

	public static inline var BLANKS_PER_AGE:Int = 25;

	public static var STARTING_ICONS:Map<String, Int> = ["human" => 5, "spear" => 3, "berry bush" => 5];
	public static var WILD_ANIMALS:Array<String> = ["hare", "deer", "wolf", "bear", "mammoth"];
	public static var WILD_ANIMAL_WEIGHTS:Array<Float> = [50, 30, 14, 5, 1];

	public static var SHOP_ITEMS:Array<String> = ["child", "berry bush"];

	public static var GLYPH_TYPES:Map<String, GlyphType> = [];

	public static var initialized:Bool = false;

	public static function initGame():Void
	{
		if (initialized)
			return;

		for (k => v in IconList)
			GLYPH_TYPES.set(k, GlyphType.ICON);

		for (k => v in TechnologiesList)
			GLYPH_TYPES.set(k, GlyphType.TECHNOLOGY);

		GLYPH_TYPES.set("population", GlyphType.RESOURCE);
		GLYPH_TYPES.set("food", GlyphType.RESOURCE);
		GLYPH_TYPES.set("production", GlyphType.RESOURCE);
		GLYPH_TYPES.set("science", GlyphType.RESOURCE);

		initialized = true;
	}

	public static var RESOURCE_DETAILS:Map<String, String> = [
		"population" => "The number of Human Elements in your Collection",
		"production" => "The amount of Industry your civilization has produced. Used to purchase new Elements",
		"food" => "The amount of food your civilization has stored. Human and Child Elements must eat each Spin or else they will Die.",
		"science" => "The amount of knowledge your civilization has collected. Used to purchase new Technologies."
	];
}

enum GlyphType
{
	ICON;
	TECHNOLOGY;
	RESOURCE;
}
