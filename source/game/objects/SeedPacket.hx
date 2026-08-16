package game.objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

var priceTxt:FlxText;
var characterString:String;
var spritePacket:FlxSprite;

class SeedPacket extends FlxSpriteGroup
{
	public function new(x:Float, y:Float, character:String, priceValue:Int, ?notRecommended:Bool = false, ?isSpecial:Bool = false)
	{
		super(x, y);
		characterString = character;
		spritePacket = new FlxSprite(x, y);
		spritePacket.loadGraphic(Paths.image("ui/seedPackets/" + character));
		add(spritePacket);
		if (notRecommended)
			spritePacket.color = FlxColor.BLACK;
		priceTxt = new FlxText(x + 15, y + 85, 100, '$priceValue');
		priceTxt.color = FlxColor.BLACK;
		priceTxt.size = 20;
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
