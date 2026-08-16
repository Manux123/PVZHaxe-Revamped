package flixel;

import cpp.vm.Gc;

class State extends flixel.FlxState
{
	public function new()
	{
		super();
	}

	override public function create()
	{
		super.create();
		FlxG.autoPause = false;
		FlxSprite.defaultAntialiasing = true;
	}

	override function openSubState(substate:flixel.FlxSubState)
	{
		super.openSubState(substate);
	}

	override function closeSubState()
	{
		super.closeSubState();
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
		openfl.Assets.cache.clear();

		super.destroy();

		#if cpp
		Gc.run(true);
		Gc.compact();
		#end
	}
}
