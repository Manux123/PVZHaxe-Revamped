package flixel;

import cpp.vm.Gc;

class Substate extends flixel.FlxSubState
{
	public function new()
	{
		super();
	}

	override public function create()
	{
		super.create();
	}

	override public function onFocus()
	{
		super.onFocus();/*
		if (FlxG.sound.music != null)
			FlxG.sound.music.resume();*/
		trace("[SYSTEM] User Focused the window");
	}

	override public function onFocusLost()
	{
		super.onFocusLost();/*
		if (FlxG.sound.music != null)
			FlxG.sound.music.pause();*/

		trace("[SYSTEM] User Lost Focus the window");
	}

	override function destroy()
	{
		super.destroy();

		#if cpp
		Gc.run(true);
		Gc.compact();
		#end
	}
}
