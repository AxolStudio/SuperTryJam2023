package macros;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class TechnologiesBuilder
{
	public static macro function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		var map:Array<Expr> = [];
		var e:Expr;

		var list:Array<Dynamic> = tjson.TJSON.parse(sys.io.File.getContent("assets/data/technologies.json"));

		for (tech in list)
		{
			e = macro gameObjects.Technology.fromData($v{tech});
			map.push(macro $v{tech.name} => $e{e});
		}

		fields.push({
			pos: Context.currentPos(),
			name: "TechnologiesList",
			meta: null,
			kind: FieldType.FVar(macro :Map<String, gameObjects.Technology>, macro $a{map}),
			doc: null,
			access: [Access.APublic]
		});

		return fields;
	}
}
