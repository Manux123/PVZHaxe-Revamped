package game.objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

class SeedPacket extends FlxSpriteGroup
{
	public var cost:Int;
	public var setRecommended(get, set):Bool;

	var _setRecommended:Bool = true;

	function get_setRecommended():Bool
		return _setRecommended;

	function set_setRecommended(value:Bool):Bool
	{
		_setRecommended = value;
		spritePacket.color = value ? FlxColor.WHITE : FlxColor.GRAY;
		return value;
	}

	var priceTxt:FlxText;
	var characterString:String = 'chamoy';
	var spritePacket:FlxSprite;

	public function new(x:Float, y:Float, character:String, priceValue:Int, ?notRecommended:Bool = false, ?isSpecial:Bool = false)
	{
		super(x, y);

		cost = priceValue;
		characterString = character;

		spritePacket = new FlxSprite(x, y);
		spritePacket.loadGraphic(Paths.gameplayImage("ui/seedPackets/" + character));
		spritePacket.antialiasing = true;
		add(spritePacket);
		if (notRecommended)
			spritePacket.color = FlxColor.GRAY;
		priceTxt = new FlxText(x + 20, y + 110, 100, '$priceValue');
		priceTxt.color = FlxColor.BLACK;
		priceTxt.size = 20;
		priceTxt.antialiasing = true;
		priceTxt.text = Std.string(priceValue);
		priceTxt.font = 'assets/fonts/vcr.ttf';
		add(priceTxt);

		setRecommended = !notRecommended;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this) && _setRecommended)
		{
			if (_setRecommended)
				game.LawnState.selectedPlant = characterString;
			else
			{
				FlxG.sound.play(Paths.gameplaySound('plant/butter'));
				flashCostRed();
			}
		}

		super.update(elapsed);
	}

	public function flashCostRed():Void
	{
		priceTxt.color = FlxColor.RED;
		flixel.tweens.FlxTween.color(priceTxt, 0.6, FlxColor.RED, FlxColor.BLACK);
	}
}
