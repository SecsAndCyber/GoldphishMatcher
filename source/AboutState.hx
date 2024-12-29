package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class AboutState extends UiState
{
	private var wipe:FlxButton;
	private var return_button:FlxButton;
	private var hi_score:FlxText;
	private var reset_ready:Bool;

	override public function create():Void
	{
		super.create();
		reset_ready = false;
		title.text = "Created for\nHaxe Jam 2024";
		title.screenCenter(X);

		hi_score = new FlxText(0,title.y + title.height + 10 * Reg.UI_Scale, 0, "", 36 * Reg.UI_Scale);
		hi_score.font = "Courier";
		draw_scores();
		hi_score.alignment = LEFT;
		hi_score.screenCenter(X);
		add(hi_score);

		wipe = new FlxButton(0,0,"", onClickWipe);
		wipe.loadGraphic("assets/UI/Wipe_Button.png");
		wipe.scale.x = Reg.UI_Scale;
		wipe.scale.y = Reg.UI_Scale;
		wipe.updateHitbox();
		wipe.x = (FlxG.width) / 2 -(wipe.width / 2);
		wipe.y = copyright.y - copyright.height - wipe.height / 2;
		add(wipe);
		
		return_button = new FlxButton(0,0,"", onClickReturn);
		return_button.loadGraphic("assets/UI/Return_Button.png");
		return_button.scale.x = Reg.UI_Scale * 1.5;
		return_button.scale.y = Reg.UI_Scale * 1.5;
		return_button.updateHitbox();
		return_button.x = (FlxG.width) / 2 -(return_button.width / 2);
		return_button.y = wipe.y - return_button.height;
		add(return_button);
	}

	private function onClickWipe():Void
	{
		if(reset_ready)
		{
			Reg.clearSave();
			Reg.loadScore();
			Reg.Sounds.reset_stats();
			wipe.visible = false;
			draw_scores();
		}
		else 
		{
			reset_ready = true;
			wipe.loadGraphic("assets/UI/Reset_Button2.png");
			wipe.updateHitbox();
		}
	}

	private function draw_scores():Void
	{
		hi_score.text = "Hi Scores\n";
		for (k in 0...16)
			if(k > 0)
			{
				hi_score.text += StringTools.lpad(Std.string(k)," ",2) + " :";
				if(Reg.HiScore.exists(k) && Reg.HiScore[k] > 0)
					hi_score.text += StringTools.lpad(Std.string(Reg.HiScore[k])," ",5);
				else 
					hi_score.text += StringTools.lpad(Std.string("----")," ",5);
				if(Reg.HiScore.exists(k+15))
				{
					hi_score.text += "|";
					hi_score.text += StringTools.lpad(Std.string(k+15)," ",3) + " :";
					hi_score.text += StringTools.lpad(Std.string(Reg.HiScore[k+15])," ",5);
				}
				hi_score.text += "\n";
			}
		hi_score.screenCenter(X);		
	}

	private function onClickReturn():Void
	{
		Reg.Sounds.menu(false);
		FlxG.camera.fade(FlxColor.BLACK, 0.33, () -> {
			FlxG.switchState(new MenuState());
		});
	}
}
