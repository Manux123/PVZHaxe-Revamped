package modding.scripting.hosts;

import modding.scripting.ScriptHost;
import hxscript.Environment;
import game.objects.Projectile;

class ProjectileHost extends ScriptHost<Projectile>
{
	public function new() {}

	function get_folder()
		return 'projectiles';

	function get_baseClass():Class<Projectile>
		return Projectile;

	public function createProjectile(name:String, x:Float, y:Float):Null<Projectile>
		return create(name, [x, y]);
}
