package modding.scripting;

import hxscript.Config;
import hxscript.Environment;
import hxscript.error.Sink;
import hxscript.error.Diagnostic;
import hxscript.setup.Boot;
import hxscript.syntax.Expr.ImportMode;
import hxscript.types.TypeCollection;
import sys.FileSystem;

class ScriptWorld
{
	static var _env:Environment;
	static var _hosts:Array<ScriptHost<Dynamic>> = [];
	static var _hostMap:Map<String, ScriptHost<Dynamic>> = [];
	static var _modsRoot:String;
	static var _ready:Bool = false;

	public static function addHost(host:ScriptHost<Dynamic>):Void
	{
		var key = Type.getClassName(Type.getClass(host));
		_hosts.push(host);
		_hostMap.set(key, host);
	}

	public static function init(modsRoot:String):Void
	{
		_modsRoot = modsRoot;

		Sink.listen(onDiagnostic);

		_registerGameGlobals();

		_buildWorld();
	}

	static function _buildWorld():Void
	{
		_ready = false;

		_env = new Environment();

		for (host in _hosts)
		{
			host.attachWorld(_env);
			host.registerGlobals(_env);
		}

		for (host in _hosts)
			host.loadModules(_modsRoot);

		_env.start();
		_ready = true;

		_snapshotTimestamps();

		var moduleCount = 0; for (_ in _env.modules) moduleCount++;
		trace('[ScriptWorld] Ready. Hosts: ${_hosts.length}, modules: $moduleCount');
	}

	public static function get<H:ScriptHost<Dynamic>>(hostClass:Class<H>):Null<H>
	{
		var key = Type.getClassName(hostClass);
		return cast _hostMap.get(key);
	}

	public static var ready(get, never):Bool;

	static function get_ready()
		return _ready;

	public static var env(get, never):Environment;

	static function get_env()
		return _env;

	// hotreload
	static var _timestamps:Map<String, Float> = [];

	/**
	 * Callback that fires AFTER a successful reload.
	 * Your LawnState can hook this up to re-spawn scripted entities, etc.
	 *
	 *   ScriptWorld.onReload = () -> lawnState.rebuildScriptedEntities();
	 */
	public static var onReload:Null<() -> Void> = null;

	public static function reload():Void
	{
		var t = haxe.Timer.stamp();

		if (_env != null)
		{
			_env.snapshot();
			_env = null;
		}

		modding.scripting.ScriptPatch.clear();

		_ready = false;
		_buildWorld();

		var ms = Std.int((haxe.Timer.stamp() - t) * 1000);
		trace('[ScriptWorld] Reloaded in ${ms}ms');

		if (onReload != null)
			onReload();
	}

	public static function checkForChanges():Bool
	{
		if (!_ready)
			return false;

		var changed = false;
		_walkModFiles(_modsRoot, function(path:String)
		{
			var mtime = FileSystem.stat(path).mtime.getTime();
			var prev = _timestamps.get(path);
			if (prev == null || mtime > prev)
				changed = true;
		});

		if (changed)
		{
			reload();
			return true;
		}
		return false;
	}

	static function _snapshotTimestamps():Void
	{
		_timestamps.clear();
		_walkModFiles(_modsRoot, function(path:String)
		{
			_timestamps.set(path, FileSystem.stat(path).mtime.getTime());
		});
	}

	static function _walkModFiles(root:String, fn:String->Void):Void
	{
		if (!FileSystem.exists(root))
			return;
		for (host in _hosts)
		{
			var dir = '$root/${host.folder}';
			if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir))
				continue;
			for (file in FileSystem.readDirectory(dir))
				if (StringTools.endsWith(file, '.hx'))
					fn('$dir/$file');
		}
	}

	static function _registerGameGlobals():Void
	{
		var ambients = [
			'flixel.FlxG',
			'flixel.FlxSprite',
			'flixel.FlxBasic',
			'flixel.tweens.FlxTween',
			'flixel.util.FlxTimer',
			'flixel.math.FlxPoint',
			'game.objects.Plant',
			'game.objects.Zombie',
			'game.objects.Projectile',
			'game.LawnState',
		];

		Boot.importGlobals(ambients);

		var blocked = Config.blacklist.get(ByType);
		for (t in [
			'sys.io.File',
			'sys.io.Process',
			'sys.FileSystem',
			'sys.io.FileInput',
			'sys.io.FileOutput'
		])
			blocked.push(t);
	}

	public static dynamic function reportError(ctx:String, e:Dynamic):Void
	{
		var msg = (e is hxscript.error.Diagnostic) ? (cast e : Diagnostic).toString() : Std.string(e);
		trace('[ScriptWorld] ERROR in $ctx:\n$msg');
	}

	static function onDiagnostic(d:Diagnostic):Void
	{
		reportError(d.origin ?? '?', d);
	}
}
