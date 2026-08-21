package modding.scripting.hosts;

import modding.scripting.ScriptHost;
import modding.scripting.ScriptPatch;
import hxscript.Environment;
import hxscript.Module;
import sys.FileSystem;
import sys.io.File;

class PatchHost extends ScriptHost<Dynamic>
{
	public function new() {}

	function get_folder()
		return 'patches';

	function get_baseClass():Class<Dynamic>
		return null;

	override public function registerGlobals(world:Environment):Void
	{
		ScriptPatch.registerGlobals(world);
	}

	override public function getAll():Array<hxscript.types.ScriptedClass>
		return [];
}
