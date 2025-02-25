extends UiState

var reset_ready:bool;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if Reg.Levels == GameBoardLayout.LEVEL_CONST_TUTORIAL:
		$MapButton.visible = false
	Reg.Replay = false
	reset_ready = false
	
	if OS.has_feature("web"):
		$ExitButton.visible = false
	if OS.has_feature("ios"):
		$ExitButton.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if Input.is_action_just_pressed("ui_cancel"):
		_on_exit_button_pressed()


func _on_play_button_pressed() -> void:
	if Reg.HiScore.get(0):
		change_scene_to_file("res://source/play_state.tscn")
	else:
		change_scene_to_file("res://source/tutorial_state.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_reset_button_pressed() -> void:
	if reset_ready:
		Reg.telemetryNode.reset_game()
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


func _on_map_button_pressed() -> void:
	change_scene_to_file("res://source/level_map_state.tscn")


func _on_texture_button_pressed() -> void:
	Reg.Levels = 1 + Reg.CurrentChallenge*1000
	Reg.saveScore()
	change_scene_to_file("res://source/play_state.tscn")
