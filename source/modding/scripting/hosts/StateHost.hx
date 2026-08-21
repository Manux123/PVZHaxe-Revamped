package modding.scripting.hosts;

import modding.scripting.ScriptHost;
import hxscript.Environment;
import hxscript.types.ScriptedClass;
import flixel.FlxState;

class StateHost extends ScriptHost<FlxState>
{
	public function new() {}

	function get_folder()
		return 'states';

	function get_baseClass():Class<FlxState>
		return FlxState;

	override public function registerGlobals(world:Environment):Void
	{
		world.variables.set('switchState', function(name:String)
		{
			var host = modding.scripting.ScriptWorld.get(StateHost);
			host.switchTo(name);
		});
	}

	public function switchTo(name:String):Void
	{
		var state = create(name, []);
		if (state != null)
			flixel.FlxG.switchState(state);
		else
			trace('[StateHost] State not found: $name');
	}
}
