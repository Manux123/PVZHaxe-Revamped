package game.controllers;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import game.objects.Sun;
import game.controllers.HUD;
import core.json.LevelData.LevelJson;

class SunController
{
	public static inline var LAWN_X_MIN:Float = 80.0;
	public static inline var LAWN_X_MAX:Float = 720.0;

	public static inline var SPAWN_Y:Float = -80.0;

	public static inline var TARGET_Y_MIN:Float = 100.0;
	public static inline var TARGET_Y_MAX:Float = 680.0;

	static inline var DEFAULT_DROP_RATE:Float = 7.0;
	static inline var DEFAULT_SUN_AMOUNT:Int = 25;

	var timer:FlxTimer;
	var suns:FlxGroup;
	var hud:HUD;
	var dropRate:Float;
	var sunAmount:Int;
	var paused:Bool = false;

	public function new(levelData:LevelJson, suns:FlxGroup, hud:HUD)
	{
		this.suns = suns;
		this.hud = hud;

		dropRate = (levelData.sunDropRate != null) ? levelData.sunDropRate : DEFAULT_DROP_RATE;
		sunAmount = (levelData.sunDropAmount != null) ? levelData.sunDropAmount : DEFAULT_SUN_AMOUNT;

		timer = new FlxTimer();
		scheduleNext();
	}

	public function setPaused(value:Bool)
	{
		paused = value;
		if (timer != null)
			timer.active = !value;
	}

	public function destroy()
	{
		if (timer != null)
		{
			timer.cancel();
			timer.destroy();
			timer = null;
		}
	}

	function scheduleNext()
	{
		var delay = (timer.loops == 0) ? dropRate * 0.5 : dropRate;
		timer.start(delay, (_) -> spawnSun());
	}

	function spawnSun()
	{
		if (paused)
			return;

		var spawnX = LAWN_X_MIN + FlxG.random.float() * (LAWN_X_MAX - LAWN_X_MIN);
		var targetY = TARGET_Y_MIN + FlxG.random.float() * (TARGET_Y_MAX - TARGET_Y_MIN);

		var sun = new Sun(spawnX, SPAWN_Y, targetY, hud, sunAmount);
		suns.add(sun);

		scheduleNext();
	}
}
