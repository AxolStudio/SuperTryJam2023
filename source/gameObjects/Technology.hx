package gameObjects;

import globals.Globals;

class Technology
{
	public var name:String = "";
	public var age:Int = -1;
	public var effect:Array<String> = [];
	public var scienceCost:Int = -1;
	public var requires:Array<String> = [];
	public var description:String = "";

	public function new(Name:String, Age:Int, Effect:Array<String>, ScienceCost:Int, Requires:Array<String>, Description:String = "")
	{
		name = Name;
		age = Age;
		effect = Effect;
		scienceCost = ScienceCost;
		requires = Requires;
		description = Description;
	}

	public static inline function fromData(Data:Dynamic):Technology
	{
		return new Technology(Data.name, Data.age, Data.effect, Data.science, Data.requires, Data.description);
	}

	public function doEffect():Void
	{
		for (e in effect)
		{
			var split:Array<String> = e.split("=");
			var type:String = split[0];
			var target:String = split[1];

			switch (type)
			{
				case "r": // replace an Icon's effects
					var details:Array<String> = split[2].split("!");
					var which:String = details[0];
					var change:String = details[1];

					var icon:Icon = Globals.PlayState.IconList.get(target);

					if (which == "e")
					{
						icon.effect = [change];
					}
					else if (which == "d")
					{
						icon.death = [change];
					}
				case "i": // change an icon's effects
					var details:Array<String> = split[2].split("!");
					var which:String = details[0];
					var change:String = details[1];

					var icon:Icon = Globals.PlayState.IconList.get(target);

					if (which == "e")
					{
						icon.effect.push(change);
					}
					else if (which == "d")
					{
						icon.death.push(change);
					}

					Globals.PlayState.IconList.set(target, icon);

				case "u": // unlock a new icon in the shop
					Globals.PlayState.SHOP_ITEMS.push(target);
					Globals.PlayState.newShop.revive();

				case "e": // some special effect
					switch (target)
					{
						case "fish":
							Globals.PlayState.WILD_ANIMALS.push("fish");
							Globals.PlayState.WILD_ANIMAL_WEIGHTS.push(30);

						case "construction":
							Globals.PlayState.constructionEnabled = true;
					}
			}
		}
	}
}
