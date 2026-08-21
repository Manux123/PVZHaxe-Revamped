package game.menus.substate;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class PauseSubstate extends flixel.Substate
{
	var optionsOpen = false;
	var optionsMenu:FlxSpriteGroup;
	var optionsBG:FlxSprite;
	var optionsOk:FlxButton;
	var backTo:FlxButton;
	var optionsOkTextShadow:FlxText;

	override public function create()
	{
		super.create();

		destroySubStates = false;
		this.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

		optionsBG = AngelUtils.fromAlphaMask(Paths.menuImage('general/options/options_menuback'), Paths.menuImage('general/options/options_menuback_'), 0, 0);

		optionsOk = new FlxButton(0, 0, "", closeOptions);
		optionsOk.loadGraphic(Paths.menuImage('general/options/options_backtogamebutton_full'), true, 360, 100);

		backTo = new FlxButton(0, 0, "", backToMenu);
		backTo.loadGraphic(Paths.menuImage('general/options/options_backtogamebutton_full'), true, 360, 100);
		backTo.scale.set(0.6, 0.6);
		backTo.updateHitbox();

		optionsMenu = new FlxSpriteGroup();
		optionsMenu.add(optionsBG);
		optionsMenu.add(backTo);
		optionsMenu.add(optionsOk);
		add(optionsMenu);
		optionsMenu.screenCenter();

		optionsOk.x = optionsBG.x + 29;
		optionsOk.y = optionsBG.y + 380;

		backTo.x = optionsBG.x + 100;
		backTo.y = optionsBG.y + 315;

		FlxG.sound.play(Paths.sound('roll_in'));

		optionsOpen = true;
	}

	function closeOptions()
	{
		game.LawnState.instance.paused = false;
		game.LawnState.instance.persistentUpdate = true;

		if (FlxG.sound.music != null)
			FlxG.sound.music.resume();

		FlxG.sound.play(Paths.sound('hud/buttonclick'));

		if (!game.LawnState.instance.startFirstWave && game.LawnState.instance.remainingTime > 0)
		{
			game.LawnState.instance.startTimer = new flixel.util.FlxTimer().start(game.LawnState.instance.remainingTime, function(tmr:flixel.util.FlxTimer)
			{
				game.LawnState.instance.onStart();
			});
		}

		close();
	}

	function backToMenu()
	{
		game.LawnState.instance.paused = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.play(Paths.sound('hud/buttonclick'));
		close();
		FlxG.switchState(new game.menus.MainMenuState());
	}
}
