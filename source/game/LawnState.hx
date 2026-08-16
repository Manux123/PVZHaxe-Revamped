package game;

import core.json.LevelData;
import core.api.DiscordRPC;
import haxe.Exception;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.State;
import game.objects.Zombie;
import game.objects.Plant;
import game.objects.Lawn;
import game.controllers.HUD;
import core.audio.DynamicGameMusic;
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

	var zombie:Zombie;

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
			AnimationHandler.parseAnimation('data/plants', plant);

		background = new Lawn();
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

		zombie = new Zombie(800, 180, "basic", true);
		add(zombie);

		hud = new HUD();
		hud.cameras = [camHUD];
		add(hud);

		pauseMenu();
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
			case 'grass_dirt':
				DiscordRPC.changePressence('Waiting for User Input...');
				background.reloadImage('assets/images/levels/grassday/grassday_dirt.png');
				music.audioGame(1, 'grasswalk');
			case 'grass':
				DiscordRPC.changePressence('Waiting for User Input...');
				background.reloadImage('assets/images/levels/grassday/grassday.png');
				music.audioGame(1, 'grasswalk');

			case 'night':
				DiscordRPC.changePressence('Waiting for User Input...');
				background.reloadImage('assets/images/levels/grassnight/grassnight.jpg');
				music.audioGame(2, 'moongrains');
			case 'pool':
				DiscordRPC.changePressence('Waiting for User Input...');
				background.reloadImage('assets/images/levels/poolday/poolday.jpg');
				if (GameSave.fastPool)
					music.audioGame(3, 'watery_graves_fast');
				else
					music.audioGame(3, 'watery_graves');
			case 'night_pool':
				DiscordRPC.changePressence('Waiting for User Input...');
				background.reloadImage('assets/images/levels/poolnight/poolnight.jpg');
				music.audioGame(4, 'rigor_moris');
			case 'roof':
				DiscordRPC.changePressence('Playing Adventure', 'Version: [PRIVATE BETA 2]', 'discord_rpc_512', 'Plants VS Zombies: Haxe Edition',
					'discord_rpc_512_adventure', 'Playing: '
					+ GameSave.world
					+ '-'
					+ GameSave.level);
				background.reloadImage('assets/images/levels/roofday/roofday.jpg');
				music.audioGame(5, 'graze_the_roof');
			case 'roof_night':
				DiscordRPC.changePressence('Playing the final Adventure Level!', 'Version: [PRIVATE BETA 2]', 'discord_rpc_512',
					'Plants VS Zombies: Haxe Edition', 'discord_rpc_512_boss', 'holy shit they are about to beat the game, partly');
				background.reloadImage('assets/images/levels/roofnight/roofnight.jpg');
				music.audioGame(5, 'brainiac_maniac');
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

		super.destroy();
	}
}
