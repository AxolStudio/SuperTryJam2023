package macros;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class IconsBuilder
{
	public static macro function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		var map:Array<Expr> = [];
		var e:Expr;

		var list:Array<Dynamic> = tjson.TJSON.parse(sys.io.File.getContent("assets/data/icons.json"));

		for (icon in list)
		{
			e = macro gameObjects.Icon.fromData($v{icon});
			map.push(macro $v{icon.name} => $e{e});
		}

		fields.push({
			pos: Context.currentPos(),
			name: "IconList",
			meta: null,
			kind: FieldType.FVar(macro :Map<String, gameObjects.Icon>, macro $a{map}),
			doc: null,
			access: [Access.APublic]
		});

		return fields;
	}
}
