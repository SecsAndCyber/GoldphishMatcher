package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxSlider;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class MenuState extends UiState
{
	private var play:FlxButton;
	private var exit:FlxButton;
	private var reset:FlxButton;
	private var about:FlxButton;
	private var reset_ready:Bool;
	private var current_level:FlxText;

	override public function create():Void
	{
		super.create();
		reset_ready = false;

		play = new FlxButton(0, 0, onClickPlay);
		play.loadGraphic("assets/UI/Play_Button_Frames.png", true, 298);
		play.x = (FlxG.width) / 2 -(play.width / 2);
		play.y = (FlxG.height) / 2 -(play.height / 2);
		add(play);
		
		reset = new FlxButton(0, 0, onClickReset);
		reset.loadGraphic("assets/UI/Reset_Button_Frames.png", true, 298);
		reset.x = (FlxG.width) / 2 - (reset.width / 2);
		reset.y = play.y + play.height + reset.height / 2;
		add(reset);
		exit = new FlxButton(0, 0, onClickExit);
		exit.loadGraphic("assets/UI/Exit_Button_Frames.png", true, 298);
		exit.x = (FlxG.width) / 2 - (exit.width / 2);
		exit.y = reset.y + reset.height + exit.height / 2;
		#if !html5
		add(exit);
		#end
		
		about = new FlxButton(0, 0, onClickAbout);
		about.loadGraphic("assets/UI/About_Button_Frames.png", true, 298);
		about.scale.x *= 0.75;
		about.scale.y *= 0.75;
		about.updateHitbox();
		about.x = (FlxG.width) / 2 -(about.width / 2);
		about.y = exit.y + exit.height + about.height / 2;
		add(about);
		
		current_level = new FlxText(0,20 * Reg.UI_Scale, 0, "Level\n1", 64 * Reg.UI_Scale);
		current_level.alignment = CENTER;
		current_level.screenCenter(X);
		current_level.y = title.y + title.height + current_level.height / 2;
		current_level.font = "monsterrat";
		add(current_level);
	}

	private function onClickPlay():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, () -> {FlxG.switchState(new PlayState());});
	}

	private function onClickAbout():Void
	{
		Reg.Sounds.menu(true);
		FlxG.camera.fade(FlxColor.BLACK, 0.33, () -> {
			FlxG.switchState(new AboutState());
		});
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
		if(reset_ready)
		{
			Reg.Levels = 1;
			Reg.saveScore();
			Reg.Sounds.reset_stats();
			reset.visible = false;
		}
		else 
		{
			reset_ready = true;
			reset.loadGraphic("assets/UI/Reset_Button2_Frames.png", true, 298);
			reset.updateHitbox();
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		current_level.text = "Level\n" + Reg.Levels;
		#if !android
		if (FlxG.keys.pressed.SPACE){
			onClickPlay();
		}
		#end
	}
}
