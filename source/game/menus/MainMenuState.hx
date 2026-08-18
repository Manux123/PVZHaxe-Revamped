package game.menus;

import flixel.addons.ui.FlxUIInputText;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.State;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
#if windows
import core.api.DiscordRPC;
#end

class MainMenuState extends State
{
	// background stuff \\
	var selectMenu:FlxSprite;
	var tree:FlxSprite;
	var sky:FlxSprite;
	var backdrop:FlxSprite;
	var background:FlxSprite;

	// Select Menu Buttons \\
	/* ==Menu Button Pathss==
		Adventure Start: 'assets/menus/images/mainmenu/SelectorScreen_StartAdventure_Button1.png'
		Adventure Start Shadow: 'assets/menus/images/mainmenu/SelectorScreen_Shadow_StartAdventure.png'
		Adventure: 'assets/menus/images/mainmenu/SelectorScreen_Adventure_Button.png'
		Adventure Shadow: 'assets/menus/images/mainmenu/SelectorScreen_Shadow_Adventure.png'
	 */
	var adventure:FlxButton;
	var adventure_shadow:FlxSprite;
	var minigame:FlxButton;
	var minigame_shadow:FlxSprite;
	var almanac:FlxButton;
	// Pot Buttons \\
	var options:FlxButton;
	var help:FlxButton;
	var quit:FlxButton;
	// Funny Wood \\
	var woodName:FlxSprite;
	var woodUsrSwitch:FlxButton;
	var woodUsrName:FlxText;
	var woodBroken:FlxSprite;

	var acceptOption:Bool = false;

	// var name:String = 'No Name'; // will change I swear

	override public function create()
	{
		super.create();

		core.audio.DynamicGameMusic.musicMenu(Paths.menuMusic("main_menu_theme"));

		woodName = new FlxSprite(22, -8).loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_WoodSign1'));
		woodUsrSwitch = new FlxButton(25, 126);
		woodUsrSwitch.loadGraphic(Paths.menuImage('mainmenu/ScreenSelector_WoodSign_Button'), true, 291, 71);
		woodUsrName = new FlxText(147, 86);
		woodUsrName.setFormat(Paths.font('Brianne_s_hand'), 18, 0xFFF5C8, CENTER); // WHY IS THE E DIFFERENTTTTTTTTTTTTTTTTTT
		woodUsrName.text = GameSave.playerName != null ? GameSave.playerName + '!' : "Unknown!"; // We don't have a name yet
		woodBroken = new FlxSprite(32, 179).loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_WoodSign3'));

		FlxG.sound.play('assets/sounds/roll_in.ogg');
		background = new FlxSprite();
		background.makeGraphic(800, 600, FlxColor.WHITE);

		#if windows
		DiscordRPC.changePressence('In the Main Menu.');
		#end

		// Background Shit \\
		sky = new FlxSprite().loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_BG'));
		add(background);
		// Stupid masking because the actual images are jpegs and not pngs >:c \\

		selectMenu = AngelUtils.fromAlphaMask(Paths.menuImage('mainmenu/SelectorScreen_BG_Right'), Paths.menuImage('mainmenu/SelectorScreen_BG_Right_'), 71,
			41); // VSCode what the fuck is wrong with you

		tree = AngelUtils.fromAlphaMask(Paths.menuImage('mainmenu/SelectorScreen_BG_Left'), Paths.menuImage('mainmenu/SelectorScreen_BG_Left_'), 0, -80);

		backdrop = AngelUtils.fromAlphaMask(Paths.menuImage('mainmenu/SelectorScreen_BG_Center'), Paths.menuImage('mainmenu/SelectorScreen_BG_Center_'), 103,
			250);

		add(sky);
		add(backdrop);
		sky.setGraphicSize(800, 600);
		sky.updateHitbox();

		add(tree);
		add(selectMenu); // thank you Angel for helping me to get the masks to work, and for the Utils <3
		backdrop.setGraphicSize(778, 350); // not exact, but close
		// selectMenu.y = 40;
		// selectMenu.x = 70;
		add(woodName);
		add(woodUsrSwitch);
		add(woodBroken);
		add(woodUsrName);
		// Get the Select Menu Buttons \\
		getButtons();
		trace('[SYSTEM] tried loading buttons');
		doShit();
		trace("Doing shit?");
	}

	override function closeSubState()
	{
		super.closeSubState();
		if (minigame != null)
			minigame.active = true;
		if (adventure != null)
			adventure.active = true;
		if (quit != null)
			quit.active = true;
		if (help != null)
			help.active = true;
		if (options != null)
			options.active = true;
		persistentUpdate = true;
	}

	var nameTitle:FlxText;

	var nameSubTitle:FlxText;
	var nameInput:FlxUIInputText;
	var nameSubmit:FlxButton;

	function doShit()
	{
		trace('Animation not finished.');

		if (GameSave.playerName == null)
		{
			nameTitle = new FlxText(337.5, 241);
			nameTitle.setFormat('assets/fonts/DWARVESC.ttf', 24, 0xFFF5C8, CENTER);
			nameTitle.y -= 45;
			nameTitle.text = 'new user';
			nameSubTitle = new FlxText(279, 275);
			nameSubTitle.setFormat('assets/fonts/DWARVESC.ttf', 18, 0xFFF5C8, CENTER);
			nameSubTitle.y -= 25;
			nameSubTitle.text = 'Please enter your name:';

			nameInput = new FlxUIInputText(350, 289, 100, '');
			nameInput.setFormat('assets/fonts/DWARVESC.ttf', 18, 0xFFF5C8, CENTER);
			nameInput.maxLength = 12;

			// VScode likes to lie about this line, it does actually work.
			nameInput.color = 0x000000; // Even though the UI isn't finished, make it so you can at least read it! (I was very lazy 3 years ago) - Eliana

			nameSubmit = new FlxButton(288, 320, 'Ok', submitName);

			add(nameTitle);
			add(nameSubTitle);
			add(nameInput);
			add(nameSubmit);
		}

		trace("Continuing to main Function.");
	}

	function submitName()
	{
		GameSave.playerName = nameInput.text;
		nameInput.maxLength = 13;
		woodUsrName.text = GameSave.playerName + '!';

		trace('Set name to ' + GameSave.playerName);

		// Remove the UI
		remove(nameTitle);
		remove(nameSubTitle);
		remove(nameInput);
		remove(nameSubmit);
	}

	function getButtons()
	{
		trace('[SYSTEM] loaded button function');
		// Adventure Button \\
		adventure = new FlxButton(405, 65, "", openAdventure);
		// game data \\
		if (GameSave.isNewGame)
		{
			adventure.loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_StartAdventure_Button1'), true, 331, 146);
			adventure_shadow = new FlxSprite().loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_Shadow_StartAdventure'));
		}
		else
		{
			adventure.loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_Adventure_button'), true, 331, 146);
			adventure_shadow = new FlxSprite().loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_Shadow_Adventure'));
		}
		adventure_shadow.x = 399;
		adventure_shadow.y = 65;
		trace('[SYSTEM] adventure button');
		// Mini-Games Button \\
		minigame = new FlxButton(405, 65, "", openMinigames);
		minigame.loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_Survival_button'), true, 313, 133);
		minigame_shadow = new FlxSprite().loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_Shadow_Survival'));
		minigame.y = 173;
		minigame.x = 406;
		minigame_shadow.x = 407;
		minigame_shadow.y = 177;
		if (!GameSave.minigamesUnlocked)
			minigame.color = 0xFF808080;
		trace('[SYSTEM] Mini-Games button');

		// Almanac Button \\
		almanac = new FlxButton(405, 65, "", openAlmanac);
		almanac.loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_Almanac'), true, 99, 99);
		almanac.y = 433;
		almanac.x = 306;
		trace('[SYSTEM] Almanac button');

		add(adventure_shadow);
		add(minigame_shadow);
		add(adventure);
		add(minigame);
		add(almanac);

		// Pot Buttons \\
		trace('[SYSTEM] started Pot Button collection...');
		options = new FlxButton(565, 490, "", optionsShit);
		options.loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_Options'), true, 81, 31);
		help = new FlxButton(647, 529, "", helpShit);
		help.loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_Help'), true, 46, 22);
		quit = new FlxButton(720, 515, "", quitShit);
		quit.loadGraphic(Paths.menuImage('mainmenu/SelectorScreen_Quit'), true, 45, 27);
		add(options);
		add(help);
		add(quit);
		trace('[SYSTEM] finished get buttons function');
	}

	function openAdventure()
	{
		acceptOption = true;
		FlxG.sound.play('assets/sounds/gravebutton.ogg'); // button sound
		fuckYouStop();

		if (GameSave.isNewGame)
		{
			trace("[SYSTEM] New Adventure");
			game.LawnConfig.curLevel = "1-1";
		}
		else
		{
			trace("[SYSTEM] Resume Adventure");
		}

		trace("[SYSTEM] Animation not finished!");

		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('gameover/losemusic'));

		var wait:Float = 0;

		if (GameSave.isNewGame)
		{
			new FlxTimer().start(1.5, (tmr:FlxTimer) ->
			{
				FlxG.sound.play('assets/sounds/evillaugh.ogg');
			});
			wait = 6.5;
		}

		new FlxTimer().start(wait, (tmr:FlxTimer) ->
		{
			FlxG.switchState(new game.LawnState());
		});
	}

	function openMinigames()
	{
		if (acceptOption)
			return;

		FlxG.sound.play('assets/sounds/gravebutton.ogg'); // button sound
		if (GameSave.minigamesUnlocked)
		{
			trace("[SYSTEM] MiniGame Unlocked");
			FlxG.switchState(new MinigameState());
		}
		else
		{
			trace("[SYSTEM] MiniGame Locked");
			FlxG.switchState(new MinigameState());
		}
	}

	function openAlmanac()
	{
		if (acceptOption)
			return;
		FlxG.sound.play('assets/sounds/gravebutton.ogg'); // button sound
		FlxG.switchState(new game.menus.almanac.AlmanacState());
	}

	function fuckYouStop()
	{
		minigame.active = false;
		adventure.active = false;
		quit.active = false;
		help.active = false;
		options.active = false;
	}

	function optionsShit()
	{
		if (acceptOption)
			return;
		FlxG.sound.play('assets/sounds/tap.ogg');
		fuckYouStop();
		persistentUpdate = false;
		persistentDraw = true;
		openSubState(new game.menus.substate.OptionsSubstate());
	}

	function helpShit()
	{
		if (acceptOption)
			return;
		FlxG.sound.play('assets/sounds/tap.ogg'); // button sound
		FlxG.sound.music.stop();
		new FlxTimer().start(0.2, (tmr:FlxTimer) ->
		{
			FlxG.switchState(new game.menus.options.HelpState());
		});
	}

	function quitShit()
	{
		if (acceptOption)
			return;
		FlxG.sound.play('assets/sounds/tap.ogg'); // button sound
		// !!IMPORTANT: GET A MENU BEFORE CLOSING!! \\
		lime.system.System.exit(0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		#if windows
		// keep it running when it's alive and kill it when it's not?????? \\
		DiscordRPC.process();
		if (false)
		{
			DiscordRPC.shutdown();
		}
		#end
	}
}
