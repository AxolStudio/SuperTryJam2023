package gameObjects;

class GodSpeeches
{
	public var when:String = "";
	public var texts:Array<String> = [];
	public var next:String = "";
	public var spins:Int = 0;
	public var needs:Float = 0;

	public function new(When:String, Texts:Array<String>, Next:String, Spins:Int, Needs:Float)
	{
		when = When;
		texts = Texts;
		next = Next;
		spins = Spins;
		needs = Needs;
	}

	public static function fromData(Data:Dynamic):GodSpeeches
	{
		return new GodSpeeches(Data.when, Data.texts, Data.next, Data.spins, Data.needs);
	}
}
