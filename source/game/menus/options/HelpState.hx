package game.menus.options;

import flixel.util.FlxTimer;
import flixel.system.FlxAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.State;

using flixel.util.FlxSpriteUtil;

#if windows
import core.api.DiscordRPC;
#end

class HelpState extends State
{
	var bg:FlxSprite;
	var paper:FlxSprite;
	var text:FlxSprite;
	var fade:FlxSprite;
	var button:FlxButton;

	override public function create()
	{
		super.create();
		FlxAssets.FONT_DEFAULT = 'assets/fonts/DWARVESC.ttf';
		DiscordRPC.changePressence('Reading Help.');

		button = new FlxButton(325, 521, '', goBack);
		button.loadGraphic(Paths.menuImage('notes/help_Button'), true, 156, 42);
		bg = new FlxSprite().loadGraphic(Paths.gameplayImage('levels/grassday/grassday'));
		paper = AngelUtils.fromAlphaMask(Paths.menuImage('notes/ZombieNote'), Paths.menuImage('notes/ZombieNote_'), 80, 79.5);
		text = new FlxSprite(130.5, 131.5).loadGraphic(Paths.menuImage('notes/text/ZombieNoteHelp'));
		fade = new FlxSprite().loadGraphic(Paths.menuImage('notes/text/ZombieNoteHelpBlack'));

		FlxG.sound.play('assets/sounds/paper.ogg');

		add(bg);
		add(paper);
		add(text);
		add(button);
		bg.screenCenter();
		add(fade);
		fade.width = FlxG.width;
		fade.height = FlxG.height;
		fade.screenCenter();
		fade.setGraphicSize(3000); // just want to fill the screen tbh
		bg.setGraphicSize(3000);
		fadeAnimation();
	}

	function fadeAnimation()
	{
		fade.alpha = 1;
		FlxTween.tween(fade, {alpha: 0}, 0.5, {ease: FlxEase.expoInOut});
	};

	function goBack()
	{
		trace("go back! I want to be MONKE!"); // I wrote this at school, end me
		FlxG.sound.play('assets/sounds/tap.ogg'); // button sound
		new FlxTimer().start(0.2, (tmr:FlxTimer) ->
		{
			FlxG.switchState(new game.menus.MainMenuState());
		});
	};

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		DebugUtils.debug(text);
	}
}