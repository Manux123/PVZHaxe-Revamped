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

	public function new() {
		super();
		createHUD();
	}

	public function createHUD()
	{
		seedBank = new FlxSprite(100, 0).loadGraphic(Paths.image("ui/SeedBank"));
		add(seedBank);

		for (i in 0...seedPacketList.length)
		{
			var seedPacket = new SeedPacket(80 + (i * 50), -50, seedPacketList[i], 100);
			seedPacket.scale.set(0.6, 0.6);
			seedPacket.updateHitbox();
			add(seedPacket);
		}

		houseTxt = new FlxText(0, 0);
		houseTxt.color = FlxColor.WHITE;
		houseTxt.borderStyle = OUTLINE;
		houseTxt.borderSize = 2;
		houseTxt.font = 'assets/fonts/HouseofTerror-Regular.ttf';
		houseTxt.text = game.LawnConfig.displayLevel;
		houseTxt.size = 32;
		houseTxt.active = false;
		add(houseTxt);
	}
}
