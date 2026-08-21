package modding.scripting.hosts;

import modding.scripting.ScriptHost;
import hxscript.Environment;
import hxscript.types.ScriptedClass;
import game.objects.Lawn;

class LawnHost extends ScriptHost<Lawn>
{
	public function new() {}

	function get_folder()
		return 'lawns';

	function get_baseClass():Class<Lawn>
		return Lawn;

	override public function registerGlobals(world:Environment):Void {}

	public function createLawn(x:Float, y:Float, backgroundType:String = 'grassday'):Lawn
	{
		var cls = find(backgroundType);
		if (cls != null)
		{
			var inst:Lawn = cls.typeCreateInstance([x, y, backgroundType]);
			return inst;
		}

		return new Lawn(x, y, backgroundType);
	}

	public function getScriptedNames():Array<String>
		return [for (cls in getAll()) cls.name];
}
