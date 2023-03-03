package globals;

import haxe.ui.Toolkit;
import flixel.util.FlxColor;
import states.PlayState;

class Globals
{
	public static var PlayState:PlayState;

	public static var initialized:Bool = false;

	public static var RESOURCES:Array<String> = ["food", "production", "science", "population", "faith"];

	public static function initGame():Void
	{
		if (initialized)
			return;

		Toolkit.init();

		Toolkit.styleSheet.parse("
            .scrollview {
                border: 2px solid black;
            }

            .scrollview .vertical-scroll {
                padding-left: 2px;
                width: 30px;
                background-color: white;
                border-left: 2px solid black;
            }

            .scrollview .vertical-scroll .thumb {
                width: 30px;
                background-color: gray;
                opacity:1;
            }

            .scrollview .vertical-scroll .thumb:hover {
                background-color: #999;
                opacity:1;
            
            }

            .scrollview .vertical-scroll .thumb:down {
                background-color: #333;
                opacity:1;
            
            }
        ");

		initialized = true;
	}

	public static var RESOURCE_DETAILS:Map<String, String> = [
		"population" => "The number of Human Elements in your Collection",
		"production" => "The amount of Industry your civilization has produced. Used to purchase new Elements",
		"food" => "The amount of food your civilization has stored. Human and Child Elements must eat each Spin or else they will Die.",
		"science" => "The amount of knowledge your civilization has collected. Used to purchase new Technologies.",
		"faith" => "The amount of faith your civilization has generated. Given to the Deity to keep It happy."
	];
}

enum GlyphType
{
	ICON;
	TECHNOLOGY;
	RESOURCE;
}

abstract Colors(Int) from Int from UInt to Int to UInt
{
	public static inline var TRANSPARENT:FlxColor = 0x00000000;
	public static inline var BLACK:FlxColor = 0xFF000000;
	public static inline var GRAY:FlxColor = 0xFF666666;
	public static inline var WHITE:FlxColor = 0xFFFFFFFF;

	public static inline var MAGENTA:FlxColor = 0xFF881177;
	public static inline var RED:FlxColor = 0xFFAA3355;
	public static inline var PINK:FlxColor = 0xFFCC6666;
	public static inline var ORANGE:FlxColor = 0xFFEE9944;
	public static inline var YELLOW:FlxColor = 0xFFEEDD00;
	public static inline var LIME:FlxColor = 0xFF99DD55;
	public static inline var GREEN:FlxColor = 0xFF44DD88;
	public static inline var CYAN:FlxColor = 0xFF22CCBB;
	public static inline var LIGHTBLUE:FlxColor = 0xFF00BBCC;
	public static inline var BLUE:FlxColor = 0xFF0099CC;
	public static inline var DARKBLUE:FlxColor = 0xFF3366BB;
	public static inline var VIOLET:FlxColor = 0xFF663399;
}
