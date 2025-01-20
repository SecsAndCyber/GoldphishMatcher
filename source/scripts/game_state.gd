extends Control
class_name GameState

@onready var reg:Reg = Reg.instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Reg.loadScore()
	call_deferred("do_gamestate_setup")
	
func change_scene_to_file(filename):
	remove_child(Reg.Sounds)
	remove_child(Reg.telemetryNode)
	get_tree().change_scene_to_file(filename)
	
func reload_current_scene():
	remove_child(Reg.Sounds)
	remove_child(Reg.telemetryNode)
	get_tree().reload_current_scene()
	
func do_gamestate_setup():
	# Do initialization here
	add_child(Reg.Sounds)
	add_child(Reg.telemetryNode)
	Reg.Sounds.start_level()
	Reg.telemetryNode.start_level(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Handle left mouse button click
		print("Left mouse button clicked at:", event.position)
		# Add your custom logic here
		reg.Sounds.click()
