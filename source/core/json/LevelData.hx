package core.json;

typedef LevelJson =
{
	var ?name:String;
	var ?world:Int;
    var lawn:String;

	var ?flags:Int;

	var ?isBossLevel:Bool;

	var ?seedSlots:Int;
    var ?forcedSeeds:Array<String>;

	var ?startingSun:Int;
    var ?sunDropRate:Float;
    var ?sunDropAmount:Int;
    var ?noSunDrop:Bool;

	var zombies:Array<ZombieSpawn>;
	var ?music:String;

	var ?reward:LevelReward;

	var ?winCondition:WinCondition;
	var ?loseCondition:LoseCondition;
}

typedef ZombieSpawn =
{
	var type:String; // "basic", "cone", "football"...
	var ?flag:Int;
	var ?row:Int; // file especifique (null = random)
	var ?count:Int; // how many appear (default 1)
	var ?delay:Float; // extra delay in seconds within the wave
	var ?isBoss:Bool; // He is the zombie leader of the horde
}

typedef WinCondition =
{
	var type:WinType; // SURVIVE, KILL_ALL, COLLECT, ESCORT
	var ?target:Int; // target quantity (COLLECT/KILL_ALL)
	var ?targetID:String; // what to collect or kill (COLLECT/KILL_ALL)
	var ?timeLimit:Float; // time limit in seconds (SURVIVE timed)
}

typedef LoseCondition =
{
	var type:LoseType;
	var ?timeLimit:Float;
}

typedef LevelReward =
{
	var type:RewardType; // PLANT, TROPHY, MINIGAME_UNLOCK, NONE
	var ?plantID:String; // which plant do you unlock
	var ?minigameID:String; // which minigame do you unlock
	var ?trophyID:String;
}

enum abstract WinType(String) from String to String
{
	var SURVIVE = "survive"; // defend until the waves end
	var KILL_ALL = "kill_all"; // kill X quantity of a type
	var COLLECT = "collect"; // collect X soles/items
	var ESCORT = "escort"; // protect an object/character
}

enum abstract LoseType(String) from String to String
{
	var BRAIN_EATEN = "brain_eaten";
	var TIME_UP = "time_up";
	var PLANT_DIED = "plant_died"; // perder si muere una planta específica
}

enum abstract RewardType(String) from String to String
{
	var PLANT = "plant";
	var TROPHY = "trophy";
	var MINIGAME_UNLOCK = "minigame_unlock";
	var NONE = "none";
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

		trace('[LEVEL] Loaded: ${lawnJson.name ?? game.LawnConfig.curLevel} | lawn: ${lawnJson.lawn} | zombies: ${lawnJson.zombies?.length ?? 0}');
	}
}
