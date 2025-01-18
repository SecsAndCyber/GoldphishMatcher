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
	if !Reg.HiScore[0] and Reg.RunningScore:
		title.text = "Best (Current) Run\n" + str(Reg.RunningScore)
	else:
		title.text = "Best Run\n" + str(Reg.HiScore[0])
	hi_score.text = "";
	for k in range(16):
		if k > 0:
			hi_score.text += "%2s :" % str(k);
			print(Reg.HiScore)
			if k in Reg.HiScore and Reg.HiScore[k] > 0:
				hi_score.text += "%5s" % str(Reg.HiScore[k])
			else:
				hi_score.text += "%5s" % str("----")
			if k+15 in Reg.HiScore:
				hi_score.text += " |";
				hi_score.text += "%3s :" % str(k+15)
				hi_score.text += "%5s" % str(Reg.HiScore[k+15])
			hi_score.text += "\n";
	print(hi_score.text)


func _on_return_button_pressed() -> void:
	change_scene_to_file("res://source/menu_state.tscn")


func _on_wipe_button_pressed() -> void:
	if reset_ready:
		Reg.clearSave()
		Reg.loadScore()
		Reg.Sounds.reset_stats()
		wipe_button.visible = false
		draw_scores()
		wipe_button.visible = false;
	else:
		reset_ready = true
		wipe_button.texture_normal.atlas = load("res://assets/UI/Reset_Button2_Frames.png")
		wipe_button.texture_hover.atlas = load("res://assets/UI/Reset_Button2_Frames.png")
