package modding.scripting;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

class ScriptReloadPlugin extends FlxBasic
{
	public static var reloadKey:Int = Keyboard.F5;
	public static var showConsole:Bool = true;
	public static var consoleSeconds:Float = 4.0;

	var _console:ScriptConsole;
	var _reloading:Bool = false;

	public function new()
	{
		super();
		active = true;
		visible = false;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if debug
		if (FlxG.keys.justPressed.F5 || _keyJustPressed(reloadKey))
			_doReload();
		#end
	}

	function _doReload():Void
	{
		if (_reloading || !ScriptWorld.ready)
			return;
		_reloading = true;

		_showMessage('Reloading scripts…', 0xFFFFCC00);

		var errors:Array<String> = [];
		var prevReport = ScriptWorld.reportError;
		ScriptWorld.reportError = function(ctx, e)
		{
			var msg = Std.string(e);
			errors.push('$ctx: $msg');
			prevReport(ctx, e);
		};

		var t = haxe.Timer.stamp();
		ScriptWorld.reload();
		var ms = Std.int((haxe.Timer.stamp() - t) * 1000);

		ScriptWorld.reportError = prevReport;
		_reloading = false;

		if (errors.length > 0)
			_showErrors(errors, ms);
		else
			_showMessage('Scripts reloaded in ${ms}ms', 0xFF00FF88);
	}

	function _showMessage(msg:String, color:Int):Void
	{
		if (!showConsole)
		{
			trace(msg);
			return;
		}
		_getConsole().show(msg, color, consoleSeconds);
	}

	function _showErrors(errors:Array<String>, ms:Int):Void
	{
		if (!showConsole)
		{
			trace('[ScriptReload] ${errors.length} error(s)');
			return;
		}
		var summary = '${errors.length} error(s) in ${ms}ms\n' + errors.join('\n');
		_getConsole().show(summary, 0xFFFF4444, consoleSeconds * 1.5);
	}

	function _getConsole():ScriptConsole
	{
		if (_console == null)
		{
			_console = new ScriptConsole();
			_console.scrollFactor.set(0, 0);
			FlxG.state.add(_console);
		}
		return _console;
	}

	static var _pressedKeys:Map<Int, Bool> = [];

	@:access(openfl.events.KeyboardEvent)
	function _keyJustPressed(code:Int):Bool
	{
		return false;
	}
}

class ScriptConsole extends flixel.group.FlxSpriteGroup
{
	static inline var PAD = 8;
	static inline var MAX_LINES = 12;

	var _bg:flixel.FlxSprite;
	var _txt:FlxText;
	var _timer:Null<FlxTimer>;

	public function new()
	{
		super();

		_bg = new flixel.FlxSprite(0, 0);
		_bg.makeGraphic(1, 1, 0xCC000000);
		add(_bg);

		_txt = new FlxText(PAD, PAD, FlxG.width - PAD * 2, '');
		_txt.setFormat(null, 12, FlxColor.WHITE, LEFT);
		_txt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		_txt.wordWrap = true;
		add(_txt);

		visible = false;
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	public function show(msg:String, color:Int = 0xFFFFFFFF, duration:Float = 4.0):Void
	{
		var lines = msg.split('\n');
		if (lines.length > MAX_LINES)
		{
			lines = lines.slice(0, MAX_LINES);
			lines.push('… (${lines.length - MAX_LINES} more)');
		}
		var text = lines.join('\n');

		_txt.text = text;
		_txt.color = color;
		_txt.updateHitbox();

		var h = _txt.height + PAD * 2;
		_bg.setGraphicSize(FlxG.width, Std.int(h));
		_bg.updateHitbox();

		y = FlxG.height - h - 4;
		x = 0;

		visible = true;
		alpha = 1.0;

		if (_timer != null)
		{
			_timer.cancel();
			_timer = null;
		}
		_timer = new FlxTimer().start(duration, function(_) _fadeOut());
	}

	function _fadeOut():Void
	{
		flixel.tweens.FlxTween.tween(this, {alpha: 0}, 0.4, {
			onComplete: function(_) visible = false
		});
	}
}
