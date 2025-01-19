extends UiState

@onready var game_id: LineEdit = $ClientIDContainer/GameId

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	call_deferred("do_setup")
	
func do_setup():
	# Do initialization here
	game_id.text = Reg.GameId

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)


func _on_return_button_pressed() -> void:
	change_scene_to_file("res://source/menu_state.tscn")


func _on_game_id_text_changed(new_text) -> void:
	if new_text:
		Reg.GameId = new_text
		Reg.saveScore()


func _on_game_id_focus_entered() -> void:
	game_id.text = ""


func _on_game_id_focus_exited() -> void:
	game_id.text = Reg.GameId
