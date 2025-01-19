extends UiState

@onready var game_id: LineEdit = $ClientIDContainer/GameId
@onready var music_mute: CheckButton = $MusicContainer/MusicMute
@onready var sfx_mute: CheckButton = $SfxContainer/SfxMute

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	call_deferred("do_setup")
	
func do_setup():
	# Do initialization here
	game_id.text = Reg.GameId
	music_mute.button_pressed = Reg.MusicMute
	sfx_mute.button_pressed = Reg.SfxMute
	if Reg.SfxMute:
		$SfxContainer/SfxSettingsLabel.text = "SFX🔇"
	else:
		$SfxContainer/SfxSettingsLabel.text = "SFX🔊"

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


func _on_music_mute_toggled(toggled_on: bool) -> void:
	Reg.MusicMute = toggled_on
	Reg.saveScore()


func _on_sfx_mute_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$SfxContainer/SfxSettingsLabel.text = "SFX🔇"
	else:
		$SfxContainer/SfxSettingsLabel.text = "SFX🔊"
	Reg.SfxMute = toggled_on
	Reg.saveScore()
