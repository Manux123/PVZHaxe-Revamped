package core.json;

typedef LevelJson =
{
	var ?flags:Int;
	var lawn:String;
	var possibleZombies:Array<String>;
}

class LevelData
{
	public var lawnJson:LevelJson;

	public function new() {}

	public function loadLevel()
	{
		lawnJson = cast AngelUtils.JsonifyFile(Paths.json('levels/${game.LawnConfig.curLevel}'));

		if (lawnJson == null || lawnJson.lawn == null)
		{
			trace('Error: The current level could not be loaded or the JSON structure is invalid.');
			return;
		}
	}
}
