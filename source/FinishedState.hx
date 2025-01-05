package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class FinishedState extends GameState
{
	private var current_level:FlxText;
	private var current_score:FlxText;
	private var hi_score:FlxText;
	private var run_score:FlxText;
	private var best_run_score:FlxText;

	private var background:FlxSprite;
	private var foreground:FlxSprite;

	private var play:FlxButton;

	override public function create():Void
	{
		super.create();

		background = new FlxSprite(0, 0);
		background.loadGraphic("assets/backgrounds/background-4.png");
		add(background);

		foreground = new FlxSprite(0, 0);
		foreground.loadGraphic("assets/backgrounds/foreground-4.png");
		add(foreground);
		
		current_level = new FlxText(0, 0, 0, "Level\n1", 48 * Reg.UI_Scale);
		current_level.alignment = CENTER;
		current_level.font = "monsterrat";
		current_level.x = 128 * 2;
		current_level.y = 128;
		add(current_level);
		
		
		current_score = new FlxText(0, 0, 0, "Score\n0", 48 * Reg.UI_Scale);
		current_score.alignment = CENTER;
		current_score.font = "monsterrat";
		current_score.x = 128 * 2;
		current_score.y = 128 * 3;
		add(current_score);
		
		
		hi_score = new FlxText(0, 0, 0, "Hi Score\n---", 48 * Reg.UI_Scale);
		hi_score.alignment = CENTER;
		hi_score.font = "monsterrat";
		hi_score.x = 128 * 6;
		hi_score.y = 128 * 3;
		add(hi_score);

		run_score = new FlxText(0, 0, 0, "Run Score\n0", 48 * Reg.UI_Scale);
		run_score.alignment = CENTER;
		run_score.font = "monsterrat";
		run_score.x = 128 * 2;
		run_score.y = 128 * 6;
		add(run_score);

		best_run_score = new FlxText(0, 0, 0, "Best Run\n0", 48 * Reg.UI_Scale);
		best_run_score.alignment = CENTER;
		best_run_score.font = "monsterrat";
		best_run_score.x = 128 * 6;
		best_run_score.y = 128 * 6;
		add(best_run_score);

		play = new FlxButton(0, 0, onClickPlay);
		play.loadGraphic("assets/UI/Play_Button_Frames.png", true, 298);
		play.scale.x *= Reg.UI_Scale;
		play.scale.y *= Reg.UI_Scale;
		play.updateHitbox();
		play.x = (FlxG.width) / 2 -(play.width / 2);
		play.y = (FlxG.height) / 2 - (play.height);
		add(play);		
	}

	private function onClickPlay():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, () -> {FlxG.switchState(new PlayState());});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		current_level.text = "Level\n" + Reg.Levels;
		current_score.text = "Score\n" + Reg.Score;
		if(Reg.HiScore.exists(Reg.Levels))
			hi_score.text = "Hi Score\n" + Reg.HiScore[Reg.Levels];
		if(Reg.Done)
			run_score.text = "Free Score\n" + (Reg.RunningScore + Reg.Score);
		else
			run_score.text = "Run Score\n" + (Reg.RunningScore + Reg.Score);
		best_run_score.text = "Best Run\n" + Reg.HiScore[0];
		#if !android
		if (FlxG.keys.pressed.SPACE){
			onClickPlay();
		}
		#end
	}
}
