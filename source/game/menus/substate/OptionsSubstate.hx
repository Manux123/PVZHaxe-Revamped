package game.menus.substate;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class OptionsSubstate extends flixel.Substate
{
	var optionsMenu:FlxSpriteGroup;
	var optionsBG:FlxSprite;
	var optionsOk:FlxButton;

	var menuPrevX:Float = 0;
	var menuPrevY:Float = 0;
	var cursorPrevX:Int = 0;
	var cursorPrevY:Int = 0;
	var draggingMenu:Bool = false;

	override public function create()
	{
		super.create();

		destroySubStates = false;
		this.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

		optionsBG = AngelUtils.fromAlphaMask(Paths.menuImage('general/options/options_menuback'), Paths.menuImage('general/options/options_menuback_'), 0, 0);

		optionsOk = new FlxButton(0, 0, "", closeOptions);
		optionsOk.loadGraphic(Paths.menuImage('general/options/options_backtogamebutton_full'), true, 360, 100);

		optionsMenu = new FlxSpriteGroup();
		optionsMenu.add(optionsBG);
		optionsMenu.add(optionsOk);
		add(optionsMenu);
		optionsMenu.screenCenter();

		optionsOk.x = optionsBG.x + 29;
		optionsOk.y = optionsBG.y + 380;
	}

	function closeOptions()
	{
		FlxG.sound.play(Paths.sound('hud/buttonclick'));
		close();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
		{
			var inButtonArea = false;
			var x1 = optionsOk.getScreenPosition().x;
			var x2 = x1 + optionsOk.width;
			var y1 = optionsOk.getScreenPosition().y;
			var y2 = y1 + optionsOk.height;

			if (FlxG.mouse.screenX >= x1 && FlxG.mouse.screenX <= x2 && FlxG.mouse.screenY >= y1 && FlxG.mouse.screenY <= y2)
				inButtonArea = true;

			if (!inButtonArea)
			{
				var bx1 = optionsBG.getScreenPosition().x;
				var bx2 = bx1 + optionsBG.width;
				var by1 = optionsBG.getScreenPosition().y;
				var by2 = by1 + optionsBG.height;

				if (FlxG.mouse.screenX >= bx1 && FlxG.mouse.screenX <= bx2 && FlxG.mouse.screenY >= by1 && FlxG.mouse.screenY <= by2)
				{
					draggingMenu = true;
					menuPrevX = optionsMenu.x;
					menuPrevY = optionsMenu.y;
					cursorPrevX = FlxG.mouse.screenX;
					cursorPrevY = FlxG.mouse.screenY;
				}
			}
		}

		if (FlxG.mouse.justReleased)
		{
			draggingMenu = false;
			menuPrevX = menuPrevY = 0;
			cursorPrevX = cursorPrevY = 0;
		}

		if (FlxG.mouse.pressed && draggingMenu)
		{
			optionsMenu.x = menuPrevX + (FlxG.mouse.screenX - cursorPrevX);
			optionsMenu.y = menuPrevY + (FlxG.mouse.screenY - cursorPrevY);
			AngelUtils.bounceToFrame(optionsMenu);
		}
	}

	override public function destroy()
	{
		if (optionsMenu != null)
		{
			optionsMenu.destroy();
			optionsMenu = null;
		}
		super.destroy();
	}
}
