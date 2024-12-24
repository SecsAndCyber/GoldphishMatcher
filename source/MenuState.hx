package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxSlider;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class MenuState extends FlxState
{
	private var title:FlxText;
	private var copyright:FlxText;
	private var play:FlxButton;
	private var exit:FlxButton;
	private var reset:FlxButton;

	override public function create():Void
	{
		Reg.loadScore();
		title = new FlxText(50,20, 0, "Goldphish\nMatch", 18);
		title.alignment = CENTER;
		title.screenCenter(X);
		add(title);

		play = new FlxButton(0,0,"Play", onClickPlay);
		play.x = (FlxG.width) / 2 -(play.width / 2);
		play.y = (FlxG.height) / 2 -(play.height / 2);
		add(play);
		
		exit = new FlxButton(0,0,"Exit", onClickExit);
		exit.x = (FlxG.width) / 2 -(exit.width / 2);
		exit.y = play.y + play.height + 5;
		add(exit);
		
		copyright = new FlxText(50,FlxG.height-50,0, "Copyright 2024 S1air Coding", 8);
		copyright.alignment = CENTER;
		copyright.screenCenter(X);
		add(copyright);
		
		reset = new FlxButton(0,0,"Reset", onClickReset);
		reset.x = (FlxG.width) / 2 -(exit.width / 2);
		reset.y = copyright.y - copyright.height - 10;
		add(reset);

		super.create();
	}

	private function onClickPlay():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, () -> {FlxG.switchState(new PlayState());});
	}

	private function onClickExit():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33,
			#if cpp
			//your desktop code
			() -> {Sys.exit(0);}
			#end
		);
	}

	private function onClickReset():Void
	{
		if(reset.text == "For sure?")
		{
			Reg.clearSave();
			Reg.loadScore();
			reset.text = "Reset";
		}
		else 
		{
			reset.text = "For sure?";
		}
	}
}
