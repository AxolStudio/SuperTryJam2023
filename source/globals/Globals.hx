package globals;

@:build(macros.IconsBuilder.build()) // IconList
class Globals
{
	public static inline var BLANKS_PER_AGE:Int = 25;

	public static var STARTING_ICONS:Map<String, Int> = ["human" => 5, "berry bush" => 1, "boulder" => 1, "tree" => 1, "spear" => 2];
	public static var WILD_ANIMALS:Array<String> = ["hare", "deer", "wolf", "bear", "mammoth"];
	public static var WILD_ANIMAL_WEIGHTS:Array<Float> = [50, 30, 14, 5, 1];
}
