package globals;

@:build(macros.IconsBuilder.build()) // IconList
class Globals
{
	public static inline var BLANKS_PER_AGE:Int = 25;

	public static var STARTING_ICONS:Map<String, Int> = [
		"human" => 5,
		"berry bush" => 5,
		"mammoth" => 1,
		"bear" => 2,
		"wolf" => 3,
		"boulder" => 2,
		"tree" => 2
	];
}
