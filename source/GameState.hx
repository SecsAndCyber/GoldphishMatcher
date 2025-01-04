package;

import flixel.FlxG;
import flixel.FlxState;

using flixel.util.FlxSpriteUtil;

class GameState extends FlxState
{

	override public function create():Void
	{
		super.create();
		if(null == Reg.Sounds)
			Reg.Sounds = new AudioController(this);
		else
			Reg.Sounds.refresh(this);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if !android
		if(FlxG.mouse.justReleased)
		{
			Reg.Sounds.click();
		}
		#end
	}
}
