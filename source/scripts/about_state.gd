extends UiState

@onready var title: Label = $Title
@onready var hi_score: Label = $HiScore
@onready var return_button: TextureButton = $ReturnButton
@onready var wipe_button: TextureButton = $WipeButton
var reset_ready:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	draw_scores()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

func draw_scores():
	pass


func _on_return_button_pressed() -> void:
	change_scene_to_file("res://source/menu_state.tscn")


func _on_wipe_button_pressed() -> void:
	if reset_ready:
		Reg.telemetryNode.reset_scores()
		Reg.Sounds.reset_stats()
		Reg.clearSave()
		Reg.loadScore()
		wipe_button.visible = false
		draw_scores()
		wipe_button.visible = false
	else:
		reset_ready = true
		wipe_button.texture_normal.atlas = load("res://assets/UI/Reset_Button2_Frames.png")
		wipe_button.texture_hover.atlas = load("res://assets/UI/Reset_Button2_Frames.png")


func _on_options_button_pressed() -> void:
	change_scene_to_file("res://source/options_state.tscn")


func _on_reddit_button_pressed() -> void:
	OS.shell_open("https://www.reddit.com/r/goldphish_match/")
