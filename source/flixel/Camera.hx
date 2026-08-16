package flixel;

import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Camera extends FlxCamera
{
	public var followTarget:FlxPoint = null;
	public var camLerp:Float = 0.1;
	public var followEnabled:Bool = false;

	public var scrollMinX:Null<Float> = null;
	public var scrollMaxX:Null<Float> = null;
	public var scrollMinY:Null<Float> = null;
	public var scrollMaxY:Null<Float> = null;

	var _shakeOffset:FlxPoint = FlxPoint.get();

	public function new(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0)
	{
		super(x, y, width, height);
	}

	public function followObject(target:{x:Float, y:Float}, lerp:Float = 0.08):Void
	{
		followTarget = FlxPoint.get(target.x, target.y);
		camLerp = lerp;
		followEnabled = true;
	}

	public function followPoint(x:Float, y:Float, lerp:Float = 0.08):Void
	{
		if (followTarget == null)
			followTarget = FlxPoint.get();
		followTarget.set(x, y);
		camLerp = lerp;
		followEnabled = true;
	}

	public function stopCamFollow():Void
	{
		followEnabled = false;
		if (followTarget != null)
		{
			followTarget.put();
			followTarget = null;
		}
	}

	public function panTo(tx:Float, ty:Float, duration:Float = 0.6, ?ease:EaseFunction, ?onDone:Void->Void):Void
	{
		stopCamFollow();
		FlxTween.tween(scroll, {x: tx, y: ty}, duration, {
			ease: ease ?? FlxEase.quartOut,
			onComplete: (_) ->
			{
				if (onDone != null)
					onDone();
			}
		});
	}

	public function snapTo(tx:Float, ty:Float):Void
	{
		stopCamFollow();
		scroll.set(tx, ty);
	}

	public function zoomTo(targetZoom:Float, duration:Float = 0.5, ?ease:EaseFunction, ?onDone:Void->Void):Void
	{
		FlxTween.cancelTweensOf(this, ["zoom"]);
		FlxTween.tween(this, {zoom: targetZoom}, duration, {
			ease: ease ?? FlxEase.quartOut,
			onComplete: (_) ->
			{
				if (onDone != null)
					onDone();
			}
		});
	}

	public function snapZoom(targetZoom:Float):Void
	{
		FlxTween.cancelTweensOf(this, ["zoom"]);
		zoom = targetZoom;
	}

	public function camShake(intensity:Float = 4, duration:Float = 0.3):Void
	{
		var elapsed = 0.0;
		var origX = scroll.x;
		var origY = scroll.y;

		var timer = new flixel.util.FlxTimer();
		timer.start(1 / 60, function(t:flixel.util.FlxTimer)
		{
			elapsed += 1 / 60;
			if (elapsed >= duration)
			{
				_shakeOffset.set(0, 0);
				t.cancel();
				return;
			}
			var progress = 1 - (elapsed / duration);
			_shakeOffset.set((Math.random() * 2 - 1) * intensity * progress, (Math.random() * 2 - 1) * intensity * progress);
		}, 0);
	}

	public function setCamBounds(minX:Null<Float>, maxX:Null<Float>, minY:Null<Float>, maxY:Null<Float>):Void
	{
		scrollMinX = minX;
		scrollMaxX = maxX;
		scrollMinY = minY;
		scrollMaxY = maxY;
	}

	public function clearCamBounds():Void
	{
		scrollMinX = scrollMaxX = scrollMinY = scrollMaxY = null;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (followEnabled && followTarget != null)
		{
			scroll.x += (followTarget.x - scroll.x - width / 2) * camLerp;
			scroll.y += (followTarget.y - scroll.y - height / 2) * camLerp;
		}

		scroll.x += _shakeOffset.x;
		scroll.y += _shakeOffset.y;

		if (scrollMinX != null)
			scroll.x = Math.max(scroll.x, scrollMinX);
		if (scrollMaxX != null)
			scroll.x = Math.min(scroll.x, scrollMaxX);
		if (scrollMinY != null)
			scroll.y = Math.max(scroll.y, scrollMinY);
		if (scrollMaxY != null)
			scroll.y = Math.min(scroll.y, scrollMaxY);
	}

	override public function destroy():Void
	{
		stopCamFollow();
		_shakeOffset.put();
		FlxTween.cancelTweensOf(this);
		super.destroy();
	}
}
