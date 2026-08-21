package modding.scripting.hosts;

import core.json.LevelData;
import game.objects.Plant;
import game.objects.Zombie;
import game.objects.Projectile;
import game.LawnState;

/**
 * Example:
 *   // assets/scripts/levels/1-1.hx
 *   class Level_1_1 extends LevelScript {
 *       override public function onStart():Void {
 *           LawnState.instance.spawnZombie('cone', 800, 150);
 *       }
 *   }
 */
@:scriptable
class LevelScript
{
	public var state(get, never):LawnState;

	inline function get_state()
		return LawnState.instance;

	// JSON
	public var levelData(get, never):LevelData;

	inline function get_levelData()
		return LawnState.instance?.levelData;

	public function new() {}

	public function onCreate():Void {}

	public function onPlantingPhase():Void {}

	public function onStart():Void {}

	public function onUpdate(elapsed:Float):Void {}

	public function onPlantPlaced(plant:Plant, row:Int, col:Int):Void {}

	public function onZombieKilled(zombie:Zombie):Void {}

	public function onProjectileHit(proj:Projectile, zombie:Zombie):Void {}

	public function onCountdown():Void {}

	public function postCountdown():Void {}

	public function hugeWave():Void {}

	public function onWin():Void {}

	public function onLose():Void {}

	public function onPause():Void {}

	public function onResume():Void {}

	public function onDestroy():Void {}
}
