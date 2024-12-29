package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.sound.FlxSound;

class AudioController extends FlxBasic
{
	private var cursor_click:FlxSound;
	private var actions:Array<FlxSound>;
	private var row:FlxSound;
	private var col:FlxSound;
	private var points:FlxSound;
	private var lost:FlxSound;
	private var combo_1:FlxSound;
	private var combo_2:FlxSound;
	private var combo_3:FlxSound;
	private var combo_4:FlxSound;

	private var menu_open:FlxSound;
	private var menu_close:FlxSound;
	private var reset:FlxSound;

	private var playing_level:FlxSound;
	private var loading_level:FlxSound;
	private var level_step:Int;

	public function new(gs:GameState) {
		super();
		playing_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic1.mp3");
		loading_level = null;
		refresh(gs);
	}
	public function refresh(gs:GameState) {
		cursor_click = FlxG.sound.load("assets/Audio/cursor-click.wav");
		row = FlxG.sound.load("assets/Audio/rotate_row.mp3");
		col = FlxG.sound.load("assets/Audio/rotate_col.mp3");
		points = FlxG.sound.load("assets/Audio/basic_score.wav");
		lost = FlxG.sound.load("assets/Audio/level_lost.wav");
		combo_1 = FlxG.sound.load("assets/Audio/combo_score_1.wav");
		combo_2 = FlxG.sound.load("assets/Audio/combo_score_2.wav");
		combo_3 = FlxG.sound.load("assets/Audio/combo_score_3.wav");
		combo_4 = FlxG.sound.load("assets/Audio/combo_score_4.wav");
		menu_open = FlxG.sound.load("assets/Audio/menu_open.wav");
		menu_close = FlxG.sound.load("assets/Audio/menu_close.wav");
		reset = FlxG.sound.load("assets/Audio/reset.wav");
		actions = [row, col, points, combo_1, combo_2, combo_3, combo_4, menu_open, menu_close];
		
		start_level(gs);
	}

	public function click(){
		for (snd in actions) if(snd.playing) return;
		cursor_click.play(true);
	}

	public function reset_stats(){
		if(cursor_click.playing)
			cursor_click.stop();
		reset.play(true);
	}

	public function row_shift(){
		if(cursor_click.playing)
			cursor_click.stop();
		row.play(true);
	}

	public function level_lost(){
		if(cursor_click.playing)
			cursor_click.stop();
		lost.play(true);
	}

	public function menu(open:Bool){
		if(cursor_click.playing)
			cursor_click.stop();
		if(open)
			menu_open.play(true);
		else
			menu_close.play(true);
	}

	public function col_shift(){
		if(cursor_click.playing)
			cursor_click.stop();
		col.play(true);
	}

	public function score(combo_count){
		if(row.playing)
			row.stop();
		if(col.playing)
			col.stop();
		if(combo_count == 1)
			points.play(true);
		if(combo_count == 2)
			combo_1.play(true);
		if(combo_count == 3)
			combo_2.play(true);
		if(combo_count == 4)
			combo_3.play(true);
		if(combo_count == 5)
			combo_4.play(true);
		if(combo_count >= 6)
		{
			points.play(true);
			combo_1.play(true);
			combo_2.play(true);
		}
	}

	public function start_level(gs:GameState) {
		var bg_time = playing_level.time;
		if(Std.isOfType(gs, PlayState)) {
			var LevelStep = Std.int(Reg.Levels / 5);
			if(LevelStep == 0)
				loading_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic1.mp3");
			if(LevelStep == 1)
				loading_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic2.mp3");
			if(LevelStep == 2)
				loading_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic3.mp3");
			if(LevelStep == 3)
				loading_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic4.mp3");
			if(LevelStep == 4)
				loading_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic5.mp3");
			if(LevelStep == 5)
				loading_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic6.mp3");
			if(LevelStep == 6)
				loading_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic7.mp3");
			if(LevelStep == 7)
				loading_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic8.mp3");
			if(LevelStep == 8)
				loading_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic9.mp3");
			if(LevelStep >= 9)
				loading_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic10.mp3");
			if(level_step != LevelStep)
				bg_time = 0;
			level_step = LevelStep;
			playing_level = loading_level;
		}
		else
		{
			playing_level = FlxG.sound.load("assets/Audio/Background/UpbeatMelodic1.mp3");
		}
		playing_level.looped = true;
		playing_level.volume = .125;
		playing_level.play(bg_time);
	}
}
