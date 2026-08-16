package game;

import core.json.LevelData;
import discord_rpc.DiscordRpc;
import haxe.Exception;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.geom.Point;
import flixel.util.FlxSave;
import AngelUtils; // for json reading
import flixel.FlxSprite;
import flixel.FlxState;
import game.objects.Zombie;
import game.objects.Plant;
import game.objects.Lawn;
import game.controllers.HUD;
import core.audio.DynamicGameMusic;

class LawnState extends FlxState
{
	override public function onFocus()
	{
		super.onFocus();
		FlxG.sound.music.resume();
		trace("[SYSTEM] User Focused the window");
	}

	override public function onFocusLost()
	{
		super.onFocusLost();
		FlxG.sound.music.pause();
		trace("[SYSTEM] User Lost Focus the window");
	}

	var background:Lawn;

	var _gamedata:FlxSave;

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
	public var camGame:flixel.FlxCamera;
	public var camHUD:flixel.FlxCamera;

	// objects
	public var hud:HUD;
	public var music:DynamicGameMusic;

	var menuButton:flixel.ui.FlxButton;

	override public function create()
	{
		super.create();

		initializeCameras();
		levelData = new LevelData();
		levelData.loadLevel();

		// Load Plant Animations
		for (plant in Plant.plantIDs)
			AnimationHandler.parseAnimation('data/plants', plant);

		background = new Lawn();
		add(background);

		getLevel();

		tileSpr = new FlxSprite().makeGraphic(Std.int(background.gridWid / background.rows), Std.int(background.gridHei / background.columns), 0x7FFFFFFF);
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
		add(hud);

		menuButton = new flixel.ui.FlxButton(681, -12, '', pauseBitch);
		menuButton.loadGraphic('assets/images/menu/inGamePause.png', true, 117, 48);
		add(menuButton);

		// game data \\
		_gamedata = new FlxSave();
		_gamedata.bind("Save");
		// Level shit \\
		if (_gamedata.data.world == 1)
		{
			levelType = 'grass';
			if (_gamedata.data.level == 1 || _gamedata.data.level == 2 || _gamedata.data.level == 3)
			{
				levelType = 'grass_dirt';
			}
		}
		else if (_gamedata.data.world == 2)
		{
			levelType = 'night';
		}
		else if (_gamedata.data.world == 3)
		{
			levelType = 'pool';
		}
		else if (_gamedata.data.world == 4)
		{
			levelType = 'pool_night';
		}
		else if (_gamedata.data.world == 5)
		{
			levelType = 'roof';
		}
		else if (_gamedata.data.world == 6)
		{
			levelType = 'roof_night';
		}
	}

	function pauseBitch() {}

	function getLevel()
	{
		trace('level Type is ' + levelType);
		switch (levelType)
		{
			case 'grass_dirt':
				DiscordRpc.presence({
					details: 'Version: [PRIVATE BETA 2]',
					state: 'Waiting for User Input...',
					largeImageKey: 'discord_rpc_512',
					largeImageText: 'Plants VS Zombies: Haxe Edition'
				});
				background.reloadImage('assets/images/levels/grassday/grassday_dirt.png');
				music.audioGame(1, 'grasswalk');
			case 'grass':
				DiscordRpc.presence({
					details: 'Version: [PRIVATE BETA 2]',
					state: 'Waiting for User Input...',
					largeImageKey: 'discord_rpc_512',
					largeImageText: 'Plants VS Zombies: Haxe Edition'
				});
				background.reloadImage('assets/images/levels/grassday/grassday.png');
				music.audioGame(1, 'grasswalk');

			case 'night':
				DiscordRpc.presence({
					details: 'Version: [PRIVATE BETA 2]',
					state: 'Waiting for User Input...',
					largeImageKey: 'discord_rpc_512',
					largeImageText: 'Plants VS Zombies: Haxe Edition'
				});
				background.reloadImage('assets/images/levels/grassnight/grassnight.jpg');
				music.audioGame(2, 'moongrains');
			case 'pool':
				DiscordRpc.presence({
					details: 'Version: [PRIVATE BETA 2]',
					state: 'Waiting for User Input...',
					largeImageKey: 'discord_rpc_512',
					largeImageText: 'Plants VS Zombies: Haxe Edition'
				});
				background.reloadImage('assets/images/levels/poolday/poolday.jpg');
				if (_gamedata.data.fastpool == true)
				{
					music.audioGame(3, 'watery_graves_fast');
				}
				else
				{
					music.audioGame(3, 'watery_graves');
				}
			case 'night_pool':
				DiscordRpc.presence({
					details: 'Version: [PRIVATE BETA 2]',
					state: 'Waiting for User Input...',
					largeImageKey: 'discord_rpc_512',
					largeImageText: 'Plants VS Zombies: Haxe Edition'
				});
				background.reloadImage('assets/images/levels/poolnight/poolnight.jpg');
				music.audioGame(4, 'rigor_moris');
			case 'roof':
				DiscordRpc.presence({
					details: 'Version: [PRIVATE BETA 2]',
					state: 'Playing Adventure',
					smallImageKey: 'discord_rpc_512_adventure',
					smallImageText: 'Playing: ' + _gamedata.data.world + '-' + _gamedata.data.level,
					largeImageKey: 'discord_rpc_512',
					largeImageText: 'Plants VS Zombies: Haxe Edition'
				});
				background.reloadImage('assets/images/levels/roofday/roofday.jpg');
				music.audioGame(5, 'graze_the_roof');
			case 'roof_night':
				DiscordRpc.presence({
					details: 'Version: [PRIVATE BETA 2]',
					state: 'Playing the final Adventure Level!',
					largeImageKey: 'discord_rpc_512',
					smallImageKey: 'discord_rpc_512_boss',
					smallImageText: 'holy shit they are about to beat the game, partly',
					largeImageText: 'Plants VS Zombies: Haxe Edition'
				});
				background.reloadImage('assets/images/levels/roofnight/roofnight.jpg');
				music.audioGame(5, 'brainiac_maniac');
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var plantSelectedIndex:Int = Std.int(Plant.plantIDs.indexOf(selectedPlant));
		FlxG.watch.add(plantSelectedIndex, "String", "curPlantSelected");

		// Funni thingie just gets what tile the mouse is currently on
		curRow = Std.int(Math.max(0, Math.min(background.rows - 1, Math.round((FlxG.mouse.x - 30 - background.tileWid / 2) / background.tileWid))));
		curCol = Std.int(Math.max(0, Math.min(background.columns - 1, Math.round((FlxG.mouse.y - 75 - background.tileHei / 2) / background.tileHei))));

		var currentTile = background.tileData[curRow][curCol];
		var isValid = false;
		if (plantOverlay.plantableType == DEFAULT)
			isValid = !currentTile.hasDEFAULT
		else if (plantOverlay.plantableType == TILED)
			isValid = !currentTile.hasTILED
		else if (plantOverlay.plantableType == SECONDARY)
			isValid = !currentTile.hasSECONDARY;

		tileSpr.visible = plantOverlay.visible = FlxG.mouse.x >= 30
			&& FlxG.mouse.x <= background.gridWid + 30
			&& FlxG.mouse.y >= 75
			&& FlxG.mouse.y <= background.gridHei + 75
			&& isValid;

		if (tileSpr.visible)
		{
			placePlant();
		}
	}

	function initializeCameras()
	{
		camGame = new flixel.FlxCamera();
		FlxG.cameras.reset(camGame);

		camHUD = new flixel.FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);
	}

	private function placePlant()
	{
		var currentTile = background.tileData[curRow][curCol];
		tileSpr.setPosition(curRow * background.tileWid + 30, curCol * background.tileHei + 75);
		plantOverlay.setPosition(tileSpr.x + 7.5, tileSpr.y + 12.5);

		if (FlxG.mouse.justPressed && plantOverlay.visible)
		{
			#if debug
			trace('At Row ${curRow + 1}, Coloumn: ${curCol + 1}');
			#end
			currentTile.appendPlant(plantOverlay.plantableType, () -> plantGrp.add(new Plant(plantOverlay.x, plantOverlay.y)));
		}
	}

	override public function destroy()
	{
		super.destroy();
	}
}
