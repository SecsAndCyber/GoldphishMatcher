package;

import flixel.FlxG;
import flixel.math.FlxPoint;

class Reg
{
	/**
	* A reference to the active playstate. Lets you call Reg.PS globally to access the playstate.
	*/
	static public var PS:PlayState = null;
	static public var Sounds:AudioController = null;
	static public var GameId:String = null;

	static public var Levels:Int = 0;
	static public var RunningScore:Int = 0;
	static public var Score:Int = 0;
	static public var HiScore:Map<Int,Int> = [0=>0];
	static public var HiScoreSet:Bool = false;
	static public var Loss:Bool = false;
	static public var Done:Bool = false;

	static public var UI_Scale:Int = 2;
	static public var MusicVolume:Float = .125;
	static public var SFXVolume:Float = .75;
	static public var hideMouse:Bool = false;
	
	static public var fish_speed:Float = 50.0;
	static public var fish_location:FlxPoint;
	
	/**
	 * Safely store a new high score into the saved session, if possible.
	 */
	 static public function saveScore():Void
	{
		// Have to do this in order for saves to work on native targets!
		if ((FlxG.save.data.Levels == null) || (Reg.Levels > 0))
			FlxG.save.data.Levels = Reg.Levels;
		if ((FlxG.save.data.RunningScore == null) || (Reg.RunningScore >= 0))
			FlxG.save.data.RunningScore = Reg.RunningScore;
		if ((FlxG.save.data.GameId == null) || (FlxG.save.data.GameId != Reg.GameId))
			FlxG.save.data.GameId = Reg.GameId;
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
		Reg.RunningScore = 0;

		if ((FlxG.save.data != null) && (FlxG.save.data.Levels != null))
			Reg.Levels = FlxG.save.data.Levels;
		if ((FlxG.save.data != null) && (FlxG.save.data.RunningScore != null))
			Reg.RunningScore = FlxG.save.data.RunningScore;

		if ((FlxG.save.data != null) && (FlxG.save.data.GameId != null))
			Reg.GameId = FlxG.save.data.GameId;
		else
			Reg.GameId = Uuid.v4();

		if ((FlxG.save.data != null) && (FlxG.save.data.HiScore != null))
			Reg.HiScore = FlxG.save.data.HiScore;
		Reg.Done = Reg.Levels > 30;
		return 0;
	}

	/**
		* Wipe save data.
		*/
	static public function clearSave(fullClear:Bool = false):Void
	{
		trace("Clearing saved state");
		Reg.Levels = 1;
		Reg.RunningScore = 0;
		if (fullClear)
			Reg.HiScore = [0 => 0];
		Reg.Score = 0;
		saveScore();
	}
}
