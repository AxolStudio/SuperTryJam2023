package macros;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class GodTalkBuilder
{
	public static macro function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		var map:Array<Expr> = [];

		var list:Array<Dynamic> = tjson.TJSON.parse(sys.io.File.getContent("assets/data/god_msgs.json"));

		for (msg in list)
		{
			map.push(macro $v{msg.when} => $v{msg.texts});
		}

		fields.push({
			pos: Context.currentPos(),
			name: "GodSpeeches",
			meta: null,
			kind: FieldType.FVar(macro:Map<String, Array<String>>, macro $a{map}),
			doc: null,
			access: [Access.APublic]
		});

		return fields;
	}
}
