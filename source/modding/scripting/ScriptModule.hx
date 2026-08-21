package modding.scripting;

import hxscript.Module;

class ScriptModule
{
	public var name(default, null):String;
	public var failed(default, null):Bool = false;

	var _mod:Module;

	public function new(mod:Module, name:String)
	{
		_mod = mod;
		this.name = name;
	}

	public function has(fn:String):Bool
	{
		if (failed)
			return false;
		var v = _mod.variables.get(fn);
		return v != null && Reflect.isFunction(v);
	}

	public function call(fn:String, args:Array<Dynamic>):Dynamic
	{
		if (!has(fn))
			return null;
		try
		{
			return _mod.call(fn, args);
		}
		catch (e:Dynamic)
		{
			ScriptWorld.reportError('[$name] $fn()', e);
			return null;
		}
	}
}
