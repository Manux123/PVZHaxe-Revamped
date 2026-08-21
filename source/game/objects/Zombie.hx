package game.objects;

import flxanimate.FlxAnimate;
import flixel.FlxSprite;
import haxe.Json;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import core.sprites.AnimationData;
import openfl.Assets;

typedef ZombieJson =
{
	var textureName:String;
	var ?health:Int;
	var ?speed:Float;
	var anims:Array<AnimationData>;
	var ?flipX:Bool;
	var ?flipY:Bool;
}

@:scriptable
class Zombie extends FlxSprite
{
	public var jsonSystem:ZombieJson;
	public var curZombie:String = 'basic';
	public var isWalking:Bool = false;
	public var animOffsets:Map<String, Array<Dynamic>>;

	public var currentHealth:Int = 100;

	public var zombieHealth(get, never):Int;

	inline function get_zombieHealth():Int
		return jsonSystem.health ?? 100;

	var shadow:FlxSprite;

	public function new(x:Float, y:Float, ?zombieName:String = "basic", ?shouldWalk:Bool = false)
	{
		super(x, y);
		curZombie = zombieName;
		animOffsets = new Map<String, Array<Dynamic>>();
		isWalking = shouldWalk;
		var tex:FlxAtlasFrames;
		var path:String;
		switch (curZombie)
		{
			default:
				jsonSystem = Json.parse(Assets.getText(Paths.gameplayJson('zombies/$curZombie')));
				tex = Paths.gameplaySparrow('zombies/$curZombie/${jsonSystem.textureName}');
				frames = tex;

				for (anim in jsonSystem.anims)
				{
					if (anim.fps < 1)
						anim.fps = 12;

					if (anim.looped != true && anim.looped != false)
						anim.looped = false;

					animation.addByPrefix(anim.prefix, anim.postfix, anim.fps, anim.looped);
					addOffset(anim.prefix, anim.offsets[0], anim.offsets[1]);
				}

				flipX = jsonSystem.flipX;
				flipY = jsonSystem.flipY;

				if (!isWalking)
					playAnim("idle");
				else
					playAnim("walk");
		}

		currentHealth = zombieHealth;

		shadow = new FlxSprite(0, 0);
		shadow.loadGraphic(Paths.gameplayImage('shadowPZ'));
	}

	override function draw()
	{
		if (shadow != null)
		{
			shadow.x = x + (width - shadow.width) / 2 - 5;
			shadow.y = y + height - shadow.height / 2 + 15;
			shadow.cameras = cameras;
			shadow.draw();
		}

		super.draw();
	}

	override function destroy()
	{
		shadow.destroy();
		shadow = null;
		super.destroy();
	}

	public var isDying:Bool = false;

	var _deathTweening:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isDying)
		{
			if (!_deathTweening && animation.curAnim != null && animation.curAnim.finished)
			{
				_deathTweening = true;
				flixel.tweens.FlxTween.tween(this, {alpha: 0}, 0.4, {
					onComplete: function(_) kill()
				});
				flixel.tweens.FlxTween.tween(shadow, {alpha: 0}, 0.4);
			}
			return;
		}

		this.velocity.x = jsonSystem.speed - (jsonSystem.speed * 2); // makes the value negative so it goes left

		if (animation.curAnim.finished)
		{
			if (isWalking)
				this.playAnim("walk");
		}
	}

	public function death():Void
	{
		if (isDying)
			return;
		isDying = true;

		var deathRandom:Int = FlxG.random.int(1, 3);
		var animName = 'death' + deathRandom;

		if (animation.exists(animName))
		{
			playAnim(animName);
			this.velocity.x = 0;
		}
		else
		{
			flixel.tweens.FlxTween.tween(this, {alpha: 0}, 0.4, {
				onComplete: function(_) destroy()
			});
			flixel.tweens.FlxTween.tween(shadow, {alpha: 0}, 0.4);
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame); // so i dont specify EACH F###ING TIME
		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
	}
}
