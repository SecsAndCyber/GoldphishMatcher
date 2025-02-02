extends GameState
class_name PlayState

@onready var board: Board = $Board
@onready var return_button: TextureButton = $ReturnButton
@onready var retry_button: TextureButton = $RetryButton
@onready var next_button: TextureButton = $NextButton
@onready var background: TextureRect = $background
@onready var foreground: TextureRect = $foreground
@onready var current_level: Label = $CurrentLevel
@onready var run_score: Label = $RunScore
@onready var current_score: Label = $CurrentScore
@onready var hi_score: Label = $HiScore
@onready var done_banner: Label = $DoneBanner
@onready var star_feed_back: Control = $StarFeedBack
var final_state: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	call_deferred("do_setup")
	
func do_setup():
	# Do initialization here
	if !Reg.Replay:
		Reg.RunningScore += Reg.Score
		Reg.saveScore()
	Reg.PS = self
	Reg.Score = 0
	Reg.HiScoreSet = false
	Reg.Loss = false
	final_state = false
	
	@warning_ignore("integer_division")
	var rows:int = 4 + int(Reg.Levels / 5)
	@warning_ignore("integer_division")
	var columns:int = 4 + int(Reg.Levels / 5)
	board.size = Vector2(rows, columns)
	board.create(rows, columns)
	
	retry_button.visible = false
	next_button.visible = false
	
	if Reg.Levels >= 30:
		$NextButton.texture_normal.atlas = load("res://assets/UI/FreePlay_Button_Frames.png")
		$NextButton.texture_hover.atlas = load("res://assets/UI/FreePlay_Button_Frames.png")

func popup(level_stats:Dictionary = {}):
	star_feed_back.begin(level_stats)
	if !Reg.Replay:
		return_button.visible = false
		retry_button.visible = false
		next_button.visible = false
		if Reg.Levels >= 30:
			Reg.Done = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$CurrentLevel.text = "Level\n" + str(Reg.Levels)
	$CurrentScore.text = "Score\n" + str(Reg.Score)
	if Reg.Done && Reg.Levels > 30:
		run_score.text = "Free Score\n"
	else:
		run_score.text = "Run Score\n"
	run_score.text += str(Reg.RunningScore + Reg.Score)
	if Reg.Replay: return
	if Reg.Levels in Reg.HiScore:
		$HiScore.text = "Hi Score\n" + str(Reg.HiScore[Reg.Levels])
	
	if Reg.Loss:
		if return_button.visible:
			# Code here will run just once after the Loss flag is set
			pass
		return_button.visible = false
		retry_button.visible = false
		next_button.visible = false
		background.texture = BG_TEXTURE_LOSS
		foreground.texture = FG_TEXTURE_LOSS
		return
	if !return_button.visible and !final_state:
		if (.5 > animate_popup()):
			final_state = true
			if (Reg.HiScoreSet):
				Reg.Sounds.level_won();
				background.texture = BG_TEXTURE_HISCORE
				foreground.texture = FG_TEXTURE_HISCORE
			else:
				background.texture = load("res://assets/backgrounds/background-2.png")
				foreground.texture = load("res://assets/backgrounds/foreground-2.png")
	if final_state and star_feed_back.complete:
		retry_button.visible = true
		next_button.visible = true
		return_button.visible = true

func animate_popup() -> float:
	var delta = current_level.global_position.y
	current_level.global_position.x = lerp(current_level.global_position.x, 40.0, .02);
	current_level.global_position.y = lerp(current_level.global_position.y, 54.0, .02);

	run_score.global_position.x = lerp(run_score.global_position.x, 185.0, .02);
	run_score.global_position.y = lerp(run_score.global_position.y, 54.0, .02);

	current_score.global_position.x = lerp(current_score.global_position.x, 40.0, .02);
	current_score.global_position.y = lerp(current_score.global_position.y,150.0, .02);
	
	retry_button.global_position.x = current_score.global_position.x + 40;
	retry_button.global_position.y = current_score.global_position.y + 90;

	hi_score.global_position.x = lerp(hi_score.global_position.x, 185.0, .02);
	hi_score.global_position.y = lerp(hi_score.global_position.y, 150.0, .02);
	
	next_button.global_position.x = hi_score.global_position.x + 40;
	next_button.global_position.y = retry_button.global_position.y;

	if Reg.Done:
		done_banner.visible = true
		done_banner.global_position.x = 115.0;
		done_banner.global_position.y = 310.0;

	return abs(delta - current_level.global_position.y)

func _on_menu_button_pressed() -> void:
	if retry_button.visible:
		Reg.RunningScore += Reg.Score
		Reg.Levels += 1;
	Reg.Score = 0;
	Reg.saveScore();
	change_scene_to_file("res://source/menu_state.tscn")


func _on_retry_button_pressed() -> void:
	Reg.RunningScore = 0;
	Reg.Score = 0;
	Reg.saveScore();
	reload_current_scene()


func _on_next_button_pressed() -> void:
	Reg.Levels += 1;
	Reg.saveScore();
	reload_current_scene()
