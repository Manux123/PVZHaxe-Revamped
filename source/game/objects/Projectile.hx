package game.objects;

import flixel.FlxSprite;
import haxe.Json;
import openfl.Assets;

typedef ProjectileJson =
{
	var path:String;
	var speed:Float;
	var health:Int;
}

class Projectile extends FlxSprite
{
	public var jsonData:ProjectileJson;
	public var damage:Int;

	public function new(x:Float, y:Float, type:String = "pea")
	{
		super(x, y);

		jsonData = Json.parse(Assets.getText(Paths.gameplayJson('projectiles/$type')));
		loadGraphic(Paths.gameplayImage('projectiles/${jsonData.path}'));
		damage = jsonData.health;
	}

	override function update(elapsed:Float)
	{
		velocity.x = jsonData.speed;

		super.update(elapsed);
	}
}
