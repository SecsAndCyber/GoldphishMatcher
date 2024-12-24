package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		Reg.loadScore();
		addChild(new FlxGame(1600, 2400, PlayState));
	}
}
