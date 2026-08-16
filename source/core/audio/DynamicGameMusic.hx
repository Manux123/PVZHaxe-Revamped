package core.audio;

class DynamicGameMusic
{
	public function new() {}

	public function audioGame(world:Int = 1, music:String)
	{
		FlxG.sound.music.play(Paths.music('gameplay/world' + world + '/' + music));
	}
}
