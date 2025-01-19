extends UiState


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)


func _on_return_button_pressed() -> void:
	change_scene_to_file("res://source/menu_state.tscn")
