package modding.scripting.hosts;

import modding.scripting.ScriptHost;
import hxscript.Environment;
import hxscript.types.ScriptedClass;
import game.objects.Plant;
import core.sprites.AnimationHandler;

class PlantHost extends ScriptHost<Plant>
{
	public function new() {}

	function get_folder()
		return 'plants';

	function get_baseClass():Class<Plant>
		return Plant;

	public function registerScriptedPlants():Void
	{
		for (cls in getAll())
		{
			var id = cls.name;
			Plant.registerID(id);
			AnimationHandler.parseAnimation('plants', id);
		}
	}

	public function spawnPlant(id:String, x:Float, y:Float):Plant
	{
		var cls = find(id);
		if (cls != null)
		{
			var plantIndex = Plant.plantIDs.indexOf(id);
			var inst:Plant = cls.typeCreateInstance([x, y, plantIndex]);
			return inst;
		}

		var plantIndex = Plant.plantIDs.indexOf(id);
		return new Plant(x, y, plantIndex);
	}

	public function getScriptedNames():Array<String>
		return [for (cls in getAll()) cls.name];
}
