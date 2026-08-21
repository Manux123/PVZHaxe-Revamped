package game.objects;

import flixel.FlxSprite;
import haxe.Json;
import openfl.Assets;

typedef ProjectileJson =
{
	var path:String;
	var hitbox:Array<Float>;
	var ?speed:Float;
	var damage:Int;
	var sound:String;
}

@:scriptable
class Projectile extends FlxSprite
{
	public var jsonData:ProjectileJson;

	public var type:String;

	public var isHit:Bool = false;

	public var damage(get, never):Int; // bites it can withstand

	inline function get_damage():Int
		return jsonData.damage ?? -25;

	public function new(x:Float, y:Float, type:String = "pea")
	{
		super(x, y);
		this.type = type;

		jsonData = Json.parse(Assets.getText(Paths.gameplayJson('projectiles/$type')));
		loadGraphic(Paths.gameplayImage('projectiles/${jsonData.path}'));

		if (jsonData.hitbox != null)
		{
			setSize(width * (jsonData.hitbox[0] ?? 1), height * (jsonData.hitbox[1] ?? 1));
			centerOffsets();
		}

		velocity.x = jsonData.speed ?? 400;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (x > FlxG.width + 100 || x < -50)
		{
			destroy();
		}
	}

	public function onHit():Void
	{
		if (isHit)
			return;

		isHit = true;
		velocity.x = 0;

		var plRandom:Int = FlxG.random.int(1, 3);
		FlxG.sound.play(Paths.gameplaySound('plant/splat'+plRandom));

		if (animation.exists("splat"))
		{
			playAnim("splat", true);
			animation.finishCallback = function(name:String)
			{
				destroy();
			};
		}
		else
		{
			destroy();
		}
	}

	public function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
	{
		if (animation.exists(animName))
			animation.play(animName, force, reversed, frame);
	}
}
