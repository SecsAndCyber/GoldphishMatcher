extends Label
class_name CurrentLevel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameBoardLayout.LEVEL_CONST_TUTORIAL == Reg.Levels:
		text = "First play\nTUTORIAL"
	elif Reg.Levels / 1000:
		text = "Challenge\n" + str(Reg.Levels % 1000)
	else:
		text = "Level\n" + str(Reg.Levels)
