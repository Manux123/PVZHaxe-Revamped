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
import game.objects.Projectile;
import game.controllers.SunController;
import core.sprites.AnimationHandler;
import modding.scripting.ScriptWorld;
import modding.scripting.hosts.PlantHost;
import modding.scripting.hosts.ZombieHost;
import modding.scripting.hosts.LevelHost;
import modding.scripting.hosts.LawnHost;

class LawnState extends State
{
	public static var instance:LawnState;

	var background:Lawn;

	var levelType = 'grass';

	public static var selectedPlant:String = '';

	public var zombieGrp:FlxTypedGroup<Zombie>;

	public var plantGrp:FlxTypedGroup<Plant>;
	public var projectileGrp:FlxTypedGroup<Projectile>;

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

	public var modePlay:Bool = false;

	// selection for plants, etc
	public var modeSelection:Bool = false;

	public var startFirstWave:Bool = false;

	public var levelScript:Null<modding.scripting.hosts.LevelScript> = null;

	public var isCutscene:Bool = false;

	var _plantHost(get, never):PlantHost;
	var _zombieHost(get, never):ZombieHost;
	var _levelHost(get, never):LevelHost;
	var _lawnHost(get, never):LawnHost;

	inline function get__plantHost()
		return ScriptWorld.get(PlantHost);

	inline function get__zombieHost()
		return ScriptWorld.get(ZombieHost);

	inline function get__levelHost()
		return ScriptWorld.get(LevelHost);

	inline function get__lawnHost()
		return ScriptWorld.get(LawnHost);

	override public function create()
	{
		super.create();

		instance = this;

		initializeCameras();
		levelData = new LevelData();
		levelData.loadLevel();

		if (ScriptWorld.ready)
			_plantHost?.registerScriptedPlants();

		// Load Plant Animations
		for (plant in Plant.plantIDs)
			AnimationHandler.parseAnimation('plants', plant);

		background = _lawnHost != null ? _lawnHost.createLawn(0, 0, levelData.lawnJson.lawn) : new Lawn(0, 0, levelData.lawnJson.lawn);
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

		plantOverlay = _spawnPlantOverlay(0, 0, 0);
		add(plantOverlay);

		plantGrp = new FlxTypedGroup<Plant>();
		add(plantGrp);

		hud = new HUD(levelData.lawnJson);
		hud.cameras = [camHUD];

		hud.onSeedSelected = function(plantId:String)
		{
			selectedPlant = plantId;

			if (plantId != '')
			{
				var plantIndex = Plant.plantIDs.indexOf(plantId);

				remove(plantOverlay);
				plantOverlay = _spawnPlantOverlay(0, 0, plantIndex);
				add(plantOverlay);
			}
			else
			{
				plantOverlay.visible = false;
			}
		};

		sunGroup = new flixel.group.FlxGroup();
		add(sunGroup);

		sunController = new SunController(levelData.lawnJson, sunGroup, hud);

		add(hud);

		zombieGrp = new FlxTypedGroup<Zombie>();
		add(zombieGrp);

		projectileGrp = new FlxTypedGroup<Projectile>();
		add(projectileGrp);

		pauseMenu();

		if (ScriptWorld.ready)
		{
			levelScript = _levelHost?.loadForCurrentLevel();
			if (levelScript != null)
				trace('[LawnState] Script level loaded: ${LawnConfig.curLevel}');
		}

		levelScript?.onCreate();

		if (!modeSelection && !isCutscene)
			onCountdown();
	}

	function _spawnPlantOverlay(x:Float, y:Float, plantIndex:Int):Plant
	{
		var id = Plant.plantIDs[plantIndex];
		var p = _plantHost != null ? _plantHost.spawnPlant(id, x, y) : new Plant(x, y, plantIndex);
		p.updateHitbox();
		p.alpha = 0.5;
		p.visible = false;
		p.active = false;
		return p;
	}

	public function makePlantShoot(plant:Plant)
	{
		var proj = plant.attack();
		if (proj != null)
		{
			projectileGrp.add(proj);
		}
	}

	function initializeCameras()
	{
		camGame = new flixel.Camera();
		FlxG.cameras.reset(camGame);

		camHUD = new flixel.FlxCamera();
		camHUD.bgColor.alpha = 0;

		camHUD.scroll.set(0, 0);

		FlxG.cameras.add(camHUD, false);
	}

	public var startTimer:flixel.util.FlxTimer;
	public var remainingTime:Float = 20;

	function onCountdown()
	{
		levelScript?.onCountdown();

		FlxG.sound.play(Paths.gameplaySound('start/readysetplant'));

		modePlay = true;

		var countdownSprite = new FlxSprite();
		countdownSprite.loadGraphic(Paths.gameplayImage('ui/countdown'), true, 310, 103);
		countdownSprite.animation.add('ready', [0], 0, false);
		countdownSprite.animation.add('set', [1], 0, false);
		countdownSprite.animation.add('plant', [2], 0, false);
		countdownSprite.screenCenter();
		countdownSprite.scrollFactor.set();
		add(countdownSprite);

		var showStep = function(animName:String, delay:Float)
		{
			new flixel.util.FlxTimer().start(delay, function(tmr:flixel.util.FlxTimer)
			{
				countdownSprite.animation.play(animName);
				countdownSprite.visible = true;

				countdownSprite.scale.set(1.3, 1.3);
				countdownSprite.alpha = 1;

				flixel.tweens.FlxTween.tween(countdownSprite.scale, {x: 1, y: 1}, 0.2, {ease: flixel.tweens.FlxEase.backOut});

				if (animName == 'plant')
				{
					flixel.tweens.FlxTween.tween(countdownSprite, {alpha: 0}, 0.3, {
						startDelay: 0.8,
						onComplete: function(t:flixel.tweens.FlxTween)
						{
							countdownSprite.destroy();
							getMusic();

							remainingTime = 20;

							levelScript?.onPlantingPhase();

							startTimer = new flixel.util.FlxTimer().start(remainingTime, function(tmr:flixel.util.FlxTimer)
							{
								onStart();
							});
						}
					});
				}
				else
				{
					flixel.tweens.FlxTween.tween(countdownSprite, {alpha: 0}, 0.2, {startDelay: 0.8});
				}
			});
		};

		countdownSprite.visible = false;
		showStep('ready', 0.0);
		showStep('set', 0.7);
		showStep('plant', 1.2);

		levelScript?.postCountdown();
	}

	public function onStart()
	{
		if (startFirstWave)
			return;

		startFirstWave = true;

		FlxG.sound.play(Paths.gameplaySound('zombiesarecoming'));
		hud.onStartZombies();
		spawnLevelZombies();

		levelScript?.onStart();
	}

	public function onWin():Void
	{
		levelScript?.onWin();
		trace('[LawnState] Win!');
	}

	public function onLose():Void
	{
		levelScript?.onLose();
		trace('[LawnState] GameOver.');
	}

	public function hugeWave():Void
	{
		levelScript?.hugeWave();
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
				var spawnY = spawnRow * background.tileHei + 37 + tileOffY;

				var createZombie = function()
				{
					var z = _zombieHost != null ? _zombieHost.spawnZombie(type, 800, spawnY, true) : new Zombie(800, spawnY, type, true);
					zombieGrp.add(z);
					sortZombiesByY();
				};

				if (delay > 0)
					new flixel.util.FlxTimer().start(delay, function(_) createZombie());
				else
				{
					createZombie();
				}
			}
		}
	}

	function sortZombiesByY():Void
	{
		zombieGrp.sort(flixel.util.FlxSort.byY, flixel.util.FlxSort.ASCENDING);
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

			if (startTimer != null && startTimer.active)
			{
				remainingTime = startTimer.timeLeft;
				startTimer.cancel();
			}

			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			levelScript?.onPause();

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

		if (paused || modeSelection)
			return;

		levelScript?.onUpdate(elapsed);

		plantGrp.forEachAlive(function(p:Plant)
		{
			p.dance();
			p.shootTimer -= elapsed;

			if (p.shootTimer <= 0)
			{
				if (checkForZombiesInRow(p))
				{
					makePlantShoot(p);

					p.shootTimer = p._handler.data.shootTimer ?? 1.5;
				}
			}
		});

		FlxG.overlap(projectileGrp, zombieGrp, onZombieHit);

		if (selectedPlant == null || selectedPlant == '')
		{
			tileSpr.visible = false;
			plantOverlay.visible = false;
			return;
		}

		var plantSelectedIndex:Int = Std.int(Plant.plantIDs.indexOf(selectedPlant));
		FlxG.watch.add(plantSelectedIndex, "String", "curPlantSelected");

		// Funni thingie just gets what tile the mouse is currently on
		curRow = Std.int(Math.max(0, Math.min(background.rows - 1, Math.round((FlxG.mouse.x - 30 - tileOffX - background.tileWid / 2) / background.tileWid))));
		curCol = Std.int(Math.max(0,
			Math.min(background.columns - 1, Math.round((FlxG.mouse.y - 75 - tileOffY - background.tileHei / 2) / background.tileHei))));

		var currentTile = background.tileData[curRow][curCol];
		var isValid = false;

		if (plantOverlay.plantableType == DEFAULT)
			isValid = !currentTile.hasDEFAULT;
		else if (plantOverlay.plantableType == TILED)
			isValid = !currentTile.hasTILED;
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

	private function placePlant()
	{
		var currentTile = background.tileData[curRow][curCol];
		tileSpr.setPosition(curRow * background.tileWid + 30 + tileOffX, curCol * background.tileHei + 75 + tileOffY);
		plantOverlay.setPosition(tileSpr.x + 7.5, tileSpr.y + 12.5);

		if (FlxG.mouse.justPressed && plantOverlay.visible)
		{
			var plantIndex = Plant.plantIDs.indexOf(selectedPlant);
			var key = Plant.plantIDs[plantIndex];
			var cost = AnimationHandler.animations[key]?.data?.cost ?? 100;

			if (hud.spendSun(cost))
			{
				#if debug
				trace('At Row ${curRow + 1}, Coloumn: ${curCol + 1}');
				#end

				var plRandom:String = FlxG.random.bool() ? 'plant' : 'plant2';
				FlxG.sound.play(Paths.gameplaySound('plant/$plRandom'));

				var px = plantOverlay.x;
				var py = plantOverlay.y;

				currentTile.appendPlant(plantOverlay.plantableType, () ->
				{
					var plant = _plantHost != null ? _plantHost.spawnPlant(key, px, py) : new Plant(px, py, Plant.plantIDs.indexOf(key));
					plantGrp.add(plant);

					levelScript?.onPlantPlaced(plant, curRow, curCol);

					return plant;
				});

				selectedPlant = '';
				plantOverlay.visible = false;
			}
			else
			{
				trace("There are not enough suns.");
				FlxG.sound.play(Paths.gameplaySound('plant/butter'));
			}
		}
	}

	function onZombieHit(proj:Projectile, zomb:Zombie)
	{
		if (!proj.isHit && !zomb.isDying)
		{
			proj.onHit();
			zomb.currentHealth -= proj.damage;

			levelScript?.onProjectileHit(proj, zomb);

			if (zomb.currentHealth <= 0)
			{
				levelScript?.onZombieKilled(zomb);
				zomb.death();
			}
		}
	}

	function checkForZombiesInRow(p:Plant):Bool
	{
		var foundTarget:Bool = false;

		zombieGrp.forEachAlive(function(z:Zombie)
		{
			if (!z.isDying)
			{
				if (Math.abs(z.y - p.y) < 60 && z.x > p.x && z.x < FlxG.width)
					foundTarget = true;
			}
		});

		return foundTarget;
	}

	override public function destroy()
	{
		levelScript?.onDestroy();
		levelScript = null;

		sunController?.destroy();
		sunController = null;

		super.destroy();
	}
}
