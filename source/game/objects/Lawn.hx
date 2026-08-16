package game.objects;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import haxe.Json;
import openfl.utils.Assets;

typedef LawnData =
{
	var ?defaultZoom:Float;
	var ?cols:Int;
	var ?rows:Int;
	var ?position:Array<Float>;
	var ?positionTile:Array<Float>;
	var ?scale:Array<Float>;
	var ?camPos:Array<Float>;
}

class Lawn extends FlxSpriteGroup
{
	public var lawnJson:LawnData;

	public var defaultZoom:Float = 1;

	public var columns:Int;
	public var rows:Int;
	public var type:String;
	// public var tileZone:Tile;
	public var lawnSprite:FlxSprite;

	public var gridWid:Int = 720;
	public var gridHei:Int = 500;
	public var tileWid:Float = 80;
	public var tileHei:Float = 100;
	public var tileData:Array<Array<Tile>> = [];

	public function new(x:Float = 0, y:Float = 0, backgroundType:String = "grassday", ?row:Int = 9, ?column:Int = 5)
	{
		super(x, y);

		lawnJson = Json.parse(Assets.getText('assets/data/lawns/${backgroundType}.json'));

		if (lawnJson == null)
		{
			trace('Error to loading the lawn Json');
			return;
		}

		if (lawnJson.defaultZoom != null)
			defaultZoom = lawnJson.defaultZoom;

		this.rows = lawnJson.rows;
		this.columns = lawnJson.cols;
		this.type = backgroundType;

		tileData = [for (i in 0...rows) [for (j in 0...column) new Tile()]];
		lawnSprite = new FlxSprite();
		lawnSprite.loadGraphic(Paths.image('levels/${backgroundType}/${backgroundType}'));
		lawnSprite.active = false;
		lawnSprite.x += lawnJson.position[0];
		lawnSprite.y += lawnJson.position[1];
		if (lawnJson.scale != null)
			lawnSprite.scale.set(lawnJson.scale[0], lawnJson.scale[1]);
		lawnSprite.updateHitbox();
		add(lawnSprite);
	}

	public function reloadImage(imagePath:String)
	{
		lawnSprite.loadGraphic(imagePath);
	}
}

class Tile
{
	public var tileType:TileType;
	public var specialType:SpecialType;
	public var hasTILED:Bool; // for Plants like Lilypad &  Flower Pot.
	public var hasDEFAULT:Bool; // for Plants like Peashooter ect.
	public var hasSECONDARY:Bool; // for Plants like Pumpkin ect.
	public var storedPlants:Array<Plant>;

	public function new(tileType:TileType = NORMAL, specialType:SpecialType = DAY)
	{
		this.tileType = tileType;
		this.specialType = specialType;
		this.hasTILED = false;
		this.hasDEFAULT = false;
		this.hasSECONDARY = false;
		this.storedPlants = [];
	}

	public function appendPlant(type:Plant.PlantableType, callback:Void->Plant)
	{
		var isValid = false;
		if (type == DEFAULT)
			isValid = !hasDEFAULT;
		else if (type == TILED)
			isValid = !hasTILED;
		else if (type == SECONDARY)
			isValid = !hasSECONDARY;

		if (!isValid)
			return;

		if (type == DEFAULT)
			hasDEFAULT = true;
		else if (type == TILED)
			hasTILED = false;
		else if (type == SECONDARY)
			hasSECONDARY = false;

		var plant = callback();
		storedPlants.push(plant);
		updatePlants();

		#if debug
		trace('planted \'${Plant.plantIDs[plant.plantID]}\'');
		#end
	}

	public function updatePlants() {}
}

enum TileType
{
	INVALID;
	NORMAL;
	DESTROYED;
	WATER;
	ROOF;
}

enum SpecialType
{
	DAY;
	NIGHT;
	ALL;
}
