package;

import flixel.FlxG;
import flixel.util.FlxSave;

class Reg
{
	/**
	* A reference to the active playstate. Lets you call Reg.PS globally to access the playstate.
	*/
	static public var PS:PlayState;

	static public var Levels:Int = 0;
	
	
	/**
	 * Safely store a new high score into the saved session, if possible.
	 */
	 static public function saveScore():Void
	{
		// Have to do this in order for saves to work on native targets!
		if ((FlxG.save.data.Levels == null) || (FlxG.save.data.Levels < Reg.Levels))
			FlxG.save.data.Levels = Reg.Levels;

		FlxG.save.flush();
	}

	/**
		* Load data from the saved session.
		*
		* @return	The total points of the saved high score.
		*/
	static public function loadScore():Int
	{
		Reg.Levels = 0;
		if ((FlxG.save.data != null) && (FlxG.save.data.Levels != null))
			Reg.Levels = FlxG.save.data.Levels;

		return 0;
	}

	/**
		* Wipe save data.
		*/
	static public function clearSave():Void
	{
		FlxG.save.erase();
	}
}
