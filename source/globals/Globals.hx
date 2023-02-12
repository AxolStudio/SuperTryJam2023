package globals;

import states.PlayState;

@:build(macros.IconsBuilder.build()) // IconList
class Globals
{
	public static var PlayState:PlayState;

	public static inline var BLANKS_PER_AGE:Int = 25;

	public static var STARTING_ICONS:Map<String, Int> = ["human" => 5, "spear" => 3, "berry bush" => 5];
	public static var WILD_ANIMALS:Array<String> = ["hare", "deer", "wolf", "bear", "mammoth"];
	public static var WILD_ANIMAL_WEIGHTS:Array<Float> = [50, 30, 14, 5, 1];

	public static var SHOP_ITEMS:Array<String> = ["child", "berry bush"];
}
