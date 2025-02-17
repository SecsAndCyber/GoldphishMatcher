extends Control # GameState
class_name RewatchState

@onready var return_button: TextureButton = $ReturnButton
@onready var play_button: TextureButton = $PlayButton
@onready var background: TextureRect = $background
@onready var foreground: TextureRect = $foreground
@onready var current_level: Label = $CurrentLevel
@onready var current_score: Label = $CurrentScore
@onready var hi_score: Label = $HiScore
@onready var done_banner: Label = $DoneBanner
@onready var star_feed_back: Control = $StarFeedBack

var display_score:int = Reg.Score
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# super._ready()
	Reg.Levels = Reg.LastLevel
	Reg.LastMoves = Reg.HiScoreMoves.get(Reg.LastLevel,[])
	display_score = Reg.HiScore.get(Reg.LastLevel,0)
	call_deferred("do_rewatch_setup")
	
func do_rewatch_setup():
	# Do initialization here
	Reg.HiScoreSet = false
	$CurrentLevel.text = "Level\n" + str(Reg.Levels);
	$CurrentScore.text = "Score\n" + str(display_score);
		
	if Reg.Levels in Reg.HiScore:
		$HiScore.text = "Hi Score\n" + str(Reg.HiScore[Reg.Levels]);

	star_feed_back.global_position = Vector2(242, 625)
	star_feed_back.scale  = Vector2(0.286, 0.286)
	star_feed_back.display(Reg.LevelStars.get(Reg.Levels, 0))
	
	Reg.Score = 0
	Reg.saveScore()
	Reg.PS = null
	get_tree().create_timer(1).timeout.connect(func():
		replay_state._on_check_button_toggled(true)
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_menu_button_pressed() -> void:
	Reg.RunningScore = 0
	Reg.Score = 0
	Reg.saveScore()
	Reg.Replay = false
	replay_state.change_scene_to_file("res://source/menu_state.tscn")

@onready var replay_state: ReplayState = $"../ReplayState/Container"

func _on_play_button_pressed() -> void:
	Reg.RunningScore = 0
	Reg.Score = 0
	Reg.saveScore()
	Reg.Replay = false
	replay_state.change_scene_to_file("res://source/play_state.tscn")
