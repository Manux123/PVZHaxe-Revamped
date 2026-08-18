package game;

import core.json.LevelData;
import core.api.DiscordRPC;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import core.audio.DynamicGameMusic;
import flixel.State;
import game.objects.Zombie;
import game.objects.Plant;
import game.objects.Lawn;
import game.controllers.HUD;
import game.objects.Sun;
import game.controllers.SunController;
import core.sprites.AnimationHandler;

class LawnState extends State
{
	public static var instance:LawnState;

	var background:Lawn;

	var levelType = 'grass';

	public static var selectedPlant:String = '';

	public var zombieList:Array<Zombie> = [];
	public var plantList:Array<Plant> = [];

	public var plantGrp:FlxTypedGroup<Plant>;

	public var curRow:Int = 0;
	public var curCol:Int = 0;
	public var tileSpr:FlxSprite;
	public var plantOverlay:Plant;

	public var levelData:LevelData;

	// cameras
	public var camGame:flixel.Camera;
	public var camHUD:flixel.FlxCamera;

	// objects
	public var hud:HUD;
	public var music:DynamicGameMusic;

	var sunController:SunController;
	var sunGroup:flixel.group.FlxGroup;

	public var paused:Bool = false;

	var tileOffX:Float = 0;
	var tileOffY:Float = 0;

	override public function create()
	{
		super.create();

		instance = this;

		initializeCameras();
		levelData = new LevelData();
		levelData.loadLevel();

		// Load Plant Animations
		for (plant in Plant.plantIDs)
			AnimationHandler.parseAnimation('plants', plant);

		background = new Lawn(0, 0, levelData.lawnJson.lawn);
		camGame.zoom = background.defaultZoom;
		add(background);

		applyLawnCamera();

		music = new DynamicGameMusic();

		if (GameSave.world == 1)
		{
			levelType = 'grass';
			if (GameSave.level <= 3)
				levelType = 'grass_dirt';
		}
		else if (GameSave.world == 2)
			levelType = 'night';
		else if (GameSave.world == 3)
			levelType = 'pool';
		else if (GameSave.world == 4)
			levelType = 'pool_night';
		else if (GameSave.world == 5)
			levelType = 'roof';
		else if (GameSave.world == 6)
			levelType = 'roof_night';

		getLevel();

		tileSpr = new FlxSprite().makeGraphic(Std.int(background.gridWid / background.rows), Std.int(background.gridHei / background.columns), 0x7FFFFFFF);
		if (background.lawnJson.positionTile != null)
		{
			tileOffX = background.lawnJson.positionTile[0];
			tileOffY = background.lawnJson.positionTile[1];
		}
		tileSpr.active = false;
		add(tileSpr);

		plantOverlay = new Plant(0, 0);
		plantOverlay.updateHitbox();
		plantOverlay.alpha = 0.5;
		plantOverlay.visible = false;
		plantOverlay.active = false;
		add(plantOverlay);

		plantGrp = new FlxTypedGroup<Plant>();
		add(plantGrp);

		hud = new HUD();
		hud.cameras = [camHUD];

		sunGroup = new flixel.group.FlxGroup();
		add(sunGroup);

		sunController = new SunController(levelData.lawnJson, sunGroup, hud);

		add(hud);
		hud.initFromLevel(levelData.lawnJson);

		spawnLevelZombies();

		pauseMenu();
	}

	function spawnLevelZombies():Void
	{
		if (levelData.lawnJson.zombies == null)
			return;

		for (spawnData in levelData.lawnJson.zombies)
		{
			var type:String = spawnData.type ?? "basic";
			var count:Int = spawnData.count ?? 1;
			var row:Null<Int> = spawnData.row;

			var delay:Float = spawnData.delay ?? 0.0;
			var isBoss:Bool = spawnData.isBoss ?? false;
			var flag:Int = spawnData.flag ?? 0;

			for (i in 0...count)
			{
				var spawnRow = row != null ? row : Std.int(Math.random() * background.rows);
				var spawnY = spawnRow * background.tileHei + 45 + tileOffY;

				var createZombie = function()
				{
					var z = new Zombie(800, spawnY, type, true);
					add(z);
					zombieList.push(z);

					sortZombiesByY();
				};

				if (delay > 0)
				{
					new flixel.util.FlxTimer().start(delay, function(tmr:flixel.util.FlxTimer)
					{
						createZombie();
					});
				}
				else
				{
					createZombie();
				}
			}
		}
	}

	function sortZombiesByY():Void
	{
		zombieList.sort(function(a, b) return Reflect.compare(a.y, b.y));

		for (z in zombieList)
		{
			remove(z, true);
			add(z);
		}
	}

	function applyLawnCamera():Void
	{
		var json = background.lawnJson;

		camGame.snapZoom(json.defaultZoom != null ? json.defaultZoom : 1.0);

		if (json.camPos != null)
			camGame.snapTo(json.camPos[0], json.camPos[1]);
		else
			camGame.snapTo(0, 0);
	}

	function pauseMenu()
	{
		hud.pauseBitch = function()
		{
			if (paused)
				return;

			if (FlxG.sound.music != null)
				FlxG.sound.music.pause();

			sunController?.setPaused(paused);

			FlxG.sound.play(Paths.sound('pause'));

			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new game.menus.substate.PauseSubstate());
		};
	}

	function getLevel()
	{
		trace('level Type is ' + levelType);
		switch (levelType)
		{
			case 'night':
				DiscordRPC.changePressence('Waiting for User Input...');
				background.reloadImage(Paths.gameplayImage('levels/grassnight/grassnight'));
				music.audioGame(2, 'moongrains');
			case 'pool':
				DiscordRPC.changePressence('Waiting for User Input...');
				background.reloadImage(Paths.gameplayImage('levels/poolday/poolday'));
				if (GameSave.fastPool)
					music.audioGame(3, 'watery_graves_fast');
				else
					music.audioGame(3, 'watery_graves');
			case 'night_pool':
				DiscordRPC.changePressence('Waiting for User Input...');
				background.reloadImage(Paths.gameplayImage('levels/poolnight/poolnight'));
				music.audioGame(4, 'rigor_moris');
			case 'roof':
				DiscordRPC.changePressence('Playing Adventure', 'Version: [PRIVATE BETA 2]', 'discord_rpc_512', 'Plants VS Zombies: Haxe Edition',
					'discord_rpc_512_adventure', 'Playing: '
					+ GameSave.world
					+ '-'
					+ GameSave.level);
				background.reloadImage(Paths.gameplayImage('levels/roofday/roofday'));
				music.audioGame(5, 'graze_the_roof');
			case 'roof_night':
				DiscordRPC.changePressence('Playing the final Adventure Level!', 'Version: [PRIVATE BETA 2]', 'discord_rpc_512',
					'Plants VS Zombies: Haxe Edition', 'discord_rpc_512_boss', 'holy shit they are about to beat the game, partly');
				background.reloadImage(Paths.gameplayImage('levels/roofnight/roofnight'));
				music.audioGame(5, 'brainiac_maniac');
			default:
				DiscordRPC.changePressence('Waiting for User Input...');
				getMusic();
		}
	}

	function getMusic()
	{
		if (levelData != null && levelData.lawnJson != null)
		{
			if (levelData.lawnJson.world != null && levelData.lawnJson.music != null)
			{
				music.audioGame(levelData.lawnJson.world, levelData.lawnJson.music);
			}
			else
			{
				trace('WARNING: Music data is missing from the JSON (World: ${levelData.lawnJson.world}, Music: ${levelData.lawnJson.music})');
			}
		}
		else
		{
			trace("WARNING: The music could not be played. 'music', 'levelData' o 'lawnJson' is null.");
		}
	}

	override public function onFocus()
	{
		super.onFocus();
	}

	override public function onFocusLost()
	{
		super.onFocusLost();
		if (!paused && hud.pauseBitch != null)
			hud.pauseBitch();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (paused)
			return;

		var plantSelectedIndex:Int = Std.int(Plant.plantIDs.indexOf(selectedPlant));
		FlxG.watch.add(plantSelectedIndex, "String", "curPlantSelected");

		// Funni thingie just gets what tile the mouse is currently on
		curRow = Std.int(Math.max(0, Math.min(background.rows - 1, Math.round((FlxG.mouse.x - 30 - tileOffX - background.tileWid / 2) / background.tileWid))));
		curCol = Std.int(Math.max(0,
			Math.min(background.columns - 1, Math.round((FlxG.mouse.y - 75 - tileOffY - background.tileHei / 2) / background.tileHei))));

		var currentTile = background.tileData[curRow][curCol];
		var isValid = false;
		if (plantOverlay.plantableType == DEFAULT)
			isValid = !currentTile.hasDEFAULT
		else if (plantOverlay.plantableType == TILED)
			isValid = !currentTile.hasTILED
		else if (plantOverlay.plantableType == SECONDARY)
			isValid = !currentTile.hasSECONDARY;

		tileSpr.visible = plantOverlay.visible = FlxG.mouse.x >= 30 + tileOffX
			&& FlxG.mouse.x <= background.gridWid + 30 + tileOffX
			&& FlxG.mouse.y >= 75 + tileOffY
			&& FlxG.mouse.y <= background.gridHei + 75 + tileOffY
			&& isValid;

		if (tileSpr.visible)
		{
			placePlant();
		}
	}

	function initializeCameras()
	{
		camGame = new flixel.Camera();
		FlxG.cameras.reset(camGame);

		camHUD = new flixel.FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);
	}

	private function placePlant()
	{
		var currentTile = background.tileData[curRow][curCol];
		tileSpr.setPosition(curRow * background.tileWid + 30 + tileOffX, curCol * background.tileHei + 75 + tileOffY);
		plantOverlay.setPosition(tileSpr.x + 7.5, tileSpr.y + 12.5);

		if (FlxG.mouse.justPressed && plantOverlay.visible)
		{
			#if debug
			trace('At Row ${curRow + 1}, Coloumn: ${curCol + 1}');
			#end
			FlxG.sound.play(Paths.sound('plant'));
			currentTile.appendPlant(plantOverlay.plantableType, () -> plantGrp.add(new Plant(plantOverlay.x, plantOverlay.y)));
		}
	}

	override public function destroy()
	{
		zombieList = null;
		plantList = null;

		sunController?.destroy();
		sunController = null;

		super.destroy();
	}
}
