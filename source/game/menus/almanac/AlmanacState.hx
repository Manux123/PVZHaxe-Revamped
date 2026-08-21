package game.menus.almanac;

import flixel.FlxSprite;
import flixel.State;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class AlmanacState extends State
{
	var background:FlxSprite;
	var titleTxt:FlxText;

	var exitButton:FlxButton;
	var exitText:FlxText;

	public static var buttonColor:FlxColor = FlxColor.fromRGB(41, 39, 97);

	var plantButton:FlxButton;

	override public function create()
	{
		background = new FlxSprite(0, 0).loadGraphic(Paths.menuImage("almanac/Almanac_IndexBack"));
		add(background);

		titleTxt = new FlxText(305, 20, 356, 'Suburban Almanac - Index', 36);
		titleTxt.color = FlxColor.WHITE;
		titleTxt.borderStyle = OUTLINE;
		titleTxt.borderSize = 2;
		titleTxt.font = 'assets/fonts/HouseofTerror-Regular.ttf';
		titleTxt.screenCenter(X); // i can't see no diference
		add(titleTxt);

		exitButton = new FlxButton(700, FlxG.height - 35, "", exitAlmanac);
		exitButton.loadGraphic(Paths.menuImage('almanac/Almanac_CloseButton'), true, 89, 26);
		add(exitButton);

		exitText = new FlxText(exitButton.x + 10, exitButton.y + 4);
		exitText.text = "CLOSE";
		exitText.color = buttonColor;
		exitText.size = 16;
		add(exitText);

		plantButton = new FlxButton(130, FlxG.height - 245, "", enterPlant);
		plantButton.loadGraphic(Paths.menuImage('almanac/viewplant'), true, 156, 42);
		add(plantButton);
	}

	function exitAlmanac()
	{
		FlxG.sound.play(Paths.sound('hud/buttonclick')); // button sound
		FlxG.switchState(new game.menus.MainMenuState());
	}

	function enterPlant()
	{
		FlxG.sound.play(Paths.sound('hud/buttonclick')); // button sound
		FlxG.switchState(new PlantEntryPage());
	}
}
