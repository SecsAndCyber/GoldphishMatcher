extends Control
class_name GameState

var BG_TEXTURE_NORMAL = preload("res://assets/backgrounds/background-1.png")
var FG_TEXTURE_NORMAL = preload("res://assets/backgrounds/foreground-1.png")
var BG_TEXTURE_LOSS = preload("res://assets/backgrounds/background-4.png")
var FG_TEXTURE_LOSS = preload("res://assets/backgrounds/foreground-4.png")
var BG_TEXTURE_HISCORE = preload("res://assets/backgrounds/background-3.png")
var FG_TEXTURE_HISCORE = preload("res://assets/backgrounds/foreground-3.png")

var args: Dictionary

func args_dict(cmdline_args: Array) -> Dictionary:
	var args: Dictionary = {}
	# Remove current scene from the list of command line arguments
	cmdline_args = cmdline_args.slice(1)
	for arg in cmdline_args:
		print(arg)
		var key_value: Array = arg.split("=")
		if len(key_value) == 2:
			args[key_value[0]] = key_value[1]
	return args

func moves_from_cmd_string(moves: String) -> Array:
	var moves_array: Array = []
	moves = moves.lstrip('[').rstrip(']')
	for move in moves.split(","):
		moves_array.append(move.strip_edges().lstrip('"').rstrip('"'))
	return moves_array

func parse_command_line_args():
	var cmdline_args: Array = OS.get_cmdline_args()
	var moves_str: String = ""
	if len(cmdline_args) == 0:
		return
	var current_scene: String = cmdline_args[0]
	if current_scene.begins_with("res://"):
		return
	args = args_dict(cmdline_args)
	if not current_scene.ends_with("replay_state.tscn"):
		get_tree().quit()

	if not '--level' in args:
		print("No level flag specified")
		get_tree().quit()

	if not '--bmoves' in args:
		print("No bmoves flag specified")
		if not '--moves' in args:
			print("No moves flag specified")
			get_tree().quit()
	else:
		print(args['--bmoves'])
		moves_str = Marshalls.base64_to_utf8(args['--bmoves']+'=')
		print(moves_str)
		if not moves_str:
			print("Invalid base64 moves string")
			get_tree().quit()

	if not '--score' in args:
		print("No score flag specified")
		get_tree().quit()

	if not moves_str:
		moves_str = args['--moves']
	Reg.LastLevel = int(args['--level'])
	Reg.LastMoves = moves_from_cmd_string(moves_str)
	Reg.LastScore = int(args['--score'])
	Reg.Levels = Reg.LastLevel
	Reg.saveScore()
	# get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Reg.loadScore()
	parse_command_line_args()
	if !Reg.HiScore.get(0):
		Reg.Levels = GameBoardLayout.LEVEL_CONST_TUTORIAL
		Reg.saveScore()
	@warning_ignore("integer_division")
	if Reg.Levels / 1000:
		if not Reg.Levels == GameBoardLayout.LEVEL_CONST_TUTORIAL:
			@warning_ignore("integer_division")
			if not (Reg.Levels/1000) == Reg.CurrentChallenge:
				Reg.Levels = 1 + Reg.CurrentChallenge*1000
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
		# print("Left mouse button clicked at:", event.position)
		# Add your custom logic here
		Reg.Sounds.click()
