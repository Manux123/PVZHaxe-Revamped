package core.audio;

class DynamicGameMusic
{
	public function new() {}

	public static function musicMenu(path:String, volume:Float = 1, ?bpm:Float = 102) {
		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			FlxG.sound.playMusic(path, volume, true);
	}

	public function audioGame(world:Int = 1, music:String)
	{
		FlxG.sound.playMusic(Paths.music('gameplay/world' + world + '/' + music));
	}
}
