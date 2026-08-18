package;

import core.api.WindowAPI;
import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.display.FPS;

class Main extends Sprite
{
	static public var fpsCounter:FPS;
	static public var antiAlias:Bool = true;

	public function new()
	{
		super();
		var game = new FlxGame(800, 600, game.menus.MainLoadState, 60, 60, false, false);
		addChild(game);

		game.addEventListener(openfl.events.Event.ADDED_TO_STAGE, function(_)
		{
			FlxG.autoPause = false;
		});

		FlxG.mouse.load('assets/cursor.png');

		WindowAPI.init();

		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		#end

		stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, onKeyDown);
	}


	private function onKeyDown(e:openfl.events.KeyboardEvent):Void {
		if (e.keyCode == flash.ui.Keyboard.F11) {
			openfl.Lib.application.window.fullscreen = !openfl.Lib.application.window.fullscreen;
			core.api.WindowAPI.resizeGame();
		}
	}
}
