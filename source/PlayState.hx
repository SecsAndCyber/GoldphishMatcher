package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PlayState extends GameState
{
	public var board:Board;
	private var done:Int;
	private var return_button:FlxButton;
	
	private var current_level:FlxText;
	private var current_score:FlxText;
	private var hi_score:FlxText;
	
	override public function create():Void
	{
		super.create();

		// Keep a reference to this state in Reg for global access.
		Reg.PS = this;

		FlxG.mouse.visible = !Reg.hideMouse;
		
		var background:FlxSprite;
		background = new FlxSprite(0, 0);
		background.loadGraphic("assets/GameBackground-1.png");
		add(background);
		Reg.Score = 0;

		var rows:Int = 4 + Std.int(Reg.Levels / 5);
		var columns:Int = 4 + Std.int(Reg.Levels / 5);
		
		return_button = new FlxButton(0,0,"", onClickReturn);
		return_button.loadGraphic("assets/UI/Return_Button.png");
		return_button.scale.x = Reg.UI_Scale;
		return_button.scale.y = Reg.UI_Scale;
		return_button.updateHitbox();
		return_button.x = (FlxG.width) / 2 -(return_button.width / 2);
		return_button.y = FlxG.height - return_button.height * 1.2;
		add(return_button);
		
		current_level = new FlxText(0,20 * Reg.UI_Scale, 0, "Level\n1", 48 * Reg.UI_Scale);
		current_level.alignment = CENTER;
		current_level.x = 5 * Reg.UI_Scale;
		current_level.y = return_button.y - return_button.height - current_level.height / 2;
		add(current_level);
		
		
		current_score = new FlxText(0,20 * Reg.UI_Scale, 0, "Score\n0", 48 * Reg.UI_Scale);
		current_score.alignment = CENTER;
		current_score.x = current_level.x + current_level.width + (current_score.width / 4);
		current_score.y = return_button.y - return_button.height - current_score.height / 2;
		add(current_score);
		
		
		hi_score = new FlxText(0,20 * Reg.UI_Scale, 0, "Hi Score\n0", 48 * Reg.UI_Scale);
		hi_score.alignment = CENTER;
		hi_score.x = current_score.x + current_score.width + (hi_score.width / 4);
		hi_score.y = return_button.y - return_button.height - hi_score.height / 2;
		add(hi_score);

		board = new Board(rows,columns, new FlxPoint(128,128), 128*rows,128*columns);
		add(board);

		done = 0;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		current_level.text = "Level\n" + Reg.Levels;
		current_score.text = "Score\n" + Reg.Score;
		if(Reg.HiScore.exists(Reg.Levels))
			hi_score.text = "Hi Score\n" + Reg.HiScore[Reg.Levels];
	}

	private function onClickReturn():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, () -> {FlxG.switchState(new MenuState());});
	}
}
