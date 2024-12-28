package;

import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.system.Capabilities;

class Main extends Sprite
{
	public function new()
	{
		super();
		Reg.loadScore();
		if(Capabilities.screenResolutionX < Capabilities.screenResolutionY)
		{
			Reg.hideMouse = true;
		}
		addChild(new FlxGame(1600, 2400, SplashState));
	}
}
