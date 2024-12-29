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

		play = new FlxButton(0,0,"", onClickPlay);
		play.loadGraphic("assets/UI/Play_Button.png");
		play.scale.x = Reg.UI_Scale;
		play.scale.y = Reg.UI_Scale;
		play.updateHitbox();
		play.x = (FlxG.width) / 2 -(play.width / 2);
		play.y = (FlxG.height) / 2 -(play.height / 2);
		add(play);
		
		exit = new FlxButton(0,0,"", onClickExit);
		exit.loadGraphic("assets/UI/Exit_Button.png");
		exit.scale.x = Reg.UI_Scale;
		exit.scale.y = Reg.UI_Scale;
		exit.updateHitbox();
		exit.x = (FlxG.width) / 2 -(exit.width / 2);
		exit.y = play.y + play.height + exit.height / 2;
		add(exit);
		
		reset = new FlxButton(0,0,"", onClickReset);
		reset.loadGraphic("assets/UI/Reset_Button.png");
		reset.scale.x = Reg.UI_Scale;
		reset.scale.y = Reg.UI_Scale;
		reset.updateHitbox();
		reset.x = (FlxG.width) / 2 -(reset.width / 2);
		reset.y = copyright.y - copyright.height - reset.height / 2;
		add(reset);
		
		about = new FlxButton(0,0,"", onClickAbout);
		about.loadGraphic("assets/UI/About_Button.png");
		about.scale.x = Reg.UI_Scale;
		about.scale.y = Reg.UI_Scale;
		about.updateHitbox();
		about.x = (FlxG.width) / 2 -(about.width / 2);
		about.y = reset.y - reset.height - about.height / 2;
		add(about);
		
		current_level = new FlxText(0,20 * Reg.UI_Scale, 0, "Level\n1", 64 * Reg.UI_Scale);
		current_level.alignment = CENTER;
		current_level.screenCenter(X);
		current_level.y = title.y + title.height + current_level.height / 2;
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
			Reg.clearSave();
			Reg.loadScore();
			Reg.Sounds.reset_stats();
			reset.visible = false;
		}
		else 
		{
			reset_ready = true;
			reset.loadGraphic("assets/UI/Reset_Button2.png");
			reset.updateHitbox();
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		current_level.text = "Level\n" + Reg.Levels;
		if (FlxG.keys.pressed.SPACE){
			onClickPlay();
		}
	}
}
