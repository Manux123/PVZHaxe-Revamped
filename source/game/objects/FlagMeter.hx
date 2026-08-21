package game.objects;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxBar;
import flixel.math.FlxMath;
import flixel.math.FlxRect;

class FlagMeter extends FlxSpriteGroup
{
	public var progressBar:FlxBar;
	public var levelText:FlxSprite;
	public var zombieHead:FlxSprite;
	public var flags:FlxSpriteGroup;

	public var currentProgress(default, set):Float = 0;

	public function new(X:Float, Y:Float)
	{
		super(X, Y);

		progressBar = new FlxBar(0, 0, RIGHT_TO_LEFT, 150, 20, this, "currentProgress", 0, 1, true);
		progressBar.createImageBar(Paths.gameplayImage("ui/levelBar/FlagMeter_bg"), Paths.gameplayImage("ui/levelBar/FlagMeter_fg"));
		add(progressBar);

		levelText = new FlxSprite(0, 0, Paths.gameplayImage("ui/levelBar/FlagMeterLevelProgress"));
		levelText.x = progressBar.x;
		levelText.y = progressBar.y + 2;
		add(levelText);

		flags = new FlxSpriteGroup();
		add(flags);

		addFlagAt(0.5);
		addFlagAt(1.0);

		zombieHead = new FlxSprite(0, 0);
		zombieHead.loadGraphic(Paths.gameplayImage("ui/levelBar/FlagMeterParts"), true, 30, 30);
		zombieHead.animation.add("idle", [0], 1, false);
		zombieHead.animation.play("idle");

		zombieHead.y = progressBar.y + (progressBar.height / 2) - (zombieHead.height / 2);
		add(zombieHead);

		updateZombieHeadPosition();
	}

	public function addFlagAt(percentage:Float):Void
	{
		var flag = new FlxSprite();
		flag.loadGraphic(Paths.gameplayImage("ui/levelBar/FlagMeterParts"), true, 20, 30);
		flag.animation.frameIndex = 1;

		var targetX = progressBar.x + progressBar.width - (progressBar.width * percentage);

		flag.x = targetX - (flag.width / 2);
		flag.y = progressBar.y - (flag.height / 2);

		flags.add(flag);
	}

	private function set_currentProgress(Value:Float):Float
	{
		currentProgress = FlxMath.bound(Value, 0, 1);
		updateZombieHeadPosition();
		return currentProgress;
	}

	private function updateZombieHeadPosition():Void
	{
		if (zombieHead != null && progressBar != null)
		{
			var targetX = progressBar.x + progressBar.width - (progressBar.width * currentProgress);
			zombieHead.x = targetX - (zombieHead.width / 2);
		}
	}
}
