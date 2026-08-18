package game.objects;

import game.controllers.HUD;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;

class Sun extends FlxSprite
{
	public static inline var FALL_SPEED:Float = 60.0;

	public static inline var SPIN_SPEED:Float = 90.0;

	public var sunValue:Int = 25;

	public var targetY:Float = 0.0;

	var hud:HUD;

	var collected:Bool = false;

	public function new(x:Float, y:Float, targetY:Float, hud:HUD, ?sunValue:Int = 25)
	{
		super(x, y);
		this.targetY = targetY;
		this.hud = hud;
		this.sunValue = sunValue;

		loadGraphic(Paths.gameplayImage("Sun"));
		setGraphicSize(65, 65);
		updateHitbox();

		this.x -= width / 2;

		velocity.y = FALL_SPEED;
		angle = 0;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		angle += SPIN_SPEED * elapsed;

		if (velocity.y > 0 && y >= targetY)
		{
			y = targetY;
			velocity.y = 0;
		}

		if (!collected && FlxG.mouse.justPressed && overlapsPoint(FlxG.mouse.getWorldPosition()))
			collect();
	}

	function collect()
	{
		collected = true;
		velocity.set(0, 0);

		hud.addSun(sunValue);

		var collectSound = FlxG.sound.play(Paths.sound('hud/points'));

		if (collectSound != null)
			collectSound.pitch = FlxG.random.float(0.9, 1.1);

		FlxTween.tween(this, {x: this.x - 200, y: y - 60, alpha: 0}, 0.3, {
			ease: FlxEase.quadIn,
			onComplete: (_) -> kill()
		});
	}
}
