class_name LevelMapState extends GameState

@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var level_islands: Control = $LevelIslands
@onready var LevelIslandFactory = preload("res://source/level_island.tscn")


@export_range(.001, 1000, .01) var scroll_speed: float = 20.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	call_deferred("do_lms_setup")

func do_lms_setup() -> void:
	camera_2d.limit_top = 0
	camera_2d.limit_bottom = 720*3
	
	var x_steps = [480/6, 480/3, 480/2, 2*480/3, 480/2, 480/3]
	for level_id in range(1,31):
		var level_button = LevelIslandFactory.instantiate()
		level_button.level_id = level_id
		level_button.name = "LevelIsland_%d" % level_id
		level_button.pressed.connect(_on_LevelIsland.bind(level_button))
		level_islands.add_child(level_button)
		level_button.position = Vector2(
			x_steps[level_id % len(x_steps)],
			level_id * 70
		)

func _on_LevelIsland(level_button):
	Reg.Levels = level_button.level_id
	Reg.saveScore();
	change_scene_to_file("res://source/play_state.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_text_scroll_up"):
		camera_2d.move_local_y(scroll_speed)
	elif Input.is_action_just_pressed("ui_text_scroll_down"):
		camera_2d.move_local_y(-1.0 * scroll_speed)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pass
	else:
		pass
