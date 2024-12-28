package;

import flixel.FlxG;
import flixel.FlxSprite;

class Cracker extends FlxSprite
{
	static private var symbols:Array<Int> = [3,5,7,13];
	private var _symbol:Int;

	static public var Max(get, default):Int;
	static function get_Max() {
		return symbols.length;
	  }
	public var Value(get, default):Int;

	function get_Value() {
		return _symbol;
	  }

	public function new(symbol:Int, _x:Float, _y:Float)
	{
		super(_x, _y);
		_symbol = symbols[symbol % symbols.length];
		switch (_symbol){
			case 3:
				loadGraphic("assets/HappyGoldfishCookieSquare.png");
			case 5:
				loadGraphic("assets/SadGoldfishCookieSquare.png");
			case 7:
				loadGraphic("assets/EvilGoldfishCookieSquare.png");
			case 13:
				loadGraphic("assets/DeadGoldfishCookieSquare.png");
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
