package;

import flixel.graphics.frames.FlxAtlasFrames;
#if sys
import sys.FileSystem;
#else
import openfl.Assets;
#end

/**
 * Folders Structure:
 *   assets/
 *     cursor.png
 *     fonts/
 *     sounds/
 *     gameplay/
 *       images/   (plants/, zombies/, projectiles/, levels/, ui/)
 *       data/     (levels/, plants/, zombies/, projectiles/, lawns/)
 *       music/    (world1/, world2/, ...)
 *     menus/
 *       images/   (mainmenu/, almanac/, general/, loading/, minigames/, notes/)
 *       data/     (minigames/)
 *       music/    (main_menu_theme.ogg, ...)
 */
class Paths
{
	private static inline function getPath(path:String):String
	{
		#if sys
		if (!FileSystem.exists(path))
			trace('WARNING: File not found -> $path');
		#else
		if (!Assets.exists(path))
			trace('WARNING: Asset not found -> $path');
		#end

		return path;
	}

	private static function getSparrow(image:String, xml:String):FlxAtlasFrames
	{
		#if sys
		if (!FileSystem.exists(image) || !FileSystem.exists(xml))
			return null;
		#else
		if (!Assets.exists(image) || !Assets.exists(xml))
			return null;
		#end

		return FlxAtlasFrames.fromSparrow(image, xml);
	}

	/** Any asset with an absolute path from assets/. */
	public static inline function raw(path:String):String
		return getPath('assets/$path');

	public static inline function font(key:String, ?ext:String = "ttf"):String
		return getPath('assets/fonts/$key.$ext');

	public static inline function sound(key:String):String
		return getPath('assets/sounds/$key.ogg');

	// gameplay

	public static inline function gameplayImage(key:String):String
		return getPath('assets/gameplay/images/$key.png');

	public static inline function gameplayXml(key:String):String
		return getPath('assets/gameplay/images/$key.xml');

	public static inline function gameplayJson(key:String):String
		return getPath('assets/gameplay/data/$key.json');

	public static inline function gameplayMusic(key:String):String
		return getPath('assets/gameplay/music/$key.ogg');

	public static inline function gameplaySparrow(key:String):FlxAtlasFrames
		return getSparrow(gameplayImage(key), gameplayXml(key));

	// menus

	public static inline function menuImage(key:String):String
		return getPath('assets/menus/images/$key.png');

	public static inline function menuXml(key:String):String
		return getPath('assets/menus/images/$key.xml');

	public static inline function menuJson(key:String):String
		return getPath('assets/menus/data/$key.json');

	public static inline function menuMusic(key:String):String
		return getPath('assets/menus/music/$key.ogg');

	public static inline function menuSparrow(key:String):FlxAtlasFrames
		return getSparrow(menuImage(key), menuXml(key));
}
