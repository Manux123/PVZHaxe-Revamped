package game.objects;

import core.sprites.AnimationHandler;
import flixel.FlxSprite;

@:scriptable
class Plant extends flixel.FlxSprite
{
	static public var plantIDs:Array<String> = ['peashooter'];

	public static function registerID(id:String):Void
	{
		if (!plantIDs.contains(id))
			plantIDs.push(id);
	}

	public var _handler:Animation;

	public var currentHealth:Int = 4;

	public var plantID:Int;
	public var plantableType:PlantableType;
	public var plantType:PlantType;
	public var isAsleep:Bool;
	public var isShooting:Bool = false;

	public var shootTimer:Float = 0;

	public var cost(get, never):Int;

	inline function get_cost():Int
		return _handler.data.cost ?? 100;

	var shadow:FlxSprite;

	public var plantHealth(get, never):Int; // bites it can withstand

	inline function get_plantHealth():Int
		return _handler.data.health ?? 4;

	public function new(x:Float = 0, y:Float = 0, plantID:Int = 0, plantableType:PlantableType = DEFAULT, plantType:PlantType = ALL)
	{
		super(x, y);
		this.plantableType = plantableType;
		this.plantType = plantType;

		var key = plantIDs[plantID];
		_handler = AnimationHandler.animations[key];
		frames = _handler.sprite.frames;
		animation.copyFrom(_handler.sprite.animation);
		playAnim('idle');
		updateHitbox();

		currentHealth = plantHealth;

		shadow = new FlxSprite(0, 0);
		shadow.loadGraphic(Paths.gameplayImage('shadowPZ'));
	}

	override function draw()
	{
		shadow.x = x + (width - shadow.width) / 2 - 5;
		shadow.y = y + height - shadow.height / 2 - 7;
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

	public function attack():Projectile
	{
		if (isAsleep || _handler.data.projectile == null)
			return null;

		isShooting = true;

		var spawnX = x + width - 10;
		var spawnY = y + 10;

		var proj = new Projectile(spawnX, spawnY, _handler.data.projectile);

		playAnim("shoot", true);

		if (animation.curAnim.finished && animation.curAnim.name == "shoot")
			isShooting = false;

		return proj;
	}

	public function dance() {
		if (isShooting)
        {
            if (animation.curAnim != null && animation.curAnim.name == "shoot" && animation.curAnim.finished)
            {
                isShooting = false;
                playAnim('idle');
            }
            return;
        }

		if (animation.curAnim != null && animation.curAnim.finished && animation.curAnim.name == "idle")
			playAnim('idle');
	}

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
