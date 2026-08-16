package game.controllers;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import game.objects.SeedPacket;

class HUD extends flixel.group.FlxGroup.FlxTypedGroup<flixel.FlxBasic>
{
	/*
		Lets say we have a Peashooter. Peashooter is a normal plant, in which for example, get a plantable ID of 0. 
		Plants like Pumpkin on the other hand can be placed above plant so it has an ID of 1.
		This will check if the current grid Array of that specific index is empty. 
		If it is empty, then it will allow plants to be placed.
	 */
	public var seedBank:FlxSprite;

	public var seedPacketList:Array<String> = ['peashooter', 'peashooter'];

	public var houseTxt:FlxText;

	public var suns:FlxText;

	var menuButton:flixel.ui.FlxButton;

	var spaces:Array<Int> = [
		45, // 6 spaces plants
		40, // 7 spaces plants
		35,  // 8 spaces plants
		30, // 9 spaces plants
	];

	public var pauseBitch:Void->Void;

	public function new()
	{
		super();
		createHUD();
	}

	public function createHUD()
	{
		seedBank = new FlxSprite(100, 0).loadGraphic(Paths.image("ui/SeedBank"));
		add(seedBank);

		for (i in 0...seedPacketList.length)
		{
			var seedPacket = new SeedPacket(76 + (i * spaces[0]), -40, seedPacketList[i], 100);
			seedPacket.scale.set(0.6, 0.6);
			seedPacket.updateHitbox();
			add(seedPacket);
		}

		houseTxt = new FlxText(0, 0);
		houseTxt.color = 0xFFFCC900;
		houseTxt.borderStyle = OUTLINE;
		houseTxt.borderSize = 2;
		houseTxt.font = 'assets/fonts/HouseofTerror-Regular.ttf';
		houseTxt.text = "Level: " + game.LawnConfig.displayLevel;
		houseTxt.antialiasing = true;
		houseTxt.size = 20;
		houseTxt.active = false;
		add(houseTxt);

		menuButton = new flixel.ui.FlxButton(681, -12, '', onPausePressed);
		menuButton.loadGraphic('assets/images/menu/inGamePause.png', true, 117, 48);
		add(menuButton);
	}

	function onPausePressed()
	{
		if (pauseBitch != null)
			pauseBitch();
	}
}
