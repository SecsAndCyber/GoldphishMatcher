extends Control # GameState
class_name FailState

@onready var return_button: TextureButton = $ReturnButton
@onready var play_button: TextureButton = $PlayButton
@onready var background: TextureRect = $background
@onready var foreground: TextureRect = $foreground
@onready var current_level: Label = $CurrentLevel
@onready var run_score: Label = $RunScore
@onready var current_score: Label = $CurrentScore
@onready var hi_score: Label = $HiScore
@onready var done_banner: Label = $DoneBanner
@onready var best_run_score: Label = $BestRunScore
@onready var star_feed_back: Control = $StarFeedBack

var display_score:int = Reg.Score
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# super._ready()
	call_deferred("do_failed_setup")
	
func do_failed_setup():
	# Do initialization here
	Reg.HiScoreSet = false
	$CurrentLevel.text = "Level\n" + str(Reg.Levels);
	$CurrentScore.text = "Score\n" + str(display_score);
	if Reg.Done && Reg.Levels > 30:
		run_score.text = "Free Score\n"
	else:
		run_score.text = "Run Score\n"
	run_score.text += str(Reg.RunningScore + Reg.Score);
	best_run_score.text = "Best Run Score\n" + str(Reg.HiScore[0]);
		
	if Reg.Levels in Reg.HiScore:
		$HiScore.text = "Hi Score\n" + str(Reg.HiScore[Reg.Levels]);

	star_feed_back.global_position = Vector2(242, 625)
	star_feed_back.scale  = Vector2(0.286, 0.286)
	star_feed_back.display(Reg.LevelStars.get(Reg.Levels, 0))
	
	var rs = Reg.RunningScore
	Reg.Levels = 1
	Reg.RunningScore = 0
	Reg.Score = 0
	Reg.saveScore()
	Reg.RunningScore = rs
	Reg.PS = null
	replay_state._on_check_button_toggled(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_menu_button_pressed() -> void:
	Reg.Levels = 1
	Reg.RunningScore = 0
	Reg.Score = 0
	Reg.saveScore()
	Reg.Replay = false
	replay_state.change_scene_to_file("res://source/menu_state.tscn")

@onready var replay_state: ReplayState = $"../ReplayState/Container"

func _on_play_button_pressed() -> void:
	Reg.Levels = 1
	Reg.RunningScore = 0
	Reg.Score = 0
	Reg.saveScore()
	Reg.Replay = false
	replay_state.change_scene_to_file("res://source/play_state.tscn")
