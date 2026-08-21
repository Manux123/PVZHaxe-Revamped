package modding.scripting;

import hxscript.Environment;
import hxscript.Module;
import hxscript.error.Sink;
import hxscript.error.Diagnostic;
import hxscript.types.ScriptedClass;
import hxscript.setup.Boot;
import sys.FileSystem;
import sys.io.File;

abstract class ScriptHost<T>
{
	public var world(default, null):Environment;

	public var folder(get, never):String;

	abstract function get_folder():String;

	public var baseClass(get, never):Class<T>;

	abstract function get_baseClass():Class<T>;

	public function registerGlobals(world:Environment):Void {}

	public function getAll():Array<ScriptedClass>
	{
		var out:Array<ScriptedClass> = [];
		if (world == null)
			return out;

		for (module in world.modules)
			for (_ => type in module.types)
				if (type is ScriptedClass)
				{
					var cls:ScriptedClass = cast type;
					if (isDescendantOf(cls.instanceClass, cast baseClass))
						out.push(cls);
				}

		return out;
	}

	public function find(name:String):Null<ScriptedClass>
	{
		if (world == null)
			return null;
		var type = world.resolve(name);
		if (type != null && (type is ScriptedClass))
			return cast type;
		return null;
	}

	public function create(name:String, args:Array<Dynamic>):Null<T>
	{
		var cls = find(name);
		if (cls == null)
			return null;

		try
		{
			return cls.typeCreateInstance(args);
		}
		catch (e:Dynamic)
		{
			ScriptWorld.reportError('[$folder] create("$name")', e);
			return null;
		}
	}

	@:allow(modding.scripting.ScriptWorld)
	function attachWorld(env:Environment):Void
	{
		this.world = env;
	}

	@:allow(modding.scripting.ScriptWorld)
	function loadModules(modsRoot:String):Void
	{
		var dir = '$modsRoot/$folder';
		if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir))
			return;

		for (file in FileSystem.readDirectory(dir))
		{
			if (!StringTools.endsWith(file, '.hx'))
				continue;

			var path = '$dir/$file';
			var name = file.substr(0, file.length - 3);

			var source = File.getContent(path);
			var mod = new Module(source, name, [], path);
			mod.onParsingError = function(e)
			{
				ScriptWorld.reportError('[$folder] parse($name)', e.message);
			};
			world.addModule(mod);
		}
	}

	static function isDescendantOf(cls:Dynamic, base:Dynamic):Bool
	{
		var c = cls;
		while (c != null)
		{
			if (c == base)
				return true;
			c = Type.getSuperClass(c);
		}
		return false;
	}
}
