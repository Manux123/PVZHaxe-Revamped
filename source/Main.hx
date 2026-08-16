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
		addChild(new FlxGame(800, 600, MainLoadState, 60, 60, false, false));
		FlxG.autoPause = false;

		// mouse \\
		FlxG.mouse.load(Paths.image('cursor'));

		WindowAPI.init();

		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		#end
	}
}
