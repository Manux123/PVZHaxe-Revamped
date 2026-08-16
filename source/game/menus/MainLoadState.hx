package game.menus;

#if windows
import core.api.DiscordRPC;
#end
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.State;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.objects.Plant;
import core.sprites.AnimationHandler;

class MainLoadState extends State
{
	var loadingtxt:FlxText;
	var popcap_logo:FlxSprite;
	var popcap:FlxText;
	var eliana:FlxText;
	var eGunner:FlxText;
	var haxe_edition:FlxText;
	// PvZ Logo \\
	var pvz_logo:FlxSprite;
	// Loading Bar \\
	var bar_dirt:FlxSprite;
	var bar_grass:FlxSprite;
	var grass_ball:FlxSprite;
	var continueBttn:FlxButton;
	// fade shit \\
	var black:FlxSprite;

	// Real Asset Loading \\
	var loadQueue:Array<Void->Void> = [];
	var loadTotal:Int = 0;
	var loadDone:Int = 0;
	var loadingAssets:Bool = false;
	var assetsPerFrame:Int = 1; // subir si hay muchos assets y se quiere que vaya más rápido

	override public function create()
	{
		super.create();
		GameSave.init();

		#if windows
		DiscordRPC.init();
		#end
		// Plays the Main Menu Theme (Dave Intro) \\
		FlxG.sound.playMusic(Paths.music("main_menu_theme"));
		FlxAssets.FONT_DEFAULT = 'assets/fonts/Brianne_s_hand.ttf';
		popcap = new FlxText(260, 38, 339, 'Plants VS Zombies made by:', 24);
		popcap.alpha = 0;

		// Haxe Edition Creator
		eliana = new FlxText(237, 377, 433, 'Haxe Edition made by: Eliana', 24);
		eliana.alpha = 0;
		// Haxe Engine Creator (Thanks for continuing this :D)
		eGunner = new FlxText(237, 425, 433, 'Haxe Engine made by: Electr0Gunner', 24);
		eGunner.alpha = 0;

		popcap_logo = new FlxSprite(250, 65).loadGraphic('assets/images/menu/loading/PopCap_Logo.jpg');
		popcap_logo.alpha = 0;

		add(popcap);
		add(eliana);
		add(eGunner);
		add(popcap_logo);
		// Antialiasing \\
		popcap_logo.antialiasing = true;
		popcap.antialiasing = true;
		eliana.antialiasing = true;
		eGunner.antialiasing = true;
		fadeAnimation();
	}

	function fadeAnimation()
	{
		FlxTween.tween(popcap_logo, {alpha: 1}, 2, {ease: FlxEase.expoInOut});
		FlxTween.tween(popcap, {alpha: 1}, 2, {ease: FlxEase.expoInOut});

		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			FlxTween.tween(eliana, {alpha: 1}, 2, {ease: FlxEase.expoInOut});
			FlxTween.tween(eGunner, {alpha: 1}, 2.3, {ease: FlxEase.expoInOut});
		});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			textPlay();
		});
	};

	function textPlay()
	{
		new FlxTimer().start(2.0, function(tmr:FlxTimer)
		{
			trace('Should have switched to main loading');
			mainLoading();
		});
	};

	function mainLoading()
	{
		FlxTween.tween(popcap_logo, {alpha: 0}, 2, {ease: FlxEase.expoInOut});
		FlxTween.tween(popcap, {alpha: 0}, 2, {ease: FlxEase.expoInOut});
		FlxTween.tween(eliana, {alpha: 0}, 2, {ease: FlxEase.expoInOut});
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			FlxTween.tween(eGunner, {alpha: 0}, 1.7, {ease: FlxEase.expoInOut});
		});

		new FlxTimer().start(2, function(tmr)
		{
			// remove everything not needed \\
			remove(popcap);
			popcap.destroy();
			popcap = null;
			remove(popcap_logo);
			popcap_logo.destroy();
			popcap_logo = null;
			remove(eliana);
			eliana.destroy();
			eliana = null;
			remove(eGunner);
			eGunner.destroy();
			eGunner = null;

			// Loading Text Properties \\
			loadingtxt = new FlxText(347, 544, 0, "Loading...", 24);
			loadingtxt.color = FlxColor.fromRGB(217, 183, 32); // no more white loadingtxt
			// Contiue Button Properties \\
			continueBttn = new FlxButton(319, 553, "", continuefunc);

			// Load the start button image \\
			continueBttn.loadGraphic('assets/images/menu/loading/strtbttn.png', true, 165, 12);
			// add background \\
			var background:FlxSprite;
			background = new FlxSprite().loadGraphic('assets/images/menu/loading/titlescreen.jpg');
			// PvZ Logo \\
			pvz_logo = AngelUtils.fromAlphaMask('assets/images/menu/loading/PvZ_Logo.jpg', 'assets/images/menu/loading/PvZ_Logo_.png', 51, 10);
			add(background);
			add(pvz_logo);
			// Haxe Edition Text \\
			haxe_edition = new FlxText(305, 117, 216, 'Haxe Edition', 36);
			haxe_edition.color = FlxColor.BLACK;
			haxe_edition.font = 'assets/fonts/HouseofTerror-Regular.ttf';
			add(haxe_edition);
			// Loading Bar \\

			bar_dirt = new FlxSprite(244, 535).loadGraphic('assets/images/menu/loading/LoadBar_dirt.png');
			bar_grass = new FlxSprite(243, 520).loadGraphic('assets/images/menu/loading/LoadBar_grass.png');
			grass_ball = new FlxSprite(231, 484).loadGraphic('assets/images/menu/loading/SodRollCap.png');
			add(bar_dirt);
			add(bar_grass);
			add(grass_ball);
			add(loadingtxt);
			// Antialiasing \\
			loadingtxt.antialiasing = true;
			haxe_edition.antialiasing = true;
			bar_dirt.antialiasing = true;
			bar_grass.antialiasing = true;
			grass_ball.antialiasing = true;
			pvz_logo.antialiasing = true;
			// Moving the grass thing \\
			/* [INSERT GRASS MASKING CODE HERE] */
			FlxTween.tween(grass_ball, {angle: 360.0}, 5, {type: FlxTweenType.LOOPING}); // speeeen
			buildLoadQueue();

			// fade shit \\
			black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			add(black);
			FlxTween.tween(black, {alpha: 0}, 2, {onComplete: function(tween) remove(black)});
		});
	}

	function buildLoadQueue()
	{
		loadQueue = [];

		for (plant in Plant.plantIDs)
		{
			var id = plant;
			loadQueue.push(() ->
			{
				AnimationHandler.parseAnimation('data/plants', id);
			});
		}

		// HUD
		loadQueue.push(() ->
		{
			openfl.Assets.cache.getBitmapData(Paths.image('ui/SeedBank'));
		});

		var menuImages = [
			'assets/images/menu/mainmenu/ScreenSelector_WoodSign_Button.png',
			'assets/images/menu/mainmenu/SelectorScreen_Adventure_Button.png',
			'assets/images/menu/mainmenu/SelectorScreen_Adventure_button.png',
			'assets/images/menu/mainmenu/SelectorScreen_Almanac.png',
			'assets/images/menu/mainmenu/SelectorScreen_BG.jpg',
			'assets/images/menu/mainmenu/SelectorScreen_BG_Center.jpg',
			'assets/images/menu/mainmenu/SelectorScreen_BG_Center_.png',
			'assets/images/menu/mainmenu/SelectorScreen_BG_Left.jpg',
			'assets/images/menu/mainmenu/SelectorScreen_BG_Left_.png',
			'assets/images/menu/mainmenu/SelectorScreen_BG_Right.jpg',
			'assets/images/menu/mainmenu/SelectorScreen_BG_Right_.png',
			'assets/images/menu/mainmenu/SelectorScreen_Help.png',
			'assets/images/menu/mainmenu/SelectorScreen_Options.png',
			'assets/images/menu/mainmenu/SelectorScreen_Quit.png',
			'assets/images/menu/mainmenu/SelectorScreen_Shadow_Adventure.png',
			'assets/images/menu/mainmenu/SelectorScreen_Shadow_StartAdventure.png',
			'assets/images/menu/mainmenu/SelectorScreen_Shadow_Survival.png',
			'assets/images/menu/mainmenu/SelectorScreen_StartAdventure_Button1.png',
			'assets/images/menu/mainmenu/SelectorScreen_Survival_button.png',
			'assets/images/menu/mainmenu/SelectorScreen_WoodSign1.png',
			'assets/images/menu/mainmenu/SelectorScreen_WoodSign3.png',
			'assets/images/menu/mainmenu/options_backtogamebutton_full.png',
			'assets/images/menu/options_menuback.jpg',
			'assets/images/menu/options_menuback_.png',
		];
		for (path in menuImages)
		{
			var p = path;
			loadQueue.push(() ->
			{
				openfl.Assets.loadBitmapData(p);
			});
		}

		// Main Menu: sonidos
		var menuSounds = [
			'assets/sounds/buttonclick.ogg',
			'assets/sounds/evillaugh.ogg',
			'assets/sounds/gravebutton.ogg',
			'assets/sounds/losemusic.ogg',
			'assets/sounds/roll_in.ogg',
			'assets/sounds/tap.ogg',
		];
		for (path in menuSounds)
		{
			var p = path;
			loadQueue.push(() ->
			{
				FlxG.sound.cache(p);
			});
		}

		loadTotal = loadQueue.length;
		loadDone = 0;
		loadingAssets = loadTotal > 0;

		if (!loadingAssets)
			onLoadComplete(); // no había nada para cargar, saltamos directo
	}

	function onLoadComplete()
	{
		remove(loadingtxt);
		remove(grass_ball);
		add(continueBttn);
		DiscordRPC.changePressence('Waiting for User Input...');
	}

	function continuefunc()
	{
		FlxG.switchState(new game.menus.MainMenuState());
	}

	override public function update(elapsed:Float)
	{
		DebugUtils.debug(loadingtxt);
		super.update(elapsed);
		// keep it running when it's a live and kill it when it's not?????? \\
		DiscordRPC.process();
		if (false)
			DiscordRPC.shutdown();

		if (loadingAssets)
		{
			for (i in 0...assetsPerFrame)
			{
				if (loadQueue.length == 0)
				{
					loadingAssets = false;
					onLoadComplete();
					break;
				}
				var job = loadQueue.shift();
				job();
				loadDone++;
			}

			var pct = loadTotal > 0 ? loadDone / loadTotal : 1.0;
			bar_grass.clipRect = new FlxRect(bar_dirt.x, bar_dirt.y, bar_dirt.width * pct, bar_grass.height);

			grass_ball.x = 231 + (508 - 231) * pct;
			grass_ball.y = 484 + (500 - 484) * pct;
			var s = 1 - (1 - 0.4) * pct;
			grass_ball.scale.set(s, s);
		}
	}

	override public function destroy()
	{
		if (popcap_logo != null)
			FlxTween.cancelTweensOf(popcap_logo);
		if (popcap != null)
			FlxTween.cancelTweensOf(popcap);
		if (eliana != null)
			FlxTween.cancelTweensOf(eliana);
		if (eGunner != null)
			FlxTween.cancelTweensOf(eGunner);
		if (grass_ball != null)
			FlxTween.cancelTweensOf(grass_ball);
		if (black != null)
			FlxTween.cancelTweensOf(black);
		FlxTimer.globalManager.clear();

		super.destroy();
	}
}
