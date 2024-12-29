package;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxSave;

class Reg
{
	/**
	* A reference to the active playstate. Lets you call Reg.PS globally to access the playstate.
	*/
	static public var PS:PlayState = null;
	static public var Sounds:AudioController = null;

	static public var Levels:Int = 0;
	static public var Score:Int = 0;
	static public var HiScore:Map<Int,Int> = [0=>0];

	static public var UI_Scale:Int = 2;
	static public var hideMouse:Bool = false;
	
	static public var fish_speed:Float = 50.0;
	static public var fish_location:FlxPoint;
	
	/**
	 * Safely store a new high score into the saved session, if possible.
	 */
	 static public function saveScore():Void
	{
		// Have to do this in order for saves to work on native targets!
		if ((FlxG.save.data.Levels == null) || (FlxG.save.data.Levels < Reg.Levels))
			FlxG.save.data.Levels = Reg.Levels;
		FlxG.save.data.HiScore = Reg.HiScore;

		FlxG.save.flush();
	}

	/**
		* Load data from the saved session.
		*
		* @return	The total points of the saved high score.
		*/
	static public function loadScore():Int
	{
		if(fish_location == null) fish_location = new FlxPoint(20*Reg.UI_Scale, fish_speed*Reg.UI_Scale);
		Reg.Levels = 1;
		if ((FlxG.save.data != null) && (FlxG.save.data.Levels != null))
			Reg.Levels = FlxG.save.data.Levels;

		if ((FlxG.save.data != null) && (FlxG.save.data.HiScore != null))
			Reg.HiScore = FlxG.save.data.HiScore;
		return 0;
	}

	/**
		* Wipe save data.
		*/
	static public function clearSave():Void
	{
		trace("Clearing saved state");
		FlxG.save.erase();
		FlxG.save.data.HiScore = Reg.HiScore;
		FlxG.save.flush();
	}
}
