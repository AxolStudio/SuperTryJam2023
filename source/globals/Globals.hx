package globals;

import haxe.ui.Toolkit;
import states.PlayState;

class Globals
{
	public static var PlayState:PlayState;

	public static var initialized:Bool = false;

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
		"science" => "The amount of knowledge your civilization has collected. Used to purchase new Technologies."
	];
}

enum GlyphType
{
	ICON;
	TECHNOLOGY;
	RESOURCE;
}
