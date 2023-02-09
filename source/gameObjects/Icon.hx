package gameObjects;

class Icon
{
	public var name(default, null):String;
	public var upkeep:Int;
	public var effect:Array<String>;
	public var death:Array<String>;

	public function new(Name:String, Upkeep:Int = 0, ?Effect:Array<String>, ?Death:Array<String>):Void
	{
		name = Name;
		upkeep = Upkeep;
		effect = Effect == null ? [] : Effect;
		death = Death == null ? [] : Death;
	}

	public static function fromData(Data:Dynamic):Icon
	{
		return new Icon(Data.name, Data.upkeep, Data.effect, Data.death);
	}

	public function clone():Icon
	{
		return new Icon(name, upkeep, effect, death);
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
