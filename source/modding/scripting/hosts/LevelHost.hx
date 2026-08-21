package modding.scripting.hosts;

import modding.scripting.ScriptHost;
import hxscript.Environment;
import hxscript.types.ScriptedClass;
import game.LawnConfig;

class LevelHost extends ScriptHost<LevelScript>
{
	public function new() {}

	function get_folder()
		return 'levels';

	function get_baseClass():Class<LevelScript>
		return LevelScript;

	override public function registerGlobals(world:Environment):Void
	{
		world.variables.set('LawnConfig', LawnConfig);
	}

	public function loadForCurrentLevel():Null<LevelScript>
	{
		return loadForLevel(LawnConfig.curLevel);
	}

	public function loadForLevel(levelId:String):Null<LevelScript>
	{
		var sanitized = 'Level_' + StringTools.replace(levelId, '-', '_');
		var inst = create(sanitized, []);
		if (inst != null)
			return inst;

		inst = create(levelId, []);
		return inst;
	}

	public function getScriptedLevelIDs():Array<String>
		return [for (cls in getAll()) cls.name];
}
