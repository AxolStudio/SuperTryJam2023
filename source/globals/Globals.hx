package globals;

@:build(macros.IconsBuilder.build()) // IconList
class Globals
{
	public static var STARTING_ICONS:Map<String, Int> = [
		"human" => 5,
		"berry bush" => 5,
		"mammoth" => 1,
		"bear" => 3,
		"wolf" => 2,
		"boulder" => 2,
		"tree" => 3
	];
}
