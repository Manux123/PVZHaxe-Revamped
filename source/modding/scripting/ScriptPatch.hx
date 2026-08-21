package modding.scripting;

import hxscript.Environment;
import hxscript.Script;

class ScriptPatch
{
	static var _hooks:Map<String, Array<Dynamic>> = [];

	public static function registerGlobals(world:Environment):Void
	{
		for (hookName in _knownHooks())
			world.variables.set(hookName, _makeRegistrar(hookName));
	}

	public static function call(name:String, args:Array<Dynamic>):Dynamic
	{
		var hooks = _hooks.get(name);
		if (hooks == null || hooks.length == 0)
			return null;

		var result:Dynamic = null;
		for (fn in hooks)
		{
			try
			{
				var r = Reflect.callMethod(null, fn, args);
				if (r != null)
					result = r;
			}
			catch (e:Dynamic)
			{
				ScriptWorld.reportError('[ScriptPatch] hook "$name"', e);
			}
		}
		return result;
	}

	public static function fire(name:String, args:Array<Dynamic>):Void
		call(name, args);

	public static function clear():Void
		_hooks.clear();

	static function _makeRegistrar(hookName:String):Dynamic
	{
		return function(fn:Dynamic)
		{
			if (!_hooks.exists(hookName))
				_hooks.set(hookName, []);
			_hooks.get(hookName).push(fn);
		};
	}

	static function _knownHooks():Array<String>
	{
		return [
			// Sun
			'onSunDrop', // (amount:Int) -> Int?
			'onSunCollect', // (amount:Int) -> Void

			// Plants
			'onPlantPlaced', // (plant:Plant) -> Void
			'onPlantDeath', // (plant:Plant) -> Void
			'onPlantAttack', // (plant:Plant, target:String) -> Void

			// Zombies
			'onZombieSpawn', // (zombie:Zombie) -> Void
			'onZombieDeath', // (zombie:Zombie) -> Void
			'onZombieEat', // (zombie:Zombie, plant:Plant) -> Void

			// Level
			'onWaveStart', // (wave:Int) -> Void
			'onLevelStart', // () -> Void
			'onLevelEnd', // (won:Bool) -> Void

			// Proyectiles
			'onProjectileHit', // (proj:Projectile, zombie:Zombie) -> Void
		];
	}
}
