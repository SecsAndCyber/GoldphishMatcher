package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PlayState extends GameState
{
	public var board:Board;
	private var done:Int;
	private var background:FlxSprite;
	private var foreground:FlxSprite;
	private var return_button:FlxButton;
	private var retry_button:FlxButton;
	private var next_button:FlxButton;
	
	private var current_level:FlxText;
	private var current_score:FlxText;
	private var hi_score:FlxText;
	private var run_score:FlxText;
	private var done_banner:FlxText;
	
	override public function create():Void
	{
		super.create();

		// Keep a reference to this state in Reg for global access.
		Reg.PS = this;
		Reg.RunningScore += Reg.Score;
		Reg.Score = 0;
		Reg.HiScoreSet = false;
		Reg.Loss = false;

		#if !android
		FlxG.mouse.visible = !Reg.hideMouse;
		#end

		background = new FlxSprite(0, 0);
		background.loadGraphic("assets/backgrounds/background-1.png");
		add(background);

		var rows:Int = 4 + Std.int(Reg.Levels / 5);
		var columns:Int = 4 + Std.int(Reg.Levels / 5);

		board = new Board(rows, columns, new FlxPoint(128, 128), 128 * rows, 128 * columns);
		add(board);

		foreground = new FlxSprite(0, 0);
		foreground.loadGraphic("assets/backgrounds/foreground-1.png");
		add(foreground);

		return_button = new FlxButton(0, 0, onClickReturn);
		return_button.loadGraphic("assets/UI/Return_Button_Frames.png", true, 298);
		return_button.x = (FlxG.width) / 2 -(return_button.width / 2);
		return_button.y = FlxG.height - return_button.height * 1.2;
		add(return_button);
		
		current_level = new FlxText(0, 0, 0, "Level\n1", 48 * Reg.UI_Scale);
		current_level.alignment = CENTER;
		current_level.font = "monsterrat";
		current_level.x = 50 * Reg.UI_Scale;
		current_level.y = return_button.y - return_button.height - current_level.height / 2;
		add(current_level);
		
		
		current_score = new FlxText(0, 0, 0, "Score\n0", 48 * Reg.UI_Scale);
		current_score.alignment = CENTER;
		current_score.font = "monsterrat";
		current_score.x = current_level.x + current_level.width + (current_score.width / 4);
		current_score.y = return_button.y - return_button.height - current_score.height / 2;
		add(current_score);
		
		
		hi_score = new FlxText(0, 0, 0, "Hi Score\n0", 48 * Reg.UI_Scale);
		hi_score.alignment = CENTER;
		hi_score.font = "monsterrat";
		hi_score.x = current_score.x + current_score.width + (hi_score.width / 4);
		hi_score.y = return_button.y - return_button.height - hi_score.height / 2;
		add(hi_score);

		run_score = new FlxText(0, 0, 0, "Run Score\n0", 48 * Reg.UI_Scale);
		run_score.alignment = CENTER;
		run_score.font = "monsterrat";
		run_score.x = current_score.x + current_score.width + (run_score.width / 4);
		run_score.y = current_score.y - current_score.height - run_score.height / 2;
		add(run_score);

		done_banner = new FlxText(0, 0, 0, "Winner!", 48 * Reg.UI_Scale);
		done_banner.alignment = CENTER;
		done_banner.font = "monsterrat";

		retry_button = new FlxButton(0, 0, onClickRetry);
		retry_button.loadGraphic("assets/UI/Retry_Button_Frames.png", true, 298);
		retry_button.x = (FlxG.width) / 2 - (return_button.width / 2);
		retry_button.y = FlxG.height - return_button.height * 1.2;
		retry_button.visible = false;

		next_button = new FlxButton(0, 0, onClickNext);
		if (Reg.Levels < 30)
			next_button.loadGraphic("assets/UI/Next_Button_Frames.png", true, 298);
		else
			next_button.loadGraphic("assets/UI/FreePlay_Button_Frames.png", true, 298);
		next_button.x = (FlxG.width) / 2 - (next_button.width / 2);
		next_button.y = FlxG.height - next_button.height * 1.2;
		next_button.visible = false;

		done = 0;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		current_level.text = "Level\n" + Reg.Levels;
		current_score.text = "Score\n" + Reg.Score;
		if (Reg.Done && Reg.Levels > 30)
			run_score.text = "Free Score\n" + (Reg.RunningScore + Reg.Score);
		else
			run_score.text = "Run Score\n" + (Reg.RunningScore + Reg.Score);
		if(Reg.HiScore.exists(Reg.Levels))
			hi_score.text = "Hi Score\n" + Reg.HiScore[Reg.Levels];
		if (FlxG.keys.justPressed.ESCAPE && return_button.visible)
			onClickReturn();
		if (FlxG.keys.justPressed.SPACE && retry_button.visible)
			onClickNext();
		if (FlxG.keys.justPressed.F9)
		{
			trace("CHEAT: Level Skipped");
			onClickNext();
		}
		if (FlxG.keys.justPressed.ESCAPE && retry_button.visible)
			onClickRetry();
		if (!return_button.visible && !retry_button.visible)
			if (1 > animate_popup())
			{
				if (Reg.HiScoreSet)
				{
					Reg.Sounds.level_won();
					background.loadGraphic("assets/backgrounds/background-3.png");
					foreground.loadGraphic("assets/backgrounds/foreground-3.png");
				}
				else
				{
					background.loadGraphic("assets/backgrounds/background-2.png");
					foreground.loadGraphic("assets/backgrounds/foreground-2.png");
				}
				retry_button.visible = true;
				next_button.visible = true;
				return_button.visible = true;
			}
		if (Reg.Loss)
		{
			background.loadGraphic("assets/backgrounds/background-4.png");
			foreground.loadGraphic("assets/backgrounds/foreground-4.png");
		}
	}

	private function onClickReturn():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, () -> {FlxG.switchState(new MenuState());});
	}
	private function onClickRetry():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, () ->
		{
			Reg.saveScore();
			Reg.Score = 0;
			Reg.RunningScore = 0;
			FlxG.switchState(new PlayState());
		});
	}

	private function onClickNext():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, () ->
		{
			Reg.Levels += 1;
			Reg.saveScore();
			FlxG.switchState(new PlayState());
		});
	}

	public function popup()
	{
		return_button.visible = false;
		retry_button.visible = false;
		next_button.visible = false;
		if (Reg.Levels >= 30)
		{
			Reg.Done = true;
			add(done_banner);
		}
		add(retry_button);
		add(next_button);
	}

	private function animate_popup()
	{
		var delta = current_level.y;
		current_level.y = FlxMath.lerp(current_level.y, 128, .02);
		current_level.x = FlxMath.lerp(current_level.x, 128 * 2, .02);

		run_score.y = FlxMath.lerp(run_score.y, 128 * 6, .02);
		run_score.x = FlxMath.lerp(run_score.x, 128 * 2, .02);

		current_score.y = FlxMath.lerp(current_score.y, 128 * 3, .02);
		current_score.x = FlxMath.lerp(current_score.x, 128 * 2, .02);
		retry_button.y = current_score.y + current_score.height;
		retry_button.x = current_score.x;

		hi_score.y = FlxMath.lerp(hi_score.y, 128 * 3, .02);
		hi_score.x = FlxMath.lerp(hi_score.x, 128 * 6, .02);
		next_button.y = retry_button.y;
		next_button.x = hi_score.x + 32;

		done_banner.y = current_level.y;
		done_banner.x = hi_score.x;

		return Math.abs(delta - current_level.y);
	}
}
