package game.objects;

import core.sprites.AnimationHandler;
import flixel.FlxSprite;

class Plant extends flixel.FlxSprite
{
	static public final plantIDs:Array<String> = ['peashooter'];

	public var _handler:Animation;

	public var plantID:Int;
	public var plantableType:PlantableType;
	public var plantType:PlantType;
	public var isAsleep:Bool;
	public var isShooting:Bool;

	var shadow:FlxSprite;

	public function new(x:Float = 0, y:Float = 0, plantID:Int = 0, plantableType:PlantableType = DEFAULT, plantType:PlantType = ALL)
	{
		super(x, y);
		this.plantableType = plantableType;
		this.plantType = plantType;

		var key = plantIDs[plantID];
		_handler = AnimationHandler.animations[key];
		frames = _handler.sprite.frames;
		animation.copyFrom(_handler.sprite.animation);
		animation.play("idle");
		updateHitbox();

		shadow = new FlxSprite(0, 0);
		shadow.loadGraphic(Paths.image('plants/plantshadow'));
		shadow.alpha = 0.5;
	}

	override function draw()
	{
		shadow.x = x + (width - shadow.width) / 2 - 20;
		shadow.y = y + height - shadow.height / 2 - 20;
		shadow.cameras = cameras;
		shadow.draw();

		super.draw();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function destroy()
	{
		shadow.destroy();
		shadow = null;
		super.destroy();
	}

	public function attack(projectile:String):Void {}

	public function damage(points:Int):Void {}

	public function sleep():Void {};

	public function wake():Void {};

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);
		if (!_handler.offsets.exists(AnimName))
		{
			offset.set();
			return;
		}
		var animOffset = _handler.offsets[AnimName];
		offset.set(animOffset.x, animOffset.y);
	}
}

enum PlantableType
{
	DEFAULT; // Normal Plants ect
	TILED; // Flower Pots and Lilipads
	SECONDARY; // Pumpkins
}

enum DamageType
{
	NORMAL; // addin more later???
	MASSIVE;
	LIGHT;
}

enum PlantType
{
	ALL; // Normal Plants ect.
	NIGHTONLY; // Sleeps during Day time
	DAYONLY; // Sleeeps during Night time
}
