package game.objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

class SeedPacket extends FlxSpriteGroup
{
	public var notRecommended:Bool = false;
	var priceTxt:FlxText;
	var characterString:String = 'chamoy';
	var spritePacket:FlxSprite;

	public function new(x:Float, y:Float, character:String, priceValue:Int, ?notRecommended:Bool = false, ?isSpecial:Bool = false)
	{
		super(x, y);

		this.notRecommended = notRecommended;
		characterString = character;

		spritePacket = new FlxSprite(x, y);
		spritePacket.loadGraphic(Paths.gameplayImage("ui/seedPackets/" + character));
		spritePacket.antialiasing = true;
		add(spritePacket);
		if (notRecommended)
			spritePacket.color = FlxColor.GRAY;
		priceTxt = new FlxText(x + 15, y + 110, 100, '$priceValue');
		priceTxt.color = FlxColor.BLACK;
		priceTxt.size = 20;
		priceTxt.antialiasing = true;
		priceTxt.text = Std.string(priceValue);
		priceTxt.font = 'assets/fonts/vcr.ttf';
		add(priceTxt);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this))
			game.LawnState.selectedPlant = characterString;

		super.update(elapsed);
	}
}
