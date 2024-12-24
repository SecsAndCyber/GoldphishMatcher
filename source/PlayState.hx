package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	public var board:Board;
	private var done:Int;
	
	override public function create():Void
	{
		super.create();

		// Keep a reference to this state in Reg for global access.

		Reg.PS = this;
		board = new Board(4,4, new FlxPoint(128,128), 128*4,128*4);
		add(board);

		done = 0;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
