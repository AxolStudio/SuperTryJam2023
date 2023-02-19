package gameObjects;

class Icon
{
	public var name(default, null):String;
	public var cost:Int;
	public var effect:Array<String>;
	public var death:Array<String>;
	public var description:String;
	public var workMultiplier:Float = 0;

	public function new(Name:String, Cost:Int = 0, ?Effect:Array<String>, ?Death:Array<String>, ?Description:String, ?WorkMultiplier:Float):Void
	{
		name = Name;
		cost = Cost;
		effect = Effect == null ? [] : Effect;
		death = Death == null ? [] : Death;
		description = Description == null ? "" : Description;
		workMultiplier = WorkMultiplier == null ? 0 : WorkMultiplier;
	}

	public static function fromData(Data:Dynamic):Icon
	{
		return new Icon(Data.name, Data.cost, Data.effect, Data.death, Data.description, Data.workmultiplier);
	}

	public function clone():Icon
	{
		return new Icon(name, cost, effect, death, description, workMultiplier);
	}
}

class GridIcon
{
	public var name:String;
	public var wounded:Bool = false;
	public var timer:Int = -1;

	public function new(Name:String):Void
	{
		name = Name;
	}
}
