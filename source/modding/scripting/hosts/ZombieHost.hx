package modding.scripting.hosts;

import modding.scripting.ScriptHost;
import hxscript.Environment;
import hxscript.types.ScriptedClass;
import game.objects.Zombie;

class ZombieHost extends ScriptHost<Zombie>
{
	public function new() {}

	function get_folder()
		return 'zombies';

	function get_baseClass():Class<Zombie>
		return Zombie;

	override public function registerGlobals(world:Environment):Void {}

	public function spawnZombie(type:String, x:Float, y:Float, shouldWalk:Bool = true):Zombie
	{
		var cls = find(type);
		if (cls != null)
		{
			var inst:Zombie = cls.typeCreateInstance([x, y, type, shouldWalk]);
			return inst;
		}

		return new Zombie(x, y, type, shouldWalk);
	}

	public function getScriptedNames():Array<String>
		return [for (cls in getAll()) cls.name];
}
