extends GameState
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	call_deferred("do_setup")
	
func do_setup():
	# Do initialization here
	Reg.loadScore()
	Reg.HiScoreSet = false
	$CurrentLevel.text = "Level\n" + str(Reg.Levels);
	$CurrentScore.text = "Score\n" + str(Reg.Score);
	if Reg.Done && Reg.Levels > 30:
		run_score.text = "Free Score\n"
	else:
		run_score.text = "Run Score\n"
	run_score.text += str(Reg.RunningScore + Reg.Score);
	best_run_score.text = "Best Run Score\n" + str(Reg.HiScore[0]);
		
	if Reg.Levels in Reg.HiScore:
		$HiScore.text = "Hi Score\n" + str(Reg.HiScore[Reg.Levels]);
	Reg.PS = self
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Reg.PS == self:
		Reg.Levels = 1
		Reg.RunningScore = 0
		Reg.Score = 0
		Reg.saveScore()
		Reg.PS = null


func _on_menu_button_pressed() -> void:
	Reg.Levels = 1
	Reg.RunningScore = 0
	Reg.Score = 0
	Reg.saveScore()
	change_scene_to_file("res://source/menu_state.tscn")


func _on_play_button_pressed() -> void:
	Reg.Levels = 1
	Reg.RunningScore = 0
	Reg.Score = 0
	Reg.saveScore()
	change_scene_to_file("res://source/play_state.tscn")
