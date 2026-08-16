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

	public var sunText:FlxText;

	var menuButton:flixel.ui.FlxButton;

	var spaces:Array<Int> = [45, 40, 35, 30]; // 6,7,8,9 slots

	public var pauseBitch:Void->Void;

	public function new()
	{
		super();
		createHUD();
	}

	public function initFromLevel(levelJson:core.json.LevelData.LevelJson)
	{
		game.LawnConfig.suns = levelJson.startingSun ?? 50;

		if (levelJson.forcedSeeds != null)
			seedPacketList = levelJson.forcedSeeds.copy();

		var slots = levelJson.seedSlots ?? 5;
		while (seedPacketList.length < slots)
			seedPacketList.push('');

		if (seedPacketList.length > slots)
			seedPacketList = seedPacketList.slice(0, slots);

		createHUD();
	}

	public function createHUD()
	{
		seedBank = new FlxSprite(10, 5).loadGraphic(Paths.image("ui/SeedBank"));
		seedBank.scale.set(0.88, 0.88);
		seedBank.updateHitbox();
		add(seedBank);

		sunText = new FlxText(seedBank.x + 29, seedBank.y + 50);
		sunText.color = 0xFF000000;
		sunText.font = 'assets/fonts/Brianne_s_hand.ttf';
		sunText.text = Std.string(game.LawnConfig.suns);
		sunText.antialiasing = true;
		sunText.size = 16;
		add(sunText);

		var slotCount = seedPacketList.length;
		var spaceIdx = Std.int(Math.max(0, Math.min(spaces.length - 1, slotCount - 6)));
		var spacing = spaces[spaceIdx];

		for (i in 0...slotCount)
		{
			var id = seedPacketList[i];
			if (id == '')
				continue;

			var packetX:Float = seedBank.x + 5 + (i * spacing);
			var packetY:Float = seedBank.y - 45;

			var seedPacket = new SeedPacket(packetX, packetY, id, 100);
			seedPacket.scale.set(0.46, 0.46);
			seedPacket.updateHitbox();
			add(seedPacket);
		}

		houseTxt = new FlxText(FlxG.width * 0.9, FlxG.height * 0.95);
		houseTxt.color = 0xFFFCC900;
		houseTxt.x -= houseTxt.width;
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

	public function addSun(amount:Int):Void
	{
		game.LawnConfig.suns += amount;
		if (game.LawnConfig.suns < 0)
			game.LawnConfig.suns = 0;
		sunText.text = Std.string(game.LawnConfig.suns);
	}

	public function canAfford(cost:Int):Bool
		return game.LawnConfig.suns >= cost;

	public function spendSun(cost:Int):Bool
	{
		if (!canAfford(cost))
			return false;
		addSun(-cost);
		return true;
	}

	function onPausePressed()
	{
		if (pauseBitch != null)
			pauseBitch();
	}

	override public function destroy() {
		game.LawnConfig.suns = 0;
	}
}
