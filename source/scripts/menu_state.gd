extends UiState

var reset_ready:bool;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	reset_ready = false
	
	if OS.has_feature("web"):
		$ExitButton.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	$CurrentLevel.text = "Level\n" + str(Reg.Levels)
	if Reg.Done:
		$RunScore.text = "Free Score\n" + str(Reg.RunningScore)
	else:
		$RunScore.text = "Run Score\n" + str(Reg.RunningScore)


func _on_play_button_pressed() -> void:
	change_scene_to_file("res://source/play_state.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_reset_button_pressed() -> void:
	if reset_ready:
		Reg.RunningScore = 0;
		Reg.Levels = 1;
		Reg.saveScore();
		Reg.Sounds.reset_stats();
		$ResetButton.visible = false;
	else:
		reset_ready = true
		$ResetButton.texture_normal.atlas = load("res://assets/UI/Reset_Button2_Frames.png")
		$ResetButton.texture_hover.atlas = load("res://assets/UI/Reset_Button2_Frames.png")


func _on_about_button_pressed() -> void:
	change_scene_to_file("res://source/about_state.tscn")
