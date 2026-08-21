package core.sprites;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.geom.Point;
import flixel.animation.FlxAnimationController;
import core.sprites.AnimationData;
import haxe.Json;

/**
 * Author: Inliothixi (2024)
 */
class AnimationHandler
{
	static public var animations:Map<String, Animation> = new Map<String, Animation>();

	/**
	 * Get existing animation to avoid duplicated and save memory.
	 * @param path Path to Json Data containing Animation ( e.g. `assets/gameplay/data/plants/peashooter.json`)
	 * @param key Key for Animation to avoid duplicates (e.g. `peashooter`)
	 */
	static public function parseAnimation(path:String, key:String):Void
	{
		if (animations.exists(key))
			return;

		var datas:PlantJson = Json.parse(openfl.utils.Assets.getText(Paths.gameplayJson('$path/$key')));
		animations[key] = new Animation(Paths.gameplaySparrow('plants/${datas.textureName}'), datas);
		for (anim in datas.anims)
		{
			animations[key].sprite.animation.addByPrefix(anim.prefix, anim.postfix, anim.fps, anim.looped);
			animations[key].offsets[anim.prefix] = new Point(anim.offsets[0], anim.offsets[1]);
		}

		var g = animations[key].sprite.graphic;
		if (g != null && g.bitmap != null)
			g.bitmap.disposeImage();
	}
}

class Animation
{
	public var offsets:Map<String, Point>;
	public var sprite:FlxSprite;
	public var data:PlantJson;

	public function new(frames:FlxAtlasFrames, data:PlantJson)
	{
		this.offsets = new Map<String, Point>();
		this.sprite = new FlxSprite();
		this.sprite.frames = frames;
		this.sprite.animation = new FlxAnimationController(sprite);
		this.sprite.kill();
		this.sprite.active = false;
		this.data = data;
	}
}

typedef PlantJson =
{
	var textureName:String;
	var ?timer:Float;
	var ?anims:Array<AnimationData>;
	var ?flipX:Bool;
	var ?flipY:Bool;
	var ?projectile:String;
	var ?cost:Int;
	var ?shootTimer:Float;
	var ?health:Int;
}
