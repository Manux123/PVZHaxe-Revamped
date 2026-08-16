package core.save;

import flixel.util.FlxSave;

class GameSave
{
	static var _save:FlxSave;

	public static var playerName(get, set):String;
	public static var world(get, set):Int;
	public static var level(get, set):Int;
	public static var isNewGame(get, set):Bool;
	public static var minigamesUnlocked(get, set):Bool;
	public static var survivalUnlocked(get, set):Bool;
	public static var fastPool(get, set):Bool;

	public static function init():Void
	{
		if (_save != null)
			return;

		_save = new FlxSave();
		_save.bind("PvZHaxeSave");

		if (_save.data.initialized == null)
		{
			trace("[SAVE] First Attempt, defaults loading...");
			_save.data.initialized = true;
			_save.data.playerName = null;
			_save.data.world = 1;
			_save.data.level = 1;
			_save.data.isNewGame = true;
			_save.data.minigames = false;
			_save.data.survival = false;
			_save.data.fastPool = false;
			flush();
		}

		trace("[SAVE] Loaded: " + summary());
	}

	public static function flush():Void
	{
		if (_save != null)
			_save.flush();
	}

	public static function reset():Void
	{
		if (_save == null)
			return;
		_save.data.initialized = true;
		_save.data.playerName = null;
		_save.data.world = 1;
		_save.data.level = 1;
		_save.data.isNewGame = true;
		_save.data.minigames = false;
		_save.data.survival = false;
		_save.data.fastPool = false;
		flush();
		trace("[SAVE] Reset to defaults.");
	}

	public static function summary():String
	{
		return 'name=${playerName} world=${world}-${level} newGame=${isNewGame}';
	}

	// --- Getters/Setters ---

	static function get_playerName():String
		return _save.data.playerName;

	static function set_playerName(v:String):String
	{
		_save.data.playerName = v;
		flush();
		return v;
	}

	static function get_world():Int
		return _save.data.world ?? 1;

	static function set_world(v:Int):Int
	{
		_save.data.world = v;
		flush();
		return v;
	}

	static function get_level():Int
		return _save.data.level ?? 1;

	static function set_level(v:Int):Int
	{
		_save.data.level = v;
		flush();
		return v;
	}

	static function get_isNewGame():Bool
		return _save.data.isNewGame ?? true;

	static function set_isNewGame(v:Bool):Bool
	{
		_save.data.isNewGame = v;
		flush();
		return v;
	}

	static function get_minigamesUnlocked():Bool
		return _save.data.minigames ?? false;

	static function set_minigamesUnlocked(v:Bool):Bool
	{
		_save.data.minigames = v;
		flush();
		return v;
	}

	static function get_survivalUnlocked():Bool
		return _save.data.survival ?? false;

	static function set_survivalUnlocked(v:Bool):Bool
	{
		_save.data.survival = v;
		flush();
		return v;
	}

	static function get_fastPool():Bool
		return _save.data.fastPool ?? false;

	static function set_fastPool(v:Bool):Bool
	{
		_save.data.fastPool = v;
		flush();
		return v;
	}
}
