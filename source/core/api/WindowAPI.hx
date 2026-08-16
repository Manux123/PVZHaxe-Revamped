package core.api;

#if windows
import winapi.WindowsAPI;
#end
import openfl.Lib;
import flixel.system.scaleModes.RatioScaleMode;
import sys.io.Process;
import flash.system.System;

class WindowAPI {
	public static function init() {
		#if windows
		WindowsAPI.reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsAPI.windowDarkMode(true);
		#end
		scaleWindow();
	}

	public static function scaleWindow() {
		#if windows
		//WindowsAPI.setProgramDPIAware();
		#end
		Lib.application.window.x = Std.int((Lib.application.window.display.bounds.width - Lib.application.window.width) / 2);
		Lib.application.window.y = Std.int((Lib.application.window.display.bounds.height - Lib.application.window.height) / 2);
	}

	public static function resizeGame() {
		FlxG.scaleMode = new RatioScaleMode();
	}
}
